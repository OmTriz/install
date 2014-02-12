#!/bin/bash

# go to root
cd

# set time GMT +7
ln -fs /usr/share/zoneinfo/Asia/Jakarta /etc/localtime

# repo
yum -y install yum-priorities
rpm -Uvh http://packages.sw.be/rpmforge-release/rpmforge-release-0.5.2-2.el6.rf.i686.rpm
rpm -Uvh http://download.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm
rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-6.rpm
yum -y update
yum -y groupinstall 'Development Tools'

#nano
yum -y install nano

# setting port ssh
echo "Port 143" >> /etc/ssh/sshd_config
echo "Port 109" >> /etc/ssh/sshd_config
service sshd restart
chkconfig sshd on

# install dropbear
yum -y install dropbear
echo "OPTIONS=\"-p 22 -p 110 -p 443\"" > /etc/sysconfig/dropbear
echo "/bin/false" >> /etc/shells
service dropbear restart
chkconfig dropbear on

# install webmin
wget http://prdownloads.sourceforge.net/webadmin/webmin-1.660-1.noarch.rpm
rpm -i webmin-1.660-1.noarch.rpm;
rm webmin-1.660-1.noarch.rpm
service webmin restart

# user login
wget https://raw2.github.com/dutyzn/install/master/user-login.sh
sed -i 's/auth.log/secure/g' user-login.sh
chmod +x user-login.sh

# speedtest
wget http://proxy.ninit.us/speedtest_cli.py
