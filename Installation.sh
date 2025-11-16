#!/bin/bash

#install nginx , mysql , python3 in the server throgh the script
#we will pass nginx , mysql python3 as the arguments to this script

USER_ID=$(id -u)
if [ $USER_ID -ne 0 ]; then
    echo "Run with the root user please"
    exit 1
fi

INSTALLING(){
    echo "Installing $1"
    dnf install $1 -y
}

INSTALLED_CHECK(){
    dnf list installed $1 -y
    if [ $? -ne 0 ]; then
        INSTALLING $1
    else 
        echo "Already Installed $1 skipping"
    fi
}

INSTALLED_CHECK $1
INSTALLED_CHECK $2
INSTALLED_CHECK $3

