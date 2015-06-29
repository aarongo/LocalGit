#!/bin/bash
#------------------------------------------------------
#For Usvn crod back use scp copy to 172.31.1.160
# Name:         USVN自动备份脚本
# Purpose:      此脚本scp本地USVN数据到远程
# Version:      1.0
# Founder       LonnyLiu
#USVN_IPADDRESS=172.31.0.252
#Remotely_IPADDRS=172.31.1.160
#------------------------------------------------------
DATE=`date "+%Y-%m-%d-%H"`
REMOTELY_IPADDRS=172.31.1.160
USVN_FILE=/software/usvn/files
BACK_DIRECTORY=/install/backup/usvnback/

#创建存放Usvn文件目录
ssh root@$REMOTELY_IPADDRS "cd $BACK_DIRECTORY && mkdir $DATE"
#copy USVNfiels to back server
scp -r $USVN_FILE $REMOTELY_IPADDRS:$BACK_DIRECTORY/$DATE  2>&1 > /dev/null
if [ $? -eq 0 ]; then
    #statements
        echo -e "\033[32m  Command Sueccful \033[0m"
        rm -rf ./pro$DATE-$SVN_NUMBER
    else
        echo -e "\033[32m  Command Fail \033[0m"
fi