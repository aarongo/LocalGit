#!/bin/bash
#For carrefour Demo backend front
#WEB1 WEB2 IPaddress
WEBNODE1=10.132.250.11
WEBNODE2=10.132.250.12
#cybershop-front PID
FRONTPID=`ssh $WEBNODE2 "ps aux | grep tomcat-front | grep -v 'grep' | awk '{print \$2}'"`
#cybserhp-backend PID
BACKENDPID=`ps aux | grep  tomcat-backend | grep -v 'grep' | awk '{print $2}'`
#Deploy  distribute Directory
WARDIR=/home/war
#WEB1-tomcat Directory
TOMCATBACKEND=/home/deploy/tomcat-backend/bin
#WEB1-deploy Directory
WEB1DEPLOY=/home/deploy/web
#WEB1 Files exists
WEB1FILES=/home/deploy/web/cybershop-web-0.0.1-SNAPSHOT.war
#WEB1  App Directory
WEB1APP1=/home/deploy/web/cybershop-web-0.0.1-SNAPSHOT/assets/upload
WEB1APP2=/home/deploy/web/ROOT/assets/upload
#WEB2-tomcat Directory
TOMCATFRONT=/home/deploy/tomcat-front/bin
#WEB2-deploy Directory
WEB2DEPLOY=/home/deploy/front
#WEB2-FILES exists
WEB2FILES=`ssh  $WEB-NODE2 "[ -e /home/deploy/front/cybershop-front-0.0.1-SNAPSHOT.war ]" ; echo $?`
#WEB2  App Directory
WEB2APP1=`ssh  $WEB-NODE2 "[ -L /home/deploy/front/cybershop-front-0.0.1-SNAPSHOT/assets/upload ]" ; echo $?`
WEB2APP2=`ssh $WEB-NODE2 "[ -L /home/deploy/front/ROOT/assets/upload ] " ; echo $?`
#WEB1-images mount Directory
IMAGESDIRNODE1=/home/deploy/upload
#WEB2-images mount Directory
IMAGESDIRNODE2=/home/images/dockerimages


#send file *.war
send_files () {
	#send cybershop-backend files
	mv $WARDIR/cybershop-web-0.0.1-SNAPSHOT.war  $WEB1DEPLOY/
	if [ -f $WEB1FILES ]; then
		echo -e "\033[32m  cybershop-web-0.0.1-SNAPSHOT.war exists \033[0m"
	else
		echo -e "\033[32m  cybershop-web-0.0.1-SNAPSHOT.war don't exists \033[0m"
	fi
	#Send cybserhop-fornt files
	scp $WARDIR/cybershop-front-0.0.1-SNAPSHOT.war $WEBNODE2:$WEB2DEPLOY/
	if [ $WEB2FILES -eq 0 ]; then
		echo -e "\033[32m  cybershop-front-0.0.1-SNAPSHOT.war exists \033[0m"
	else
		echo -e "\033[32m cybershop-front-0.0.1-SNAPSHOT.war don't exists \033[0m"
	fi
}
#String backnd front
start_all () {
	#Staring cybsershop-backend
	$TOMCATBACKEND/startup.sh
	if [ $? -eq 0 ]; then
		echo -e "\033[32m Staring cybsershop-backend OK====================================== \033[0m"
	else
		echo -e "\033[32m Staring cybsershop-backend FAIL==================================== \033[0m"
	fi
	echo "Wariting 15S"
	sleep 20
	ssh $WEBNODE2 $TOMCATFRONT/startup.sh
	if [ $? -eq 0 ]; then
		echo -e "\033[32m String cybserhop-front OK ========================================= \033[0m"
	else
		echo -e "\033[32m String cybserhop-front FAIL======================================== \033[0m"
	fi
}
#Stop backend front
stop_all () {
	#Stop cybershop-backend
	$TOMCATBACKEND/shutdown.sh
	if [ $? -eq 0 ]; then
		echo -e "\033[32m Stop cybershop-backend OK ========================================= \033[0m"
	else
		echo -e "\033[32m Stop cybershop-backend FAIL execute kill ========================== \033[0m"
		kill -9 $BACKENDPID
		if  [ $? -eq 0 ]; then
			echo -e "\033[32m Kill cybershop-backend OK ====================================== \033[0m"
		else
			echo -e "\033[32m $BACKENDPID don't exists \033[0m"
		fi
	fi
	ssh $WEBNODE2 $TOMCATFRONT/shutdown.sh
	if [ $? -eq 0 ]; then
		echo -e "\033[32m Stop cybserhop-front OK ============================================ \033[0m"
	else
		echo -e "\033[32m Stop cybershop-front FAIL execute kill ============================= \033[0m"
		ssh $WEBNODE2 "kill -9 $FRONTPID"
		if [ $? -eq 0 ]; then
			echo -e "\033[32m Kill cybershp-front OK========================================== \033[0m"
		else
			echo -e "\033[32m $FRONTPID don't exists \033[0m"
		fi
	fi
}
#Unlink upload
unlink_all () {
	#Unlink 
	rm -f $WEB1APP1
	if [ -L $WEB1APP1 ]; then
		echo -e "\033[32m Soft Links exists Unlinks Fail ======================= \033[0m"
	else
		echo -e "\033[32m Soft Links Don't exists Unlink Successful============== \033[0m"
	fi
	rm -f $WEB1APP2
	if [ -L $WEB1APP2 ]; then
		echo -e "\033[32m Soft Links exists Unlinks Fail ========================= \033[0m"
	else
		echo -e "\033[32m Soft Links Don't exists Unlinks Successful============== \033[0m"
	fi
	ssh $WEBNODE2 "rm -f $WEB2APP1"
	if [ $WEB2APP1 -eq 0  ]; then
		echo -e "\033[32m Soft Links exists Unlinks Fail ========================= \033[0m"
	else
		echo -e "\033[32m Soft Links Don't exists Unlinks Successful============== \033[0m"
	fi
	ssh $WEBNODE2 "rm -f $WEB2APP2"
	if [ $WEB2APP2 -eq 0 ]; then
		echo -e "\033[32m Soft Links exists Unlinks Fail ========================= \033[0m"
	else
		echo -e "\033[32m Soft Links Don't exists Unlinks Successful============== \033[0m"
	fi
}
#delete *war
delete_all () {	
	#empty Deploy  Directory backend
	rm -rf $WEB1DEPLOY/*
	if [ $? -eq 0 ]; then
		echo -e "\033[32m empty Deploy  Directory backend========= ======  ======Successful \033[0m"
	else
		echo -e "\033[32m empty Deploy  Directory backend=====================Fail \033[0m"
	fi
	#empty Deploy  Directory Front
	ssh $WEBNODE2 "rm -rf $WEB2DEPLOY/*"
	if [ $? -eq 0 ]; then
		echo -e "\033[32m $WEBNODE2 empty Deploy  Directory front================Successful \033[0m"
	else
		echo -e "\033[32m $WEBNODE2 empty Deploy  Directory front================Fail \033[0m"
	fi
}
#Creste Links
create_links () {
	#create_links cybershop-backends
	ln -s $IMAGESDIRNODE1 $WEB1APP1
	if [ -L $WEB1APP1 ]; then
		echo -e "\033[32m  $WEB-NODE1 Soft Links exists======Unlink Successful \033[0m"
	else
		echo -e "\033[32m $WEB-NODE1 Soft Links Don't exists ==============Unlinks Fail \033[0m"
	fi
	ln -s $IMAGESDIRNODE1 $WEB1APP2
	if [ -L $WEB1APP2 ]; then
		echo -e "\033[32m $WEBNODE1 Soft Links  exists ===========Unlink Successful \033[0m"
	else
		echo -e "\033[32m $WEBNODE1 Soft Links Don'texists ==============Unlinks Fail \033[0m"
	fi
	ssh $WEBNODE2 "ln -s $IMAGESDIRNODE2 /home/deploy/front/cybershop-front-0.0.1-SNAPSHOT/assets/upload"
	if [ $WEB2APP1 -eq 0 ]; then
		echo -e "\033[32m $WEBNODE2 Soft Links exists ==========Unlink Successful \033[0m"
	else
		echo -e "\033[32m $WEBNODE2 Soft Links  Don't exists============== Unlinks Fail \033[0m"
	fi
	ssh $WEBNODE2 "ln -s $IMAGESDIRNODE2 /home/deploy/front/ROOT/assets/upload"
	if [ $WEB2APP2 -eq 0 ]; then
		echo -e "\033[32m $WEBNODE2 Soft Links  exists =========Unlink Successful \033[0m"
	else
		echo -e "\033[32m $WEBNODE2 Soft Links Don't exists ==============Unlinks Fail \033[0m"
	fi
}
case $1 in
	deploy)
		send_files;
		sleep 15
		start_all;
		sleep 30
		create_links;
		;;
	undeploy)
		stop_all;
		unlink_all;
		delete_all;
		;;
	 *)
		echo "Usage:$0(undeploy|deploy)"
		exit 1
		;;
esac
