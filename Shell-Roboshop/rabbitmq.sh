#!/bin/bash

set -e

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

cp ./rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo &>> "$FOLDER/$FILE_NAME.log"
VALIDATE "Adding the rabbitmq repo is" $?

dnf install rabbitmq-server -y &>> "$FOLDER/$FILE_NAME.log"
VALIDATE "Installing the rabbitmq-server is" $?

systemctl enable rabbitmq-server &>> "$FOLDER/$FILE_NAME.log"
VALIDATE "Enabling the rabbitmq-server is" $?

systemctl start rabbitmq-server &>> "$FOLDER/$FILE_NAME.log"
VALIDATE "Starting the rabbitmq-server is" $?

rabbitmqctl add_user roboshop roboshop123 &>> "$FOLDER/$FILE_NAME.log"
VALIDATE "Adding the user for rabbitmq-server is" $?

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>> "$FOLDER/$FILE_NAME.log"
VALIDATE "Seting permisssions for the user for rabbitmq-server is" $?

echo "=================================================================" | tee -a "$FOLDER/$FILE_NAME.log"
