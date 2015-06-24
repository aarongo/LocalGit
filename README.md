#Gitlab and CollabNet Install For Centos 6.4

    GitLab                              Subversion
    操作系统:Centos6.4 64位             操作系统:Centos6.4 64位
    Web服务器: apache                   Python Python-devel(2.4--2.6)
    数据库版本:MySQL 5.5.44             JDK版本:JDK1.7
    GitLab 7.11.4                       CollabNetSubversionEdge-5.0.1_linux-x86_64
    GitLab Shell 2.6.3
    GitLab API V3
    Ruby 2.1.0p0
    Rails 4.1.9
##GitLab
##Start the instance
    service gitlab start|restart|status
    service httpd start|restart|status
##Screenshots during installation
###bundle Install Success
![](https://raw.githubusercontent.com/aarongo/LocalGit/InstallationDocument/images/bundle-install.jpg)
###gitlab Install Error
![](https://github.com/aarongo/LocalGit/blob/InstallationDocument/images/gitlab-install-bundler-error.jpg)
###yum repolist Success
![](https://github.com/aarongo/LocalGit/blob/InstallationDocument/images/yum%20repolist.jpg)
###gitlab and Webserver Install Success
![](https://github.com/aarongo/LocalGit/blob/InstallationDocument/images/%E6%89%80%E6%9C%89%E6%9C%8D%E5%8A%A1%E5%AE%89%E8%A3%85%E6%88%90%E5%8A%9F%E8%AE%BF%E9%97%AE%E6%88%AA%E5%9B%BE.jpg)
##Subversion
##Start the instance
    /home/subversion/csvn/bin/csvn start|stop|restart
##start Success

##Access Method
