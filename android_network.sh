#!/system/bin/sh

iptables -F;
iptables -F -t nat;
busybox ifconfig usb0 192.168.0.2;
busybox route del default;
busybox route add default gw 192.168.0.1;
netprop net.dns1 8.8.8.8;
netprop "net.gprs.http-proxy" "";
