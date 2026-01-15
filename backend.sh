#!/bin/bash

USERID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGS_FOLDER="/var/log/expense-logs"
LOG_FILE=$(basename $0 | cut -d "." -f1)
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOG_FILE_NAME="$LOGS_FOLDER/$LOG_FILE-$TIMESTAMP.log"

mkdir -p $LOGS_FOLDER

VALIDATE () {
  if [ $1 -ne 0 ]; then
    echo -e "$2 ...... $R FAILURE $N"
    exit 1
  else
    echo -e "$2 ...... $G SUCCESS $N"
  fi
}

CHECK_ROOT () {
  if [ $USERID -ne 0 ]; then
    echo "ERROR:: Run this script as root"
    exit 1
  fi
}

echo "Script started at $TIMESTAMP" &>>$LOG_FILE_NAME

CHECK_ROOT

# NodeJS (safe even if already installed)
dnf module disable nodejs -y &>>$LOG_FILE_NAME
dnf module enable nodejs:20 -y &>>$LOG_FILE_NAME
dnf install nodejs -y &>>$LOG_FILE_NAME
VALIDATE $? "NodeJS setup"

# Expense user (idempotent)
id expense &>/dev/null || useradd expense
VALIDATE $? "Expense user check/create"

# App directory (idempotent)
mkdir -p /app
VALIDATE $? "App directory check/create"

# Download backend
curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend=v2.zip &>>$LOG_FILE_NAME
VALIDATE $? "Backend download"

# Unzip backend (overwrite safe)
cd /app
unzip -o /tmp/backend.zip &>>$LOG_FILE_NAME
VALIDATE $? "Backend unzip"

# Permissions + npm install (critical for idempotency)
chown -R expense:expense /app
su - expense -c "cd /app && npm install" &>>$LOG_FILE_NAME
VALIDATE $? "NPM install"

# Backend service (overwrite safe)
cp -f /home/ec2-user/Expense-Shell/backend/backend.service /etc/systemd/system/backend.service
VALIDATE $? "Backend service copy"

# MySQL client
dnf install mysql -y &>>$LOG_FILE_NAME
VALIDATE $? "MySQL client install"

# DB schema (SQL must use IF NOT EXISTS)
mysql -h mysql.practice25.online -uroot -p < /app/schema/backend.sql &>>$LOG_FILE_NAME
VALIDATE $? "DB schema setup"

# systemd (safe on re-run)
systemctl daemon-reload &>>$LOG_FILE_NAME
systemctl enable backend &>>$LOG_FILE_NAME
systemctl restart backend &>>$LOG_FILE_NAME
VALIDATE $? "Backend service restart"

echo -e "$G Script completed successfully $N"
