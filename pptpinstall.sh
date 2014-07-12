#!/bin/bash
# Interactive PoPToP install script for XEN VPS
# Tested on Debian 5, 6, and Ubuntu 11.04
# July, 2013 v1.11
# Author: Commander Waffles modified by Regolithmedia
# http://www.putdispenserhere.com/pptp-debian-ubuntu-openvz-setup-script/

echo "######################################################"
echo "Interactive PoPToP Install Script for an Debian XEN VPS"
echo "Modified by Regolithmedia for Cloud Vps"
echo
echo "######################################################"
echo
echo
echo "######################################################"
echo "Select on option:"
echo "1) Set up new PoPToP server AND create one user"
echo "2) Create additional users"
echo "######################################################"
read x
if test $x -eq 1; then
	echo "Enter username that you want to create (eg. client1 or john):"
	read u
	echo "Specify password that you want the server to use:"
	read p

# get the VPS IP
ip=`grep address /etc/network/interfaces | grep -v 127.0.0.1 | awk '{print $2}'`

echo
echo "######################################################"
echo "Downloading and Installing PoPToP"
echo "######################################################"
apt-get update
apt-get -y install pptpd

echo
echo "######################################################"
echo "Creating Server Config"
echo "######################################################"
cat > /etc/ppp/pptpd-options <<END
name pptpd
refuse-pap
refuse-chap
refuse-mschap
require-mschap-v2
require-mppe-128
ms-dns 8.8.8.8
ms-dns 8.8.4.4
proxyarp
nodefaultroute
lock
nobsdcomp
END

# setting up pptpd.conf
echo "option /etc/ppp/pptpd-options" > /etc/pptpd.conf
echo "logwtmp" >> /etc/pptpd.conf
echo "localip $ip" >> /etc/pptpd.conf
echo "remoteip 10.1.0.1-100" >> /etc/pptpd.conf

# adding new user
echo "$u	*	$p	*" >> /etc/ppp/chap-secrets

echo
echo "######################################################"
echo "Forwarding IPv4 and Enabling it on boot"
echo "######################################################"
cat >> /etc/sysctl.conf <<END
net.ipv4.ip_forward=1
END
sysctl -p

echo
echo "######################################################"
echo "Updating IPtables Routing and Enabling it on boot"
echo "######################################################"
iptables -t nat -A POSTROUTING -j SNAT --to $ip
# saves iptables routing rules and enables them on-boot
iptables-save > /etc/iptables.conf

cat > /etc/network/if-pre-up.d/iptables <<END
#!/bin/sh
iptables-restore < /etc/iptables.conf
END

chmod +x /etc/network/if-pre-up.d/iptables
cat >> /etc/ppp/ip-up <<END
ifconfig ppp0 mtu 1400
END

echo
echo "######################################################"
echo "Restarting PoPToP"
echo "######################################################"
sleep 5
/etc/init.d/pptpd restart

echo
echo "######################################################"
echo "Server setup complete!"
echo "Connect to your VPS at $ip with these credentials:"
echo "Username:$u ##### Password: $p"
echo "######################################################"

# runs this if option 2 is selected
elif test $x -eq 2; then
	echo "Enter username that you want to create (eg. client1 or john):"
	read u
	echo "Specify password that you want the server to use:"
	read p

# get the VPS IP
ip=`grep address /etc/network/interfaces | grep -v 127.0.0.1 | awk '{print $2}'`

# adding new user
echo "$u	*	$p	*" >> /etc/ppp/chap-secrets

echo
echo "######################################################"
echo "Addtional user added!"
echo "Connect to your VPS at $ip with these credentials:"
echo "Username:$u ##### Password: $p"
echo "######################################################"

else
echo "Invalid selection, quitting."
exit
fi