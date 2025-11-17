#!/bin/bash

#install nginx , mysql , python3 in the server throgh the script
#Executing the script with the root user 
#we will pass nginx  mysql python3 as the arguments to this script

R="\e[31m" # colors for the better visual RED
G="\e[32m" # Green
Y="\e[33m" # Yellow
N="\e[0m" # Normal color (white)

LOGS_FOLDER="/var/log/shell_logs"
mkdir -p $LOGS_FOLDER
SCRIPT_NAME=$( echo $0 | cut -d "." -f1 )
FILE_NAME="$LOGS_FOLDER/$SCRIPT_NAME.log"
USER_ID=$(id -u)

echo -e "Script started executed at $G $(date) $N" | tee -a $FILE_NAME

if [ $USER_ID -ne 0 ]; then
    echo -e "Run with the $R ROOT $N user please" | tee -a $FILE_NAME
    exit 1 #exiting fromt he script
fi

INSTALLING(){
    echo -e "$G Installing $1 $N"
    dnf install $1 -y &>> $FILE_NAME
    if [ $? -ne 0 ]; then
        echo -e "Installing $1 is $R FAILURE $N" | tee -a $FILE_NAME
    else
        echo -e "Installing $1 is $G SUCCESS $N" | tee -a $FILE_NAME
    fi
}

INSTALLED_CHECK(){
    dnf list installed $1 -y &>> $FILE_NAME
    if [ $? -ne 0 ]; then
        INSTALLING $1
    else 
        echo -e "Already Installed $1 So... $Y SKIPPING $N" | tee -a $FILE_NAME
    fi
}

INSTALLED_CHECK $1
INSTALLED_CHECK $2
INSTALLED_CHECK $3

