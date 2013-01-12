#!/bin/bash
templatedir=/home/huangyu/Documents/4-大四/2-数据结构/template
while getopts 'n:d:' opt
do
	case $opt in
		n)	#echo $OPTARG
			workname=$OPTARG
		;;
		d)
			workdir=$OPTARG #make workname under this dir
		;;
	esac
done
	if [ "${workname}x" == "x" ];then
		echo "usage:$0 -n workname {-d workdir}default current dir"
		exit 1
	fi

if [ ! -d $templatedir ];then
	echo "$templatedir doesn't exist!"
	exit 1
fi

if [ "${workdir}x" == "x" ];then
	if [ ! -d $workname ];then
		mkdir $workname
		cp $templatedir/* $workname/
		if [ ! -e  $
	fi
else
	if [ ! -d $workdir/$workname ];then
		mkdir $workdir/$workname
		cp $templatedir/* $workdir/$workname/
	fi
fi



