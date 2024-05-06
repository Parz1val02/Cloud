#!/bin/bash
nombre_VM=$1
nombre_OVS=$2
vlan_ID=$3
puerto_VNC=$4
generate_random_mac() {
	printf '%02x:%02x:%02x:%02x:%02x:%02x\n' \
		$((RANDOM % 256)) $((RANDOM % 256)) $((RANDOM % 256)) \
		$((RANDOM % 256)) $((RANDOM % 256)) $((RANDOM % 256))
}
if [ $# -ne 4 ]; then
	echo "Uso: $0 <nombre_VM> <nombre_OVS> <vlan_id> <puerto_vnc>"
	exit 1
fi
wget -c https://download.cirros-cloud.net/0.6.2/cirros-0.6.2-x86_64-disk.img
ip tuntap add mode tap name ovs-tap-"${nombre_VM}"
random_mac=$(generate_random_mac)
qemu-system-x86_64 \
	-enable-kvm \
	-vnc 0.0.0.0:"${puerto_VNC}" -netdev tap,id=ovs-tap-"${nombre_VM}",ifname=ovs-tap-"${nombre_VM}",script=no,downscript=no \
	-device e1000,netdev=ovs-tap-"${nombre_VM}",mac="${random_mac}" \
	-daemonize \
	-snapshot \
	cirros-0.6.2-x86_64-disk.img
ovs-vsctl add-port "$nombre_OVS" ovs-tap-"${nombre_VM}" tag="$vlan_ID"
ip link set dev ovs-tap-"${nombre_VM}" up
