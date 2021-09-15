#!/bin/bash

option=$1
domain=$2
argCount=$#
timeStamp=`date +"%Y-%m-%d_%s"`
toolPath=~/DownloadedTools
wordList=/usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt

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
	echo "${green}Grabbing subdomains from Amass, this may take some time...${reset}"
	amass enum -passive -o amass.txt -r 8.8.8.8 -d $domain

	echo '--------------------------------------------------------------------'
	echo "${green}Grabbing subdomains from subfinder...${reset}"
	subfinder -o subfinder.txt -d $domain

	echo '--------------------------------------------------------------------'
	echo "${green}Gather domains from assetfinder...${reset}"
	assetfinder $domain > assetfinder.txt

	echo '--------------------------------------------------------------------'
	echo "${green}Merging subdomain lists and removing duplicates...${reset}"
	sort -u amass.txt subfinder.txt assetfinder.txt > domains.txt
}

massTools() {
	echo '--------------------------------------------------------------------'
	echo "${green}Getting valid domains through massdns...${reset}"
	massdns -r $toolPath/massdns/lists/resolvers.txt -t A -o S -w results.txt domains.txt
	cat results.txt | awk '{print $1}' | sed -e 's/\.$//' > livehosts.txt
}

hostStatus() {
	echo '--------------------------------------------------------------------'
	echo "${green}Checking for live hosts from domains...${reset}"
	cat livehosts.txt | httprobe > httprobe.txt
}

serviceScan() {
	echo '--------------------------------------------------------------------'
	echo "${green}Using host list to determine open services with naabu...${reset}"
	naabu -iL httprobe.txt -o naabu.txt
}

fuzz() {
	echo '--------------------------------------------------------------------'
	echo "${green}Directory fuzzing using ffuf...${reset}"
	mkdir "$domain-fuzz"
	cd "$domain-fuzz"
	while read url; do
		fuzzFileName=`echo "$url" | awk -F/ '{print $3}'`-fuzz.txt
		ffuf -w $wordList -u $url/FUZZ -mc 200,302 -o $fuzzFileName
	done < ../httprobe.txt
}

crawl() {
	echo '--------------------------------------------------------------------'
	echo "${green}Crawling through sites with GoSpider...${reset}"
	mkdir "$domain-crawl"
	cd "$domain-crawl"
	while read url; do
		fullUrl=$(echo $url | sed -e 's/.\/\//_/g')
		gospider -s "$url" -c 10 -d 1 #| grep "\[href\] - $url" | awk '{print $3}' > "$fullUrl" 
	done < ../httprobe.txt 
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
	mv amass.txt subfinder.txt domains.txt assetfinder.txt httprobe.txt results.txt utilityFiles

	if [ -e geckodriver.log ]
	then
		mv geckodriver.log utilityFiles
	fi

	echo "${green}Finished gathering domains, sorting livehosts...${reset}"
	sort -u livehosts.txt > sites.txt
	mv livehosts.txt utilityFiles	
	echo "${green}Done!${reset}"
}

#############
#validate
#header
#setup
#############
#subdomains
#massTools
#hostStatus
#serviceScan
#fuzz
crawl
#screenshots
#############
#cleanup

exit 0
