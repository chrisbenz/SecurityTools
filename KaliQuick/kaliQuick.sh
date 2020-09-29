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

echo "Installing gau"
git clone https://github.com/lc/gau.git
echo "Complete"

echo "Installing Sublist3r"
git clone https://github.com/aboul3la/Sublist3r.git
cd Sublist3r
sudo pip install -r requirements.txt
cd ~/DownloadedTools
echo "Complete"

echo "Installing Github Search"
git clone https://github.com/gwen001/github-search.git
echo "Complete"

echo "Installing Amass"
sudo apt-get install -y amass
echo "Complete"