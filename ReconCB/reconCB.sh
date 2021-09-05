#!/bin/bash

option=$1
domain=$2
argCount=$#
timeStamp=`date +"%Y-%m-%d_%s"`
toolPath=~/DownloadedTools

red=`tput setaf 1`
green=`tput setaf 2`
reset=`tput sgr0`

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

setup() {
	storage="${domain}-recon-${timeStamp}"
	mkdir ${storage}
	cd $storage
}

subdomains() {
	echo "${green}Grabbing subdomains from (Amass), this may take some time..."
	amass enum -o amass.txt -r 8.8.8.8 -d $domain

	echo '--------------------------------------------------------------------'
	echo "Grabbing subdomains from (subfinder)..."
	subfinder -o subfinder.txt -d $domain

	echo '--------------------------------------------------------------------'
	echo "Gather domains from gau..."
	gau -subs $domain | cut -d / -f 3 > gau.txt

	echo '--------------------------------------------------------------------'
	echo "Gathering domains from SubDomainizer..."
	python3 $toolPath/SubDomainizer/SubDomainizer.py -u $domain -o subdomainizer.txt

	echo '--------------------------------------------------------------------'
	echo "Merging subdomain lists and removing duplicates..."
	sort -u amass.txt subfinder.txt gau.txt subdomainizer.txt > domains.txt

}

hostStatus() {
	echo '--------------------------------------------------------------------'
	echo "Checking for live hosts from domains..."
	cat domains.txt | httprobe > livehosts.txt
}

crawl() {
	echo '--------------------------------------------------------------------'
	echo "Crawling through sites with GoSpider..."
	gospider -S livehosts.txt -o spiderResults -c 10 -d 1 
}

screenshots() {
	echo '--------------------------------------------------------------------'
	echo "Gathering some screenshots of live hosts..."
	yes n | $toolPath/EyeWitness/Python/EyeWitness.py -f livehosts.txt --web -d screenshots
}

cleanup() {
	echo '--------------------------------------------------------------------'
	echo "Gathering generated files together..."
	mkdir utilityFiles
	mv amass.txt subfinder.txt gau.txt subdomainizer.txt domains.txt utilityFiles

	if [ -e geckodriver.log ]
	then
		mv geckodriver.log utilityFiles
	fi

	echo "Finished gathering domains, sorting livehosts..."
	sort -u livehosts.txt > hostList.txt	
	echo "Done!${reset}"
}

#############
validate
header
setup
#############
subdomains
hostStatus
crawl
screenshots
#############
cleanup

exit 0
