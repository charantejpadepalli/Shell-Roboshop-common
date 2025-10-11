#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGS_FOLDER="/var/log/shell-roboshop"
SCRIPT_NAME=$( echo $0 | cut -d "." -f1 )
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"
START_TIME=$(date +%s)
SCRIPT_DIR=$PWD
MONGODB_HOST=mongodb.devopspractice.shop
MYSQL_HOST=mysql.devopspractice.shop
mkdir -p $LOGS_FOLDER
echo "Script started executed at:$(date)" | tee -a $LOG_FILE

check_root(){
    if [ $USERID -ne 0 ]; then
        echo "ERROR:: Please run this script with root user"
        exit 1 #failure is other than 0
    fi
}

VALIDATE(){
    if [ $1 -ne 0 ]; then
        echo -e "$2... $R failure $N" | tee -a $LOG_FILE
        exit 1 
    else
        echo -e "$2...$G success $N" | tee -a $LOG_FILE
    fi
}

nodejs_setup(){
    dnf module disable nodejs -y &>>$LOG_FILE
    VALIDATE $? "Disabling NodeJS"
    dnf module enable nodejs:20 -y &>>$LOG_FILE
    VALIDATE $? "Enabling NodeJS:20"
    dnf install nodejs -y &>>$LOG_FILE
    VALIDATE $? "Installing NodeJS"
}
java_setup(){
    dnf install maven -y &>>$LOG_FILE
    VALIDATE $? "Installing Maven"
    mvn clean package &>>$LOG_FILE
    VALIDATE $? "Installing Dependencies"
    mv target/shipping-1.0.jar shipping.jar &>>$LOG_FILE
    VALIDATE $? "moving shipping service"
}

python_setup(){
    dnf install python3 gcc python3-devel -y &>>$LOG_FILE
    VALIDATE $? "Installing Python3"
    pip3 install -r requirements.txt &>>$LOG_FILE
    VALIDATE $? "Installing dependencies"
}

app_setup(){
    id roboshop &>>$LOG_FILE
    if [ $? -ne 0 ]; then
        useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
        VALIDATE $? "Creating System User"
    else
        echo -e "User already exist... $Y SKIPPING $N"
    fi
    mkdir -p /app 
    VALIDATE $? "Creating Directory" 
    curl -o /tmp/$app_name.zip https://roboshop-artifacts.s3.amazonaws.com/$app_name-v3.zip &>>$LOG_FILE
    VALIDATE $? "Downloading code"
    cd /app 
    VALIDATE $? "Changing to app directory"
    rm -rf /app/*
    VALIDATE $? "Removing Existing Code"
    unzip /tmp/$app_name.zip &>>$LOG_FILE
    VALIDATE $? "Unzipping Code"
    npm install &>>$LOG_FILE
    VALIDATE $? "Installing Dependencies"
}

systemd_setup(){
    cp $SCRIPT_DIR/$app_name.service /etc/systemd/system/$app_name.service &>>$LOG_FILE
    VALIDATE $? "Copying $app_name service"
    systemctl daemon-reload 
    systemctl enable $app_name &>>$LOG_FILE
    VALIDATE $? "Enable $app_name"
    systemctl start $app_name &>>$LOG_FILE
    VALIDATE $? "Start $app_name"
}

app_restart(){
    systemctl restart $app_name
    VALIDATE $? "Restarting $app_name" 
}

print_total_time(){
    END_TIME=$(date +%s)
    TOTAL_TIME=$(( $END_TIME - $START_TIME ))
    echo -e "Script executed in: $Y $TOTAL_TIME Seconds $N"
}

