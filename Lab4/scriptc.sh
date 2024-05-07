#!/bin/bash

nombre_OVS=$1
nombre_red=$2
vlan_id=$3
direccion_red=$4
rango_dhcp=$5

interfaz_interna_OVS() {
	ovs-vsctl add-port "$1" vlan"${2}" tag="${2}" -- set interface vlan"${2}" type=internal
}
siguiente_ip() {
	ip=$(echo "$1" | cut -d '/' -f 1)

	IFS=. read -r ip1 ip2 ip3 ip4 <<<"$ip"
	ip_int=$((ip1 * 256 ** 3 + ip2 * 256 ** 2 + ip3 * 256 + ip4))

	next_ip_int=$((ip_int + 1))

	next_ip=$((next_ip_int / 256 ** 3)).$(((next_ip_int / 256 ** 2) % 256)).$(((next_ip_int / 256) % 256)).$((next_ip_int % 256))

	echo $next_ip
}

if [ $# -ne 5 ]; then
	echo "Uso: $0 <nombre_OVS> <nombre_red> <vlan_id> <direccion_red> <rango_dhcp>"
	exit 1
fi
siguiente_direccion=$(siguiente_ip "$direccion_red")
subsiguiente_direccion=$(siguiente_ip "$siguiente_direccion")

interfaz_interna_OVS "$nombre_OVS" "$vlan_id"

ip netns add ns-dhcp-server-vlan"${vlan_id}"
ip link set vlan"${vlan_id}" netns ns-dhcp-server-vlan"${vlan_id}"
ip netns exec ns-dhcp-server-vlan"${vlan_id}" ip link set dev lo up
ip netns exec ns-dhcp-server-vlan"${vlan_id}" ip link set dev vlan"${vlan_id}" up
ip netns exec ns-dhcp-server-vlan"${vlan_id}" ip address add "$subsiguiente_direccion" dev vlan"${vlan_id}"
ip address add "$siguiente_direccion" dev "$nombre_OVS"
ip netns exec ns-dhcp-server-vlan"${vlan_id}" dnsmasq --interface=vlan"${vlan_id}" \
	--dhcp-range="${rango_dhcp}" \
	--dhcp-option=3,"$siguiente_direccion" \
	--dhcp-option=6,8.8.8.8,8.8.4.4
echo "Red interna del orquestador creada correctamente."
