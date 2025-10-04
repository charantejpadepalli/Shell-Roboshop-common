#/bin/bash

source ./common.sh

check_root

cp mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "Adding Mongo repo"

dnf install mongodb-org -y &>>$LOG_FILE
VALIDATE $? "Installing Mongodb"

systemctl enable mongod &>>$LOG_FILE
VALIDATE $? "Enable mongoDB"

systemctl start mongod &>>$LOG_FILE
VALIDATE $? "Start mongoDB"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongo.conf
VALIDATE $? "Allowing remote connections to MongoDB"

systemctl restart mongod
VALIDATE $? "Restarted MongoDB"

print_total_time

#create new repository in git shell-roboshop-common