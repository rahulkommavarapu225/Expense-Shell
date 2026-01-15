#!/bin/bash

USERID=$(id -u)
#Colours
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[34m"

LOGS_FOLDER="/var/log/expense-logs"
LOG_FILE=$(echo $0 |cut -d "." -f1)
TIMESTAMP=$(date +%y-%m-%d-%H-%M-%S)
LOG_FILE_NAME="$LOGS_FOLDER/$LOG_FILE-$TIMESTAMP.log" 

#Validate the Script of Mysqld
VALIDATE (){
   if [ $1 -ne 0 ] 
    then
       echo -e "$2......$R FAILURE $N"
       exit 1
     else
      echo -e "$2......$G SUCCESS $N"
    fi
}
# Check the Root access
CHECK_ROOT (){   
  if [ $USERID -ne 0 ]
   then
   echo "ERROR:: you must have Access to execute this script"
   exit 1
   else
    echo "Continue the script"
  fi
     }

echo "Script started executing at:$TIMESTAMP" &>>$LOG_FILE_NAME
  
CHECK_ROOT

dnf install mysql-server -y  &>>$LOG_FILE_NAME
VALIDATE $? "Installing mysql server"

systemctl enable mysqld &>>$LOG_FILE_NAME
VALIDATE $? "Enabling the Mysql-server"

systemctl start mysqld  &>>$LOG_FILE_NAME
VALIDATE $? "Starting Mysql-server"

mysql -h mysql.practice25.online -u root -p'ExpenseApp@1' -e 'show databases;' >> $LOG_FILE_NAME 2>&1


if [ $? -ne 0 ]
then
   echo "Mysql Root password not setup" 
   mysql_secure_installation --set-root-pass ExpenseApp@1 &>>$LOG_FILE_NAME
   VALIDATE $? "Setting Root Password"   
else
  echo -e "Mysql Root Password already setup.....$Y SKIPPING $G"
fi   
 

 
