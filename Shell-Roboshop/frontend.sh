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

dnf module disable nginx -y &>> "$FOLDER/$FILE_NAME.log"
VALIDATE "Disabling nginx is" $?

dnf module enable nginx:1.24 -y &>> "$FOLDER/$FILE_NAME.log"
VALIDATE "Enabling nginx is" $?

dnf install nginx -y &>> "$FOLDER/$FILE_NAME.log"
VALIDATE "Installing nginx is" $?

systemctl enable nginx &>> "$FOLDER/$FILE_NAME.log"
VALIDATE "Enabling nginxis" $?

systemctl start nginx &>> "$FOLDER/$FILE_NAME.log"
VALIDATE "Starting nginx is" $?

rm -rf /usr/share/nginx/html/* &>> "$FOLDER/$FILE_NAME.log"
VALIDATE "Removinf files in html folder" $?

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>> "$FOLDER/$FILE_NAME.log"
VALIDATE "Downloading the zip file is" $?

unzip /tmp/frontend.zip -d /usr/share/nginx/html &>> "$FOLDER/$FILE_NAME.log"
VALIDATE "Unziping the file is" $?

chmod 777 /etc/nginx &>> "$FOLDER/$FILE_NAME.log"
VALIDATE "Changing the file permissions of nginx folder is" $?

rm -r /etc/nginx/nginx.conf &>> "$FOLDER/$FILE_NAME.log"
VALIDATE "removing the nginx.conf file is" $?

cp ./nginx.conf /etc/nginx/nginx.conf &>> "$FOLDER/$FILE_NAME.log"
VALIDATE "coping the nginx.conf in /etc/nginx/nginx.conf is" $?

systemctl restart nginx &>> "$FOLDER/$FILE_NAME.log"
VALIDATE "Restarting the nginx" $?

echo "=================================================================" | tee -a "$FOLDER/$FILE_NAME.log"
