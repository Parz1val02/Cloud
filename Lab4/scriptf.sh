#!/bin/bash

# Parámetros
vlan_id=$1

# Interfaz de la red Management/Internet
internet_interface="eth0" # Cambia a la interfaz correcta si es diferente en tu configuración

# Habilitar el forwarding de IPv4 en el kernel
echo "1" > /proc/sys/net/ipv4/ip_forward

# Configurar reglas de iptables para el enrutamiento hacia Internet desde la VLAN
iptables -t nat -A POSTROUTING -s 10.0.$vlan_id.0/24 -o $internet_interface -j MASQUERADE

# Permitir el tráfico de reenvío desde la VLAN hacia Internet
iptables -A FORWARD -i ovs1-vlan$vlan_id -o $internet_interface -j ACCEPT
iptables -A FORWARD -i $internet_interface -o ovs1-vlan$vlan_id -m state --state RELATED,ESTABLISHED -j ACCEPT

echo "Configuración completada para otorgar acceso a Internet a la VLAN $vlan_id."

