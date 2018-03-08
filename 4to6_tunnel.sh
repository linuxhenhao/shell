#!/bin/bash
eth=br0
eth_flag=br0
wcard=wlan0
wcard_flag=wlan
function get_card()
{
	ifce_w=$(ifconfig $wcard_flag |grep -i inet)
	ifce_e=$(ifconfig $eth_flag|grep -i inet)
	if [ !	$(echo $ifce_w |wc -L) -eq 0 ];then
		echo $wcard
	else
	{	if [ ! $(echo $ifce_e|wc -L) -eq 0 ];then
			echo $eth
		else echo error
		fi	
	}
	fi	
}

card=$(get_card)
if [ $card == 'error' ];then
	echo unknow card,exit
	exit 1
fi
#echo $card
function get_ip()
{
	ip=$(ifconfig $card |grep inet\ addr|cut -d ":" -f2|cut -d " " -f1)
	if [ ! $(echo $ip|grep -E "192\.|10\." |wc -L) -eq 0 ];then
		ip=$(wget -O- ipdetect.dnspark.com|grep -i Address|cut -d " " -f3) 
    fi
	echo $ip
}
IP=""
IP=$(get_ip)
ip tunnel add sit1 mode sit remote 59.66.4.50 local $IP
ifconfig sit1 up
ifconfig sit1 add 2001:da8:200:900e:0:5efe:$IP/64
ip route add ::/0 via 2001:da8:200:900e::1 metric 1


