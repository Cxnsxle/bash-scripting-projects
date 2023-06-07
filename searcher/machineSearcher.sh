#!/bin/bash

# Colors
greenColor="\e[0;32m\033[1m"
redColor="\e[0;31m\033[1m"
blueColor="\e[0;34m\033[1m"
yellowColor="\e[0;33m\033[1m"
purpleColor="\e[0;35m\033[1m"
turquoiseColor="\e[0;36m\033[1m"
grayColor="\e[0;37m\033[1m"
endColor="\033[0m\e[0m"


function ctrl_c() {
	echo -e "\n\n${redColor}[!] Exiting...${endColor}\n"
	tput cnorm && exit 1
}

# ctrl+c
trap ctrl_c INT

# Global variables
main_url="https://htbmachines.github.io/bundle.js"

# Functions

function helpPanel() {
	echo -e "\n${yellowColor}[+]${endColor} ${grayColor}How to use:${endColor}"
	echo -e "\t${purpleColor}u)${endColor} ${grayColor}Download or update necessary files.${endColor}"
	echo -e "\t${purpleColor}m)${endColor} ${grayColor}Search by machine name.${endColor}"
	echo -e "\t${purpleColor}i)${endColor} ${grayColor}Search by IP address.${endColor}"
	echo -e "\t${purpleColor}y)${endColor} ${grayColor}Retrieve machine's YouTube link.${endColor}"
	echo -e "\t${purpleColor}d)${endColor} ${grayColor}List machines by difficulty [Fácil,Media,Difícil,Insane].${endColor}"
	echo -e "\t${purpleColor}o)${endColor} ${grayColor}List machines by OS [Linux,Windows].${endColor}"
	echo -e "\t${purpleColor}h)${endColor} ${grayColor}Show help panel.${endColor}"

	echo -e ""
}

function searchMachine() {
	machineName=$1

	echo -e "\n${yellowColor}[+]${endColor} ${grayColor}Listing${endColor} ${blueColor}$machineName${endColor}${grayColor}'s properties:${endColor}\n"

	machineInfo=$(cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku|resuelta" | tr -d '",' | sed 's/^ *//' | sed 's/://')

	if [ ! -z "$machineInfo" ]; then
		echo -e "$machineInfo"
	else
		echo -e "\n${redColor}[!] ${endColor}${grayColor}There is not${endColor} ${blueColor}$machineName${endColor} ${grayColor}machine.${endColor}\n"
	fi
	
	echo -e ""
}

function updateFiles() {
	tput civis
	# Comprobation
	if [ ! -f bundle.js ]; then
		echo -e "\n${yellowColor}[+]${endColor}${grayColor}Downloading necessary files...${endColor}"
		curl -s -X GET $main_url > bundle.js
		js-beautify bundle.js | sponge bundle.js
		echo -e "\n${yellowColor}[+]${endColor}${grayColor}All necessary files has been downloaded.${endColor}"
	else
		echo -e "\n${yellowColor}[+]${endColor} ${greenColor}Checking for updates...${endColor}"

		curl -s -X GET $main_url > bundle_tmp.js
		js-beautify bundle_tmp.js | sponge bundle_tmp.js
		md5_tmp=$(md5sum bundle_tmp.js | awk '{print $1}')
		md5_original=$(md5sum bundle.js | awk '{print $1}')
		#echo -e "$md5_tmp"
		#echo -e "$md5_original"

		if [ "$md5_tmp" == "$md5_original" ]; then
			echo -e "\n${grayColor}There isn't updates :D${endColor}"
			rm -f bundle_tmp.js
		else
			echo -e "\n${grayColor}There is updates!${endColor}"
			sleep 1
			rm -f bundle.js && mv bundle_tmp.js bundle.js
			echo -e "\n${grayColor}All files updated!${endColor}"
		fi
	fi
	tput cnorm
}

function searchByIP() {
	ipAddress=$1
	machineName=$(cat bundle.js | grep -e "ip: \"$ipAddress\"" -B 3 | grep -e "name: " | awk 'NF{print $NF}' | tr -d '",')

	if [ ! -z "$machineName" ]; then
		echo -e "\n${yellowColor}[+] ${endColor}${grayColor}IP: $ipAddress -> Name: ${endColor}${blueColor}$machineName${endColor}\n"
	else
		echo -e "\n${redColor}[!] ${endColor}${grayColor}There is not${endColor} ${blueColor}$ipAddress${endColor} ${grayColor}IP address.${endColor}\n"
	fi
}

function getYoutubeLink() {
	machineName=$1
	youtubeLink=$(cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku|resuelta" | tr -d '",' | sed 's/^ *//' | sed 's/://' | grep -e "youtube" | awk 'NF{print $NF}')

	if [ ! -z "$youtubeLink" ]; then
		echo -e "\n${yellowColor}[+] ${endColor}${grayColor}Video tutorial of this machine is: ${endColor}${greenColor}$youtubeLink${endColor}\n"
	else
		echo -e "\n${redColor}[!] ${endColor}${grayColor}There is not${endColor} ${blueColor}$machineName${endColor} ${grayColor}machine.${endColor}\n"
	fi
}

function machinesByDifficulty() {
	difficulty=$1
	machines=$(cat bundle.js | grep -e "dificultad: \"$difficulty\"" -B 7 | grep -e "name: " | awk 'NF{print $NF}' | tr -d '",' | column)

	if [ ! -z "$machines" ]; then
		echo -e "\n${yellowColor}[+] ${endColor}${grayColor}Listing machines with diffculty: ${endColor}${blueColor}$difficulty${endColor}\n"
		echo -e "$machines"
	else
		echo -e "\n${redColor}[!] ${endColor}${grayColor}There are not machines with difficulty: ${endColor}${blueColor}$difficulty${endColor}\n"
	fi
}

function machinesByOS() {
	os=$1
	machines=$(cat bundle.js | grep -e "so: \"$os\"" -B 7 | grep -e "name: " | awk 'NF{print $NF}' | tr -d '",' | column)

	if [ ! -z "$machines" ]; then
		echo -e "\n${yellowColor}[+] ${endColor}${grayColor}Listing machines with os: ${endColor}${blueColor}$os${endColor}\n"
		echo -e "$machines"
	else
		echo -e "\n${redColor}[!] ${endColor}${grayColor}There are not machines with os: ${endColor}${blueColor}$os${endColor}\n"
	fi
}

function machinesByDifficultyOS() {
	difficulty=$1
	os=$2
	machines=$(cat bundle.js | grep -e "dificultad: \"$difficulty\"" -B 6 | grep -e "so: \"$os\"" -B 5 | grep -e "name: " | awk 'NF{print $NF}' | tr -d '",' | column)

	if [ ! -z "$machines" ]; then
		echo -e "\n${yellowColor}[+] ${endColor}${grayColor}Listing machines with os: ${endColor}${blueColor}$os${endColor} ${grayColor}and difficulty: ${endColor}${purpleColor}$difficulty${endColor}\\n"
		echo -e "$machines"
	else
		echo -e "\n${redColor}[!] ${endColor}${grayColor}There are not machines with os: ${endColor}${blueColor}$os${endColor} ${grayColor}and difficulty: ${endColor}${purpleColor}$difficulty${endColor}\n"
	fi
}

# Triggers
declare -i difficulty_trigger=0
declare -i os_trigger=0

declare -i i=0
while getopts "m:ui:y:d:o:h" arg; do
	case $arg in
		m) machineName=$OPTARG; let i+=1;;
		u) let i+=2;;
		i) ipAddress=$OPTARG; let i+=3;;
		y) machineName=$OPTARG; let i+=4;;
		d) difficulty=$OPTARG; difficulty_trigger=1; let i+=5;;
		o) os=$OPTARG; os_trigger=1; let i+=6;;
		h) ;;
	esac
done

if [ $i -eq 1 ]; then
	searchMachine $machineName
elif [ $i -eq 2 ]; then
	updateFiles
elif [ $i -eq 3 ]; then
	searchByIP $ipAddress
elif [ $i -eq 4 ]; then
	getYoutubeLink $machineName
elif [ $i -eq 5 ]; then
	machinesByDifficulty $difficulty
elif [ $i -eq 6 ]; then
	machinesByOS $os
elif [ $difficulty_trigger -eq 1 ] && [ $os_trigger -eq 1 ]; then
	machinesByDifficultyOS $difficulty $os
else
	helpPanel
fi
