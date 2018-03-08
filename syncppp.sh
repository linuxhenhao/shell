#!/bin/sh
# 多拨数
PPP_NUM=2
# 用户名
USERNAME='xa0275061'
# 密码
PASSWORD='898909'
# 多个wan接口的前缀，比如用macvlan生成了eth1, eth2,... 就设置成eth
WAN_IF_PREFIX='eth0.'
# 生成的pppoe接口名前缀，这个应该关系不大
PPP_IF_PREFIX='pppoe-'

pkill -f pppd && sleep 3

# start all pppd with a loop
for i in $(seq 0 $(($PPP_NUM-1)))
do
    echo -n "executing pppd for connection ${i} ... "
    pppd plugin rp-pppoe.so syncppp $PPP_NUM mtu 1492 mru 1492 nic-${WAN_IF_PREFIX}${i} nopersist usepeerdns user ${USERNAME} password ${PASSWORD} ipparam wan ifname ${PPP_IF_PREFIX}${i} nodetach &
    echo "done"
done
