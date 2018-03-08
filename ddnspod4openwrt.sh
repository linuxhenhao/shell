#!/bin/sh

ipaddr=""
old_ipaddr=""

get_ip_from_self()
{
	echo $(uci -P /var/state get network.wan.ipaddr)
}

get_dns_ip()
{
	ip_regex="[0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}"
	echo $(ping -c 1 work.diwang90.tk|head -1|grep -o "$ip_regex")
}

ddns()
{

		echo 	"wget -q -O- https://dnsapi.cn/Record.Ddns?login_email=diwang90@gmail.com&login_password=Yk6zIZuy&format=json&domain_id=1627919&record_id=75183567&sub_domain=work&record_type=A&record_line=默认&value=$ipaddr"
		wget --no-check-certificate -O- --post-data "login_email=diwang90@gmail.com&login_password=Yk6zIZuy&format=json&domain_id=1627919&record_id=75183567&sub_domain=work&record_type=A&record_line=默认&value=$ipaddr" "https://dnsapi.cn/Record.Ddns"
}

#to make sure only one ddns script is running
check_state()
{
	if [ $(ps uax|grep -i $0|wc -l) != "3" ];then
		echo "There is a $0 running "
		exit
	fi
}

check_state
while true
	do
		ipaddr=$(get_ip_from_self)
		old_ipaddr=$(get_dns_ip)
		echo "ipaddr: $ipaddr odl_ipaddr: $old_ipaddr"
		if [ $ipaddr != $old_ipaddr ];then
			ddns
		fi
		sleep 60
	done
