#!/bin/bash
MAX=2133000
freq=""
PATH="/sys/devices/system/cpu/"
while getopts f: ARG ;
do
	case $ARG in
		f)
			freq=$OPTARG;
			;;
		*)
			echo "Usage $0 -f cpufreq"
			echo "max freq are $MAX"
			;;
	esac
done

if [ "x$freq" == "x" ];then
	echo "Usage $(basename $0) -f cpufreq"
	echo "max freq are $MAX"
	exit 1;
fi


for((i=0;i<4;i++))
do
	echo $freq > $PATH/cpu$i/cpufreq/scaling_setspeed;
done
