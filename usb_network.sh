#!/bin/bash
#use this to surf the internet by usb

IPTABLES=/sbin/iptables
P_CARD=usb0
output_card=wlan0
P_IP="192.168.0.1"

if [ ! $(id -u) -eq 0 ];then 
	echo "must run as root!"	
	exit 1
fi

function get_phone_ip()
{
	 P_IP=$(ifconfig $P_CARD |grep inet\ |cut -f2 -d ":"|cut -f1 -d " ")
}

function iptables_nat_set()
{
$IPTABLES -F 
$IPTABLES -F -t nat
$IPTABLES -X
$IPTABLES -P INPUT ACCEPT
$IPTABLES -P OUTPUT ACCEPT
$IPTABLES -P FORWARD ACCEPT
###start ipv4 forword 
echo 1 > /proc/sys/net/ipv4/ip_forward
###end of start ipv4 forward

###use iptable nat to forward data
$IPTABLES -t nat -A POSTROUTING -s $P_IP/24 -o $output_card -j MASQUERADE
###SET iptalbes finished 
}
#get_phone_ip
ifconfig $P_CARD $P_IP
iptables_nat_set

