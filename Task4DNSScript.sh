#!/bin/bash
#-----------------------------------------------------------------------#
#DNS Setup
#-----------------------------------------------------------------------#

#Install BIND
yum -y install bind

#Add settings to DNS config file
echo 'options {
        listen-on port 53 { 127.0.0.1; 10.1.1.3; };
        directory       "/var/named";
        dump-file       "/var/named/data/cache_dump.db";
        statistics-file "/var/named/data/named_stats.txt";
        memstatistics-file "/var/named/data/named_mem_stats.txt";
        secroots-file   "/var/named/data/named.secroots";
        recursing-file  "/var/named/data/named.recursing";
        allow-query     { localhost;10.1.1.0/24; };

        recursion yes;

        dnssec-enable yes;
        dnssec-validation yes;

        managed-keys-directory "/var/named/dynamic";

        pid-file "/run/named/named.pid";
        session-keyfile "/run/named/session.key";

        include "/etc/crypto-policies/back-ends/bind.config";
};

logging {
        channel default_debug {
                file "data/named.run";
                severity dynamic;
        };
};

zone "." IN {
        type hint;
        file "named.ca";
};

include "/etc/named.rfc1912.zones";
include "/etc/named.root.key";

zone "scriptnet.local" IN {

           type master;
           file "/etc/named/zones/scriptnet.local.db";
           allow-update { none; };
};

zone "1.1.10.in-addr.arpa" IN {

             type master;
             file "/etc/named/zones/10.1.1.db";   
             allow-update { none; };
};' > /etc/named.conf

#Create forward zone files
mkdir /etc/named/zones
echo '$TTL    604800
@       IN      SOA    dns.scriptnet.local. admin.scriptnet.local. (
                              1         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL

@     IN      NS      dns.gethinnet.local.

dns.scriptnet.local.            IN      A       10.1.1.3
gateway.scriptnet.local.        IN      A       10.1.1.1
dhcp.scriptnet.local.           IN      A       10.1.1.2' > /etc/named/zones/scriptnet.local.db


echo '$TTL    604800
@       IN      SOA    dns.scriptnet.local. admin.scriptnet.local. (
                              1         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL

@     IN      NS      dns.scriptnet.local.

3       IN      PTR     dns.scriptnet.local.    ; 10.1.1.3
1       IN      PTR     gateway.scriptnet.local ; 10.1.1.1
2       IN      PTR     dhcp.scriptnet.local    ; 10.1.1.2' > /etc/named/zones/10.1.1.db

##Could add a sectin here to check if the config files for errors and report back if there are any problems

#Start DNS service
systemctl start named
systemctl enable named

#Allow dns through firewall
firewall-cmd --permanent --add-service=dns
firewall-cmd --reload