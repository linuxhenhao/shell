#!/bin/bash
function start_win7()
{
	kvm -smp 2 -m 1300 -drive file=/media/multimedia/vm/win7/win7.qcow2,cache=writeback -usbdevice tablet #-net nic,model=virtio -net tap,ifname=tap0,script=no 
}
function start_debian()
{
	kvm -smp 2 -m 1300 -drive file=/media/multimedia/vm/debian/debian.img,cache=writeback -net nic,model=virtio -net tap,ifname=tap0,script=no -usbdevice tablet
}
function start_centos()
{
	kvm -smp 2 -m 512 -drive file=/media/extdata/kvm/centos/centos.qcow2,cache=writeback -net nic,model=virtio -net tap,ifname=tap0,script=no -usbdevice tablet
}
function start_freebsd()
{
	kvm -smp 2 -m 512 -drive file=/media/extdata/kvm/freebsd/freebsd.qcow2,cache=writeback -net nic,model=virtio -net tap,ifname=tap0,script=no -usbdevice tablet
}
		
while getopts 's:' OPT
do 
	case $OPT in
		s)
			sys=$OPTARG;	
		;;
		*)
		echo "Usage: vm.sh -s {win7|debian}"
		;;
	esac
done


case $sys in
	win7)
	start_win7 &
	;;
	debian)
	start_debian &
	;;
	centos)
	start_centos &
	;;
	freebsd)
	start_freebsd &
	;;
	*)
	echo "Unkown system $sys"
	;;
esac

