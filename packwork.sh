while getopts 'd:' opt
do
	case $opt in
		d)	#echo $OPTARG
			workdir=$OPTARG
		;;
		*) echo "usage:$0 -d chrootdir"
		;;
	esac
done

if [ "$workdir" = "" ];then
	echo usage:$0 -d workdir
	exit
fi
if [ ! -d $workdir ];then
	echo "the dir >$workdir< doesn't exists"
	exit
fi
if [ ${workdir#/} == ${workdir} ];then
	cd $(pwd)/$workdir
else
	cd $workdir
fi
ls ./*/{*.c,*.h,*.txt,*.cpp} 2>/dev/null|xargs tar -cvzf   $(basename $workdir).tgz
