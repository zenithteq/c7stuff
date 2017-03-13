#c7prereqs
###Bash script to do the following on CentOS 7 (Minimal Install):
```
Prompt to change hostname
Prompt to install Webmin
Update CentOS
Disable SELinux
Install EPEL
Install some useful tools
Install network tools
Install NTP
Disable firewalld
Install iptables
Install Fail2Ban
Install Yubico
Secure SSH
```
The script will reboot your box once complted.

####Run the script:
```
curl -o c7prereqs.sh https://raw.githubusercontent.com/zenithteq/c7stuff/master/c7prereqs.sh && bash c7prereqs.sh
```
