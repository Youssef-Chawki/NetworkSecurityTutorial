#!/usr/bin/env bash

ep_name=$1
ip_addr=$2
ip_mask=$3
mac_address=$4
type_ep=$5
port=$6

echo "namespace_handler heyy"
ip netns add $ep_name
ip link add vethg-$ep_name type veth peer name vethl-$ep_name
ovs-vsctl add-port br-sfc vethl-$ep_name
ip link set dev vethl-$ep_name up
ip link set vethg-$ep_name netns $ep_name
ip netns exec $ep_name ifconfig vethg-$ep_name $ip_addr/24 up
ip netns exec $ep_name ip link set dev vethg-$ep_name  addr $mac_address
ip netns exec $ep_name ip link set dev vethg-$ep_name up
ip netns exec $ep_name ip link set dev lo up
ip netns exec $ep_name ifconfig vethg-$ep_name mtu 1400
ip netns exec $ep_name ip route add default via $ip_mask.1



#if [ $type_ep = "server" ]; then
    #nohup ip netns exec $ep_name python -m SimpleHTTPServer 80 > /tmp/http_server.log 2>&1  &
#then
#    echo "endpoint is server type"
#    if [ -z "$port" ] 
#    then
#        echo "No port specified"
#        nohup ip netns exec $ep_name python -m SimpleHTTPServer 80 > /tmp/http_server.log 2>&1  &
#    else
#        nohup ip netns exec $ep_name python -m SimpleHTTPServer $port > /tmp/http_server.log 2>&1  &
#    fi

#fi


#reverse proxy and mod_security

#ip netns exec $ep_name a2enmod proxy
#ip netns exec $ep_name a2enmod proxy_http
#ip netns exec $ep_name /etc/init.d/apache2 restart

#ip netns exec $ep_name rm /etc/apache2/sites-available/000-default.conf
#ip netns exec $ep_name mv /tmp/modsecurity.conf /etc/modsecurity
#ip netns exec $ep_name mv /tmp/000-default.conf /etc/apache2/sites-available/
#ip netns exec $ep_name /etc/init.d/apache2 restart

echo "################### apache2 and mod-security done ##################"



set -x

NS=$ep_name
VETH="veth2"
VPEER="vpeer2"
VETH_ADDR="10.100.1.1"
VPEER_ADDR="10.100.1.2"

# Create veth link.
#ip link add ${VETH} type veth peer name ${VPEER}

# Add peer-1 to NS.
#ip link set ${VPEER} netns $NS

# Setup IP address of ${VETH}.
#ip addr add ${VETH_ADDR}/24 dev ${VETH}
#ip link set ${VETH} up

# Setup IP ${VPEER}.
#ip netns exec $NS ip addr add ${VPEER_ADDR}/24 dev ${VPEER}
#ip netns exec $NS ip link set ${VPEER} up
#ip netns exec $NS ip link set lo up
#ip netns exec $NS ip route add default via ${VETH_ADDR}

# Enable IP-forwarding.
#echo 1 > /proc/sys/net/ipv4/ip_forward

# Flush forward rules.
#iptables -P FORWARD DROP
#iptables -F FORWARD
 
# Flush nat rules.
#iptables -t nat -F

# Enable masquerading of 10.200.1.0.
#iptables -t nat -A POSTROUTING -s ${VPEER_ADDR}/24 -o eth0 -j MASQUERADE
 
#iptables -A FORWARD -i eth0 -o ${VETH} -j ACCEPT
#iptables -A FORWARD -o eth0 -i ${VETH} -j ACCEPT


#Delete existing route
#ip netns exec $NS route del -net 0.0.0.0 gw $ip_mask.1 netmask 0.0.0.0 dev vethg-$NS
#Add route for internet connectivity
#ip netns exec $NS ip route add default via ${VETH_ADDR}
#Add route for 10.0.36.0 network
#ip netns exec $NS ip route add $ip_addr dev vethg-$NS

#ip netns exec $NS route add 172.217.16.74 gw $VETH_ADDR $VPEER
#ip netns exec $NS route add 104.19.197.151 gw $VETH_ADDR $VPEER

#mkdir -p /etc/netns/$NS/
#echo 'nameserver 8.8.8.8' > /etc/netns/$NS/resolv.conf

#mkdir -p /etc/resolv.conf/
#echo 'nameserver 8.8.8.8'  >  /etc/resolv.conf
