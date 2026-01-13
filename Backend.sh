
#!/bin/bash

USERID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[34m"

LOGS_FOLDER= " var/log/expense-logs"
LOG_FILE=$(echo $0 | cut-d "." -f1)
TIMESTAMP=$(date +%y-%m-%d-%H-%M-%S)
LOG_FILE_NAME="$LOGS_FOLDER/$LOG_FILE-$TIMESTAMP.log"


VALIDATE(){
    if [ $1 -ne 0 ]
    then
     echo -e "$2......$R FAILURE $N"
     exit 1
    else
     echo -e "$2....$G Success $N"
    fi 
}

CHECK_ROOT(){
    if [ USERID -ne 0 ]
    then
      echo "ERROR:: you must have sudo access to execute this Script"
      exit 1
    fi
}

echo "Script Started executing at :$TIMESTAMP "

dnf module disable nodejs -y &>>$LOG_FILE_NAME
VALIDATE $? "Disabling existing default Nodejs"

dnf module Enable nodejs:20 -y &>>$LOG_FILE_NAME
VALIDATE $? "Enableing Nodejs:20"

dnf install nodejs -y &>>$LOG_FILE_NAME
VALIDATE $? "Installig nodejs"

Useradd Expense &>>$LOG_FILE_NAME
VALIDATE $? "Adding/Creating Expense User"

mkdir /app &>>$LOG_FILE_NAME
VALIDATE $? "Creating app Directory"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip & >>$LOG_FILE_NAME
VALIDATE $? "Downloading Backend"

cd /app  #Change the App Directory

unzip /tmp/backend.zip &>>$LOG_FILE_NAME
VALIDATE $? "Unzip Backend"

npm install &>>$LOG_FILE_NAME
VALIDATE $? "Installing Dependencies"

cp /home/ec2-user/Expense-Shell/backend.service/etc/systemd/system/backend.service
#Prepare Mysql Schema

dnf install mysql -y &>>$LOG_FILE_NAME
VALIDATE $? "Installing Mysql Client"

Mysql -h mysql.practice25.online -uroot -pExpenseApp@1 < /app/schema/backend.sqlVALIDATE $? "Setting up the Transactions schema and Tables"&>>$LOG_FILE_NAME
VALIDATE $? "Setting up the Trasactions schema and Tables "

systemctl daemon-reload &>>$LOG_FILE_NAME
VALIDATE $? "Daemon-reload"

systemctl enable backend &>>$LOG_FILE_NAME
VALIDATE $? "Enabling Backend"

systemctl start backend &>>$LOG_FILE_NAME
VALIDATE $? "Starting Backend"