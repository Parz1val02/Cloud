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

function helpPanel() {
	echo -e "\n${greenColour}Este script realiza la configuración de una interfaz de red${endColour}"
	echo -e "\n${redColour}[!] Uso: $0${endColour}\n"
	for _ in $(seq 1 80); do echo -ne "${turquoiseColour}-"; done
	echo -ne "${endColour}"
	echo -e "\n\n${grayColour}[-i]${endColour}${yellowColour}: Listar información de interfaces${endColour}\n"
	echo -e "${grayColour}[-c]${endColour}${yellowColour}: Configurar una interfaz${endColour}${blueColour} (Ejemplo: -c ens3)${endColour}\n"
	echo -e "${grayColour}[-h]${endColour}${yellowColour}: Invocar este panel de ayuda${endColour}\n"
	tput cnorm
}

#Ejecucion principal del programa
tput civis
while getopts "i,h,c:" arg; do
	case ${arg} in
	i)
		ip -br addr
		tput cnorm
		exit 0
		;;
	c)
		interfaz_output=$OPTARG
		echo "${interfaz_output}"
		tput cnorm
		exit 0
		;;
	h)
		helpPanel
		exit 0
		;;
	?)
		helpPanel
		exit 1
		;;
	esac
done
helpPanel
exit 0
