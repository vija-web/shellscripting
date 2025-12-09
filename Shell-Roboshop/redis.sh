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


dnf module disable redis -y &>> "$FOLDER/$FILE_NAME.log"
VALIDATE "Disabling redis is" $?

dnf module enable redis:7 -y &>> "$FOLDER/$FILE_NAME.log"
VALIDATE "Enabling redis is" $?

dnf install redis -y &>> "$FOLDER/$FILE_NAME.log"
VALIDATE "Installing redis is" $?

chmod 777 /etc/redis/redis.conf &>> "$FOLDER/$FILE_NAME.log"
VALIDATE "Chnaging permission to redis.conf is" $?

sed -i -e 's/127.0.0.1/0.0.0.0/' -e 's/protected-mode yes/protected-mode no/' /etc/redis/redis.conf &>> "$FOLDER/$FILE_NAME.log"
VALIDATE "Modified redis.conf for 0.0.0.0" $?

systemctl enable redis &>> "$FOLDER/$FILE_NAME.log"
VALIDATE "Enablinging redis is" $?

systemctl start redis &>> "$FOLDER/$FILE_NAME.log"
VALIDATE "Starting redis is" $? 

echo "=================================================" | tee -a "$FOLDER/$FILE_NAME.log"
