#!/bin/bash

option=$1
domain=$2
argCount=$#
timeStamp=`date +"%Y-%m-%d_%H-%M-%s"`

header() {
	echo '--------------------------------------------------------------------'
	echo 'Starting Recon...'
	echo '--------------------------------------------------------------------'

}

validate() {
	if [ "$option" != '-d' ]
	then
		echo "Usage: ./reconSB.sh -d domain"
		exit 1
	fi

	if [ $argCount -ne 2 ]
	then
		echo "Usage: ./reconSB.sh -d domain"
		exit 1
	fi
}

subdomains() {
	cd ${storage}

	echo "Grabbing subdomains from (Amass), this may take some time..."
	amass enum -passive -o amass-enum.txt -r 8.8.8.8 -d ${domain}

	echo '--------------------------------------------------------------------'
	echo "Grabbing subdomains from (subfinder)..."
	subfinder -o subfinder-enum.txt -d ${domain}

	echo '--------------------------------------------------------------------'
	echo "Merging subdomain lists and removing duplicates..."
	sort -u amass-enum.txt subfinder-enum.txt > domains.txt

	echo '--------------------------------------------------------------------'
	echo "Checking for live hosts from domains..."
	cat domains.txt | httprobe > livehosts.txt

	echo "Gather domains from gau..."
	gau -subs ${domain} | cut -d / -f 3 | sort -u >> livehosts.txt

	echo "Gathering some screenshots of live hosts..."
	~/DownloadedTools/EyeWitness/Python/EyeWitness.py -f ~/Desktop/${storage}/livehosts.txt --web -d "${storage}-screenshots"

	echo "Crawling through sites with GoSpider..."
	gospider -S livehosts.txt -o spiderResults -c 10 -d 1 

	echo "Finished gathering domains, sorting livehosts..."
	sort livehosts.txt > hostList.txt

	echo "Done!"
}

validate
header

storage="${domain}-recon-${timeStamp}"
mkdir ${storage}

subdomains

exit 0
