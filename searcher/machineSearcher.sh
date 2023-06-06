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
	echo -e "\t${purpleColor}h)${endColor} ${grayColor}Show help panel.${endColor}"
}

function searchMachine() {
	machineName=$1
	echo -e "$machineName"
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

declare -i i=0
while getopts "m:uh" arg; do
	case $arg in
		m) machineName=$OPTARG; let i+=1;;
		u) let i+=2;;
		h) ;;
	esac
done

if [ $i -eq 1 ]; then
	searchMachine $machineName
elif [ $i -eq 2 ]; then
	updateFiles
else
	helpPanel
fi
