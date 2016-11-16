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

if [ -z $2 ]; then
	echo "Usage:"
	echo "	$0 LAN_DHCP_INTERFACE GATEWAY_INTERFACE"
	echo "Example:"
	echo "	$0 eth0 wlan0"
	exit 0
fi

LAN=$1
GATEWAY=$2

service tftpd-hpa         restart && \
service isc-dhcp-server   restart && \
service nfs-kernel-server restart || exit 1

iptables --flush
iptables --table nat    --flush
iptables --table mangle --flush
iptables -X

# Always accept loopback traffic
iptables -A INPUT -i lo -j ACCEPT

# Allow established connections, and those not coming from the outside
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -m state --state NEW ! -i $GATEWAY -j ACCEPT
iptables -A FORWARD -i $GATEWAY -o $LAN -m state --state ESTABLISHED,RELATED -j ACCEPT

# Allow outgoing connections from the LAN side
iptables -A FORWARD -i $LAN -o $GATEWAY -j ACCEPT

# Masquerade
iptables -t nat -A POSTROUTING -o $GATEWAY -j MASQUERADE

# Don't forward from the outside to the inside (WHY?)
# iptables -A FORWARD -i $LAN -o $LAN -j REJECT
iptables -A FORWARD -i $GATEWAY -o $LAN -j REJECT

# Enable routing.
echo 1 > /proc/sys/net/ipv4/ip_forward
