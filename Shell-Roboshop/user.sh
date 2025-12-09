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
VALIDATE "Enabling nodejs 20 is" $?

dnf install nodejs -y &>> "$FOLDER/$FILE_NAME.log"
VALIDATE "Installing nodejs 20 is" $?

useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>> "$FOLDER/$FILE_NAME.log"
VALIDATE "Adding user roboshop is" $?

mkdir /app &>> "$FOLDER/$FILE_NAME.log"
VALIDATE "Creating /app directory is" $?

curl -L -o /tmp/user.zip https://roboshop-artifacts.s3.amazonaws.com/user-v3.zip &>> "$FOLDER/$FILE_NAME.log"
VALIDATE "Downloading zip file is" $?

cd /app &>> "$FOLDER/$FILE_NAME.log"
VALIDATE "Changing directory is" $?

unzip /tmp/user.zip -d /app &>> "$FOLDER/$FILE_NAME.log"
VALIDATE "unziping the file is" $?

npm install &>> "$FOLDER/$FILE_NAME.log"
VALIDATE "Installing the dependencies is" $?

cp ./user.service /etc/systemd/system/user.service &>> "$FOLDER/$FILE_NAME.log"
VALIDATE "coping the user.service file is" $?

systemctl daemon-reload &>> "$FOLDER/$FILE_NAME.log"
VALIDATE "daemon-reload is" $?

systemctl enable user &>> "$FOLDER/$FILE_NAME.log"
VALIDATE "Enabling the user is" $?

systemctl start user &>> "$FOLDER/$FILE_NAME.log"
VALIDATE "Starting the user is" $?