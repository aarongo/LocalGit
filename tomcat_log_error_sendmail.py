#!/usr/bin/env python
# coding=utf-8

#---------------------------------------------------------
# Name:         Tomcat错误日志发送邮件脚本
# Purpose:      收集Tomcat异常日志并发送邮件
# Version:      1.0
# Author:       LEO
# Copyright:    (c) LEO 2013
# Python：       2.7/2.4  皆可使用
#--------------------------------------------------------

from smtplib import SMTP
from email import MIMEText
from email import Header
from os.path import getsize
from sys import exit
from re import compile, IGNORECASE


#定义主机 帐号 密码 收件人 邮件主题
smtpserver = 'smtp.163.com'
sender = '帐号/发件人'
password = '密码'
receiver = ('收件人1','收件人2',)
subject = u'Web服务器Tomcat日志错误信息'
From = u'xxx Web服务器'
To = u'服务器管理员'

#定义tomcat日志文件位置
tomcat_log = '/usr/local/tomcat/logs/catalina.out'

#该文件是用于记录上次读取日志文件的位置,执行脚本的用户要有创建该文件的权限
last_position_logfile = '/tmp/last_position.txt'

#匹配的错误信息关键字的正则表达式
pattern = compile(r'Exception|^\t+\bat\b',IGNORECASE)

#发送邮件函数
def send_mail(error):

    #定义邮件的头部信息
    header = Header.Header
    msg = MIMEText.MIMEText(error,'plain','utf-8')
    msg['From'] = header(From)
    msg['To'] = header(To)
    msg['Subject'] = header(subject+'\n')

    #连接SMTP服务器，然后发送信息
    smtp = SMTP(smtpserver)
    smtp.login(sender, password)
    smtp.sendmail(sender, receiver, msg.as_string())
    smtp.close()


#读取上一次日志文件的读取位置
def get_last_position(file):
    try:
        data = open(file,'r')
        last_position = data.readline()
        if last_position:
            last_position = int(last_position)
        else:
            last_position = 0
    except:
        last_position = 0

    return last_position

#写入本次日志文件的本次位置
def write_this_position(file,last_positon):
    try:
        data = open(file,'w')
        data.write(str(last_positon))
        data.write('\n' + "Don't Delete This File,It is Very important for Looking Tomcat Error Log !! \n")
        data.close()
    except:
        print "Can't Create File !" + file
        exit()

#分析文件找出异常的行
def analysis_log(file):

    error_list = []                                        
    try:
        data = open(file,'r')
    except:
        exit()
        
    last_position = get_last_position(last_position_logfile)
    this_postion = getsize(tomcat_log)
    if this_postion < last_position:
        data.seek(0)
    elif this_postion == last_position:
        exit()
    elif this_postion > last_position:
        data.seek(last_position)

    for line in data:
        if pattern.search(line):
            error_list.append(line)
            
    write_this_position(last_position_logfile,data.tell())
    data.close()

    return ''.join(error_list)

#调用发送邮件函数发送邮件
error_info = analysis_log(tomcat_log)
if error_info:
    send_mail(error_info)
