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
 echo -n "Please enter the new hostname: "
 read NEW_HOSTNAME < /dev/tty
echo ""
echo "Changing hostname from $HOSTNAME to $NEW_HOSTNAME..."
hostnamectl set-hostname $NEW_HOSTNAME
echo "hostname has been changed."
else
  echo ""
  echo "hostname is unchanged."
fi

#Install Webmin part 1
echo ""
read -p "Do you want to install Webmin? [y/n]: " -e -i n WEBMININSTALL
if [ "$WEBMININSTALL" = 'y' ]; then
  echo ""
  echo -n "Webmin will be installed."
else
  echo ""
  echo "Webmin will not be installed."
fi

sleep 5

#Update CentOS
yum update -y

#Disable SELinux
setenforce 0
sed -i "s|SELINUX=enforcing|SELINUX=disabled|" /etc/selinux/config

#Install EPEL
if rpm -q epel-release > /dev/null; then
  echo "Package epel-release is already installed.";
else 
  yum install epel-release -y
fi

#Install NTP
if rpm -q ntp > /dev/null; then
  echo "Package ntp is already installed."; 
else
  yum install ntp -y
  systemctl start ntpd
  systemctl enable ntpd
fi

#Install Vmware Tools (Open VM Tools)
if dmidecode -s system-product-name | grep VMware > /dev/null; then
  echo "You are running on VMware. Open VM Tools will now be installed.";
  yum install open-vm-tools -y
  systemctl start vmtoolsd.service
  systemctl enable vmtoolsd.service
fi

#Disable firewalld
systemctl disable firewalld
systemctl mask firewalld.service
systemctl stop firewalld.service

#Install iptables
if rpm -q iptables-services > /dev/null; then
  echo "Package iptables-services is already installed."; 
else
  yum install iptables-services -y
  systemctl enable iptables.service
  systemctl start iptables.service
fi

#Install Fail2Ban
if rpm -q fail2ban > /dev/null; then
  echo "Package fail2ban is already installed."; 
else
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
fi

#Install Yubico
if rpm -q pam_yubico > /dev/null; then
  echo "Package pam_yubico is already installed."; 
else
  yum install pam_yubico -y
fi

#Install Webmin part 2
if [[ "$WEBMININSTALL" = 'y' ]]; then
  wget http://www.webmin.com/download/rpm/webmin-current.rpm
  yum install perl perl-Net-SSLeay openssl perl-IO-Tty perl-Encode-Detect -y
  rpm -U webmin-current.rpm
  iptables -I INPUT -p tcp -m tcp --dport 10000 -j ACCEPT
  service iptables save
fi

#Secure SSH
#sed -i 's/^#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/^#Protocol 2/Protocol 2/' /etc/ssh/sshd_config

#Install useful tools
yum install vim nano wget unzip rsync -y

#Install monitoring tools
yum install net-tools iptraf iftop mtr iperf bind-utils dstat -y

#Update CentOS - redo
yum update -y

#Reboot
echo "This host will now reboot."
sleep 5
#reboot
