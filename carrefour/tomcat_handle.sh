#!/usr/bin/env bash
#######Is Variable#######
Tomcat_base_dir="/software/tomcat-front /software/tomcat-backend"
Tomcat_Deploy_front=/software/deploy-front
Tomcat_Deploy_backend=/software/deploy-backend
project_name_front=cybershop-front-0.0.1-SNAPSHOT
project_name_backend=cybershop-web-0.0.1-SNAPSHOT
images_link_name=upload
static_link_name=/data/www
deploy_files_name="cybershop-front-0.0.1-SNAPSHOT.war cybershop-web-0.0.1-SNAPSHOT.war"
war_path=/software
mount_nfs_dir=/software/newupload

clear (){
    #清空本机 Tomcat 临时目录
    echo -e "\033[32mClear LocalHost Tomcat_Tmp\033[0m"
    for dir in ${Tomcat_base_dir}
        do
            rm -rf $dir/work/Catalina/*
        done
    #清空其他节点的临时目录
    echo -e "\033[32m Clear Remote Host Tomcat_tmp\033[0m"
    for ip in $ip_address
        do
            ssh $ip "/sotftware/tomcat_handle.sh clear"
        done

}

stop_front (){
    #停止本机服务
    tomcat_front_pid=`ps -ef |grep java | grep -v "grep" | grep "tomcat-front" | awk '{print $2}'`
    echo -e "\033[32mStop Local tomcat_front ==========================================\033[0m"
    sudo kill -9 $tomcat_front_pid
    if [ $? -eq 0 ]; then
        echo -e "\033[32m  Stop Tomcat_front Ok \033[0m"
    else
        echo -e "\033[32m  Stop Tomcat_front Fail \033[0m"
    fi
}
stop_backend (){
    #停止本机服务
    tomcat_backend_pid=`ps -ef |grep java | grep -v "grep" | grep "tomcat-backend" | awk '{print $2}'`
    echo -e "\033[32mStop Local tomcat_front ==========================================\033[0m"
    sudo kill -9 $tomcat_backend_pid
    if [ $? -eq 0 ]; then
        echo -e "\033[32m  Stop Tomcat_backend Ok \033[0m"
    else
        echo -e "\033[32m  Stop Tomcat_backend Fail \033[0m"
    fi
}

#2.删除软连接
unlink_front (){
    #删除本机 Link 目录
	echo -e "\033[32m  Delete soft connection ================================"
    if [ ! -d ${Tomcat_Deploy_front}/${project_name_front} ]; then
        rm -f ${Tomcat_Deploy_front}/${project_name_front}/assets/${images_link_name}
        rm -f ${Tomcat_Deploy_front}/ROOT/assets/${images_link_name}
    else
        echo -e "\033[31m Link Dir Is Not Exits\033[0m"
    fi
}
unlink_backend () {
    #删除本机 Link 目录
	echo -e "\033[32m  Delete soft connection ================================"
    if [ ! -d ${Tomcat_Deploy_backend}/${project_name_backend} ]; then
        rm -f ${Tomcat_Deploy_backend}/${project_name_backend}/assets/${images_link_name}
    else
        echo -e "\033[31m Link Dir Is Not Exits\033[0m"
    fi
}

#清除项目部署目录
clear_files_front (){
    #删除项目目录
    echo "\033[32m Clear Deploy Files \033[0m"
    if [ ! -L ${Tomcat_Deploy_front}/${project_name_front}/assets/${images_link_name} ] || [ ! -L ${Tomcat_Deploy_front}/ROOT/assets/${images_link_name} ] ; then
        rm -rf ${Tomcat_Deploy_front}/*
    else
        echo "\033[32 Link symbol exists Don't delete "
    fi
}
clear_files_backend (){
    #删除项目目录
    echo "\033[32m Clear Deploy Files \033[0m"
    if [ ! -L ${Tomcat_Deploy_backend}/${project_name_backend}/assets/${images_link_name} ]; then
        rm -rf ${Tomcat_Deploy_backend}/*
    else
        echo "\033[32 Link symbol exists Don't delete "
    fi
}

move_files_front () {
    #移动本机部署文件
    for war in ${deploy_files_name}
        do
            if [ ${war} == cybershop-front-0.0.1-SNAPSHOT.war ] ; then
                mv ${war_path}/${war} ${Tomcat_Deploy_front}/
            fi
        done
}
move_files_backend (){
    #移动本机部署文件
    for war in ${deploy_files_name}
        do
            if [ ${war} == cybershop-web-0.0.1-SNAPSHOT.war ] ; then
                mv ${war_path}/${war} ${Tomcat_Deploy_backend}/
            fi
        done
}

#6.启动 Tomcat, 判断是否启动成功
start_front () {
    #启动本机 Tomcat
    for bin in ${Tomcat_base_dir}
        do
            if [ ${bin} == /software/tomcat-front ]; then
                ${bin}/bin/startup.sh
                until [ -d ${Tomcat_Deploy_front}/${project_name_front}/assets ];do
                    echo "the directory dosn't exists, sleep 5s"
                    sleep 5
                done
            fi
        done
}
start_backend (){
    #启动本机 Tomcat
    for bin in ${Tomcat_base_dir}
        do
            if [ ${bin} == /software/tomcat-backend ] ;then
                ${bin}/bin/startup.sh
                until [ -d ${Tomcat_Deploy_backend}/${project_name_backend}/assets ];do
                    echo "the directory dosn't exists, sleep 5s"
                    sleep 5
                done
            fi
        done
}

#7.建立软连接
create_link_front (){
    #创建本机 Link
    for link in $link_on_dir
        do
            if [ ${link} == ${Tomcat_Deploy_front}/${project_name_front}/assets ]; then
                echo "033[32m Create Front Images Link\033[0m"
                ln -s ${mount_nfs_dir} ${Tomcat_Deploy_front}/${project_name_front}/assets/upload
                ln -s ${mount_nfs_dir} ${Tomcat_Deploy_front}/ROOT/assets/upload
                ln -s ${static_link_name} ${Tomcat_Deploy_front}/${project_name_front}/www
	            ln -s ${static_link_name} ${Tomcat_Deploy_front}/ROOT/www
            fi
        done
}
create_link_backend (){
    #创建本机 Link
    for link in $link_on_dir
        do
            if [ ${link} == ${Tomcat_Deploy_backend}/${project_name_backend}/assets ]; then
                echo "\033[32m Create Web Images Link\033[0m"
                ln -s ${mount_nfs_dir} ${Tomcat_Deploy_backend}/${project_name_backend}/assets/upload
                ln -s ${mount_nfs_dir} ${Tomcat_Deploy_backend}/ROOT/assets/upload
            fi
        done
}
discover_front () {
       #检测本机服务
       curl -I http://localhost:8080
}
discover_web (){
       #检测本机服务
       curl -I http://localhost:8081
}

main (){
    case $1 in
        clear )
            clear;
            ;;
        stop_front )
            stop_front;
            ;;
        stop_backend )
            stop_backend;
            ;;
        discover_front )
            discover_front;
            ;;
        discover_web )
            discover_web;
            ;;
        create_link_backend )
            create_link_backend;
            ;;
        create_link_front )
            create_link_front;
            ;;
        start_backend )
            start_backend;
            ;;
        start_front )
            start_front;
            ;;
        move_files_backend )
            move_files_backend;
            ;;
        move_files_front )
            move_files_front;
            ;;
        unlink_front )
            unlink_front;
            ;;
        unlink_backend )
            unlink_front;
            ;;
        clear_files_front )
            clear_files_front;
            ;;
        clear_files_backend )
            clear_files_front;
            ;;
        *)
	        echo "Usage:$0(clear|stop_front|stop_backend|discover_front|discover_web|create_link_backend|create_link_front|start_backend|start_front|move_files_backend|move_files_front|unlink_front|unlink_backend|clear_files_front|clear_files_backend)"
            exit 1
            ;;
    esac
}
main $1