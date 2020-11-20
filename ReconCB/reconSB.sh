#!/bin/bash

ARG="$1"
DOMAIN=$2

header() {
	echo '_____________________________________   _________________ 
___  __ \__  ____/_  ____/_  __ \__  | / /_  ____/__  __ )
__  /_/ /_  __/  _  /    _  / / /_   |/ /_  /    __  __  |
_  _, _/_  /___  / /___  / /_/ /_  /|  / / /___  _  /_/ / 
/_/ |_| /_____/  \____/  \____/ /_/ |_/  \____/  /_____/  
                                                          '
}

if [ "$ARG" != '-d' ]
then
	echo "Usage: ./reconSB.sh -d domain"
	exit 1
fi

header

STORAGE="${DOMAIN}-recon"
mkdir ${STORAGE}

echo "Grabbing subdomains from Amass..."
cd ${STORAGE}
#amass enum -o amass-enum.txt -d ${DOMAIN}
echo "Grabbing subdomains from subfinder..."
subfinder -o subfinder-enum.txt -d ${DOMAIN}
exit 0

