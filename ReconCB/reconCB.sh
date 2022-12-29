#!/bin/bash

option=$1
domain=$2
argCount=$#
timeStamp=`date +"%Y-%m-%d"`
toolPath=~/DownloadedTools
wordList=/usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt

number=0

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

	file_storage_name="${domain}-${timeStamp}"

	while [ -e "$file_storage_name" ]; do
	    printf -v file_storage_name '%s-%02d' "${domain}-${timeStamp}" "$(( ++number ))"
	done

	mkdir ${file_storage_name}
	cd $file_storage_name
}

run_amass() {
	echo "${green}Grabbing subdomains from Amass, this may take some time...${reset}"
	amass enum -passive -o amass.txt -r 8.8.8.8 -d $domain
}

run_subfinder() {
	eval "$borderEcho"
	echo "${green}Grabbing subdomains from subfinder...${reset}"
	echo $domain
	subfinder -o subfinder.txt -d $domain
}

run_assetfinder() {
	eval "$borderEcho"
	echo "${green}Gather domains from assetfinder...${reset}"
	assetfinder $domain > assetfinder.txt
}

subdomains() {
	#run_amass
	run_subfinder
	run_assetfinder

	eval "$borderEcho"
	echo "${green}Merging subdomain lists and removing duplicates...${reset}"
	# sort -u amass.txt subfinder.txt assetfinder.txt > domains.txt
	sort -u subfinder.txt assetfinder.txt > domains.txt
	rm subfinder.txt
	rm assetfinder.txt
}

mass_tools() {
	eval "$borderEcho"	
	echo "${green}Getting valid domains through massdns...${reset}"
	massdns -r $toolPath/massdns/lists/resolvers.txt -t A -o S -w results.txt domains.txt
	cat results.txt | awk '{print $1}' | sed -e 's/\.$//' | sort -u > livehosts.txt
	rm results.txt
}

host_status() {
	eval "$borderEcho"
	echo "${green}Checking for live hosts from domains using httprobe...${reset}"
	cat livehosts.txt | httprobe 2 >&1 | tee httprobe.txt
}

service_scan() {
	eval "$borderEcho"
	echo "${green}Using host list to determine open services with naabu...${reset}"
	naabu -list livehosts.txt | sort -u > open_services.txt
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

spider() {
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
}

run_gau() {
	eval "$borderEcho"
	echo "${green}Checking for interesting Javascript files with gau and httpx...${reset}"
	gau $domain | grep '\.js' | httpx -status-code -mc 200 -content-type | grep 'application/javascript'
}

crawl() {
	#spider
	run_gau
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
	mv domains.txt httprobe.txt results.txt utilityFiles

	if [ -e geckodriver.log ]
	then
		mv geckodriver.log utilityFiles
	fi

	echo "${green}Finished gathering domains, sorting livehosts...${reset}"
	sort -u livehosts.txt > sites.txt
	echo -e "\n===Live hosts discovered via Naabu ===" >> sites.txt
	if [ -f open_services.txt ]
	then
		cat open_services.txt >> sites.txt 
		mv open_services.txt utilityFiles
	fi
	
	mv livehosts.txt utilityFiles	
	echo "${green}Done!${reset}"
}

validate
header
setup
subdomains
mass_tools
host_status
service_scan

# fuzz
# crawl
# screenshots

cleanup

exit 0
