#!/bin/bash
# Interactive PoPToP install script for an OpenVZ VPS
# Tested on Debian 5, 6, and Ubuntu 11.04
# April 2, 2013 v1.11
# Author: Commander Waffles
# http://www.putdispenserhere.com/pptp-debian-ubuntu-openvz-setup-script/

echo "######################################################"
echo "www.freefeenet.ga"
echo "Pastikan PPP VPS anda enable sebelum menjalankan script ini"
echo "Piih no 1 jika VPS anda belum di install PPTP VPN"
echo "Jika sudah diinstall, jika mau menambah user pilih no 2 ."
echo "######################################################"
echo "######################################################"
echo "Opsi Pilihan:"
echo "1) Setup PPTP VPN dan buat user baru"
echo "2) Tambah user saja"
echo "######################################################"
read x
if test $x -eq 1; then
	echo "ketik username yang ingin ente buat(contoh : prapto):"
	read u
	echo "ketikkan passwordnya: (contoh : ganteng)"
	read p

# get the VPS IP
ip=`ifconfig venet0:0 | grep 'inet addr' | awk {'print $2'} | sed s/.*://`

echo "######################################################"
echo "Downloading and Installing PoPToP"
echo "######################################################"
apt-get update
apt-get -y install pptpd

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

echo "######################################################"
echo "Forwarding IPv4 and Enabling it on boot"
echo "######################################################"
cat >> /etc/sysctl.conf <<END
net.ipv4.ip_forward=1
END
sysctl -p

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

echo "######################################################"
echo "Restarting PoPToP"
echo "######################################################"
sleep 5
/etc/init.d/pptpd restart

echo "######################################################"
echo "Server setup complete!"
echo "Connect PPTP VPN dengan IP $ip :"
echo "Username:$u ##### Password: $p"
echo "######################################################"

# runs this if option 2 is selected
elif test $x -eq 2; then
	echo "ketik username yang ingin ente buat (contoh : prapto):"
	read u
	echo "ketikkan passwordnya:  (contoh : ganteng)"
	read p

# get the VPS IP
ip=`ifconfig venet0:0 | grep 'inet addr' | awk {'print $2'} | sed s/.*://`

# adding new user
echo "$u	*	$p	*" >> /etc/ppp/chap-secrets

echo "######################################################"
echo "SIAP PAKAI BRO. User PPTP VPN sudah ditambah!"
echo "Connect PPTP VPN dengan IP $ip :"
echo "Username:$u ##### Password: $p"
echo "######################################################"

else
echo "Invalid selection, quitting."
exit
fi