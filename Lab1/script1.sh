#!/bin/bash
#Colors
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

#Catch the sigkill signal when it is send to end with CTRL-C to kill the program
trap ctrl_c INT
function ctrl_c() {
	echo -e "\n${redColour}[!] Saliendo del programa...\n${endColour}"
	exit 1
}

function helpPanel() {
	echo -e "\n${greenColour}Este script realiza la configuración de una interfaz de red${endColour}\n"
	echo -e "${redColour}[!] Uso: $0${endColour}\n"
	for _ in $(seq 1 80); do echo -ne "${turquoiseColour}-"; done
	echo -ne "${endColour}"
	echo -e "\n\n${grayColour}[-i]${endColour}${yellowColour}: Listar información de interfaces${endColour}\n"
	echo -e "${grayColour}[-c]${endColour}${yellowColour}: Configurar una interfaz${endColour}${blueColour} (Ejemplo: -c ens3)${endColour}\n"
}

function config() {
	local iface=$1
	echo -e "\n${greenColour}La interfaz ${endColour}${blueColour}${iface}${endColour}${greenColour} cuenta con las siguientes ips: ${endColour}"
	ip address show dev "$iface" | grep -w inet | awk '{print $2}'
	echo -e "\n${greenColour}Limpiar interfaz? (y/n)> ${endColour}"
	read -p -r choice
	if [ "$choice" == "y" ]; then
		ip address flush dev "$iface"
		echo -e "\n${greenColour}La interfaz ${endColour}${blueColour}${iface}${endColour}${greenColour}se limpió correctamente ${endColour}"
	fi
	echo -e "\n${greenColour}Dirección IP a configurar (ip/mask)> ${endColour}"
	read -p -r ip
	ip address add "$ip" dev "$iface"
	if [ "$(ip address show dev "$iface" | grep state | cut -d" " -f 9)" == "DOWN" ]; then
		echo -e "\n${greenColour}La interfaz ${endColour}${blueColour}${iface}${endColour}${greenColour} se encuentra apagada ${endColour}"
		echo -e "\n${greenColour}Levantar interfaz? (y/n)> ${endColour}"
		read -p -r  choice
		if [ "$choice" == "y" ]; then
			ip link set dev "$iface" up
			echo -e "\n${greenColour}La interfaz ${endColour}${blueColour}${iface}${endColour}${greenColour}se levantó correctamente ${endColour}"
		fi
	fi
	echo -e "\n${purpleColour}Datos relevantes de la interfaz ${endColour}${blueColour}${iface} >${endColour}"
	ip address show dev "$iface"
}

#Ejecucion principal del programa
counter=0
while getopts "i,h,c:" arg; do
	case ${arg} in
	i)
		ip -br addr
		let counter+=1
		;;
	c)
		iface_input=$OPTARG
		config "${iface_input}"
		let counter+=1
		;;
	?)
		helpPanel
		exit 1
		;;
	esac
done
if [ "$counter" -eq 0 ]; then
	helpPanel
	exit 0
fi
