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

dnf module disable nodejs -y
VALIDATE "Disabling nodejs is" $?

dnf module enable nodejs:20 -y
VALIDATE "Enabling nodejs 20 is" $?

dnf install nodejs -y
VALIDATE "Installing nodejs is" $?

id roboshop
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop 
    VALIDATE "Adding roboshop user is" $?
else
    echo "User already exits roboshop" | tee -a "$FOLDER/$FILE_NAME.log"
fi

mkdir -p /app 
VALIDATE "Creating /app directory is" $?

chmod 777 /app
VALIDATE "Changing permissions to /app is" $?

curl -o /tmp/cart.zip https://roboshop-artifacts.s3.amazonaws.com/cart-v3.zip
VALIDATE "Downloading the zip file is" $?

cd /app
VALIDATE "Changing the /app directory" $?

unzip /tmp/cart.zip -d /app
VALIDATE "Unziping in /app is" $?

npm install 
VALIDATE "Installing the dependencies is" $?

cp ./cart.service /etc/systemd/system/cart.service
VALIDATE "Coping the cart.service file is" $?

systemctl daemon-reload
VALIDATE "daemon-reload is" $?

systemctl enable cart 
VALIDATE "Enabling cart is" $?

systemctl start cart
VALIDATE "Starting cart is" $?
