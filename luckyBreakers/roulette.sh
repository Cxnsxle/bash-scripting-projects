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

# main code
function helpPanel() {
	echo -e "\n${yellowColor}[+]${endColor} ${grayColor}How to use:${endColor}"
	echo -e "\t${purpleColor}m)${endColor} ${grayColor}To specify the amount to bet.${endColor}"
	echo -e "\t${purpleColor}t)${endColor} ${grayColor}To specify the technique to apply ${endColor}${yellowColor}[Martingale/InverseLabrouchere].${endColor}"

	echo -e "\n\t${purpleColor}h)${endColor} ${grayColor}Show help panel.${endColor}"

	echo -e ""
}

function martingale() {
	amount=$1
	echo -e "\n${yellowColor}[+] ${endColor}${grayColor}Current amount: ${endColor}${yellowColor}\$/$amount${endColor}\n"
	echo -ne "${yellowColor}[+] ${endColor}${grayColor}Initial amount to bet -> ${endColor}" && read initial_bet
	echo -ne "${yellowColor}[+] ${endColor}${grayColor}Target to bet [even/odd] -> ${endColor}" && read even_odd
	# variables
	backup_bet=$initial_bet
	play_counter=0
	bad_plays=""
	max_amount=$amount

	echo -e "\n${yellowColor}[+] ${endColor}${grayColor}Summary: ${endColor}"
	echo -e "\t${grayColor}Amount to bet: ${endColor}${blueColor}\$/$initial_bet${endColor}"
	echo -e "\t${grayColor}Target to bet: ${endColor}${blueColor}$even_odd${endColor}"

	# hide cursor
	tput civis

	# infinite bucle
	while [ $(($amount - $initial_bet)) -ge 0 ]; do
		let play_counter+=1

		random=$(($RANDOM % 37))
		rand_evaluator=$(($random % 2)) # even(0) | odd(1)
		#echo -e ""
		#echo -e "${grayColor}[+] ${endColor}${grayColor}Betting: ${endColor}${greenColor}$initial_bet${endColor}"
		#echo -e "${grayColor}[+] ${endColor}${grayColor}The number has come out: ${endColor}${turquoiseColor}$random${endColor}"

		# Getting operation
		if [ $random -eq 0 ]; then
			rand_evaluator=0 # loss
		elif [ "$even_odd" == "even" ] && [ $rand_evaluator -eq 0 ]; then
			rand_evaluator=1 # win
		elif [ "$even_odd" == "odd" ] && [ $rand_evaluator -eq 1 ]; then
			rand_evaluator=1 # win
		else
			rand_evaluator=0
		fi

		# Playing
		if [ $rand_evaluator -eq 1 ]; then
			#echo -e "\t${greenColor}[+] WIN!: +$initial_bet${endColor}"
			amount=$(($amount + $initial_bet))
			initial_bet=$backup_bet				# updating initial_bet
			bad_plays=""						# restore bad plays
		else
			#echo -e "\t${redColor}[-] LOSS!: -$initial_bet${endColor}"
			amount=$(($amount - $initial_bet))
			initial_bet=$(($initial_bet * 2))	# updating initial_bet
			bad_plays+="$random "				# append bad play
		fi
		#echo -e "${yellowColor}[+] ${endColor}${grayColor}Current amount: ${endColor}${turquoiseColor}\$/$amount${endColor}"

		# Getting max amount obtained
		if [ $amount -gt $max_amount ]; then
			max_amount=$amount
		fi

		#sleep 1
	done
	# Money <= 0
	echo -e "\n${redColor}[!] You LOSS all your money! :C${endColor}"
	echo -e "${yellowColor}[+] ${endColor}${grayColor}Total bets: ${endColor}${greenColor}$play_counter${endColor}"
	echo -e "${yellowColor}[+] ${endColor}${grayColor}List of bad plays: ${endColor}${redColor}$bad_plays${endColor}"
	echo -e "${yellowColor}[+] ${endColor}${grayColor}Maximum amount obtained: ${endColor}${greenColor}$max_amount${endColor}"

	# unhide cursor
	tput cnorm

	echo -e ""
}

function inverseLabrouchere() {
	echo -e "\nInverseLabrouchere"
}

while getopts "m:t:h" arg; do
	case $arg in
		m) amount=$OPTARG;;
		t) technique=$OPTARG;;
		h) ;;
	esac
done

if [ $amount ] && [ $technique ]; then
	if [ $technique == "Martingale" ]; then
		martingale $amount
	elif [ $technique == "InverseLabrouchere" ]; then
		inverseLabrouchere
	else
		echo -e "\n${redColor}[!] ${endColor}${grayColor}There is not ${endColor}${blueColor}$technique ${endColor}${grayColor}technique.${endColor}\n"
		helpPanel
	fi
else
	helpPanel
fi
