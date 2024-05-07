#!/bin/bash

# Parámetros
vlan_id_1=$1
vlan_id_2=$2

# Habilitar el forwarding de IPv4 en el kernel
echo "1" >/proc/sys/net/ipv4/ip_forward

# Permitir el tráfico de reenvío entre las dos redes VLAN
iptables -A FORWARD -i ovs1-vlan$vlan_id_1 -o ovs1-vlan$vlan_id_2 -j ACCEPT
iptables -A FORWARD -i ovs1-vlan$vlan_id_2 -o ovs1-vlan$vlan_id_1 -j ACCEPT

echo "Configuración completada para permitir la comunicación entre las VLAN $vlan_id_1 y $vlan_id_2."
