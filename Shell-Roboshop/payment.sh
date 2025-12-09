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

dnf install python3 gcc python3-devel -y &>> "$FOLDER/$FILE_NAME.log"
VALIDATE "Installing the Python3 is" $?

id roboshop &>> "$FOLDER/$FILE_NAME.log"
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>> "$FOLDER/$FILE_NAME.log"
    VALIDATE "Adding roboshop user is" $?
else
    echo -e "User already exits roboshop ... $YELLOW SKIPPING $NORMAL" | tee -a "$FOLDER/$FILE_NAME.log"
fi

mkdir -p /app &>> "$FOLDER/$FILE_NAME.log"
VALIDATE "Creating the /app directory is" $?

curl -L -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip &>> "$FOLDER/$FILE_NAME.log"
VALIDATE "Downloading the payment.zip file is" $?

unzip /tmp/payment.zip -d /app &>> "$FOLDER/$FILE_NAME.log"
VALIDATE "unziping the file in /app directory is" $?

cd /app &>> "$FOLDER/$FILE_NAME.log" 
VALIDATE "Changing the directory to /app is" $?

pip3 install -r requirements.txt &>> "$FOLDER/$FILE_NAME.log"
VALIDATE "Installing the dependencies is" $?

cp /home/ec2-user/shellscripting/Shell-Roboshop/payment.service /etc/systemd/system/payment.service &>> "$FOLDER/$FILE_NAME.log"
VALIDATE "Adding the payment.service is" $?

systemctl daemon-reload &>> "$FOLDER/$FILE_NAME.log"
VALIDATE "Daemon-reload is" $?

systemctl enable payment &>> "$FOLDER/$FILE_NAME.log"
VALIDATE "Enabling the payment is" $?

systemctl start payment &>> "$FOLDER/$FILE_NAME.log"
VALIDATE "Starting the payment is" $?

echo "=================================================================" | tee -a "$FOLDER/$FILE_NAME.log"
