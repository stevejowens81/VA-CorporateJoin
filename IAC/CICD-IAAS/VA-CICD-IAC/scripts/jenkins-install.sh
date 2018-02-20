#!/usr/bin/env bash
#    ===========================================================================
#     Created with:     Visual Studio Code
#     Created on:       16/02/2018     
#     Company:          BJSS Ltd
#     Contact:          Steve Owens
#     Filename:         jenkins-install.sh
#     This script install Jenkins in your Ubuntu System
#    ===========================================================================
wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -
sleep 30s
sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
sleep 30s
sudo apt-get -y update
sleep 1m
sudo apt-get -y install jenkins
sleep 1m
exit