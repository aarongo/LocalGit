#!/bin/bash
############Variable##########
war_store_path=/software/deploybak/
ip_address="10.151.246.34 10.151.246.36"
remote_path=/software/

##########variable END##########


##########Tomcat deploy dir ###########
Tomcat_Deploy_front=/software/deploy-front
Tomcat_Deploy_backend=/software/deploy-backend
project_name_front=cybershop-front-0.0.1-SNAPSHOT
project_name_backend=cybershop-web-0.0.1-SNAPSHOT
images_link_name=upload
static_link_name=/data/www
Tomcat_base_dir="/software/tomcat-front /software/tomcat-backend"
##########Tomcat Deploy end###########

#########Deploy Options########
deploy_files_name="cybershop-front-0.0.1-SNAPSHOT.war cybershop-web-0.0.1-SNAPSHOT.war"
mount_nfs_dir=/software/newupload
link_on_dir="${Tomcat_Deploy_front}/${project_name_front}/assets ${Tomcat_Deploy_backend}/${project_name_backend}/assets"
static_link_dir=${Tomcat_Deploy_front}/${project_name_front}

#处理文件开始
#1.下载文件
down_war (){
    if [! ${download_url} ]; then
        echo "\033[31mPlease InPut War Urls\033[0m"
    else
        cd $war_store_path && wget --proxy-user=ecommerce_china --proxy-passwd=xK8-4=gF ${download_url}
    fi
}
#2.解压文件
extract_war (){
    cd $war_store_path && tar xzf ${download_url##*/}
}
#3.发送文件
send_war (){
    for ip in $ip_address
        do
            scp $war_store_path${download_url##*/}|awk -F '.' '{print $1}'/*.war $ip:$remote_path
            if [ $? -eq 0 ]; then
                echo "Send War TO $ip successful"
            fi
        done
}
#4.清空 tomcat 临时文件 清空部署目录
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

########停止服务操作
#1.停止服务
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
    #停止远程服务 前台
    for ip in $ip_address
        do
            ssh $ip "/software/tomcat_handle.sh stop_front"
            if [ $? -eq 0 ]; then
                echo "\033[32mStop $ip Tomcat_front successful\033[0m"
            else
                echo "\033[32mStop $ip Tomcat_front Failed\033[0m"
            fi
        done
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
    #停止远程服务 后台
    for ip in $ip_address
        do
            ssh $ip "/software/tomcat_handle.sh stop_backend"
            if [ $? -eq 0 ]; then
                echo "\033[32mStop $ip Tomcat_backend successful\033[0m"
            else
                echo "\033[32mStop $ip Tomcat_backend Failed\033[0m"
            fi
        done

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
    #删除其他节点 Link 目录
    echo -e "\033[32 Delete soft Connection Other\033[0m"
    for ip in $ip_address
        do
            ssh $ip "/sotftware/tomcat_handle.sh unlink_front"
            if [ $? -eq 0 ]; then
                echo -e "\033[32mDelete $ip Link Successful\03[0m"
            else
                echo -e "\033[32m Delete $ip Link Failed\033[0m"
            fi
        done
}
unlink_backend () {
    #删除本机 Link 目录
	echo -e "\033[32m  Delete soft connection ================================"
    if [ ! -d ${Tomcat_Deploy_backend}/${project_name_backend} ]; then
        rm -f ${Tomcat_Deploy_backend}/${project_name_backend}/assets/${images_link_name}
    else
        echo -e "\033[31m Link Dir Is Not Exits\033[0m"
    fi
    #删除其他节点 Link 目录
    echo -e "\033[32 Delete soft Connection Other\033[0m"
    for ip in ${ip_address}
        do
            ssh ${ip} "/sotftware/tomcat_handle.sh unlink_backend"
            if [ $? -eq 0 ]; then
                echo -e "\033[32mDelete $ip Link Successful\03[0m"
            else
                echo -e "\033[32m Delete $ip Link Failed\033[0m"
            fi
        done

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
    #删除远程项目目录
    echo "\033[32m Delete Remote files\033[0m"
    for ip in ${ip_address}
        do
            ssh ${ip} "/software/tomcat_handle.sh clear_files_front"
        done
}
clear_files_backend (){
    #删除项目目录
    echo "\033[32m Clear Deploy Files \033[0m"
    if [ ! -L ${Tomcat_Deploy_backend}/${project_name_backend}/assets/${images_link_name} ]; then
        rm -rf ${Tomcat_Deploy_backend}/*
    else
        echo "\033[32 Link symbol exists Don't delete "
    fi
    #删除远程项目目录
    echo "\033[32m Delete Remote files\033[0m"
    for ip in ${ip_address}
        do
            ssh ${ip} "/software/tomcat_handle.sh clear_files_backend"
        done

}
######开始部署
#5.移动相应文件到部署目录
move_files_front () {
    #移动本机部署文件
    for war in $deploy_files_name
        do
            if [ ${war} == cybershop-front-0.0.1-SNAPSHOT.war ] ; then
                mv $war_store_path${download_url##*/}|awk -F '.' '{print $1}'/${war} $Tomcat_Deploy_front/
            fi
        done
    #执行远程移动
    for ip in $ip_address
        do
            ssh $ip "/software/tomcat_handle.sh move_files_front"
        done
}
move_files_backend (){
    #移动本机部署文件
    for war in $deploy_files_name
        do
            if [ ${war} == cybershop-web-0.0.1-SNAPSHOT.war ] ; then
                cp $war_store_path${download_url##*/}|awk -F '.' '{print $1}'/${war} $Tomcat_Deploy_backend/
            fi
        done
    #执行远程移动
    for ip in $ip_address
        do
            ssh ${ip} "/software/tomcat_handle.sh move_files_backend"
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
    #启动远程 Tomcat
    for ip in ${ip_address}
        do
            ssh ${ip} "/software/tomcat_handle.sh start_front"
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
    #启动远程 Tomcat
    for ip in ${ip_address}
        do
            ssh ${ip} "/software/tomcat_handle.sh start_backend"
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
    # 创建远程 Link
    for ip in ${ip_address}
        do
            echo "\033[32m Create ${ip} Links\033[0m"
            ssh ${ip} "/software/tomcat_handle.sh create_link_front"
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
    # 创建远程 Link
    for ip in ${ip_address}
        do
            echo "\033[32m Create ${ip} Links\033[0m"
            ssh ${ip} "/software/tomcat_handle.sh create_link_backend"
        done

}
discover_front () {
       #检测本机服务
       curl -I http://localhost:8080
       #检测远程服务
       for ip in ${ip_address}
            do
                ssh ${ip} "/software/tomcat_handle.sh discover_front"
            done
}
discover_web (){
       #检测本机服务
       curl -I http://localhost:8081
       #检测远程服务
       for ip in ${ip_address}
            do
                ssh ${ip} "/software/tomcat_handle.sh discover_web"
            done

}
#######部署完毕
main (){
download_url="$2"
    case $1 in
        front )
           stop_front;
           unlink_front;
           clear_files_front;
           clear;
           move_files_front;
           start_front;
           create_link_front;
           discover_front;
           ;;
        web )
            stop_backend;
            unlink_backend;
            clear_files_backend;
            clear;
            move_files_backend;
            start_backend;
            create_link_backend;
            discover_web;
            ;;
        *)
	        echo "Usage:$0(front|web)"
            exit 1
            ;;
    esac
}
main $1 $2