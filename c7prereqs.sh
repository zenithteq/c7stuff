#!/bin/bash

#curl -o c7prereqs.sh https://raw.githubusercontent.com/zenithteq/c7stuff/master/c7prereqs.sh && bash c7prereqs.sh

#Change hostname
HOSTNAME=$(hostname)
NEW_HOSTNAME="$1"
IP=$(ip addr | grep 'inet' | grep -v inet6 | grep -vE '127\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -o -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | head -1)
if [[ "$IP" = "" ]]; then
		IP=$(wget -4qO- "http://whatismyip.akamai.com/")
fi
clear
echo "Current IP is:" $IP
echo "Current hostname is:" $HOSTNAME
echo ""
read -p "Do you want to change the hostname? [y/n]: " -e -i n NEW_HOSTNAME
if [ "$NEW_HOSTNAME" = 'y' ]; then
 echo -n "Please enter new hostname: "
 read NEW_HOSTNAME < /dev/tty
echo ""
echo "Changing hostname from $HOSTNAME to $NEW_HOSTNAME..."
hostnamectl set-hostname $NEW_HOSTNAME
echo "Done."
else
  echo "hostname unchanged"
fi

#Install Webmin part 1
clear
read -p "Do you want to install Webmin? [y/n]: " -e -i n INSTALL

#Update CentOS
yum update -y

#Disable SELinux
setenforce 0
sed -i "s|SELINUX=enforcing|SELINUX=disabled|" /etc/selinux/config

#Install EPEL
yum install epel-release -y

#Install useful tools
yum install vim nano wget unzip rsync -y

#Install monitoring tools
yum install net-tools iptraf iftop mtr iperf bind-utils dstat -y

##Install NTP
yum install ntp -y
systemctl start ntpd
systemctl enable ntpd

#Install Vmware Tools (Open VM Tools)
#yum install open-vm-tools -y
#systemctl start vmtoolsd.service
#systemctl enable vmtoolsd.service

#Disable firewalld
systemctl disable firewalld
systemctl mask firewalld.service
systemctl stop firewalld.service

#Install iptables
yum install iptables-services -y
systemctl enable iptables.service
systemctl start iptables.service

#Install Webmin part 2
if [[ "$INSTALL" = 'y' ]]; then
  wget http://www.webmin.com/download/rpm/webmin-current.rpm
  yum install perl perl-Net-SSLeay openssl perl-IO-Tty -y
  rpm -U webmin-current.rpm
  iptables -I INPUT -p tcp -m tcp --dport 10000 -j ACCEPT
  service iptables save
fi

#Install Fail2Ban
yum install fail2ban -y
systemctl enable fail2ban
echo "[DEFAULT]
# Ban hosts for one hour:
bantime = 3600
# Override /etc/fail2ban/jail.d/00-firewalld.conf:
banaction = iptables-multiport
[sshd]
enabled = true" > /etc/fail2ban/jail.local
systemctl restart fail2ban

#Update CentOS - redo
yum update -y

#Install Yubico
yum install pam_yubico -y

#Secure SSH
sed -i 's/^#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/^#Protocol 2/Protocol 2/' /etc/ssh/sshd_config

#Reboot
reboot
