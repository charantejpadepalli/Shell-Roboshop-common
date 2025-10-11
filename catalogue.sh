#!/bin/bash

source ./common.sh
app_name=catalogue

check_root
app_setup
nodejs_setup
systemd_setup

cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo &>>$LOG_FILE
VALIDATE $? "Copy MongoDB repo"

dnf install mongodb-mongosh -y &>>$LOG_FILE
VALIDATE $? "Install mongoDB client"

INDEX=$(mongosh mongodb.devopspractice.shop --quiet --eval "db.getMongo().getDBNames().indexOf('catalogue')")
if [ $INDEX -le 0 ]; then
    mongosh --host $MONGODB_HOST </app/db/master-data.js &>>$LOG_FILE
    VALIDATE $? "Load $app_name products"
else
    echo -e "$app_name Products already loaded... $Y SKIPPING $N"

app_restart
print_total_time