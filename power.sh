#!/bin/bash
####battery power status get and low power notification##

dir=$(find /sys/devices -iname "BAT1");
cd $dir;
powernow=$(cat charge_now);
#powernow=100000
powerfull=$(cat charge_full);

if [ "$(id -u)" != "0" ];then
	echo "only root can excute this script!"
	exit 1;
fi
function pwstat()
{
powerstat=$(echo "scale=2;$powernow/$powerfull*100 "|bc);
if [  "$powerstat" ==  "50.00" ];then
	notify-send  "$powerstat% battery! remained"
elif [ "$powerstat" == "25.00" ];then
	notify-send  "$powerstat% battery! remained"
elif [  "$powerstat" == "5.00" ];then
	notify-send -u critical "$powerstat% battery! remained"
elif [  ! "$powerstat" \< "2.50" ];then
	notify-send -u critical "system is going to hibernate!"
	pm-hibernate;
fi
echo $powerstat%
}

while pwstat;
do
	
	sleep 10;
done


