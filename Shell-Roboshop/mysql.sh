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

dnf install mysql-server -y &>> "$FOLDER/$FILE_NAME.log"
VALIDATE "Installing the mysql latest is" $?

systemctl enable mysqld &>> "$FOLDER/$FILE_NAME.log"
VALIDATE "Enabling the mysql is" $?

systemctl start mysqld &>> "$FOLDER/$FILE_NAME.log"
VALIDATE "Starting the mysql is" $?

mysql_secure_installation --set-root-pass RoboShop@1 &>> "$FOLDER/$FILE_NAME.log"
VALIDATE "Setting the username and password for mysql is" $?

echo "=================================================================" | tee -a "$FOLDER/$FILE_NAME.log"
