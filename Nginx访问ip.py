# _*_coding:utf-8_*_
import os

# ip地址列表
ip_list = []


def nginx_accessnum():
    command = os.system("cat /software/tengine/logs/10.90.6.34_access.log  | awk '{print $1,$6}' > list.txt")
    f = file("list.txt", "r")
    for line in f.readlines():
        ip_list.append(line.strip())
    print "\033[31m Nginx总的访问次数为：\033[0m", len(ip_list), "\n"
    # 首先遍历set集合，以遍历到的元素为值传给统计列表函数
    # 首先转换ip_list类型
    ip_set = set(ip_list)
    access_max = int(raw_input("请输入你过滤的访问次数："))
    print "\033[32m超过 %s 次访问的IP \033[0m --------\033[32m 访问次服务器的次数为：\033[0m" % access_max
    for item in ip_set:
        if ip_list.count(item) > access_max:
            print item, "--------------------", ip_list.count(item)
    f.close()


nginx_accessnum()
