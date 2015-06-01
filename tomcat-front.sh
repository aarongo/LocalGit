#!/bin/bash
#Tomcat_Dir
Tomcat_Dir=/software/tomcat-front/bin
Tomcat_log=/software/tomcat-front/logs
Tomcat_Deploy=/software/deploy-front
Tomcat_Mount_Dir=/software/upload
TomcatCache=/software/tomcat-front/work
Tomcat_pid=`ps -ef |grep java | grep -v "grep" | grep "tomcat-front" | awk '{print $2}'`
#disk used
DISK_NO="/dev/mapper/vgCNECOPD1-lvol10"
#date
DATE=`date +"%y-%m-%d %H:%M:%S"`
#ip
IPADDR=`ifconfig eth0|grep 'inet addr'|sed 's/^.*addr://g' |sed 's/Bcast:.*$//g'`
#hostname
HOSTNAME=`hostname -s`
#user
USER=`whoami`
#disk_check
DISK_SDA=`df -h | grep $DISK_NO | awk '{print $5}'`
#cpu_average_check
cpu_uptime=`cat /proc/loadavg | cut -c1-14`

cat << EOF
|-----------System Infomation-----------
| DATE       :$DATE
| HOSTNAME   :$HOSTNAME
| USER       :$USER
| IP         :$IPADDR
| DISK_USED  :$DISK_SDA
| CPU_AVERAGE:$cpu_uptime
|-----------System Infomation End--------
EOF
start (){
	echo -e "\033[32m Start Tomcat========================================="
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
	$Tomcat_Dir/shutdown.sh 
	if [ $? -eq 0 ]; then
		#statements
		echo -e "\033[32m  Stop Tomcat ===================================== Ok \033[0m"
	else
		sudo kill -9 $Tomcat_pid
		if [ $? -eq 0 ]; then
			#statements
			echo -e "\033[32m  Stop Tomcat ===================================== Ok \033[0m"
		fi
		echo -e "\033[32m  Stop Tomcat ===================================== Fail \033[0m"
	fi

}
log (){
	echo -e "\033[32m  view Tomcat log=======================================Ok \033[0m"
	tail -f $Tomcat_log/catalina.out
}
mount (){
	echo -e "\033[32m  mkdir soft connection================================== \033[32m"
	ln -s /software/upload $Tomcat_Deploy/cybershop-front-0.0.1-SNAPSHOT/assets/upload
	ln -s /software/upload $Tomcat_Deploy/ROOT/assets/upload
	if [ $? -eq 0 ]; then
		#statements
		echo -e "\033[32m  Mkdir soft connection ================================Ok \033[32m"
	else
		echo -e "\033[32m  Mkdir soft connection =================================Fail \033[32m"
	fi
}
umount (){
	echo -e "\033[32m  Delete soft connection ================================"
	rm -f $Tomcat_Deploy/cybershop-front-0.0.1-SNAPSHOT/assets/upload 
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
	rm -rf $TomcatCache/*
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
		sleep 15
		mount;
		;;
	*)
		echo "Usage:$0(start|stop|restart|log|undeploy|deploy)"
		exit 1
		;;
esac