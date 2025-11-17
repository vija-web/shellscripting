#!/bin/bash

#install nginx , mysql , python3 in the server throgh the script
#we will pass nginx , mysql python3 as the arguments to this script

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGS_FOLDER="/var/log/shell_logs"
mkdir -p $LOGS_FOLDER
SCRIPT_NAME=$( echo $0 | cut -d "." -f1 )
FILE_NAME="$LOGS_FOLDER/$SCRIPT_NAME.log"
USER_ID=$(id -u)

if [ $USER_ID -ne 0 ]; then
    echo -e "Run with the $R ROOT $N user please"
    exit 1
fi

INSTALLING(){
    echo -e "$G Installing $1 $N"
    dnf install $1 -y &>> $FILE_NAME
    if [ $? -ne 0 ]; then
        echo -e "Installing $1 is $R FAILURE $N"
    else
        echo -e "Installing $1 is $G SUCCESS $N"
    fi
}

INSTALLED_CHECK(){
    dnf list installed $1 -y &>> $FILE_NAME
    if [ $? -ne 0 ]; then
        INSTALLING $1
    else 
        echo -e "Already Installed $1 So... $Y SKIPPING $N"
    fi
}

INSTALLED_CHECK $1
INSTALLED_CHECK $2
INSTALLED_CHECK $3

