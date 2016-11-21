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

LAN=$LAN_DHCP_INTERFACE
GATEWAY=$WAN_GATEWAY_INTERFACE

service networking        restart && \
service tftpd-hpa         restart && \
service isc-dhcp-server   restart && \
service nfs-kernel-server restart || {
	echo "Not all services are OK!"
	exit 1
}

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

echo "Probably ready."
