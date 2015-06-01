#!/bin/bash
groupadd zabbix
useradd -g zabbix zabbix

#Fro Linux zabbix_agent install
yum install -y gcc gcc-c++ curl curl-devel
#isntall
cd /install/packages
tar xzf zabbix-2.2.1.tar.gz
sleep 10
cd  /install/packages/zabbix-2.2.1
./configure --prefix=/install/zabbix_agent --enable-agent --with-net-snmp --with-libcurl && make && make install
#config zabbix_agent 
sed -i "/^Hostname=/c\#Hostname=Zabbix server" /software/zabbix/etc/zabbix_agentd.conf
sed -i 's/Server=127.0.0.1/Server=cslp75414u.cdc.carrefour.com/g' /install/zabbix_agent/etc/zabbix_agentd.conf
sed -i "s/ServerActive=127.0.0.1/\#ServerActive=127.0.0.1/g" /software/zabbix/etc/zabbix_agentd.conf
/install/zabbix_agent/sbin/zabbix_agentd



sed -i "s/ServerActive=127.0.0.1/\#ServerActive=127.0.0.1/g" /software/zabbix/etc/zabbix_agentd.conf && sed -i "s/ServerActive=127.0.0.1/\#ServerActive=127.0.0.1/g" /software/zabbix/etc/zabbix_agentd.conf