#!/bin/bash
#Tomcat_Dir
Tomcat_Dir=/software/tomcat-backend/bin
Tomcat_log=/software/tomcat-backend/logs
Tomcat_Deploy=/software/deploy-backend
Tomcat_Mount_Dir=/software/newupload
Tomcat_pid=`ps -ef |grep java | grep -v "grep" | grep "tomcat-backend" | awk '{print $2}'`

start (){
	echo -e "\033[32m Start Tomcat========================================="
	mv /software/cybershop-web-0.0.1-SNAPSHOT.war /software/deploy-backend/
	$Tomcat_Dir/startup.sh
	if [ $? -eq 0 ]; then
		#statements
		echo -e "\033[32m  Start TOmcat ====================================Ok \033[0m"
	else
		echo -e "\033[32m  Start TOmcat =====================================Fail \033[0m"
	fi
}
stop (){
	echo -e "Stop Tomcat =========================================="
		sudo kill -9 $Tomcat_pid
		if [ $? -eq 0 ]; then
			#statements
			echo -e "\033[32m  Stop Tomcat ===================================== Ok \033[0m"
		else
			echo -e "\033[32m  Stop Tomcat ===================================== Fail \033[0m"
		fi
#	fi

}
log (){
	echo -e "\033[32m  view Tomcat log=======================================Ok \033[0m"
	tail -f $Tomcat_log/catalina.out
}
mount (){
	echo -e "\033[32m  mkdir soft connection================================== \033[32m"
        until [ -d /software/deploy-backend/cybershop-web-0.0.1-SNAPSHOT/assets ];do
        echo "the directory dosn't exists, sleep 5s"
        sleep 5
        done
	ln -s /software/newupload $Tomcat_Deploy/cybershop-web-0.0.1-SNAPSHOT/assets/upload
	ln -s /software/newupload $Tomcat_Deploy/ROOT/assets/upload
	if [ $? -eq 0 ]; then
		#statements
		echo -e "\033[32m  Mkdir soft connection ================================Ok \033[32m"
	else
		echo -e "\033[32m  Mkdir soft connection =================================Fail \033[32m"
	fi
}
umount (){
	echo -e "\033[32m  Delete soft connection ================================"
	rm -f $Tomcat_Deploy/cybershop-web-0.0.1-SNAPSHOT/assets/upload 
	rm -f $Tomcat_Deploy/ROOT/assets/upload
	if [ $? -eq 0 ]; then
		#statements
		echo -e "\033[32m  umount soft connection =========================Ok \033[0m"
	else
		echo -e "\033[32m  umount soft connection ===========================Fail \033[0m"
	fi
}
deletewar (){
	echo -e "\033[32m  Delete War ========================================= \033[0m"
	rm -rf $Tomcat_Deploy/*
	if [ $? -eq 0 ]; then
		#statements
		echo -e "\033[32m  Delete War =====================================OK \033[0m"
	else
		echo -e "\033[32m Delete War =======================================Fail \033[0m"
	fi
}
case $1 in
	start)
		start;
		;;
	stop)
		stop;
		;;
	restart)
		stop;
		sleep 10
		start;
		;;
	log)
		log;
		;;
	undeploy)
		stop;
		sleep 8
		umount;
		deletewar;
		;;
	deploy)
		start;
		sleep 10
		mount;
		;;
	*)
		echo "Usage:$0(start|stop|restart|log|undeploy|deploy)"
		exit 1
		;;
esac
