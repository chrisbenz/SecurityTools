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

borderEcho="echo --------------------------------------------------------------------"

validate() {
	if [ "$option" != '-d' ] || [ $argCount -ne 2 ]
	then
		echo "Usage: ./reconSB.sh -d domain"
		exit 1
	fi
}

header() {
	eval "$borderEcho"
	echo 'Starting Recon...'
	eval "$borderEcho"
}

setup() {
	storage="${domain}-recon-${timeStamp}"
	mkdir ${storage}
	cd $storage
}

subdomains() {
	echo "${green}Grabbing subdomains from Amass, this may take some time...${reset}"
	amass enum -passive -o amass.txt -r 8.8.8.8 -d $domain

	eval "$borderEcho"
	echo "${green}Grabbing subdomains from subfinder...${reset}"
	subfinder -o subfinder.txt -d $domain

	eval "$borderEcho"
	echo "${green}Gather domains from assetfinder...${reset}"
	assetfinder $domain > assetfinder.txt

	eval "$borderEcho"
	echo "${green}Merging subdomain lists and removing duplicates...${reset}"
	sort -u amass.txt subfinder.txt assetfinder.txt > domains.txt
}

massTools() {
	eval "$borderEcho"	
	echo "${green}Getting valid domains through massdns...${reset}"
	massdns -r $toolPath/massdns/lists/resolvers.txt -t A -o S -w results.txt domains.txt
	cat results.txt | awk '{print $1}' | sed -e 's/\.$//' > livehosts.txt
}

hostStatus() {
	eval "$borderEcho"
	echo "${green}Checking for live hosts from domains...${reset}"
	cat livehosts.txt | httprobe 2 >&1 | tee httprobe.txt
}

serviceScan() {
	eval "$borderEcho"
	echo "${green}Using host list to determine open services with naabu...${reset}"
	naabu -iL livehosts.txt | sort -u > openServices.txt
}

fuzz() {
	eval "$borderEcho"
	echo "${green}Directory fuzzing using ffuf...${reset}"
	mkdir "$domain-fuzz"
	cd "$domain-fuzz"
	while read url; do
		fuzzFileName=`echo "$url" | awk -F/ '{print $3}'`-fuzz.txt
		ffuf -w $wordList -u $url/FUZZ -mc 200,302 -o $fuzzFileName
	done < ../httprobe.txt
}

crawl() {
	eval "$borderEcho"
	echo "${green}Crawling through sites with GoSpider...${reset}"
	mkdir "$domain-crawl"
	cd "$domain-crawl"

	while read -u 9 url; do
		fullUrl=$(echo $url | sed -e 's/.\/\//_/g')
		echo $fullUrl
		gospider -s "$url" -c 10 -d 1 | grep "\[href\] - $url" | awk '{print $3}' > "$fullUrl" 
	done 9< ../httprobe.txt 
	cd ..

	eval "$borderEcho"
	echo "${green}Checking for interesting Javascript files with gau and httpx...${reset}"
	gau $domain | grep '\.js' | httpx -status-code -mc 200 -content-type | grep 'application/javascript'

}

screenshots() {
	eval "$borderEcho"
	echo "${green}Gathering some screenshots of live hosts...${reset}"
	yes n | $toolPath/EyeWitness/Python/EyeWitness.py -f livehosts.txt --web -d screenshots
}

cleanup() {
	eval "$borderEcho"
	echo "${green}Gathering generated files together...${reset}"
	mkdir utilityFiles
	mv amass.txt subfinder.txt domains.txt assetfinder.txt httprobe.txt results.txt utilityFiles

	if [ -e geckodriver.log ]
	then
		mv geckodriver.log utilityFiles
	fi

	echo "${green}Finished gathering domains, sorting livehosts...${reset}"
	sort -u livehosts.txt > sites.txt
	echo -e "\n===Live hosts discovered via Naabu ===" >> sites.txt
	if [ -f naabu.txt ]
	then
		cat naabu.txt >> sites.txt 
		mv naabu.txt utilityFiles
	fi
	
	mv livehosts.txt utilityFiles	
	echo "${green}Done!${reset}"
}

############
validate
header
setup
############
subdomains
massTools
hostStatus
serviceScan
############
# fuzz
crawl
screenshots
############
cleanup

exit 0
