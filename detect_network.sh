#!/bin/bash
profile='/opt/goagent/proxy.ini'
ip_server="ipv6.google.com"
ip_line="address"
set=$(grep profile\ =  $profile);

function switch()
{
	if [ ! $(echo $set |grep ipv6|wc -L) -eq 0 ];then
#now there is no ipv6 in $set,so ,it's ipv4;change to ipv6
		echo "<<<switch from ipv4 to ipv6 profile ..."
		set_protocal google_ipv6
	else 
		echo "<<<switch from ipv6 to ipv4 profile ..."
		set_protocal google_cn
	fi
}

function set_protocal()
{
	sed -i "s/profile\ =\ .*/profile\ =\ $1/" $profile;
}
function statu()
{
	if [  $(echo $set|grep ipv6|wc -L) -eq 0 ];then
		echo "ipv4"
	else
		echo "ipv6"
	fi
}

function protocal_detect()
{
	ping6 -c 2 $ip_server >/dev/null 2>&1
	
	if [ $? -eq 0 ];then
		echo ipv6;
	else
		echo ipv4;
	fi
}

function encode()
{
	case $1 in
		"ipv4")
			echo google_cn;;
		"ipv6")
			echo google_ipv6;;
			* )
			echo unkown;;
	esac
}
connect_version=$(protocal_detect);
profile_version=$(statu);

case $connect_version in
	ipv4|ipv6)
		;;
	*)
		connect_version="ipv4";;
esac
case $profile_version in
	ipv4|ipv6)
		;;
	*)
		exit 1;;
esac

echo connect_version $connect_version
echo profile_version $profile_version
if [  "$profile_version" = "$connect_version" ];then
	echo "nothing to do"
else
	VAR=$(encode $connect_version);
	set_protocal $VAR
	echo ">>>change profile to $VAR ..."
fi

