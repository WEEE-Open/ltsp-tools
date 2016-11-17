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

. ./commons.sh $0 $@ || {
	echo "Please execute in the same folder."
	exit 3
}

$SKIP || apt-get update

# dep: isc-dhcpd-server
# gettext gives envsubst
$SKIP || apt-get install ltsp-server-standalone gettext

# Will add also Debian security repository
$SKIP || ltsp-build-client

#
# Adding LTSP stuff into the NFS table
#
echo "Configuring $NFS_TABLE..."
if ! grep --quiet "$FIRM" -- "$NFS_TABLE"; then
	numeric_backup                                                   "$NFS_TABLE"
	echo                                                          >> "$NFS_TABLE"
	echo "# Added by $FIRM - $(date)"                             >> "$NFS_TABLE"
	echo "/opt/ltsp *(ro,no_root_squash,async,no_subtree_check)"  >> "$NFS_TABLE"
elif $FORCE; then
	editor "$NFS_TABLE"
fi

#
# Adding a static LAN connection
# (Overwritable file)
#
echo "Configuring $NETWORK_CONF..."
$FORCE && rm -- "$NETWORK_CONF"
if [ ! -f "$NETWORK_CONF" ]; then
	cat "$TEMPLATES_DIR/edit-and-save.txt"     > "$NETWORK_CONF"
	envsubst < "$TEMPLATES_DIR/interfaces.txt" > "$NETWORK_CONF"
	editor                                       "$NETWORK_CONF"
fi

#
# Appending network interface
# (Appendable file)
#
echo "Configuring $ISC_DEFAULTS..."
. "$ISC_DEFAULTS"
if $FORCE || [ -z $INTERFACES ]; then
	numeric_backup                             "$ISC_DEFAULTS"
	echo                                    >> "$ISC_DEFAULTS"
	cat  "$TEMPLATES_DIR/edit-and-save.txt" >> "$ISC_DEFAULTS"
	echo "INTERFACES='$LAN_DHCP_INTERFACE'" >> "$ISC_DEFAULTS"
	editor                                     "$ISC_DEFAULTS"
fi

#
# Including the default LTSP dhcp configuration from isc-dhcp-server
#
echo "Configuring $ISC_CONF..."
if ! grep --quiet "$FIRM" -- "$ISC_CONF"; then
	numeric_backup                             "$ISC_CONF"
	echo                                    >> "$ISC_CONF"
	cat  "$TEMPLATES_DIR/edit-and-save.txt" >> "$ISC_CONF"
	echo "Include \"$LTSP_ISC_DEFAULT\";"   >> "$ISC_CONF"
elif $FORCE; then
	editor "$ISC_CONF"
fi

#
# Sobstitute the default configuration file for isc-dhcpd-server.
# That file is provided by LTSP.
#
echo "Configuring $LTSP_ISC_DEFAULT..."
if $FORCE || ! grep --quiet "$FIRM" -- "$LTSP_ISC_DEFAULT"; then
	numeric_backup                                      "$LTSP_ISC_DEFAULT"
	cat "$TEMPLATES_DIR/edit-and-save.txt"           >  "$LTSP_ISC_DEFAULT"
	envsubst < "$TEMPLATES_DIR/isc-dhcpd-server.txt" >> "$LTSP_ISC_DEFAULT"
	editor                                              "$LTSP_ISC_DEFAULT"
fi

echo "Probably OK!"
echo "Now:"
echo "	./start.sh"
