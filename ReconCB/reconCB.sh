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
	echo "${green}Grabbing subdomains from (Amass), this may take some time...${reset}"
	amass enum -passive -o amass.txt -r 8.8.8.8 -d $domain

	echo '--------------------------------------------------------------------'
	echo "${green}Grabbing subdomains from (subfinder)...${reset}"
	subfinder -o subfinder.txt -d $domain

	echo '--------------------------------------------------------------------'
	echo "${green}Gather domains from gau...${reset}"
	gau -subs $domain | cut -d / -f 3 > gau.txt

	echo '--------------------------------------------------------------------'
	echo "${green}Gathering domains from SubDomainizer...${reset}"
	python3 $toolPath/SubDomainizer/SubDomainizer.py -u $domain -o subdomainizer.txt

	echo '--------------------------------------------------------------------'
	echo "${green}Gathering domains from ShuffleDNS through bruteforcing...${reset}"
	shuffledns -d $domain -w $toolPath/all.txt -r $toolPath/massdns/lists/resolvers.txt -o shuffle.txt

	echo '--------------------------------------------------------------------'
	echo "${green}Merging subdomain lists and removing duplicates...${reset}"
	sort -u amass.txt subfinder.txt gau.txt subdomainizer.txt shuffle.txt > domains.txt
}

hostStatus() {
	echo '--------------------------------------------------------------------'
	echo "${green}Checking for live hosts from domains...${reset}"
	cat domains.txt | httprobe > livehosts.txt
}

massTools() {
	echo '--------------------------------------------------------------------'
	echo "${green}Using MassDNS for DNS bruteforcing...${reset}"
	massdns -r $toolPath/massdns/lists/resolvers.txt -t AAAA livehosts.txt > massdns.txt
	echo "${green}Performing additional recon through subbrute and ct.py...${reset}"
	$toolPath/massdns/scripts/subbrute.py $toolPath/massdns/lists/names.txt $domain | massdns -r $toolPath/massdns/lists/resolvers.txt -t A -o S -w results.txt
	$toolPath/massdns/scripts/ct.py $domain | massdns -r $toolPath/massdns/lists/resolvers.txt -t A -o S -w ct.txt

	touch ips.txt
	while read p; do
		dig +short $p >> ips.txt 
	done < livehosts.txt
	sort -u ips.txt > sortedIPs.txt
	echo "${green}Checking Masscan for IP ranges...${reset}" 
	sudo masscan --top-ports 100  -iL sortedIPs.txt --max-rate 100000 -oG masscanResult.gmap
}

crawl() {
	echo '--------------------------------------------------------------------'
	echo "${green}Crawling through sites with GoSpider...${reset}"
	gospider -S livehosts.txt -o spiderResults -c 10 -d 1 
}

screenshots() {
	echo '--------------------------------------------------------------------'
	echo "${green}Gathering some screenshots of live hosts...${reset}"
	yes n | $toolPath/EyeWitness/Python/EyeWitness.py -f livehosts.txt --web -d screenshots
}

cleanup() {
	echo '--------------------------------------------------------------------'
	echo "${green}Gathering generated files together...${reset}"
	mkdir utilityFiles
	mv amass.txt subfinder.txt gau.txt subdomainizer.txt domains.txt shuffle.txt utilityFiles

	if [ -e geckodriver.log ]
	then
		mv geckodriver.log utilityFiles
	fi

	echo "${green}Finished gathering domains, sorting livehosts...${reset}"
	sort -u livehosts.txt > hostList.txt	
	echo "${green}Done!${reset}"
}

#############
validate
header
setup
#############
subdomains
hostStatus
massTools
crawl
screenshots
#############
cleanup

exit 0
