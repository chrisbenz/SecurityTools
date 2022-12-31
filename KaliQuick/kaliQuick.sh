#!/bin/bash

setup() {
	if [ ! -e ~/DownloadedTools ]; then
		mkdir ~/DownloadedTools
	fi 

	cd ~/DownloadedTools
}

snapd() {
	sudo apt-get install -y snapd
}

python() {
	# Pip, Pip3
	sudo apt-get -y install python3-pip
	sudo apt-get -y install python-pip

	# Python Setup Tools
	sudo apt-get install -y python3-setuptools
	sudo apt-get install -y python-setuptools

	# Install Dirsearch
	pip3 install dirsearch
}

sublime() {
	# Sublime Text
	wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/sublimehq-archive.gpg > /dev/null
	echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
	sudo apt-get update
	sudo apt-get install sublime-text
}

sublister() {
	echo "Installing Sublist3r"
	git clone https://github.com/aboul3la/Sublist3r.git
	cd Sublist3r
	sudo pip install -r requirements.txt
	git pull
	cd ~/DownloadedTools
	echo "Complete"
}

subfinder() {
	echo "Installing subfinder"
	git clone https://github.com/projectdiscovery/subfinder.git
	cd subfinder/v2/cmd/subfinder
	git pull
	go build .
	sudo mv subfinder /usr/local/bin/
	cd ~/DownloadedTools
	echo "Complete"
}

subdomainizer() {
	cd ~/DownloadedTools
	echo "Installing SubDomainizer"
	git clone https://github.com/nsonaniya2010/SubDomainizer.git
	cd SubDomainizer
	git pull
	pip3 install -r requirements.txt
	echo "Complete"
}

amass() {
	echo "Installing Amass"
	sudo apt-get install -y amass
	echo "Complete"
}

dirsearch() {
	echo "Installing DirSearch"
	git clone https://github.com/maurosoria/dirsearch.git
	cd dirsearch
	git pull
	sudo pip3 install -r requirements.txt
	echo "Complete"
}

gau() {
	echo "Installing getallurls (gau)"
	GO111MODULE=on go install github.com/lc/gau@latest
	echo "Complete"
}

naabu() {
	echo "Installing naabu"
	sudo apt-get install -y libpcap-dev
	GO111MODULE=on go install github.com/projectdiscovery/naabu/v2/cmd/naabu@latest
	echo "Complete"
}

gospider() {
	echo "Installing GoSpider"
	GO111MODULE=on go install github.com/jaeles-project/gospider@latest
	echo "Complete"
}

httpx() {
	echo "Installing httpx"
	GO111MODULE=on go install github.com/projectdiscovery/httpx/cmd/httpx@latest
	echo "Complete"
}

ffuf() {
	echo "Installing FFUF"
	go install github.com/ffuf/ffuf@latest
	echo "Complete"
}

eyewitness() {
	echo "Installing Eyewitness"
	cd ~/DownloadedTools
	git clone https://github.com/FortyNorthSecurity/EyeWitness.git
	cd EyeWitness/Python/setup
	sudo ./setup.sh
	echo "Complete"
}

massscan() {
	echo "Installing Masscan"
	cd ~/DownloadedTools
	git clone https://github.com/robertdavidgraham/masscan.git
	cd masscan
	git pull
	make
	sudo make install
	echo "Complete"
}

massdns() {
	echo "Installing MassDNS"
	cd ~/DownloadedTools
	git clone https://github.com/blechschmidt/massdns.git
	cd massdns
	make
	sudo make install
	echo "Complete"
}

shuffledns() {
	echo "Installing ShuffleDNS"
	go install -v github.com/projectdiscovery/shuffledns/cmd/shuffledns@latest
	echo "Complete"
}

brutespray() {
	echo "Installing Brutespray"
	sudo apt-get install brutespray
	echo "Complete"
}

setup
##############
snapd
python
sublime
sublister
subfinder
subdomainizer
amass
dirsearch
gau
naabu
gospider
httpx
ffuf
eyewitness
massscan
massdns
shuffledns
brutespray

# echo "Clone all.txt gist entry from Jason Haddix"
# cd ~/DownloadedTools
# git clone https://gist.github.com/86a06c5dc309d08580a018c66354a056.git
# mv 86a06c5dc309d08580a018c66354a056/all.txt .
# rm -rf 86a06c5dc309d08580a018c66354a056/
# echo "Complete"
