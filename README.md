##Bash script to do the following on CentOS 7 (Minimal Install):
```
Update CentOS
Disable SELinux
Install EPEL
Install some useful tools
Install network monitoring tools
Disable firewalld
Install iptables
Install Fail2Ban
```
The script will reboot your box once complted.

###Run the script:

curl -o c7prereqs.sh https://raw.githubusercontent.com/zenithteq/c7stuff/master/c7prereqs.sh && bash c7prereqs.sh
