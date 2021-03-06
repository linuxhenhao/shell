#!/bin/bash
#use this script to set wpa wireless connect
pass="";
essid="";
tmpfile=$(date +%F);
wificard=wlan0
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
while getopts s:p: ARG ;
do
	case $ARG in 
		s)
			essid=$OPTARG;
			;;
		p)
			pass=$OPTARG;
			;;
		*)
			echo "Usage: $0 -s essid -p password"
			exit 1;
			;;
	esac
done

( [ "$essid" == "" ] || [ "$pass" == "" ] ) && usage $0 
wpa_passphrase "$essid" $pass > /tmp/$tmpfile;
if [ "$(prog_stat wpa_supplicant)" == "ON" ];then
	kill $(pidof wpa_supplicant)
	echo wpa_supplicant is on,killing it!
fi
echo "wpa connecting...."
sudo wpa_supplicant -B -i${wificard} -c /tmp/$tmpfile -Dnl80211
echo "dhcp getting...."
dhclient  ${wificard}
