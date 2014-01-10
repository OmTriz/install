#!/bin/bash

# go to root
cd

# set time GMT +7
ln -fs /usr/share/zoneinfo/Asia/Jakarta /etc/localtime

# repo
yum -y install yum-priorities
curl http://geekery.altervista.org/geekery-el5-i386.repo > /etc/yum.repos.d/geekery-el5-i386.repo
wget http://packages.sw.be/rpmforge-release/rpmforge-release-0.5.2-2.el5.rf.i386.rpm
wget http://dl.fedoraproject.org/pub/epel/5/i386/epel-release-5-4.noarch.rpm
wget http://rpms.famillecollet.com/enterprise/remi-release-5.rpm
rpm -Uvh rpmforge-release-0.5.2-2.el5.rf.i386.rpm
rpm -Uvh epel-release-5-4.noarch.rpm
rpm -Uvh remi-release-5.rpm
rm -f *.rpm
sed -i '/\[rpmforge\]/ a\priority=10' /etc/yum.repos.d/rpmforge.repo
sed -i '/\[rpmforge-extras\]/ a\priority=10' /etc/yum.repos.d/rpmforge.repo
sed -i '/\[epel\]/ a\priority=15' /etc/yum.repos.d/epel.repo
sed -i '/\[remi\]/ a\priority=20' /etc/yum.repos.d/remi.repo
sed -i -e "/^\[remi\]/,/^\[.*\]/ s|^\(enabled[ \t]*=[ \t]*0\\)|enabled=1|" /etc/yum.repos.d/remi.repo
sed -i -e "/^\[rpmforge-extras\]/,/^\[.*\]/ s|^\(enabled[ \t]*=[ \t]*0\\)|enabled=1|" /etc/yum.repos.d/rpmforge.repo
yum -y update
yum -y groupinstall 'Development Tools'

#nano
yum -y install nano

# setting port ssh
echo "Port 143" >> /etc/ssh/sshd_config
echo "Port 995" >> /etc/ssh/sshd_config
service sshd restart
chkconfig sshd on

# install dropbear
yum -y install dropbear
echo "OPTIONS=\"-p 22 -p 109 -p 110 -p 443\"" > /etc/sysconfig/dropbear
echo "/bin/false" >> /etc/shells
service dropbear restart
chkconfig dropbear on

# vnstat
yum -y install vnstat
vnstat -u -i venet0
sed -i 's/eth0/venet0/g' /etc/sysconfig/vnstat
echo "MAILTO=root" > /etc/cron.d/vnstat
echo "*/5 * * * * root /usr/sbin/vnstat.cron" >> /etc/cron.d/vnstat

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

# autokill
cd /usr/sbin/
wget https://raw2.github.com/dutyzn/install/master/usermon
wget https://raw2.github.com/dutyzn/install/master/userlmt
chmod 755 usermon
chmod 755 userlmt
wget https://raw2.github.com/dutyzn/install/master/autokill.sh
chmod +x autokill.sh
screen -AmdS check /usr/sbin/autokill.sh
sed -i '$ i\screen -AmdS check /usr/sbin/autokill.sh' /etc/rc.local
