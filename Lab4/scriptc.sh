#!/bin/bash
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
siguiente_direccion=$(siguiente_ip "$4")
subsiguiente_direccion=$(siguiente_ip "$siguiente_direccion")

interfaz_interna_OVS "$1" "$3"

ip netns add ns-dhcp-server-vlan"${3}"
ip link set vlan"${3}" netns ns-dhcp-server-vlan"${3}"
ip netns exec ns-dhcp-server-vlan"${3}" ip link set dev lo up
ip netns exec ns-dhcp-server-vlan"${3}" ip link set dev vlan"${3}" up
ip netns exec ns-dhcp-server-vlan"${3}" ip address add "$subsiguiente_direccion" dev vlan"${3}"
ip address add "$siguiente_direccion" dev "$1"
ip netns exec ns-dhcp-server-vlan"${3}" dnsmasq --interface=vlan"${3}" \
	--dhcp-range="${5}" \
	--dhcp-option=3,"$siguiente_direccion" \
	--dhcp-option=6,8.8.8.8,8.8.4.4
echo "Red interna del orquestador creada correctamente."
