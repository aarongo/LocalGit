#!/bin/bash

# -------------------------------------------------------------------------------------------
# 脚本功能
# 使用标签方式 启动、停止、重启 多个Tomcat实例

# 脚本使用说明
# 1.假设Tomcat都安装在/usr/local下，那么Tomcat的命名方式是这样子 tomcat1 tomcat2 tomcat3 tomcat4 ...
# 2.使用方式: 脚本路径 标签1|标签2  start|stop|restart|status
# 3.例如: gp1 标签代表是 tomcat1 tomcat2, gp2 标签代表的是 tomcat3 tomcat4
# 4.使用时请修改标签的名称
# 5.适用于 Tomcat5 Tomcat6

# 定义变量
export JAVA_HOME=/usr/local/java 				# 输出JAVA_HOME变量
JAVA_BIN="${JAVA_HOME}/bin/java"				# JAVA可执行程序路径
TOMCATS_HOME="/usr/local" 						# 所有的Tomcat安装的目录
SCRIPT_NAME=$0									# 脚本绝对路径
GROUP_NAME=$1 									# 命令行第一个参数
START_STOP=$2									# 命令行第二个参数
HOST="127.0.0.1" 								# 本机地址用于测试本机Tomcat是否已经启动完成
STATUS="200 301 302"							# 定义正常访问返回的状态码
URI="/index.html"								# 定义测试的URI
BACKGROUD="\033[37m"							# echo 时的 背景颜色
FONTCOLOR="\033[33m"							# echo 时的 字体颜色
END="\033[0m"									# echo 时的 结束标志
JAVA_OPTS=""									# JAVA启动选项,为空就是默认启动选项
#JAVA_OPTS="-server -Xms512m -Xmx512m -XX:PermSize=16m -XX:MaxPermSize=64m -XX:MaxNewSize=64m \
#												-XX:-UseGCOverheadLimit -XX:+UseConcMarkSweepGC"

# 帮助提示函数
usage(){
	echo
	echo "Usage: ${SCRIPT_NAME} gp1|gp2 start|stop|restart|status"
	echo
	exit 1
}

# 判断命令行参数是否为空,如果为空，调用帮助提示函数
if [[ ${GROUP_NAME} == "" || ${START_STOP} == "" ]]; then
	usage
fi


# 判断命令行第一个参数，第一个参数为要启动的Tomcat分组，这里的1 2 3 4是代表的是tomcat1 tomcat2 tomcat3 tomcat4
# 使用时 请修改这里
case ${GROUP_NAME} in
	gp1 )
		TOMCATS="1 2"
		;;
	gp2 )
		TOMCATS="3 4"
		;;
	*   )
		usage
		;;
esac

# 获取PID函数
getPID(){
	PID=$(ps -ef | grep -v 'grep' | grep "${TOMCAT_NAME}/conf/logging.properties" | awk '{print $2}')
}

# 单个Tomcat启动函数
startSingleTomcat(){
	TOMCAT_OPTS="-Djava.util.logging.config.file=${TOMCATS_HOME}/${TOMCAT_NAME}/conf/logging.properties \
	-Djava.util.logging.manager=org.apache.juli.ClassLoaderLogManager \
	-Djava.endorsed.dirs=${TOMCATS_HOME}/${TOMCAT_NAME}/common/endorsed \
	-Dcatalina.base=${TOMCATS_HOME}/${TOMCAT_NAME} \
	-Dcatalina.home=${TOMCATS_HOME}/${TOMCAT_NAME} \
	-Djava.io.tmpdir=${TOMCATS_HOME}/${TOMCAT_NAME}/temp \
	-classpath :${TOMCATS_HOME}/${TOMCAT_NAME}/bin/bootstrap.jar:${TOMCATS_HOME}/${TOMCAT_NAME}/bin/commons-logging-api.jar \
	org.apache.catalina.startup.Bootstrap start"
	TOMCAT_LOG="${TOMCATS_HOME}/${TOMCAT_NAME}/logs/catalina.out"
	${JAVA_BIN} ${JAVA_OPTS} ${TOMCAT_OPTS} > ${TOMCAT_LOG} 2>&1 &
	echo $! > /tmp/${TOMCAT_NAME}.pid
}

# 输出颜色
printColor(){
	echo -ne "${BACKGROUD}${GROUP_NAME}${END} ==> [ ${FONTCOLOR}${TOMCAT_NAME}${END} ] "
}

# 输出正在启动Tomcat
printStart(){
	printColor
	echo -n "is starting Please Wait "
}

# 输出正在停止Tomcat
printStop(){
	printColor
	echo "is stopping,Please wait ..."
}

# 输出Tomcat没有运行
printNotRun(){
	printColor
	echo "is not running..."
}

# 输出Tomcat正在运行
printRunning(){
	printColor
	echo "is running... PID: ${PID}"
}

# 输出Tomcat没有，试图启动Tomcat
printNotRunTryStart(){
	printColor
	echo "is not running, trying start ${TOMCAT_NAME}"
}

# sleep 函数
sleepFun(){
	sleep 0.5
}

# 得到端口
getPort(){
	PORT=`cat ${TOMCATS_HOME}/${TOMCAT_NAME}/conf/server.xml | awk '/HTTP\/1.1/ {print $2}' | cut -d'"' -f2`
}

# 测试端口是否可以正常访问
testPortIsOk(){
	PORT_OK=1
	status=`/usr/bin/curl -I $1 2>/dev/null | head -1 | cut -d" " -f2`
	for i in $STATUS; do
		if [[ ${i} == ${status} ]]; then
			PORT_OK=0
		fi
	done
	return ${PORT_OK}
}

# 检查每个Tomcat是否已经启动好
checkTomcat(){
	status_ok=1
	sleep 1
	while [[ ${status_ok} == 1 ]]; do
		testPortIsOk http://${HOST}:${PORT}${URI}
		if [[ $? == 0 ]]; then
			echo " start OK!"	
			status_ok=0
		else
			echo -n "."
		fi	
	done
}


# Tomcat启动函数
start(){
	for i in ${TOMCATS}; do
		TOMCAT_NAME="tomcat${i}"
		getPID
		getPort
		if [[ "${PID}X" != "X" ]]; then
			printRunning
		else
			startSingleTomcat
			printStart
			checkTomcat
		fi
	done
}

# Tomcat停止函数
stop(){
	for i in ${TOMCATS}; do
		TOMCAT_NAME="tomcat${i}"
		getPID
		if [[ "${PID}X" == "X" ]]; then
			printNotRun
		else
			kill -9 $PID
			printStop
			sleepFun
		fi
	done
}

# Tomcat重启函数
restart(){
	for i in ${TOMCATS}; do
		TOMCAT_NAME="tomcat${i}"
		getPID
		getPort
		if [[ "${PID}X" == "X" ]]; then
			printNotRunTryStart
			startSingleTomcat
			printStart
			checkTomcat
		else
			kill -9 $PID
			printStop
			sleepFun
			startSingleTomcat
			printStart
			checkTomcat
		fi
	done
}

# 获取Tomcat状态函数
status(){
	for i in ${TOMCATS}; do
		TOMCAT_NAME="tomcat${i}"
		getPID
		if [[ "${PID}X" == "X" ]]; then
			printNotRun
		else
			printRunning
		fi
	done
}

# 判断命令行第二个参数
case ${START_STOP} in
	start   )
		start
		;;
	stop    )
		stop
		;;
	restart )
		restart
		;;
	status  )
		status
		;;
	* 	    )
		usage
		;;	
esac