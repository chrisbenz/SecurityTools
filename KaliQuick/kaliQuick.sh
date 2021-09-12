#!/bin/bash

# Sublime Text
wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
sudo apt-get -y update
sudo apt-get install -y sublime-text

sudo apt-get install -y snapd

# Pip, Pip3
sudo apt-get -y install python3-pip
sudo apt-get -y install python-pip

# Python Setup Tools
sudo apt-get install -y python3-setuptools
sudo apt-get install -y python-setuptools

mkdir ~/DownloadedTools
cd ~/DownloadedTools

echo "Installing Sublist3r"
git clone https://github.com/aboul3la/Sublist3r.git
cd Sublist3r
sudo pip install -r requirements.txt
cd ~/DownloadedTools
echo "Complete"

echo "Installing subfinder"
git clone https://github.com/projectdiscovery/subfinder.git
cd subfinder/v2/cmd/subfinder
go build .
sudo mv subfinder /usr/local/bin/
cd ~/DownloadedTools
echo "Complete"

echo "Installing Github Search"
git clone https://github.com/gwen001/github-search.git
echo "Complete"

echo "Installing Amass"
sudo apt-get install -y amass
echo "Complete"

echo "Installing DirSearch"
git clone https://github.com/maurosoria/dirsearch.git
cd dirsearch
sudo pip3 install -r requirements.txt
echo "Complete"

cd ~/DownloadedTools
echo "Installing SubDomainizer"
git clone https://github.com/nsonaniya2010/SubDomainizer.git
cd SubDomainizer
pip3 install -r requirements.txt
echo "Complete"

echo "Installing getallurls (gau)"
GO111MODULE=on go get -u -v github.com/lc/gau
echo "Complete"

echo "Installing GoSpider"
GO111MODULE=on go get -u github.com/jaeles-project/gospider
echo "Complete"

echo "Installing Eyewitness"
cd ~/DownloadedTools
git clone https://github.com/FortyNorthSecurity/EyeWitness.git
cd EyeWitness/Python/setup
sudo ./setup.sh
echo "Complete"

echo "Installing Masscan"
cd ~/DownloadedTools
git clone https://github.com/robertdavidgraham/masscan.git
cd masscan
make
sudo make install
echo "Complete"

echo "Installing MassDNS"
cd ~/DownloadedTools
git clone https://github.com/blechschmidt/massdns.git
cd massdns
make
sudo make install
echo "Complete"

echo "Installing ShuffleDNS"
GO111MODULE=on go get -v github.com/projectdiscovery/shuffledns/cmd/shuffledns
echo "Complete"

echo "Installing Brutespray"
sudo apt-get install brutespray
echo "Complete"

echo "Clone all.txt gist entry from Jason Haddix"
cd ~/DownloadedTools
git clone https://gist.github.com/86a06c5dc309d08580a018c66354a056.git
mv 86a06c5dc309d08580a018c66354a056/all.txt .
rm -rf 86a06c5dc309d08580a018c66354a056/
echo "Complete"

echo "Installing FFUF"
go get -u github.com/ffuf/ffuf
echo "Complete"

echo "Installing assetfinder"
go get -u github.com/tomnomnom/assetfinder
echo "Complete"

echo "Installing naabu"
sudo apt-get install -y libpcap-dev
GO111MODULE=on go get -v github.com/projectdiscovery/naabu/v2/cmd/naabu
echo "Complete"
