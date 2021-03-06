#!/bin/bash
### BEGIN INIT INFO
# Provides:	softap
# Required-Start:	$syslog
# Required-Stop:	$syslog
# Default-Start:    5
# Default-Stop:	    0 1 6 
# Short-Description: soft ap use usb wirelss device
### END INIT INFO
CONFIG_FILE=./softap.conf
function get_global_var()
{
	default_eth=$(get_value $(grep default_ethi= $CONFIG_FILE));
	wlan_card=$(get_value $(grep wlan_card= $CONFIG_FILE));
	ap_card=$(get_value $(grep ap_card= $CONFIG_FILE));
	IP=$(get_value $(grep IP= $CONFIG_FILE));
}
function get_value()
{
	echo ${1##*=}
}
function get_card()
{
	string1=$(ifconfig $wlan_card |grep inet|grep -v inet6)
	string1=$(echo ${string1#*addr:})
	string1=$(echo ${string1%Bcast*})
	if [  $(echo $string1|wc -L) -eq 0 ];then
		echo $default_eth
	else
		echo $wlan_card
	fi
}
function ip_check()
{
	string2=$(ifconfig $ap_card|grep inet|grep -v inet6)
	string2=$(echo $string2|cut -d " " -f2)
	if [  $(ifconfig $ap_card|grep UP|wc -L) -eq 0 ];then
		ifconfig $ap_card up
	fi
	if [  $(echo ${string2#*addr:}|wc -L) -eq 0 ];then
		ifconfig $ap_card $IP
	fi
	
}
function dnsmasq_do()
{
		service dnsmasq stop
		dnsmasq -i $ap_card -a 127.0.0.1,$IP -z
}

function iptables_check()
{
	case $1 in
		start)
	if [   $(iptables -t nat --list|grep -i postrouting|grep -i masquerade|wc -L) -eq 0 ];then
		iptables -t nat -A POSTROUTING  -s 192.168.2.0/24 -o $card -j MASQUERADE
	fi
		;;
		stop)
		iptables -t nat -D POSTROUTING -s 192.168.2.0/24 -o $card -j MASQUERADE
		;;
	esac
}

function sysctl_check()
{
	case $1 in
		start)
	if [ $(sysctl net.ipv4.ip_forward |grep 1|wc -L ) -eq 0 ]; then
		sysctl net.ipv4.ip_forward=1;
	fi
		;;
		stop)
	if [ $(sysctl net.ipv4.ip_forward|grep 0|wc -L ) -eq 0 ]; then
		sysctl net.ipv4.ip_forward=0
	fi
	;;
	esac
}

function hostapd_check()
{
	if [  $(ps -ef|grep hostapd|grep -v 'grep'|wc -L) -eq 0 ];then
		hostapd -d /etc/hostapd/hostapd.conf -B 2>&1 >/dev/null
	fi
}

get_global_var
card=$(get_card)

case $1 in
	start)
if [  $(ifconfig $ap_card |grep HWaddr |wc -L) -eq 0 ];then
	exit
ip_check
dnsmasq_do
iptables_check start
hostapd_check
sysctl_check start
fi
	;;
	stop)
	first=$(ps aux)
	
if [  $(echo $first|grep hostap|wc -L) -eq 0 ];then
		exit
echo ">>>setting dnsmasq"
 dnsmasq_do
echo ">>>stopping hostapd"
 killall hostapd 
echo ">>>delete iptables chain"
 iptables_check stop
echo ">>>disable kernel forward"
 sysctl_check stop
fi	
	;;
	restart)
		/etc/init.d/soft_ap.sh stop
		/etc/init.d/soft_ap.sh start
	;;
	*)
		echo "Usage: service $0 {start|stop|restart}"
esac
