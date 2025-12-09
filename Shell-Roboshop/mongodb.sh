#!/bin/bash

RED="\033[31m"
GREEN="\033[1;32m"
YELLOW="\033[4;33m"
NORMAL="\033[0m"

UIDD=$(echo $UID)
if [ "$UIDD" -ne 0 ]; then
    echo -e "Run with $RED ROOT USER $NORMAL"
    exit 1
fi

FOLDER="/var/log/shell-logs"
mkdir -p "$FOLDER"
chmod 777 /var/log/shell-logs

SCRIPT_NAME=$0
FILE_NAME=$(echo "$SCRIPT_NAME" | cut -d "." -f1)

touch $FOLDER/$FILE_NAME.log

VALIDATE(){
    if [ $2 -eq 0 ]; then
        echo -e "$1 .... $GREEN SUCCESS $NORMAL" | tee -a "$FOLDER/$FILE_NAME.log"

    else
        echo -e "$1 ... $RED FAILURE $NORMAL" | tee -a "$FOLDER/$FILE_NAME.log"
        exit 1
    fi
}

cp ./mongo.repo /etc/yum.repos.d/mongo.repo | tee -a "$FOLDER/$FILE_NAME.log"
VALIDATE "Adding repo is" $?

dnf install mongodb-org -y | tee -a "$FOLDER/$FILE_NAME.log"
VALIDATE "Installing Mongodb is" $?

systemctl enable mongod | tee -a "$FOLDER/$FILE_NAME.log"
VALIDATE "Enabling Mongodb is" $?

systemctl start mongod | tee -a "$FOLDER/$FILE_NAME.log"
VALIDATE "Starting Mongodb is" $?

sed -i -e 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf | tee -a "$FOLDER/$FILE_NAME.log"
VALIDATE "Exposed to all IP is" $?

systemctl restart mongod | tee -a "$FOLDER/$FILE_NAME.log"
VALIDATE "Restarted Mongodb is" $?

echo "=================================================" | tee -a "$FOLDER/$FILE_NAME.log"