#!/usr/bin/env bash
#    ===========================================================================
#     Created with:     Visual Studio Code
#     Created on:       16/02/2018     
#     Company:          BJSS Ltd
#     Contact:          Steve Owens
#     Filename:         jenkins-install.sh
#     This script install Jenkins in your Ubuntu System
#    ===========================================================================

wget -q -O - https://pkg.jenkins.io/debian/jenkins-ci.org.key | apt-key add - echo deb https://pkg.jenkins.io/debian-stable binary/ | tee /etc/apt/sources.list.d/jenkins.list
apt-get update -y
apt-get install -y jenkins
systemctl start jenkins
systemctl enable jenkins

Exit
