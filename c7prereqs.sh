#!/bin/bash

#Update CentOS
yum update -y

#Disable SELinux
setenforce 0
sed -i "s|SELINUX=enforcing|SELINUX=disabled|" /etc/selinux/config

#Install EPEL
yum install epel-release -y

#Install useful tools
yum install vim nano wget -y

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

#Install iptables (optional)
yum install iptables-services -y
systemctl enable iptables.service
systemctl start iptables.service

#Reboot
reboot
