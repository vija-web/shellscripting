#!/bin/bash

#install nginx , mysql , python3 in the server throgh the script
#we will pass nginx , mysql python3 as the arguments to this script

LOGS_FOLDER="/var/log/shell_logs"
mkdir -p $LOGS_FOLDER
SCRIPT_NAME=$( echo $0 | cut -d "." -f1 )
FILE_NAME="$LOGS_FOLDER/$SCRIPT_NAME.log"
USER_ID=$(id -u)
if [ $USER_ID -ne 0 ]; then
    echo "Run with the root user please"
    exit 1
fi

INSTALLING(){
    echo "Installing $1"
    dnf install $1 -y &>> /var/log/shell_logs/$FILE_NAME
}

INSTALLED_CHECK(){
    dnf list installed $1 -y &>> /var/log/shell_logs/$FILE_NAME
    if [ $? -ne 0 ]; then
        INSTALLING $1
    else 
        echo "Already Installed $1 skipping"
        echo "$FILE_NAME"
    fi
}

INSTALLED_CHECK $1
INSTALLED_CHECK $2
INSTALLED_CHECK $3

