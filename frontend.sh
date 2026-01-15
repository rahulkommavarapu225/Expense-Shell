#!/bin/bash

USERID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[34m"

LOGS_FOLDER="/var/log/expense-logs"
mkdir -p $LOGS_FOLDER
LOG_FILE=$(echo $0 | cut -d "." -f1)
TIMESTAMP=$(date +%y-%m-%d-%H-%M-%S)
LOG_FILE_NAME="$LOGS_FOLDER/LOG-FILE-$TIMESTAMP.log"

VALIDATE() {

    if [ $1 -ne 0 ]
    then
      echo -e "$2.....$R Failure $N"
      exit 1 
    else
       echo -e "$2....$G Success $N"
    fi
}

CHECK_ROOT (){
    if [ $USERID -ne 0 ]
    then
       echo "ERROR :: You Must have sudo access to execute this Script"
       exit 1
    fi
}

echo "Script started executing at: $TIMESTAMP"

CHECK_ROOT

dnf install nginx -y
VALIDATE $? "Installing Nginx-Server"

systemctl enable nginx
VALIDATE $? "Enabling nginx-server"

systemctl restart nginx
VALIDATE $? "restart Nginx"

rm -rf /usr/share/nginx/html*
VALIDATE $? "Removing Exiting Version of code"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip
VALIDATE $? "Downloading latest code"

cd /usr/share/nginx/html
VALIDATE $? "Moving to HTML Directory"

unzip /tmp/frontend.zip
VALIDATE $? "Unzipping the frontend code"

systemctl restart nginx
VALIDATE $? "Restarting nginx"