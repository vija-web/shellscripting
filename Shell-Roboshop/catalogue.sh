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

dnf module disable nodejs -y | tee -a "$FOLDER/$FILE_NAME.log"
VALIDATE "Disabling nodejs is" $?

dnf module enable nodejs:20 -y | tee -a "$FOLDER/$FILE_NAME.log"
VALIDATE "Enabling nodejs is" $?

dnf install nodejs -y | tee -a "$FOLDER/$FILE_NAME.log"
VALIDATE "Installing nodejs is" $?

useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop | tee -a "$FOLDER/$FILE_NAME.log"
VALIDATE "Adding Roboshop user" $?

mkdir -p /app | tee -a "$FOLDER/$FILE_NAME.log"
VALIDATE "Creating app directory" $? 

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip | tee -a "$FOLDER/$FILE_NAME.log"
VALIDATE "Downloading the zip" $? 

cd /app | tee -a "$FOLDER/$FILE_NAME.log"
VALIDATE "Changed to the /app directory" $?

unzip /tmp/catalogue.zip | tee -a "$FOLDER/$FILE_NAME.log"
VALIDATE "Unzip the file is" $?

npm install | tee -a "$FOLDER/$FILE_NAME.log"
VALIDATE "Installing the dependencies is" $?

cp ./catalogue.service /etc/systemd/system/catalogue.service | tee -a "$FOLDER/$FILE_NAME.log"
VALIDATE "coping the service file is" $?

systemctl daemon-reload | tee -a "$FOLDER/$FILE_NAME.log"
VALIDATE "daemon-reload is" $?

systemctl enable catalogue | tee -a "$FOLDER/$FILE_NAME.log"
VALIDATE "Enabling catalogue is" $?

systemctl start catalogue | tee -a "$FOLDER/$FILE_NAME.log"
VALIDATE "Starting catalogue is" $?

cp ./mongo.repo /etc/yum.repos.d/mongo.repo | tee -a "$FOLDER/$FILE_NAME.log"
VALIDATE "Adding mongo.repo is" $?

dnf install mongodb-mongosh -y | tee -a "$FOLDER/$FILE_NAME.log"
VALIDATE "Installing mongodb client is" $?

mongosh --host mongodb.vijayaws.fun </app/db/master-data.js | tee -a "$FOLDER/$FILE_NAME.log"
VALIDATE "Connecting the mogodb through mongosh client is" $?

if [ $COUNT -eq 0 ]; then
    COUNT=1
    mongosh --host MONGODB-SERVER-IPADDRESS </app/db/master-data.js | tee -a "$FOLDER/$FILE_NAME.log"
    VALIDATE "Connecting the mogodb through mongosh client is" $?
else
    echo -e "$YELLOW Data to the database was loaded $NORMAL" | tee -a "$FOLDER/$FILE_NAME.log"
fi

echo "=================================================================" | tee -a "$FOLDER/$FILE_NAME.log"
