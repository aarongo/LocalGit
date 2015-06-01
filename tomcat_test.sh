#!/bin/bash
#Tomcat deploy JLF　for Linux 
svn_co=/install/cybershop-pro/
svn_co_test=/install/carrefour-test/
#svn_co_api=/install/trunk/
MAVEN_HOME=/install/maven
WEB=/install/cybershop-pro/cybershop-web/target
FRONT=/install/cybershop-pro/cybershop-front/target
TEST_WEB=/install/carrefour-test/cybershop-web/target
TEST_FRONT=/install/carrefour-test/cybershop-front/target
DEV_API_D=/install/trunk/cybershop-api/target
DEPLOY_FRONT_DIR=/install/unzip/cybershop-front-0.0.1-SNAPSHOT
DEPLOY_WEB_DIR=/install/unzip/cybershop-web-0.0.1-SNAPSHOT
WEB_IPADDRS=172.31.1.200
TEST_WEB_IPADDRS=172.31.1.100
FRONT_IPADDRS=172.31.1.201
TEST_FRONT_IPADDRS=172.31.1.101
DEV_API=172.31.2.250
DATE=`date "+%Y-%m-%d-%H:%M"`
#This  172.31.1.206
MYSQL_IPADDRS=172.31.1.206
MYSQL_BACK=/install/backup/mysql
MYSQL_BASH=/usr/local/mysql-5.5.21/bin/mysqldump


#backup
back(){
	cp -rf /install/upload/ /install/backup/$DATE
	echo "Images Back Successful"
}
#back_test(){
#	cp -rf /install/test/upload /install/backup/test$DATE
#	echo "Images test upload Successful"
#}
#mysql(){
#        echo "MysqlDump  /install/back/mysql"
#        ssh root@$MYSQL_IPADDRS "$MYSQL_BASH --all-databases --lock-all-tables --routines --triggers --events --flush-logs > $MYSQL_BACK/$DATE.sql"
#        if [ $? -ne 0 ];then
#                echo "MYsqldump fail"
#                exit 1
#        fi
#}
#svn_api
svn_api(){
	svn update -r $SVN_NUMBER $svn_co_api
}


#svn_pro
svn_web(){
	svn update -r $SVN_NUMBER $svn_co
}
#SVN_TEST
svn_test(){
	svn update -r $SVN_NUMBER $svn_co_test
}
#maven_pro
maven_web(){
	cd $svn_co
	$MAVEN_HOME/bin/mvn clean install  -Ppro -DskipTests
	if [ $? -ne 0 ];then
		echo -en "\\033[1;33m"
		echo "Maven Fail"
		echo -en "\\033[1;39m"
		exit 1
	fi
}
#maven_test
maven_test(){
	cd $svn_co_test
	$MAVEN_HOME/bin/mvn clean install -Ptest -DskipTests 
	if [ $? -ne 0 ];then
		echo -en "\\033[1;33m"
		echo "Maven Fail"
		echo -en "\\033[1;39m"
		exit 1
	fi
}
#maven_api
maven_api(){
	cd $svn_co_api 
	$MAVEN_HOME/bin/mvn clean install -Pdev -DskipTests
	if [ $? -ne 0 ];then
                echo -en "\\033[1;33m"
                echo "Maven Fail"
                echo -en "\\033[1;39m"
                exit 1
        fi
}
#maven_api_deletem
maven_delet_api(){
	rm -rf /install/trunk/cybershop-api/target/
	echo -en "\\033[1;33m"
        echo "Delet cybersho_api  targe successful"
        echo -en "\\033[1;39m"
}

#Delet tmp_pro targe
maven_tmp(){
	rm -rf /install/cybershop-coamll/cybershop-web/target/
	rm -rf /install/cybershop-coamll/cybershop-front/target/
	echo -en "\\033[1;33m"
	echo "Delet tmp_pro targe successful"
	echo -en "\\033[1;39m"
}
#Delet tmp_test targe
maven_tmptest(){
	rm -rf /install/carrefour-test/cybershop-web/target/
	rm -rf /install/carrefour-test/cybershop-front/target/
	echo -en "\\033[1;33m"
	echo "Delet tmp_test targe successful"
	echo -en "\\033[1;39m"
}
#deploy dev_api
deploy_api(){
	echo -en "\\033[1;32m"
        echo "File Name: cybershop-api-0.0.1-SNAPSHOT.war"
	ssh root@$DEV_API "/root/tomcat.sh stop"
        ssh root@$DEV_API "/root/tomcat.sh delet"
	scp $DEV_API_D/*.war $DEV_API:/install/deploy/
	ssh root@$WEB_IPADDRS "/root/tomcat.sh start"
	echo $DATE "wait 60S"
	sleep 30
	if [ $? -eq 0 ];then
                echo "#################SCP and deploy comall-api(172.31.2.250) successful#######################" 
        fi


}
#deploy pro
deploy_web(){
	echo -en "\\033[1;32m"
	echo "File Name: cybershop-web-0.0.1-SNAPSHOT.war"
	ssh root@$WEB_IPADDRS "/root/tomcat.sh stop"
	ssh root@$WEB_IPADDRS "/root/tomcat.sh delet"
	scp $WEB/*.war $WEB_IPADDRS:/install/deploy/
	ssh root@$WEB_IPADDRS "/root/tomcat.sh start"
	echo $DATE "wait 60S"
	sleep 30
	ssh root@$WEB_IPADDRS "/root/tomcat.sh mount"
	if [ $? -eq 0 ];then
		echo "#################SCP and deploy comall-web-node1(172.31.1.200) successful#######################" 
	fi	
}
deploy_front(){
	echo -en "\\033[1;32m"
	echo "File Name: cybershop-front-0.0.1-SNAPSHOT.war"
	ssh root@$FRONT_IPADDRS "/root/tomcat.sh stop"
	ssh root@$FRONT_IPADDRS "/root/tomcat.sh delet"
	scp $FRONT/*.war $FRONT_IPADDRS:/install/deploy/
	ssh root@$FRONT_IPADDRS "/root/tomcat.sh start"
	echo $DATE "wait 60S"
	sleep 30
	ssh root@$FRONT_IPADDRS "/root/tomcat.sh mount"
	if [ $? -eq 0 ];then
		echo "#################SCP and deploy comall-front-node2(172.31.1.201) successful#######################" 
	fi	
}
#Deploy test
deploy_testweb(){
	echo -en "\\033[1;32m"
	echo "File Name: cybershop-web-0.0.1-SNAPSHOT.war"
	ssh root@$TEST_WEB_IPADDRS "/root/tomcat.sh stop"
	ssh root@$TEST_WEB_IPADDRS "/root/tomcat.sh delet"
	mkdir $DEPLOY_WEB_DIR
	cd $TEST_WEB && unzip cybershop-web-0.0.1-SNAPSHOT.war -d $DEPLOY_WEB_DIR/
	scp -r $DEPLOY_WEB_DIR $TEST_WEB_IPADDRS:/install/deploy/
	ssh root@$TEST_WEB_IPADDRS "/root/tomcat.sh start"
	echo $DATE "wait 60S"
	rm -rf $DEPLOY_WEB_DIR
	sleep 60
	ssh root@$TEST_WEB_IPADDRS "/root/tomcat.sh mount"
	if [ $? -eq 0 ];then
		echo "#################SCP and deploy comall-web-node1(172.31.1.100) Successful#######################" 
	fi	
}
deploy_testfront(){
	echo -en "\\033[1;32m"
	echo "File Name: cybershop-front-0.0.1-SNAPSHOT.war"
	ssh root@$TEST_FRONT_IPADDRS "/root/tomcat.sh stop"
	ssh root@$TEST_FRONT_IPADDRS "/root/tomcat.sh delet"
	mkdir $DEPLOY_front_DIR
	cd $TEST_FRONT && unzip cybershop-front-0.0.1-SNAPSHOT.war -d $DEPLOY_front_DIR/
	scp -r $DEPLOY_front_DIR $TEST_FRONT_IPADDRS:/install/deploy/
	ssh root@$TEST_FRONT_IPADDRS "/root/tomcat.sh start"
	echo $DATE "wait 60S"
	rm -rf $DEPLOY_front_DIR
	sleep 30
	ssh root@$TEST_FRONT_IPADDRS "/root/tomcat.sh mount"
	if [ $? -eq 0 ];then
		echo "#################SCP and deploy comall-web-node2(172.31.1.101) Successful#######################" 
	fi	
}
delete_target () {
    #删除Carrefour-test分支生成的target文件夹
    echo "删除Carrefour-test分支生成的target文件夹"
    cd && find /install/carrefour-test -name target > targetTmp.txt
    for line in `cat targetTmp.txt`
    do
        rm -rf $line
    done
}
#生产前后台日志
web_log(){
        ssh root@$WEB_IPADDRS "/root/tomcat.sh log"
}
front_log(){
        ssh root@$FRONT_IPADDRS "/root/tomcat.sh log"
}
#测试前后台日志
test_web_log(){
		ssh root@$TEST_WEB_IPADDRS "/root/tomcat.sh log"
}
test_front_log(){
		ssh root@$TEST_FRONT_IPADDRS "/root/tomcat.sh log"
}
main(){
SVN_NUMBER="$2"
case $1 in
	api)
		svn_api;
		maven_api;
		deploy_api;
		maven_delet_api;
                delete_target;
		;;
	pro)
		svn_web;
		maven_web;
		back;
		deploy_web;
		deploy_front;
		maven_tmp;
                delete_target
		;;
	test)
		svn_test;
		maven_test;
		deploy_testweb;
		deploy_testfront;
		maven_tmptest;
                delete_target;
		;;
	web)
		web_log;
		;;
	front)
		front_log
		;;
	test-web)
		test_web_log;
		;;
	test-front)
		test_front_log;
		;;
	*)
	echo "Usage:$0(pro|test|web|front|test-web|test-front|api)"
	exit 1
esac
}
main $1 $2 
