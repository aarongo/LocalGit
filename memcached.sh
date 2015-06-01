#!/bin/bash
#This shell For memcached(start|stop|restart)
MEMCAHCED_DIR=/install/memcached1.4/bin/memcached
PORT1="dev-11-14"
PORT2="test-15-18"
PORT3="AlL-11-18"
#disk used
DISK_NO="/dev/sda3"
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
##Star Memcached 11~18 ALL
all(){
for (( i=1; i<9; i++ )); do
	echo "Start $PORT3 Memcached"
	$MEMCAHCED_DIR -c 512 -d -u root -m 512 -p 1121$i
done
if [ $? -eq 0 ];then
	echo "================================Start Memcached Ok"
else
	echo "================================Start Memcached Fail"
fi
}
dev(){
##Start Memcached 11-14 (This is DEV)
for (( i = 1; i < 5; i++ )); do
	#statements
	echo "Start $PORT1 Memcached"
	$MEMCAHCED_DIR -c 512 -d -u root -m 512 -p 1121$i
done
if [ $? -eq 0 ]; then
	#statements
	echo "================================Start Memcached Ok"
else
	echo "================================Start Memcached Fail"
fi
}
test(){
##Start Memcached 5-8(This is test)
for (( i = 5; i < 9; i++ )); do
	#statements
	echo "Start $PORT2 Memcached"
	$MEMCAHCED_DIR -c 512 -d -u root -m 512 -p 1121$i
done
if [ $? -eq 0 ]; then
	#statements
	echo "================================Start Memcached Ok"
else
	echo "================================Start Memcached Fail"
fi
}
end_all(){
	echo "================================Stop $PORT3"
	pkill -9 memcached
if [ $? -eq 0 ]; then
	#statements
	echo "================================Stop $PORT3 Ok"
else
	echo "================================Stop $PORT3 Fail"
fi
}
end_dev(){
	echo "================================Stop $PORT1"
	ps -ef | grep memcached | grep 11211 | awk '{print $2}' > 1.txt 
	ps -ef | grep memcached | grep 11212 | awk '{print $2}' >> 1.txt
	ps -ef | grep memcached | grep 11213 | awk '{print $2}' >> 1.txt
	ps -ef | grep memcached | grep 11214 | awk '{print $2}' >> 1.txt
while read line
do
      kill -9  $line 
done < /root/1.txt
}
end_test(){
	echo "================================Stop $PORT2"
	ps -ef | grep memcached | grep 11215 | awk '{print $2}' > 2.txt 
	ps -ef | grep memcached | grep 11216 | awk '{print $2}' >> 2.txt
	ps -ef | grep memcached | grep 11217 | awk '{print $2}' >> 2.txt
	ps -ef | grep memcached | grep 11218 | awk '{print $2}' >> 2.txt
while read line
do
      kill -9  $line 
done < /root/2.txt
}
main(){
case $1 in
        stop-all)
            end_all;
            ;;
        stop-dev)
            end_dev;
            ;;
        stop-test)
            end_test;
            ;;
        start-all)
            all;
            ;;
        start-dev)
            dev;
            ;;
        start-test)
            test;
            ;;
        *)
        echo "Usage:$0(stop-dev|stop-all|stop-test|start-all|start-dev|start-test)"
        exit 1
esac
}
main $1