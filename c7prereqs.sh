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
  echo "Webmin will be installed."
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

#Install ntp
if rpm -q ntp > /dev/null; then
  echo "Package ntp is already installed."; 
else
  yum install ntp -y
  systemctl start ntpd
  systemctl enable ntpd
fi

#Install open-vm-tools
if rpm -q open-vm-tools > /dev/null; then
  echo "Package open-vm-tools is already installed."; 
elif dmidecode -s system-product-name | grep VMware > /dev/null; then
  echo "You are running on VMware. Open VM Tools will now be installed.";
  yum install open-vm-tools -y
  systemctl start vmtoolsd.service
  systemctl enable vmtoolsd.service
else
  yum install open-vm-tools -y
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

#Secure SSH
#sed -i 's/^#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/^#Protocol 2/Protocol 2/' /etc/ssh/sshd_config

#Install vim
if rpm -q vim-enhanced > /dev/null; then
  echo "Package vim is already installed."; 
else
  yum install vim -y
fi

#Install nano
if rpm -q nano > /dev/null; then
  echo "Package nano is already installed."; 
else
  yum install nano -y
fi

#Install wget
if rpm -q wget > /dev/null; then
  echo "Package wget is already installed."; 
else
  yum install wget -y
fi

#Install unzip
if rpm -q unzip > /dev/null; then
  echo "Package unzip is already installed."; 
else
  yum install unzip -y
fi

#Install rsync
if rpm -q rsync > /dev/null; then
  echo "Package rsync is already installed."; 
else
  yum install rsync -y
fi

#Install net-tools
if rpm -q net-tools > /dev/null; then
  echo "Package net-tools is already installed."; 
else
  yum install net-tools -y
fi

#Install iptraf
if rpm -q iptraf-ng > /dev/null; then
  echo "Package iptraf is already installed."; 
else
  yum install iptraf -y
fi

#Install iftop
if rpm -q iftop > /dev/null; then
  echo "Package iftop is already installed."; 
else
  yum install iftop -y
fi

#Install mtr
if rpm -q mtr > /dev/null; then
  echo "Package mtr is already installed."; 
else
  yum install mtr -y
fi

#Install iperf
if rpm -q iperf > /dev/null; then
  echo "Package iperf is already installed."; 
else
  yum install iperf -y
fi

#Install bind-utils
if rpm -q bind-utils > /dev/null; then
  echo "Package bind-utils is already installed."; 
else
  yum install bind-utils -y
fi

#Install dstat
if rpm -q dstat > /dev/null; then
  echo "Package dstat is already installed."; 
else
  yum install dstat -y
fi

#Install Webmin part 2
if [[ "$WEBMININSTALL" = 'y' ]]; then
  wget http://www.webmin.com/download/rpm/webmin-current.rpm
  yum install perl perl-Net-SSLeay openssl perl-IO-Tty perl-Encode-Detect -y
  rpm -U webmin-current.rpm
  iptables -I INPUT -p tcp -m tcp --dport 10000 -j ACCEPT
  service iptables save
fi

#Update CentOS - redo
yum update -y

#Reboot
echo "This host will now reboot."
sleep 5
#reboot
