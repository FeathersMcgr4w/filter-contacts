#!/bin/bash

# Automation to filter contacts from html file

trap ctrl_c SIGINT

function ctrl_c() {
	echo -e "\n[*] Exiting...\n"
	tput cnorm; exit 1
}

function filterClient() {
	numberPage=$1
	result=$(cat htmlContent.txt | grep -A 10 "Cliente" | grep -E "@" | sed 's/[ \t]\+/ /g' | grep -v -E "gmail.com|hotmail.com|yahoo.com.ar|outlook.com|live.com")

	if [ -n "$result" ]; then #check string length
		if [ -n "$numberPage" ]; then
			echo -e "[$numberPage] $result" >> contacts.txt
		else
			echo "$result" >> contacts.txt
		fi
	fi
}

# Main
clear; echo -e "::: Scraping Contacts :::\n"; echo -e "[->] Enter the number range for scraping pages\n"
read -p "Start of range: " start
read -p "End of range: " end

tput civis

for page in $(seq $start $end); do
	clear; echo -e "::: Scraping Contacts :::\n"; echo -e "[*] Page: $page - $end"

	curl -sX GET http://192.168.x.xxx:80/"$page.html" | w3m -dump -T text/html > htmlContent.txt; sleep 1
	email=$(cat htmlContent.txt | grep "Mail:" | awk 'NF{print $NF}') # john.doe@gmail.com

	# Validar
	pattern="@(gmail\.com|hotmail\.com|yahoo\.com\.ar|outlook\.com|live\.com)$"

	if [[ $email =~ $pattern ]]; then
		filterClient $page
	else
		contact=$(cat htmlContent.txt | grep -E "Contacto|TelÃ©fono|Mail|Sitio web" | head -n 4 | cut -d ":" -f 2-3 | sed 's/^ *//' | xargs)
		if [ -n "$contact" ]; then
			echo -e "[$page] $contact" >> contacts.txt
		fi

		filterClient
	fi
done

echo -e "\nFinish! Bye!"
tput cnorm
