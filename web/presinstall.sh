#!/usr/bin/env bash
apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y  software-properties-common && \
    add-apt-repository ppa:webupd8team/java -y && \
    apt-get update && \
    apt-get install -y inetutils-traceroute && \
    echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections && \
    apt-get install -y oracle-java8-installer && \
    apt-get clean

apt-get install -y git libtool m4 curl autoconf automake make \
    libssl-dev libcap-ng-dev python3 python-pip python3-pip python-six vlan iptables wget \
    net-tools init-system-helpers kmod uuid-runtime vim iputils-ping

apt-get install -y build-essential binutils gcc gawk libexpat1-dev libpcre3-dev \
    libssl-dev libxml2-dev libyajl-dev zlibc zlib1g-dev


#reverse proxy and mod security
apt-get install -y apache2 libapache2-modsecurity

mv reverse_proxy /tmp/
mv app /app
mv dvwa-spring-master /dvwa-spring-master
