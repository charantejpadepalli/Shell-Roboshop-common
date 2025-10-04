#/bin/bash

source ./common.sh

check_root

dnf install mysql-server -y &>>$LOG_FILE
VALIDATE $? "Installing Mysql server"

systemctl enable mysqld &>>$LOG_FILE
VALIDATE $? "Enabling Mysql"

systemctl start mysqld &>>$LOG_FILE
VALIDATE $? "Starting Mysql"

mysql_secure_installation --set-root-pass RoboShop@1 &>>$LOG_FILE
VALIDATE $? "Setting Root Password"

print_total_time