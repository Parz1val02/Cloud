#!/bin/bash
existe_ovs() {
	ovs-vsctl br-exists "$1"
	return $?
}
if [ "$#" -le 0 ]; then
	echo "Uso: $0 <nombre_OVS> <interfaz_1> <interfaz_2> ..."
	exit 1
fi
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
echo "Configuraciones completadas"
exit 0
