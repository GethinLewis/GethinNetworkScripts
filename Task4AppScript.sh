#!/bin/bash
#-----------------------------------------------------------------------#
#App A Setup
#-----------------------------------------------------------------------#

#Set environment varialbles
port=8000
url='"https://jsonplaceholder.typicode.com/posts"'

#Get and run NVM auto-installer
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

#Load NVM in current shell session
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

#Install node
nvm install node

#Make app directory
mkdir /data
mkdir /data/appa
cd /data/appa

#Install git package to get app from the repo
yum -y install git

#Clone the repo into our app directory. Done by creating a personal access token and putting it into the URL before the @ below.
git clone https://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@github.com/Enterprise-Automation/trainee-challenge-node-app.git /data/appa

#Install dotenv
npm install dotenv

#Create .env file and add the environment variables
echo "PORT=$port
TARGET_URL=$url" > /data/appa/.env

#Enable traffic on app port
firewall-cmd --permanent --add-port=8000/tcp
firewall-cmd --reload

#Set SELinux to permissive so that dotenv can access files outside of its directory
setenforce 0

#Run app
node /data/appa/index.js

#run this from any other machine on the network to request data from the app (IP may be different):
#curl http://10.1.1.50:8000