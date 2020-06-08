#!/bin/bash

#curl -o c7prereqs-no-vm-agent.sh https://bit.ly/2ARtkoo && bash c7prereqs-no-vm-agent.sh

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

sleep 5

#Update CentOS
echo ""
echo -n "Now updating CentOS"
yum update -y -q &> /dev/null
echo ""
echo "CentOS update done."

#Disable SELinux
echo ""
echo "Disabling SELinux"
setenforce 0
sed -i "s|SELINUX=enforcing|SELINUX=disabled|" /etc/selinux/config

#Install EPEL
if rpm -q epel-release > /dev/null; then
  echo "Package epel-release is already installed.";
else
  echo ""
  echo "Now installing epel"
  yum install epel-release -y -q
fi

#Install yum-cron
if rpm -q yum-cron > /dev/null; then
  echo "Package yum-cron is already installed."; 
else
  echo ""
  echo "Now installing yum-cron"
  yum install yum-cron -y -q
  systemctl start yum-cron
  systemctl enable yum-cron
  sed -i 's/^update_cmd = default/update_cmd = security/' /etc/yum/yum-cron.conf
  sed -i 's/^apply_updates = no/apply_updates = yes/' /etc/yum/yum-cron.conf
fi

#Install ntp
if rpm -q ntp > /dev/null; then
  echo "Package ntp is already installed."; 
else
  echo ""
  echo "Now installing ntp"
  yum install ntp -y -q
  systemctl start ntpd
  systemctl enable ntpd
fi

#Disable firewalld
echo ""
echo "Now disabling firewalld."
systemctl disable firewalld
systemctl mask firewalld.service
systemctl stop firewalld.service

#Install iptables
if rpm -q iptables-services > /dev/null; then
  echo "Package iptables-services is already installed."; 
else
  echo ""
  echo "Now installing iptables"
  yum install iptables-services -y -q
  systemctl enable iptables.service
  systemctl start iptables.service
fi

#Install Fail2Ban
if rpm -q fail2ban > /dev/null; then
  echo "Package fail2ban is already installed."; 
else
  echo ""
  echo "Now installing fail2ban"
  yum install fail2ban -y -q
  systemctl enable fail2ban
echo "[DEFAULT]
# Ban hosts for one hour:
bantime = 3600
#
banaction = iptables-multiport
#
[sshd]
enabled = true" > /etc/fail2ban/jail.local
  systemctl restart fail2ban
fi

#Install Yubico
if rpm -q pam_yubico > /dev/null; then
  echo "Package pam_yubico is already installed."; 
else
  echo ""
  echo "Now installing Yubico"
  yum install pam_yubico -y -q
fi

#Install Google Authenticator
if rpm -q google-authenticator > /dev/null; then
  echo "Package google-authenticator is already installed."; 
else
  echo ""
  echo "Now installing Google Authenticator"
  yum install google-authenticator -y -q
fi

#Secure SSH
#sed -i 's/^#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/^#Protocol 2/Protocol 2/' /etc/ssh/sshd_config

#Install vim
if rpm -q vim-enhanced > /dev/null; then
  echo "Package vim is already installed."; 
else
  echo ""
  echo "Now installing vim"
  yum install vim -y -q
fi

#Install nano
if rpm -q nano > /dev/null; then
  echo "Package nano is already installed."; 
else
  echo ""
  echo "Now installing nano"
  yum install nano -y -q
fi

#Install wget
if rpm -q wget > /dev/null; then
  echo "Package wget is already installed."; 
else
  echo ""
  echo "Now installing wget"
  yum install wget -y -q
fi

#Install unzip
if rpm -q unzip > /dev/null; then
  echo "Package unzip is already installed."; 
else
  echo ""
  echo "Now installing unzip"
  yum install unzip -y -q
fi

#Install screen
if rpm -q screen > /dev/null; then
  echo "Package screen is already installed."; 
else
  echo ""
  echo "Now installing screen"
  yum install screen -y -q
fi

#Install rsync
if rpm -q rsync > /dev/null; then
  echo "Package rsync is already installed."; 
else
  echo ""
  echo "Now installing rsync"
  yum install rsync -y -q
fi

#Install net-tools
if rpm -q net-tools > /dev/null; then
  echo "Package net-tools is already installed."; 
else
  echo ""
  echo "Now installing net-tools"
  yum install net-tools -y -q
fi

#Install iptraf
if rpm -q iptraf-ng > /dev/null; then
  echo "Package iptraf is already installed."; 
else
  echo ""
  echo "Now installing iptraf"
  yum install iptraf -y -q
fi

#Install iftop
if rpm -q iftop > /dev/null; then
  echo "Package iftop is already installed."; 
else
  echo ""
  echo "Now installing iftop"
  yum install iftop -y -q
fi

#Install mtr
if rpm -q mtr > /dev/null; then
  echo "Package mtr is already installed."; 
else
  echo ""
  echo "Now installing mtr"
  yum install mtr -y -q
fi

#Install iperf
if rpm -q iperf > /dev/null; then
  echo "Package iperf is already installed."; 
else
  echo ""
  echo "Now installing iperf"
  yum install iperf -y -q
fi

#Install bind-utils
if rpm -q bind-utils > /dev/null; then
  echo "Package bind-utils is already installed."; 
else
  echo ""
  echo "Now installing bind-utils"
  yum install bind-utils -y -q
fi

#Install lsof
if rpm -q lsof > /dev/null; then
  echo "Package lsof is already installed."; 
else
  echo ""
  echo "Now installing lsof"
  yum install lsof -y -q
fi

#Install dstat
if rpm -q dstat > /dev/null; then
  echo "Package dstat is already installed."; 
else
  echo ""
  echo "Now installing dstat"
  yum install dstat -y -q
fi

#Install iotop
if rpm -q iotop > /dev/null; then
  echo "Package iotop is already installed."; 
else
  echo ""
  echo "Now installing iotop"
  yum install iotop -y -q
fi

#Install iostat
if rpm -q sysstat > /dev/null; then
  echo "Package iostat is already installed."; 
else
  echo ""
  echo "Now installing iostat"
  yum install sysstat -y -q
fi

#Install Webmin part 2
if [ "$WEBMININSTALL" = 'y' ];
then
  if rpm -q webmin > /dev/null; 
  then
	echo ""
	echo -e "\e[1;31mPackage webmin is already installed.\e[0m"
  else	
  	echo ""
	echo -e "\e[1;31mWebmin will now be installed.\e[0m"
	wget http://www.webmin.com/download/rpm/webmin-current.rpm
    	yum install perl perl-Net-SSLeay openssl perl-IO-Tty perl-Encode-Detect perl-Digest-MD5 perl-Data-Dumper -y -q
    	rpm -U webmin-current.rpm
    	iptables -I INPUT -p tcp -m tcp --dport 10000 -j ACCEPT
    	service iptables save
  fi
else
  if rpm -q webmin > /dev/null; 
  then
  	echo ""
  	echo -e "\e[1;31mPackage webmin is already installed.\e[0m"
else
	echo ""
        echo "Webmin will not be installed."
  fi
fi

#Update CentOS - redo
yum update -y -q -e 0

#Reboot
#echo "This host will now reboot."
printf "\033[1;31mThis host will now reboot.\033[0m\n"
sleep 5
reboot
