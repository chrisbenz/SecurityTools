#!/bin/bash

option="$1"
domain=$2

header() {
	echo '_____________________________________   _________________ 
	___  __ \__  ____/_  ____/_  __ \__  | / /_  ____/__  __ )
	__  /_/ /_  __/  _  /    _  / / /_   |/ /_  /    __  __  |
	_  _, _/_  /___  / /___  / /_/ /_  /|  / / /___  _  /_/ / 
	/_/ |_| /_____/  \____/  \____/ /_/ |_/  \____/  /_____/  
	'
}

validate() {
	if [ "$option" != '-d' ]
	then
		echo "Usage: ./reconSB.sh -d domain"
		exit 1
	fi
}

subdomains() {
	echo "Grabbing subdomains from Amass..."
	cd ${STORAGE}
	amass enum -o amass-enum.txt -d ${domain}
	echo "Grabbing subdomains from subfinder..."
	subfinder -o subfinder-enum.txt -d ${domain}

	echo "Merging subdomain lists and removing duplicates..."
	sort -u amass-enum.txt subfinder-enum.txt > domains.txt

	echo "Checking for live hosts from domains..."
	cat domains.txt | httprobe > livehosts.txt
}


STORAGE="${domain}-recon"
mkdir ${STORAGE}

validate
header
subdomains

exit 0

