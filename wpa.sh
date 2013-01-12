#!/bin/bash
#use this script to set wpa wireless connect
pass="";
essid="";
tmpfile=$(date +%F);
function prog_stat()
{
	if [ "$(pidof $1)" != "" ];then
		echo ON;
	else
		echo OFF;
	fi
}
function usage()
{
	echo "Usage: $(basename $1) -s essid -p password"
	exit 3;
}
echo configuration file generating...
essid="softap" pass="diwang90"
( [ "$essid" == "" ] || [ "$pass" == "" ] ) && usage $0 
wpa_passphrase $essid $pass > /tmp/$tmpfile;
if [ "$(prog_stat wpa_supplicant)" == "ON" ];then
	echo wpa_supplicant is on,please check!
	echo "kill wpa_supplicant ..."
	killall wpa_supplicant
fi
echo "wpa connecting...."
sudo wpa_supplicant -B -iwlan0 -c /tmp/$tmpfile -Dnl80211
echo "dhcp getting...."
dhclient -cf /etc/dhcp/dhclient.conf wlan0
