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

dnf module disable nodejs -y &>> "$FOLDER/$FILE_NAME.log"
VALIDATE "Disabling nodejs is" $?

dnf module enable nodejs:20 -y &>> "$FOLDER/$FILE_NAME.log"
VALIDATE "Enabling nodejs is" $?

dnf install nodejs -y &>> "$FOLDER/$FILE_NAME.log"
VALIDATE "Installing nodejs is" $?

id roboshop
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>> "$FOLDER/$FILE_NAME.log"
    VALIDATE "Adding roboshop user is" $?
else
    echo "User already exits roboshop" | tee -a "$FOLDER/$FILE_NAME.log"
fi

mkdir -p /app &>> "$FOLDER/$FILE_NAME.log"
VALIDATE "Creating app directory" $? 

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>> "$FOLDER/$FILE_NAME.log"
VALIDATE "Downloading the zip" $? 

cd /app &>> "$FOLDER/$FILE_NAME.log"
VALIDATE "Changed to the /app directory" $?

chmod 777 /app &>> "$FOLDER/$FILE_NAME.log"
VALIDATE "permissions changed to the app directory" $?

if [ -z "$(ls -A /app)" ]; then
    unzip /tmp/catalogue.zip -d /app &>> "$FOLDER/$FILE_NAME.log"
    VALIDATE "Unziping in /app is" $?
else
    echo -e "/app is not empty $YELLOW skipping the unzip $NORMAL" | tee -a "$FOLDER/$FILE_NAME.log"
fi

npm install &>> "$FOLDER/$FILE_NAME.log"
VALIDATE "Installing the dependencies is" $?

cp /home/ec2-user/shellscripting/Shell-Roboshop/catalogue.service /etc/systemd/system/catalogue.service &>> "$FOLDER/$FILE_NAME.log"
VALIDATE "coping the service file is" $?

systemctl daemon-reload &>> "$FOLDER/$FILE_NAME.log"
VALIDATE "daemon-reload is" $?

systemctl enable catalogue &>> "$FOLDER/$FILE_NAME.log"
VALIDATE "Enabling catalogue is" $?

systemctl start catalogue &>> "$FOLDER/$FILE_NAME.log"
VALIDATE "Starting catalogue is" $?

cp /home/ec2-user/shellscripting/Shell-Roboshop/mongo.repo /etc/yum.repos.d/mongo.repo &>> "$FOLDER/$FILE_NAME.log"
VALIDATE "Adding mongo.repo is" $?

dnf install mongodb-mongosh -y &>> "$FOLDER/$FILE_NAME.log"
VALIDATE "Installing mongodb client is" $?

mongosh --host mongodb.vijayaws.fun </app/db/master-data.js &>> "$FOLDER/$FILE_NAME.log"
VALIDATE "Connecting the mogodb through mongosh client is" $?

if [ $COUNT -eq 0 ]; then
    COUNT=1
    mongosh --host mongodb.vijayaws.sh </app/db/master-data.js &>> "$FOLDER/$FILE_NAME.log"
    VALIDATE "Loaded the data in to the mongodb" $?
else
    echo -e "$YELLOW Data to the database was loaded $NORMAL" | tee -a "$FOLDER/$FILE_NAME.log"
fi

echo "=================================================================" | tee -a "$FOLDER/$FILE_NAME.log"
