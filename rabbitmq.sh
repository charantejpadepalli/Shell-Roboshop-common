#/bin/bash

source ./common.sh

check_root

cp $SCRIPT_DIR/rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo

dnf install rabbitmq-server -y &>>$LOG_FILE
VALIDATE $? "Installing rabbitmq server"

systemctl enable rabbitmq-server &>>$LOG_FILE
VALIDATE $? "Enabling rabbitmq server"

systemctl start rabbitmq-server &>>$LOG_FILE
VALIDATE $? "Starting rabbitmq server"

rabbitmqctl add_user -s roboshop roboshop123 &>>$LOG_FILE
VALIDATE $? "Adding System User"

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>$LOG_FILE
VALIDATE $? "Setting Root Permissions"

print_total_time