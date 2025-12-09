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

dnf install maven -y &>> "$FOLDER/$FILE_NAME.log"
VALIDATE "Installing the maven is" $?

id roboshop
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>> "$FOLDER/$FILE_NAME.log" &>> "$FOLDER/$FILE_NAME.log"
    VALIDATE "Adding roboshop user is" $?
else
    echo "User already exits roboshop" | tee -a "$FOLDER/$FILE_NAME.log"
fi

mkdir -p /app &>> "$FOLDER/$FILE_NAME.log"
VALIDATE "Creating the /app directory is" $?

curl -L -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip &>> "$FOLDER/$FILE_NAME.log"
VALIDATE "Downloading the Zip is" $?

chmod 777 /app
VALIDATE "Changing the permissions for /app is" $?

unzip /tmp/shipping.zip /app &>> "$FOLDER/$FILE_NAME.log"
VALIDATE "unzip the zip file in /app directory is" $?

cd /app &>> "$FOLDER/$FILE_NAME.log"
VALIDATE "Changing the /app directory is" $?

mvn clean package &>> "$FOLDER/$FILE_NAME.log"
VALIDATE "maven clean package is" $?

mv target/shipping-1.0.jar shipping.jar &>> "$FOLDER/$FILE_NAME.log"
VALIDATE "Changing the name of the jar file is" $?

cp /home/ec2-user/shellscripting/Shell-Roboshop/shipping.service /etc/systemd/system/shipping.service &>> "$FOLDER/$FILE_NAME.log"
VALIDATE "copying the Shipping.service is" $?

systemctl daemon-reload &>> "$FOLDER/$FILE_NAME.log"
VALIDATE "daemon-reload for Shipping.service is" $?

systemctl enable shipping &>> "$FOLDER/$FILE_NAME.log"
VALIDATE "Enabling the shipping is" $?

systemctl start shipping &>> "$FOLDER/$FILE_NAME.log"
VALIDATE "Starting the shipping is" $?

dnf install mysql -y &>> "$FOLDER/$FILE_NAME.log"
VALIDATE "Installing the mysql is" $?

mysql -h mysql.vijayaws.fun -uroot -pRoboShop@1 < /app/db/schema.sql &>> "$FOLDER/$FILE_NAME.log"
VALIDATE "Adding the schema.sql data in the MysqlDB is" $?

mysql -h mysql.vijayaws.fun -uroot -pRoboShop@1 < /app/db/app-user.sql &>> "$FOLDER/$FILE_NAME.log"
VALIDATE "Adding the app-user.sql data in the MysqlDB is" $?

mysql -h mysql.vijayaws.fun -uroot -pRoboShop@1 < /app/db/master-data.sql &>> "$FOLDER/$FILE_NAME.log"
VALIDATE "Adding the master-data.sql data in the MysqlDB is" $?

systemctl restart shipping &>> "$FOLDER/$FILE_NAME.log"
VALIDATE "Restarting the shipping is" $?

echo "=================================================================" | tee -a "$FOLDER/$FILE_NAME.log"
