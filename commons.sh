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

# Debian isc-dhcpd-server default configuration
ISC_DEFAULTS=/etc/default/isc-dhcp-server

# NFS configuration file
NFS_TABLE=/etc/exports

# DHCP network interface file
NETWORK_CONF=/etc/network/interfaces.d/ltsp-tools.conf

# Used to check if a configuration file is touched by this script
FIRM=ltsp-tools

# Configuration directory without trailing slash
CONFIGS_DIR=./configs

# Configuration templates without trailing slash
TEMPLATES_DIR=./templates

# Force the re-creation of all options / configuration files
FORCE=false

# Skip certain long things
SKIP=false

while [ -n "$2" ]; do
	case "$2" in
		--help)
			rtfm $1
			;;
		--dry-run)
			SKIP=true
			;;
		--force)
			FORCE=true
			;;
		*)
			echo "Invalid '$2' option."
			echo
			rtfm $1
			exit 2
			;;
	esac
	shift
done

#
# Stupid way checking if you are running the script from its relative pathname
#
if [ ! -d "$TEMPLATES_DIR" ]; then
	echo "Missing templates directory?"
	exit 3
fi

#
# Will be asked to install packages and edit system configuration files
#
if [ "$(id -u)" != 0 ] && ! $SKIP; then
	echo "Please run as root.";
	exit 3
fi

#
# A sort of PHP isset()
#
require_vars() {
	while [ -n "$1" ]; do
		export $1
		if [ -z "$1" ]; then
			"Missing required option '$1' from $CONFIGS_DIR/config.conf"
			exit 3
		fi
		shift
	done
}

#
# Get variables from the configuration file, or assign to it a default value.
#
# Args:
# 1: option name
# 2: option default value
#
get_option() {
	if $FORCE || [ ! -f "$CONFIGS_DIR/$1.conf" ]; then
		echo "$2" > "$CONFIGS_DIR/$1.conf"
	fi
	cat "$CONFIGS_DIR/$1.conf"
}

#
# Usage
#
rtfm() {
	echo "$1 [--help] [--dry-run]"
	echo "  --help Show this help and exit"
	echo "	--dry-run Write only configuration files"
	echo "	--force Rewrite configuration files"
}

#
# Create a backup of a file, without overwriting other backups
#
numeric_backup() {
	cp --archive --force --backup=existing -- "$1" "$1"
}

# Create configuration directory if it doen't exists
mkdir -p "$CONFIGS_DIR"

# Create default global configuration file if it doesn't exists
if $FORCE || [ ! -f "$CONFIGS_DIR/config.conf" ]; then
	# Take default global configuration file from templates
	cat "$TEMPLATES_DIR/edit-and-save.txt"    > "$CONFIGS_DIR/config.conf"
	cat "$TEMPLATES_DIR/config-example.conf" >> "$CONFIGS_DIR/config.conf"

	# Edit global configuration file
	editor "$CONFIGS_DIR/config.conf"
fi

# Include the default global configuration file
. "$CONFIGS_DIR/config.conf"

#
# Check that these vars are set
#
require_vars \
	LAN_DHCP_INTERFACE \
	LAN_DHCP_SERVER_ADDR \
	LAN_DHCP_START \
	LAN_DHCP_END \
	LAN_DHCP_BROADCAST \
	LAN_DHCP_NETWORK \
	LAN_DHCP_NETMASK \
	WAN_DNS_SERVER0 \
	WAN_DNS_SERVER1

WAN_GATEWAY_ADDR=$(get_option WAN_GATEWAY_ADDR "$(ip route | awk '/default/ { print $3 }')")
WAN_GATEWAY_INTERFACE=$(get_option WAN_GATEWAY_INTERFACE "$(ip route | awk '/default/ { print $5 }')")

# To be avaiable by subshell
export WAN_GATEWAY_ADDR
export WAN_GATEWAY_INTERFACE
