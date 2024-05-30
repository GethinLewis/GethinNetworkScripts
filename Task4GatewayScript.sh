#!/bin/bash
#-----------------------------------------------------------------------#
#Gateway Setup
#-----------------------------------------------------------------------#

#Edit the /etc/sysctl.conf file to enable IP forwarding on startup
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
sysctl -w net.ipv4.ip_forward=1

#Create internal network adapter connection
nmcli connection add type ethernet con-name internal ifname ens35 ipv4.method manual ip4 10.1.1.1/24

#Set firewall zones
firewall-cmd --permanent --zone=internal --change-interface=ens35
firewall-cmd --permanent --zone=external --change-interface=ens33

#allow ip forwarding between zones
firewall-cmd --permanent --zone=internal --add-forward
firewall-cmd --permanent --zone=external --add-forward

#restart the firewall
firewall-cmd --reload