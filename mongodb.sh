#!/bin/bash
#This For Mongodb "Mongodb  Replica Set" start or stop and restart
prodirectory=/software/mongodb/bin
MongoDBPID=` ps -ef | grep mongodb | grep conf | awk '{print $2}'`
#disk used
DISK_NO="/dev/mapper/vgCNECOPD1-lvol10"
#date
DATE=`date +"%y-%m-%d %H:%M:%S"`
#ip
IPADDR=`ifconfig eth1|grep 'inet addr'|sed 's/^.*addr://g' |sed 's/Bcast:.*$//g'`
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

#start MongoDB Master
start(){
	echo "Staring Mongodb================================= "
	$prodirectory/mongod -f /software/data/mongodb/master/mongodb_master.conf
if [ $? -eq 0 ]; then
	#statements
	echo -e "\033[32m ================================Start MongoDB  Ok  \033[0m"
else
	echo -e "\033[32m ================================Start MongoDB Fail \033[0m"
fi
}
stop(){
	echo "Stop MongoDB====================================="
	kill -9 $MongoDBPID
if [ $? -eq 0 ]; then
	#statements
	echo -e "\033[32m ================================stop MongoDB  Ok  \033[0m"
else
	echo -e "\033[32m ================================stop MongoDB Fail \033[0m"
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
		sleep 5
		start;
		;;
	*)
	echo "Usage:$0(start|stop|restart)"
	exit 1
esac