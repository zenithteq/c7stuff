#!/bin/bash

#Update CentOS
yum update -y

#Disable SELinux
setenforce 0
sed -i "s|SELINUX=enforcing|SELINUX=disabled|" /etc/selinux/config

#Install EPEL
yum install epel-release -y

#Install useful tools
yum install vim nano wget unzip rsync -y

#Install network monitoring tools
yum install net-tools iptraf iftop mtr iperf -y

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

#Install Webmin
wget http://www.webmin.com/download/rpm/webmin-current.rpm
yum install perl perl-Net-SSLeay openssl perl-IO-Tty -y
rpm -U webmin-current.rpm
iptables -I INPUT -p tcp -m tcp --dport 10000 -j ACCEPT
service iptables save

#Update CentOS - redo
yum update -y

#Reboot
reboot
