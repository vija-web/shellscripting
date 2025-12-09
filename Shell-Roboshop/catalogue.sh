#!/bin/bash

RED="\033[31m"
GREEN="\033[1;32m"
YELLOW="\033[4;33m"
NORMAL="\033[0m"
COUNT=0

UIDD=$(echo $UID)
if [ "$UIDD" -ne 0 ]; then
    echo -e "Run with $RED ROOT USER $NORMAL"
    exit 1
fi

FOLDER="/var/log/shell-logs"
mkdir -p "$FOLDER"
chmod 777 /var/log/shell-logs

SCRIPT_NAME=$0
FILE_NAME=$(echo "$SCRIPT_NAME" | awk -F "." '{print $1F}')

touch $FOLDER/$FILE_NAME.log

VALIDATE(){
    if [ $2 -eq 0 ]; then
        echo -e "$1 .... $GREEN SUCCESS $NORMAL" | tee -a "$FOLDER/$FILE_NAME.log"

    else
        echo -e "$1 ... $RED FAILURE $NORMAL" | tee -a "$FOLDER/$FILE_NAME.log"
        exit 1
    fi
}

dnf module disable nodejs -y
VALIDATE "Disabling nodejs is" $?

dnf module enable nodejs:20 -y
VALIDATE "Enabling nodejs is" $?

dnf install nodejs -y
VALIDATE "Installing nodejs is" $?

useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
VALIDATE "Adding Roboshop user" $?

mkdir -p /app 
VALIDATE "Creating app directory" $?

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip 
VALIDATE "Downloading the zip" $?

cd /app 
VALIDATE "Changed to the /app directory" $?

unzip /tmp/catalogue.zip
VALIDATE "Unzip the file is" $?

npm install 
VALIDATE "Installing the dependencies is" $?

cp ./catalogue.service /etc/systemd/system/catalogue.service
VALIDATE "coping the service file is" $?

systemctl daemon-reload
VALIDATE "daemon-reload is" $?

systemctl enable catalogue 
VALIDATE "Enabling catalogue is" $?

systemctl start catalogue
VALIDATE "Starting catalogue is" $?

cp ./mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE "Adding mongo.repo is" $?

dnf install mongodb-mongosh -y
VALIDATE "Installing mongodb client is" $?

mongosh --host mongodb.vijayaws.fun </app/db/master-data.js
VALIDATE "Connecting the mogodb through mongosh client is" $?

if [ $COUNT -eq 0 ]; then
    COUNT=1
    mongosh --host MONGODB-SERVER-IPADDRESS </app/db/master-data.js
    VALIDATE "Connecting the mogodb through mongosh client is" $?
else
    echo -e "$YELLOW Data to the database was loaded $NORMAL"
fi

