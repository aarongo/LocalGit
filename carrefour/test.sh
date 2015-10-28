#!/usr/bin/env bash
ip_address="10.151.246.34 10.151.246.36"
war_store_path=/software/deploybak/
##########Tomcat deploy dir ###########
Tomcat_Deploy_front=/software/deploy-front
Tomcat_Deploy_backend=/software/deploy-backend
project_name_front=cybershop-front-0.0.1-SNAPSHOT
project_name_backend=cybershop-web-0.0.1-SNAPSHOT
images_link_name=upload
static_link_name=/data/www
##########Tomcat Deploy end###########
remote_path=/software/
Tomcat_base_dir="/software/tomcat-front /software/tomcat-backend"
deploy_files_name="cybershop-front-0.0.1-SNAPSHOT.war cybershop-web-0.0.1-SNAPSHOT.war"


for ip in $ip_address
    do
        echo $ip
        for dir in $Tomcat_base_dir
            do
                echo $dir
            done
    done

#
#download_url=http://124.200.96.150:8081/ptest2015-10-21-01-3379.tar.gz
#echo ${download_url##*/}
#echo ${download_url##*/}|awk -F '.' '{print $1}'
#echo "测试"$war_store_path${download_url##*/}|awk -F '.' '{print $1}'
##remote_front_pid={ps -ef |grep java | grep -v 'grep' | grep 'tomcat-front' | awk '{print '$2'}'}
##echo $remote_front_pid
#echo         rm -f $Tomcat_Deploy_front/$project_name_front/assets/$images_link_name

for war in $deploy_files_name
    do
        if [ ${war} == cybershop-front-0.0.1-SNAPSHOT.war ] ; then
            echo ${war}
        elif [ ${war} == cybershop-web-0.0.1-SNAPSHOT.war ] ; then
            echo ${war}
        fi
    done

for bin in $Tomcat_base_dir
    do
        if [ ${bin} == /software/tomcat-front ]; then
            echo sdkfjsldfjdlsk
        elif [ ${bin} == /software/tomcat-backend ]; then
            echo 12121321
        fi
    done
