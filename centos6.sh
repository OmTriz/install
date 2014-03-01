#!/bin/bash

# go to root
cd

# set time GMT +7
ln -fs /usr/share/zoneinfo/Asia/Jakarta /etc/localtime

# install wget and curl
yum -y install wget curl screen

# remove unused
yum -y remove sendmail;
yum -y remove httpd;
yum -y remove cyrus-sasl

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

# install badvpn
wget -O /usr/bin/badvpn-udpgw "https://raw.github.com/dutyzn/install/master/badvpn-udpgw"
sed -i '$ i\screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300' /etc/rc.local
sed -i '$ i\screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300' /etc/rc.d/rc.local
chmod +x /usr/bin/badvpn-udpgw
screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300

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
