#!/bin/bash
#-----------------------------------------------------------------------#
#DHCP Setup
#-----------------------------------------------------------------------#

#Temporarily Configure static IP for the DHCP server (Commented out because I decided to set the network adapter up on the VM so that i could copy the script over.)
#nmcli con mod ens33 ipv4.method manual ip4 10.1.1.2/24 ipv4.gateway 10.1.1.1
#systemctl restart NetworkManager

#Install DHCP server package
yum -y install dhcp-server

#Add DHCP settings to config file
echo "authoritative;

subnet 10.1.1.0 netmask 255.255.255.0 {
  range 10.1.1.50 10.1.1.254;
  option routers 10.1.1.1;
  option broadcast-address 10.1.1.255;
  option domain-name-servers 10.1.1.3, 172.16.0.1;
  default-lease-time 600;
  max-lease-time 7200;
}" >> /etc/dhcp/dhcpd.conf

#Prompt user for DNS server MAC address:
echo Please enter MAC address of DNS server for static IP configuration
read dnsmac

##Should add validation for dnsmac

echo "host dns {
        hardware ethernet $dnsmac;
        fixed-address 10.1.1.3;
}" >> /etc/dhcp/dhcpd.conf

#Allow dhcp traffic through firewall
firewall-cmd --permanent --add-service=dhcp
firewall-cmd --reload

#start and enable DHCP service
systemctl start dhcpd
systemctl enable dhcpd
