#!/bin/bash 
init_front(){
#dir=`echo $2 |awk -F '/' '{print $4}'|awk -F '.' '{print $1}'`
#warname=`echo "$2" |awk -F '/' '{print $4}'`
#echo $2
#if [ ! $2 ];then
#echo "please input url"
#exit
#else

CODEBAS="/software/deploybak/"

if [ $? -eq 0 ];then
    mv $dir.tar.gz  /software/deploybak/
    tar -zxvf /software/deploybak/$warname
    sleep 5
    cd /software/deploybak/$dir
\cp -f cybershop-front-0.0.1-SNAPSHOT.war /software
scp cybershop-front-0.0.1-SNAPSHOT.war   10.151.246.34:/software/
scp cybershop-front-0.0.1-SNAPSHOT.war   10.151.246.36:/software/

  if [ $? -eq 0 ];then
    echo "the war scp end"
  fi

fi

}

down_war (){
	wget --proxy-user=ecommerce_china --proxy-passwd=xK8-4=gF $2
	dir=`echo $2 |awk -F '/' '{print $4}'|awk -F '.' '{print $1}'`
	warname=`echo "$2" |awk -F '/' '{print $4}'`

}

deploy_front(){
  ###########deploy web-node1#################
  echo "deploy the web-node1" 
  sudo /home/cdczhangg/deploy.sh stop
  rm -f  /software/deploy-front/cybershop-front-0.0.1-SNAPSHOT/www
  rm -f  /software/deploy-front/ROOT/www
  rm -f  /software/deploy-front/cybershop-front-0.0.1-SNAPSHOT/assets/upload
  rm -f  /software/deploy-front/ROOT/assets/upload
  if [ $? -eq 0 ];then
  echo "link cancel OK"
  else
  echo "link cancel failed"
  exit
  fi
  rm -rf  /software/deploy-front/* 
  mv /software/cybershop-front-0.0.1-SNAPSHOT.war /software/deploy-front
  sudo /home/cdczhangg/deploy.sh start
  until [ -d /software/deploy-front/cybershop-front-0.0.1-SNAPSHOT/assets ];do
     echo "the directory dosn't exists, sleep 5s"
     sleep 5
  done
  ####################link the uplod#####################
  ln -s /software/newupload /software/deploy-front/cybershop-front-0.0.1-SNAPSHOT/assets/upload
  ln -s /software/newupload /software/deploy-front/ROOT/assets/upload
  ln -s /data/www /software/deploy-front/cybershop-front-0.0.1-SNAPSHOT/www
  ln -s /data/www /software/deploy-front/ROOT/www
  if [ $? -eq 0 ];then
  echo "link  OK"
  else
  echo "link  failed"
  exit
  fi
  ###########deploy web-node2#################
  echo "deploy the web-node2" 
  sudo ssh 10.151.246.34 "/home/cdczhangg/deploy.sh stop"
  ssh 10.151.246.34 "rm -f  /software/deploy-front/cybershop-front-0.0.1-SNAPSHOT/www"
  ssh 10.151.246.34 "rm -f  /software/deploy-front/ROOT/www"
  ssh 10.151.246.34 "rm -f  /software/deploy-front/cybershop-front-0.0.1-SNAPSHOT/assets/upload"
  ssh 10.151.246.34 "rm -f  /software/deploy-front/ROOT/assets/upload"
  if [ $? -eq 0 ];then
  echo "link cancel OK"
  else
  echo "link cancel failed"
  exit
  fi
  ssh 10.151.246.34 "rm -rf  /software/deploy-front/* "
  ssh 10.151.246.34 "mv /software/cybershop-front-0.0.1-SNAPSHOT.war/ /software/deploy-front"
  sudo ssh 10.151.246.34 "/home/cdczhangg/deploy.sh start"
  ssh 10.151.246.34 "until [ -d /software/deploy-front/cybershop-front-0.0.1-SNAPSHOT/assets ];do echo "the directory dosn\'t exists, sleep 5s" sleep 5 ; done"
  ####################link the uplod#####################
  ssh 10.151.246.34 "ln -s /software/newupload /software/deploy-front/cybershop-front-0.0.1-SNAPSHOT/assets/upload"
  ssh 10.151.246.34 "ln -s /software/newupload /software/deploy-front/ROOT/assets/upload"
  ssh 10.151.246.34 "ln -s /data/www /software/deploy-front/cybershop-front-0.0.1-SNAPSHOT/www"
  ssh 10.151.246.34 "ln -s /data/www /software/deploy-front/ROOT/www"
  if [ $? -eq 0 ];then
  echo "link  OK"
  else
  echo "link  failed"
  fi
  ###########deploy web-node2#################
  echo "deploy the web-node3" 
  sudo ssh 10.151.246.36 "/home/cdczhangg/deploy.sh stop"
  ssh 10.151.246.36 "rm -f  /software/deploy-front/cybershop-front-0.0.1-SNAPSHOT/www"
  ssh 10.151.246.36 "rm -f  /software/deploy-front/ROOT/www"
  ssh 10.151.246.36 "rm -f  /software/deploy-front/cybershop-front-0.0.1-SNAPSHOT/assets/upload"
  ssh 10.151.246.36 "rm -f  /software/deploy-front/ROOT/assets/upload"
  if [ $? -eq 0 ];then
  echo "link cancel OK"
  else
  echo "link cancel failed"
  exit
  fi
  ssh 10.151.246.36 "rm -rf  /software/deploy-front/* "
  ssh 10.151.246.36 "mv /software/cybershop-front-0.0.1-SNAPSHOT.war/ /software/deploy-front"
  sudo ssh 10.151.246.36 "/home/cdczhangg/deploy.sh start"
  ssh 10.151.246.36 "until [ -d /software/deploy-front/cybershop-front-0.0.1-SNAPSHOT/assets ];do echo "the directory dosn\'t exists, sleep 5s" sleep 5 ; done"
  ####################link the uplod#####################
  ssh 10.151.246.36 "ln -s /software/newupload /software/deploy-front/cybershop-front-0.0.1-SNAPSHOT/assets/upload"
  ssh 10.151.246.36 "ln -s /software/newupload /software/deploy-front/ROOT/assets/upload"
  ssh 10.151.246.36 "ln -s /data/www /software/deploy-front/cybershop-front-0.0.1-SNAPSHOT/www"
  ssh 10.151.246.36 "ln -s /data/www /software/deploy-front/ROOT/www"
  if [ $? -eq 0 ];then
  echo "link  OK"
  else
  echo "link  failed"
  fi
}

init_web(){
  cd /software/deploybak
  
  if [ $? -eq 0 ];then
    mv $dir.tar.gz  /software/deploybak/
    tar -zxvf /software/deploybak/$warname
    sleep 5
    cd /software/deploybak/$dir
\cp -f cybershop-web-0.0.1-SNAPSHOT.war /software
scp cybershop-web-0.0.1-SNAPSHOT.war   10.151.246.34:/software/
scp cybershop-web-0.0.1-SNAPSHOT.war   10.151.246.36:/software/
if [ $? -eq 0 ];then
echo "the war scp end"
fi
fi
}                               

deploy_web(){
  ###########deploy web-node1#################
  echo "deploy the web-node1" 
  sudo /home/cdczhangg/deployend.sh stop
  rm -f  /software/deploy-backend/cybershop-web-0.0.1-SNAPSHOT/assets/upload
  rm -f  /software/deploy-backend/ROOT/assets/upload
  if [ $? -eq 0 ];then
  echo "link cancel OK"
  else
  echo "link cancel failed"
  exit
  fi
  rm -rf  /software/deploy-backend/* 
  mv /software/cybershop-web-0.0.1-SNAPSHOT.war/ /software/deploy-backend
  sudo /home/cdczhangg/deployend.sh start
  until [ -d /software/deploy-backend/cybershop-web-0.0.1-SNAPSHOT/assets ];do
     echo "the directory dosn't exists, sleep 5s"
     sleep 5
  done
  ####################link the uplod#####################
  ln -s /software/newupload /software/deploy-backend/cybershop-web-0.0.1-SNAPSHOT/assets/upload
  ln -s /software/newupload /software/deploy-backend/ROOT/assets/upload
  if [ $? -eq 0 ];then
  echo "link  OK"
  else
  echo "link  failed"
  exit
  fi
  ###########deploy web-node2#################
  echo "deploy the web-node2" 
  sudo ssh 10.151.246.34 "/home/cdczhangg/deployend.sh stop"
  ssh 10.151.246.34 "rm -f  /software/deploy-backend/cybershop-web-0.0.1-SNAPSHOT/assets/upload"
  ssh 10.151.246.34 "rm -f  /software/deploy-backend/ROOT/assets/upload"
  if [ $? -eq 0 ];then
  echo "link cancel OK"
  else
  echo "link cancel failed"
  exit
  fi
  ssh 10.151.246.34 "rm -rf  /software/deploy-backend/* " 
  ssh 10.151.246.34 "mv /software/cybershop-web-0.0.1-SNAPSHOT.war/ /software/deploy-backend"
  sudo ssh 10.151.246.34 "/home/cdczhangg/deployend.sh start"
  ssh 10.151.246.34 "until [ -d /software/deploy-backend/cybershop-web-0.0.1-SNAPSHOT/assets ];do echo "the directory dosn\'t exists, sleep 5s" sleep 5 ; done"
  ####################link the uplod#####################
  ssh 10.151.246.34 "ln -s /software/newupload /software/deploy-backend/cybershop-web-0.0.1-SNAPSHOT/assets/upload"
  ssh 10.151.246.34 "ln -s /software/newupload /software/deploy-backend/ROOT/assets/upload"
  if [ $? -eq 0 ];then
  echo "link  OK"
  else
  echo "link  failed"
  fi
  ###########deploy web-node2#################
  echo "deploy the web-node3" 
  sudo ssh 10.151.246.36 "/home/cdczhangg/deployend.sh stop"
  ssh 10.151.246.36 "rm -f  /software/deploy-backend/cybershop-web-0.0.1-SNAPSHOT/assets/upload"
  ssh 10.151.246.36 "rm -f  /software/deploy-backend/ROOT/assets/upload"
  if [ $? -eq 0 ];then
  echo "link cancel OK"
  else
  echo "link cancel failed"
  exit
  fi
  ssh 10.151.246.36 "rm -rf  /software/deploy-backend/* "
  ssh 10.151.246.36 "mv /software/cybershop-web-0.0.1-SNAPSHOT.war/ /software/deploy-backend"
  sudo ssh 10.151.246.36 "/home/cdczhangg/deployend.sh start"
  ssh 10.151.246.36 "until [ -d /software/deploy-backend/cybershop-web-0.0.1-SNAPSHOT/assets ];do echo "the directory dosn\'t exists, sleep 5s" sleep 5 ; done"
  ####################link the uplod#####################
  ssh 10.151.246.36 "ln -s /software/newupload /software/deploy-backend/cybershop-web-0.0.1-SNAPSHOT/assets/upload"
  ssh 10.151.246.36 "ln -s /software/newupload /software/deploy-backend/ROOT/assets/upload"
  if [ $? -eq 0 ];then
  echo "link  OK"
  else
  echo "link  failed"
  fi
}

main (){
case $1 in 
      front)
	down_war;
        init_front;
        deploy_front;
        ;;

      web)
	down_war;
        init_web;
        deploy_web;
        ;;
      *)
       echo "please use ./jlf_deploy.sh front|web "url""
       exit;
esac  
}


main $1 $2

