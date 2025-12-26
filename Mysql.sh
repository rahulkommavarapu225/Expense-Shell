#!/bin/bash

USERID=$(id-U)

R="\e[31m"
G="\e[32m"
Y="\e[0m"
 
 LOGS_FOLDER="var/log/Expense-shell.logs"
 LOGS_FILE=$(echo$0/cut-d"." -f1)
 TIMESTAMP=$(date +%Y-%m-%H-%M-%S)
 LOG_FILE_NAME="$LOGS_FOLDER/$LOG_FILE-$TIMESTAMP.log"

 VALIDATE(){
       if [$1 -ne 0]
       then
            echo -e "$2 ... $R FAILURE $N"
            exit 1
        else 
           echo -e "$2 ... $G SUCCESS $N"
        fi
 }

 CHECK_ROOT(){
    if [ $USERID -ne 0 ]
    then
         echo "ERROR:: You must have sudo access to execute this script"
        exit 1 #other than 0
   fi
 }

 echo "Script stated executing at: $TIMESTAMP" &>>$LOG_FILE_NAME
 
 CHECK_ROOT

 dnf install mysql-server -y &>>$LOG_FILE_NAME

 VALIDATE $? "Installing mysql server"

 systemctl enable mysqld &>>$LOG_FILE_NAME

 VALIDATE $? "Enabling mysql server"

 systemctl start mysqld &>>$LOG_FILE_NAME

 VALIDATE $? "starting mysql server"

 mysql_secure_installation --set--root--pass ExpenseApp@1

 VALIDATE $? "Setting Root Password"