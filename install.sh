#!/bin/sh
#############################################################################
# LTSP tools
# Copyright (C) 2016 Valerio Bozzolan and contributors
#############################################################################
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#############################################################################

# Default isc-dhcpd-server configuration file
ISC_CONF=/etc/dhcp/dhcpd.conf

# Default isc-dhcpd-server configuration file provided by ltsp-server-standalone package
LTSP_ISC_DEFAULT=/etc/ltsp/dhcpd.conf

# isc-dhcpd-server configuration file with comments
ISC_COMMENTS=./isc-dhcpd-server.comments

# Debian isc-dhcpd-server default configuration
ISC_DEFAULTS=/etc/default/isc-dhcp-server

# NFS configuration file
NFS_TABLE=/etc/exports

# Dry-run if true
SKIP=FALSE

# Used to check if a configuration file is touched by this script
FIRM=ltsp-tools

#
# Stupid way checking if you are running the script from its relative pathname
#
if [ ! -f "$ISC_COMMENTS" ]; then
	echo "Please run in the same directory."
	exit 1
fi

while [ -n "$1" ]; do
	case "$1" in
		--dry-run)
			SKIP=true
			;;
		--help)
			echo "$0 [--help] [--dry-run]"
			echo "  --help Show this help and exit"
			echo "	--dry-run Write only configuration files"
			exit 0
			;;
	esac
	shift
done

$SKIP || if [[ $EUID -ne 0 ]]; then
	echo "Please root.";
	exit 1
fi

$SKIP || apt-get update

# dep: isc-dhcpd-server
$SKIP || apt-get install ltsp-server-standalone

# Will add security
$SKIP || ltsp-build-client

#
# Fill the default configuration file with common isc-dhcpd-server options
#
echo "Configuring $LTSP_ISC_DEFAULT..."
if ! grep --quiet "$FIRM" -- "$LTSP_ISC_DEFAULT"; then
	cp --archive --backup=numbered --force -- "$LTSP_ISC_DEFAULT" "$LTSP_ISC_DEFAULT"

	echo                              >> "$LTSP_ISC_DEFAULT"
	echo "# Added by $FIRM - $(date)" >> "$LTSP_ISC_DEFAULT"
	cat "$ISC_COMMENTS"               >> "$LTSP_ISC_DEFAULT"
fi

echo "Configuring $ISC_DEFAULTS..."
. "$ISC_DEFAULTS"
if [ -z $INTERFACES ]; then
	sleep 1
	echo -n "Now you have to set the DHCP interface (e.g: INTERFACES=\"eth0\")"
	for i in 4 3 2 1; do
		echo -n "$1."
		sleep 1
	done
	editor "$ISC_DEFAULTS"
fi

#
# Appending the default LTSP dhcp configuration to isc-dhcp-server
#
echo "Configuring $ISC_CONF..."
if ! grep --quiet "$FIRM" -- "$ISC_CONF"; then
	cp --archive --backup=numbered --force -- "$ISC_CONF" "$ISC_CONF"

	echo                                  >> "$ISC_CONF"
	echo "# Added by $FIRM - $(date)"     >> "$ISC_CONF"
	echo "include \"$LTSP_ISC_DEFAULT\";" >> "$ISC_CONF"
fi

#
# Adding LTSP stuff into the NFS table
#
echo "Configuring $NFS_TABLE..."
if ! grep --quiet "$FIRM" -- "$NFS_TABLE"; then
	cp --archive --backup=numbered --force -- "$NFS_TABLE" "$NFS_TABLE"

	echo                                                          >> "$NFS_TABLE"
	echo "# Added by $FIRM - $(date)"                             >> "$NFS_TABLE"
	echo "/opt/ltsp *(ro,no_root_squash,async,no_subtree_check)"  >> "$NFS_TABLE"
fi

sleep 1
echo
echo "Now:"
echo "	1. Please create a static LAN connection with same values as $LTSP_ISC_DEFAULT ($INTERFACES)..."
echo "	   Note: You can use Network Manager directly to create it!"
echo
echo "	2. Once created, remember to keep it active *before* running the 'start' script"
echo "	   Note: With Network Manager: 'nmcli connection up my-lan-connection-name'"
echo "	   Note: Have you something phisically connected to your existing specified interface before running the next command?"
echo
echo "	1. ...Or you can create a static one using /etc/network/interfaces and the default file in this folder."
echo "	2. ...That will be enabled when your interface is hotplugged."
echo
echo "	3. Run:"
echo "	   ./start.sh"
