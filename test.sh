#!/bin/bash

#Disable SELinux
setenforce 0
sed -i "s|SELINUX=enforcing|SELINUX=disabled|" /etc/selinux/config

#Change hostname
#read -p "Do you want to change the hostname? [y/n]: " -e -i n NEW_HOSTNAME
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
if [ -z "$NEW_HOSTNAME" ]; then
 echo -n "Please enter new hostname: "
 read NEW_HOSTNAME < /dev/tty
fi
echo ""
if [ -z "$NEW_HOSTNAME" ]; then
 echo "Error: no hostname entered. Exiting."
# exit 1
fi
echo "Changing hostname from $HOSTNAME to $NEW_HOSTNAME..."
hostnamectl set-hostname $NEW_HOSTNAME
echo "Done."

#Secure SSH
sed -i 's/^#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/^#Protocol 2/Protocol 2/' /etc/ssh/sshd_config

#Reboot
#reboot
