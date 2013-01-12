#!/usr/bin/env bash
IPTABLES=/sbin/iptables
wireless_card=wlan0
output_card=eth0
dhcpd=isc-dhcp-server


ap_name=320abc
passwd=nyl890806
##judge the user
if [ `id -u` != 0 ] ;then
	echo "you must run this script as root".
	echo "exit...."
	exit 1	
fi
###flush existing rules and set chain policy
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
$IPTABLES -t nat -A POSTROUTING -o $output_card -j MASQUERADE
###SET iptalbes finished 
}
####set the wireless card
function judge_wirelesscard()
{
	string=`iwconfig $wireless_card | grep 'Cell: Not-Associated'` >/dev/null 2>&1
	stat=`echo "$string"|wc -L`

}

function wireless_card_set()
{
judge_wirelesscard
if [ $stat -ne  0 ];then 
	set_start
else
	#ifconfig $wireless_card down
	set_start
fi
}

function set_start()
{
	iwconfig $wireless_card essid $ap_name key s:$passwd mode ad-hoc >/dev/null 2>&1
	
}


####start dhcpd service
function judge_start_dhcp()
{
	if [ `service isc-dhcp-server status | grep not | wc -L` -ne 0 ];then
		service $dhcpd start
	else
		service  $dhcpd restart
	fi
}

function dnsmasq_do()
{
	if [ $(service dnsmasq status |grep 'not running'|wc -L) -eq 0 ];then
		service dnsmasq stop	
	fi
	case $1 in
		start)
		if [ "$(get_prog_stat dnsmasq)" = "OFF" ];then
		dnsmasq -a 127.0.0.1,$IP -z
		fi
		;;
		stop)
			killall dnsmasq
			service dnsmasq start
		;;
	esac
}
function get_prog_stat()
{
	if [ ! $(ps -C $1 |wc -L) -gt 27 ];then #27 is the PID TIME CMD's word number,this exist whenever
		echo ON
	else
		echo OFF
	fi
		
}

echo ">> setting iptables..."
iptables_nat_set
echo ">> setting wireless card..."
wireless_card_set
judge_wirelesscard
while [ $stat != 0 ] ;
	do 
		echo ">> judging wireless card' statu..."
		sleep 3
		#ifconfig $wireless_card up
		judge_wirelesscard
	done 
ifconfig $wireless_card 192.168.1.1

#judge_start_dhcp
dnsmasq_do start


exit 0
