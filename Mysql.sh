#!/bin/bash

USERID=$(id -u)
#Colours
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[34m"

LOGS_FOLDER= "/var/log/expense-logs"
LOG_FILE=$(echo $0 |cut -d "." -f1)
TIMESTAMP=$(date +%y-%m-%d-%H-%M-%S)
LOG_FILE_NAME="$LOGS_FOLDER/$LOG_FILE-$TIMESTAMP.log" 

#VAlidate the Script of Mysqld
VALIDATE (){
   if [ $1 -ne 0 ] 
    then
       echo -e "$2......$R FAILURE $N"
       exit1
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

echo "Script started executing at:$TIMESTAMP" & >>$LOG_FILE_NAME

dnf install mysql-server -y 
VALIDATE $? "Installing mysql server"

systemctl enable mysqld 
VALIDATE $? "Enabling the Mysql-server"

systemctl start mysqld 
VALIDATE $? "Starting Mysql-server"

# setting root-Password
mysql_secure_installation  ---set--root---pass ExpenseAPP@1
VALIDATE $? "setting root password"
 

 mysql -h mysql.practice25.online -u root -pExpenseApp@1 -e "show databases;"

 if [ $? -ne 0 ]
  then
   echo "Mysql root Password not setup " &>>$LOG_FILE_NAME
   mysql_secure_installation --set--root--pass ExpenseAPP@1
   VALIDATE $? "Setting Root Password"
  else
   echo -e "Mysql root Password already setup.....SKIPPING"
  fi  