#/bin/bash

source ./common.sh
app_name=redis
check_root

dnf module disable $app_name -y &>>$LOG_FILE
VALIDATE $? "Disabling $app_name"

dnf module enable $app_name:7 -y &>>$LOG_FILE
VALIDATE $? "Enabling $app_name:7"

dnf install $app_name -y &>>$LOG_FILE
VALIDATE $? "Installing $app_name"

sed -i -e 's/127.0.0.1/0.0.0.0' -e '/protected-mode/ c protected-mode no' /etc/$app_name/$app_name.conf &>>$LOG_FILE
VALIDATE $? "Allowing remote connection to $app_name"

systemctl enable $app_name &>>$LOG_FILE
VALIDATE $? "Enabling $app_name"

systemctl start $app_name &>>$LOG_FILE
VALIDATE $? "Starting $app_name"
 
print_total_time