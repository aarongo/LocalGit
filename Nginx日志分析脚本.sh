#!/usr/bin/env python
# coding=utf-8

#------------------------------------------------------
# Name:         nginx 日志分析脚本
# Purpose:      此脚本只用来分析nginx的访问日志
# Version:      1.0
# Author:       LEO
# BLOG:         http://linux5588.blog.51cto.com
# EMAIL:        chanyipiaomiao@163.com
# Created:      2013-05-07
# Modified:     2013-05-07
# Copyright:    (c) LEO 2013
#------------------------------------------------------

import sys
from time import clock

#该类是用来打印格式
class displayFormat(object):

    def format_size(self,size):
        '''格式化流量单位'''
        KB = 1024           #KB -> B  B是字节
        MB = 1048576        #MB -> B  1024 * 1024
        GB = 1073741824     #GB -> B  1024 * 1024 * 1024
        TB = 1099511627776  #TB -> B  1024 * 1024 * 1024 * 1024
        if size >= TB :
            size = str(size >> 40) + 'T'
        elif size < KB :
            size = str(size) + 'B'
        elif size >= GB and size < TB:
            size = str(size >> 30) + 'G'
        elif size >= MB and size < GB :
            size = str(size >> 20) + 'M'
        else :
            size = str(size >> 10) + 'K'
        return size

    #定义字符串格式化
    formatstring = '%-15s %-10s %-12s %8s %10s %10s %10s %10s %10s %10s %10s'

    def transverse_line(self) :
        '''输出横线'''
        print self.formatstring % ('-'*15,'-'*10,'-'*12,'-'*12,'-'*10,'-'*10,'-'*10,'-'*10,'-'*10,'-'*10,'-'*10)

    def head(self):
        '''输出头部信息'''
        print self.formatstring % ('IP','Traffic','Times','Times%','200','404','500','403','302','304','503')

    def error_print(self) :
        '''输出错误信息'''
        print
        print 'Usage : ' + sys.argv[0] + ' NginxLogFilePath [Number]'
        print
        sys.exit(1)

    def execut_time(self):
        '''输出脚本执行的时间'''
        print
        print "Script Execution Time: %.3f second" % clock()
        print

#该类是用来生成主机信息的字典
class hostInfo(object):
    #每个主机信息,如某个主机200出现的次数 请求的次数 该主机请求的流量之和
    host_info = ['200','404','500','302','304','503','403','times','size']

    def __init__(self,host):
        self.host = host = {}.fromkeys(self.host_info,0)

    def increment(self,status_times_size,is_size):
        '''该方法是用来给host_info中的各个值加1'''
        if status_times_size == 'times':
            self.host['times'] += 1
        elif is_size:
            self.host['size'] = self.host['size'] + status_times_size
        else:
            self.host[status_times_size] += 1

    def get_value(self,value):
        '''该方法是取到各个主机信息中对应的值'''
        return self.host[value]

#该类是用来分析文件
class fileAnalysis(object):
    def __init__(self):
        '''初始化一个空字典'''
        self.report_dict = {}
        self.total_request_times,self.total_traffic,self.total_200, \
        self.total_404,self.total_500,self.total_403,self.total_302, \
        self.total_304,self.total_503 = 0,0,0,0,0,0,0,0,0

    def split_eachline_todict(self,line):
        '''分割文件中的每一行，并返回一个字典'''
        split_line = line.split()
        split_dict = {'remote_host':split_line[0],'status':split_line[8],\
                      'bytes_sent':split_line[9],}
        return split_dict

    def generate_log_report(self,logfile):
        '''读取文件，分析split_eachline_todict方法生成的字典'''
        #遍历这个日志文件，出现错误的行（如:空行或split拆分时出现错误的行），跳过继续
        for line in logfile:
            try:
                line_dict = self.split_eachline_todict(line)
                host = line_dict['remote_host']
                status = line_dict['status']
            except ValueError :
                continue
            except IndexError :
                continue

            #如果这个主机（键）在report_dict不存在，就初始化一个该主机的对象，然后把该对象赋值给该键（该主机）
            #如果存在，那么就取出该主机的值（也就是主机对象）
            if host not in self.report_dict :
                host_info_obj = hostInfo(host)
                self.report_dict[host] = host_info_obj
            else :
                host_info_obj = self.report_dict[host]

            host_info_obj.increment('times',False)      #主机的请求次数进行加1
            if status in host_info_obj.host_info :      #如果得到的状态在事先定义好的列表里面
                host_info_obj.increment(status,False)   #主机的状态数进行加1
            try:
                bytes_sent = int(line_dict['bytes_sent'])   #转换字节为int类型
            except ValueError:
                bytes_sent = 0
            host_info_obj.increment(bytes_sent,True)    #主机的访问的字节数
        return self.report_dict

    def return_sorted_list(self,true_dict):
        '''计算各个状态次数、流量总量，请求的总次数，并且计算各个状态的总量 并生成一个正真的字典，方便排序'''
        for host_key in true_dict :
            host_value = true_dict[host_key]
            times = host_value.get_value('times')                          #每个IP地址请求的次数
            self.total_request_times = self.total_request_times + times     #各个请求次数之和
            size = host_value.get_value('size')                            #每个IP地址请求的字节数
            self.total_traffic = self.total_traffic + size                  #各个IP请求字节数之和

            o200 = host_value.get_value('200')
            o404 = host_value.get_value('404')
            o500 = host_value.get_value('500')
            o403 = host_value.get_value('403')
            o302 = host_value.get_value('302')
            o304 = host_value.get_value('304')
            o503 = host_value.get_value('503')

            #生成一个真正的字典方便排序,这之前主机对应的值其实是一个对象
            true_dict[host_key] = {'200':o200,'404':o404,'500':o500,\
                                   '403':o403,'302':o302,'304':o304, \
                                   '503':o503,'times':times,'size':size}

            #计算各个状态总量
            self.total_200 = self.total_200 + o200
            self.total_404 = self.total_404 + o404
            self.total_500 = self.total_500 + o500
            self.total_302 = self.total_302 + o302
            self.total_304 = self.total_304 + o304
            self.total_503 = self.total_503 + o503

        #生成的真正的字典按照先请求次数排序，然后再安装请求的字节数进行排序
        sorted_list = sorted(true_dict.items(),key=lambda t:(t[1]['times'],\
                                                             t[1]['size']),reverse=True)

        return sorted_list

class Main(object):
    def main(self) :
        '''主调函数'''

        #初始化一个displayFormat类的实例，打印报告的行头
        display_format = displayFormat()

        #判断命令行参数是否为空及判断命令行传进来的文件是否是有效的文件
        arg_length = len(sys.argv)
        if arg_length == 1 :
            display_format.error_print()
        elif arg_length == 2 or arg_length == 3:
            infile_name = sys.argv[1]
            try :
                infile = open(infile_name,'r')
                if arg_length == 3 :
                    lines = int(sys.argv[2])
                else :
                    lines = 0
            except IOError,e :
                print
                print e
                display_format.error_print()
            except ValueError :
                print
                print "Please Enter A Volid Number !!"
                display_format.error_print()
        else :
            display_format.error_print()

        #实例化一个fileAnalysis类的对象
        fileAnalysis_obj = fileAnalysis()
        #调用generate_log_report方法生成字典
        not_true_dict = fileAnalysis_obj.generate_log_report(infile)
        #对上面生成的字典进行排序，生成一个有序列表
        log_report = fileAnalysis_obj.return_sorted_list(not_true_dict)
        total_ip = len(log_report)
        if lines :
            log_report = log_report[0:lines]
        infile.close()

        #打印报告头及横线
        print
        total_traffic = display_format.format_size(fileAnalysis_obj.total_traffic)
        total_request_times = fileAnalysis_obj.total_request_times
        print 'Total IP: %s   Total Traffic: %s   Total Request Times: %d' \
              % (total_ip,total_traffic,total_request_times)
        print
        display_format.head()
        display_format.transverse_line()

        #循环这个列表，打印主机的各个值
        for host in log_report :
            times = host[1]['times']
            times_percent = (float(times) / float(fileAnalysis_obj.total_request_times)) * 100
            print display_format.formatstring % (host[0],\
                                                 display_format.format_size(host[1]['size']),\
                                                 times,str(times_percent)[0:5],\
                                                 host[1]['200'],host[1]['404'],\
                                                 host[1]['500'],host[1]['403'],\
                                                 host[1]['302'],host[1]['304'],host[1]['503'])
        #打印报告的尾部及打印各个参数之后
        if (not lines) or total_ip == lines :
            display_format.transverse_line()
            print display_format.formatstring % (total_ip,total_traffic, \
                                                 total_request_times,'100%',\
                                                 fileAnalysis_obj.total_200,\
                                                 fileAnalysis_obj.total_404,\
                                                 fileAnalysis_obj.total_500, \
                                                 fileAnalysis_obj.total_403,\
                                                 fileAnalysis_obj.total_302, \
                                                 fileAnalysis_obj.total_304,\
                                                 fileAnalysis_obj.total_503)
        #输出脚本执行的时间
        display_format.execut_time()

if __name__ == '__main__':
    main_obj = Main()
    main_obj.main()