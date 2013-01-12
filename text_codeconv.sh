#!/bin/bash
f_code=""
t_code="utf8"
true_do=0

while getopts ":nf:" opt;
		do
			case $opt in
				f)
					file=$OPTARG #optarg is from getopts
					;;
				n)
					true_do=1
					;;
				*)
					cat << HHH
use -f option to point out the file 
HHH
					
					exit 1
					;;
			esac
		done

echo  "$file >>start"


function get_f_code()
{
	string=$(file $1 |cut -d ":" -f2)
	string=$(echo $string|cut -d " " -f1)
	echo $string
}

f_code=$(get_f_code $file)

if [ ! $f_code = UTF-8 ];then
	filename=$(basename $file)
	cp $file /tmp/$filename
	if [  ! $true_do -eq 1 ];then
	echo " test iconv $file to utf8"
	iconv -f gbk -t $t_code /tmp/$filename 	
	echo "use -n to realy do the change"

	else 
	echo "truly change code"
	iconv -f gbk -t $t_code /tmp/$filename >$file	
	fi
fi
