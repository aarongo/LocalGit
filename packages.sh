#!/bin/bash
#author LonnyLiu
#carrefour-pro packages
#detailed information
PRO_Dir=/install/carrefour-pro/
#packages directory
PRO_WEB=/install/carrefour-pro/cybershop-web/target
PRO_FRONT=/install/carrefour-pro/cybershop-front/target
PRO_WEB_FILES=/install/carrefour-pro/cybershop-web/target/cybershop-web-0.0.1-SNAPSHOT.war
PRO_FRONT_FILES=/install/carrefour-pro/cybershop-front/target/cybershop-front-0.0.1-SNAPSHOT.war
DATE=`date "+%Y-%m-%d-%H"`
#The remote download directory
UPLOAD_Dir=/var/www/html/
#mvn common
MVN_BIN=/install/maven/bin/mvn
#SVN Revision
#REVISION=`/usr/bin/svn info | grep Revision: | awk '{print $2}'`

SVN_PRO () {
	cd $PRO_Dir
	/usr/bin/svn update -r $SVN_NUMBER
}
packages_pro () {
	cd $PRO_Dir
	$MVN_BIN clean install -PcarrefourPro -DskipTests
	if [ -f $PRO_WEB_FILES ]; then
		#statements
		echo -e "\033[32m  $PRO_WEB_FILES exists \033[0m"
	else
		echo -e "\033[32m  $PRO_WEB_FILES don't exists \033[0m"
	fi
}
packages_demo () {
	cd $PRO_Dir
	$MVN_BIN clean install -Pcarrefour -DskipTests
	if [ -f $PRO_WEB_FILES ]; then
		#statements
		echo -e "\033[32m  $PRO_WEB_FILES exists \033[0m"
	else
		echo -e "\033[32m  $PRO_WEB_FILES don't exists \033[0m"
	fi
}
packages_test () {
    cd $PRO_Dir
    $MVN_BIN clean install -PcarrefourPtest -DskipTests
    if [ -f $PRO_WEB_FILES ]; then
		#statements
            echo -e "\033[32m  $PRO_WEB_FILES exists \033[0m"
    else
            echo -e "\033[32m  $PRO_WEB_FILES don't exists \033[0m"
    fi
}
copy_pro() {
	mkdir ./pro$DATE-$SVN_NUMBER 
	mv $PRO_WEB/cybershop-web-0.0.1-SNAPSHOT.war ./pro$DATE-$SVN_NUMBER/
	mv $PRO_FRONT/cybershop-front-0.0.1-SNAPSHOT.war ./pro$DATE-$SVN_NUMBER/
	if [ "`ls -A ./pro$DATE-$SVN_NUMBER`" = "" ]; then
		#statements
		echo "$DIRECTORY is indeed empty execute tar "		
	fi
	    echo "$DIRECTORY is not empty"
	    cd ./
	    tar -czvPf pro${DATE}-${SVN_NUMBER}.tar.gz  ./pro$DATE-$SVN_NUMBER
}
copy_demo () {
	mkdir ./demo$DATE-$SVN_NUMBER
	mv $PRO_WEB/cybershop-web-0.0.1-SNAPSHOT.war ./demo$DATE-$SVN_NUMBER
	mv $PRO_FRONT/cybershop-front-0.0.1-SNAPSHOT.war ./demo$DATE-$SVN_NUMBER
	if [ "`ls -A ./demo$DATE-$SVN_NUMBER`" = "" ]; then
		#statements
		echo "$DIRECTORY is indeed empty execute tar "		
	fi
	    echo "$DIRECTORY is not empty"
	    cd ./
	    tar -czvPf demo${DATE}-${SVN_NUMBER}.tar.gz  ./demo$DATE-$SVN_NUMBER
}
copy_ptest () {
    mkdir ./ptest$DATE-$SVN_NUMBER
    mv $PRO_WEB/cybershop-web-0.0.1-SNAPSHOT.war ./ptest$DATE-$SVN_NUMBER
    mv $PRO_FRONT/cybershop-front-0.0.1-SNAPSHOT.war ./ptest$DATE-$SVN_NUMBER
    if [ "`ls -A ./demo$DATE-$SVN_NUMBER`" = "" ]; then
            #statements
            echo "$DIRECTORY is indeed empty execute tar "		
    fi
        echo "$DIRECTORY is not empty"
        cd ./
        tar -czvPf demo${DATE}-${SVN_NUMBER}.tar.gz  ./ptest$DATE-$SVN_NUMBER
}
remove_pro () {
	cd ./
	mv *.tar.gz /var/www/html/
	if [ $? -eq 0 ]; then
		#statements
		echo -e "\033[32m  remove  Successful Download address:http://124.200.96.150:8081/pro$DATE-$SVN_NUMBER.tar.gz \033[0m"
		rm -rf ./pro$DATE-$SVN_NUMBER
	else
		 echo -e "\033[32m  remove FALL \033[0m"
	fi
}
remove_demo () {
    cd ./
    mv *.tar.gz /var/www/html/
    if [ $? -eq 0 ]; then
		#statements
            echo -e "\033[32m  remove  Successful Download address:http://124.200.96.150:8081/demo$DATE-$SVN_NUMBER.tar.gz\033[0m"
            rm -rf ./demo$DATE-$SVN_NUMBER
    else
            echo -e "\033[32m  remove FALL \033[0m"
    fi
}
remove_ptest () {
    cd ./
    mv *.tar.gz /var/www/html/
    if [ $? -eq 0 ]; then
		#statements
		echo -e "\033[32m  remove  Successful Download address:http://124.200.96.150:8081/ptest$DATE-$SVN_NUMBER.tar.gz\033[0m"
		rm -rf ./ptest$DATE-$SVN_NUMBER
    else
		 echo -e "\033[32m  remove FALL \033[0m"
    fi
}
remove_target () {
    #删除maven编译后生成的target文件夹
    cd && find /install/carrefour-pro -name target > targetTmp.txt
    for line in `cat targetTmp.txt`
    do
        echo "删除Carrefour-pro分支生成的target文件夹"
        rm -rf $line
    done
}
main () {
 SVN_NUMBER="$2"
case $1 in
	pro )
		SVN_PRO;
		packages_pro;
		copy_pro;
		remove_pro;
                remove_target;
		;;
	demo )
		SVN_PRO;
		packages_demo;
		copy_demo;
		remove_demo;
                remove_target;
		;;
        ptest )
		SVN_PRO;
		packages_ptest;
		copy_ptest;
		remove_ptest;
                remove_target;
		;;             
	*)
	 echo "Usage:$0(pro|demo|ptest)"
	 exit 1
	;;
esac
}
main $1 $2
