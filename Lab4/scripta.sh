#!/bin/bash
existe_ovs() {
	ovs-vsctl br-exists "$1"
	return $?
}
if ! existe_ovs "$?"; then
	ovs-vsctl add-br "$1"
	echo "OVS $1 creado"
else
	echo "OVS $1 ya existe"
fi
for iface in "$@"; do
	if [ "$iface" == "$1" ]; then
		continue
	fi
	ovs-vsctl add-port "$1" "$iface"
done
echo 1 >/proc/sys/net/ipv4/ip_forward
iptables -P FORWARD DROP
echo "Configuraciones completadas"
