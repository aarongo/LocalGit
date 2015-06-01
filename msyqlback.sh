#!/bin/sh   
# /install/shell/mysqlback.sh
DB_ADDRESS=172.31.2.230    
DB_USER="root"                                                               
DB_PASS="comall2014"                                                          
DB_NAME="cybershop_test"                                                      
  
 
DATE=`date +%Y_%m_%d`                                               
TwoDAYAgo=`date -d "2 day ago" +%Y_%m_%d`           #删除两天前的备份   
  
BIN_DIR="/usr/bin"  
BCK_DIR="/install/back/mysql"                          
  
  
#删除以前该数据库的备份 
cd $BCK_DIR      
if [ -f $TwoDAYAgo".sql"]; then
	#statements
	echo "Delete Tow day ago mysqldump=========="
	rm -rf $TwoDAYAgo".sql"
fi
#Start MysqlBack   
ssh root@172.31.2.230 "${BIN_DIR}/mysqldump --opt -u${DB_USER} -p${DB_PASS} ${DB_NAME} > ${BCK_DIR}/${DATE}${DB_NAME}.sql"
scp 172.31.2.230:${BCK_DIR}/${DATE}${DB_NAME}.sql /install/backup/mysql/
ssh root@172.31.2.230 "rm -rf ${BCK_DIR}/*"