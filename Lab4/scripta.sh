#!/bin/bash
existe_OVS() {
	ovs-vsctl br-exists "$1"
	return $?
}
if ! existe_OVS "$?"; then
    echo "crearlo"
else
    echo "creado"
fi
