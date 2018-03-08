#!/bin/bash

HOME=/home/huangyu/
PIC_LINK=${HOME}/Pictures
PIC_SHOTWELL_LINK=${HOME}/.local/share/shotwell
PIC_SHOTWELL_THUMBS_LINK=${HOME}/.cache/shotwell
PIC_PARENT_DIR=/media/multimedia/
PIC_CONFIG_PARENT_DIR=/media/multimedia/shotwell-configs/
PIC_OLD_DIR=Pictures
PIC_NEW_DIR=Pictures1

DIR_NOW=$(readlink $PIC_LINK)

function remove_last_slash() #remove last '/' in target name if exists
{
    dir_name=$(dirname $1)
    echo ${dir_name}/$(basename $1)
}

function remove_links()
{
    rm -i $PIC_LINK
    rm -i $PIC_SHOTWELL_LINK
    rm -i $PIC_SHOTWELL_THUMBS_LINK
}

function set_new_links()
{
    #pic link
    ln -s ${PIC_PARENT_DIR}/$1 $(remove_last_slash ${PIC_LINK})
    #shotwell data link
    ln -s ${PIC_CONFIG_PARENT_DIR}/$1/shotwell $(remove_last_slash ${PIC_SHOTWELL_LINK})
    #shotwell thumbs link
    ln -s ${PIC_CONFIG_PARENT_DIR}/$1/shotwell-thumbs $(remove_last_slash ${PIC_SHOTWELL_THUMBS_LINK})
}

if [ $DIR_NOW == "$PIC_PARENT_DIR/$PIC_OLD_DIR" ];then
    remove_links
	if [ $? == 0 ];then
        set_new_links ${PIC_NEW_DIR}
		echo "switched to new pic lib"
	else
		echo "current link didn't removed,do nothing"
	fi
else
    remove_links
	if [ $? == 0 ];then
        set_new_links ${PIC_OLD_DIR}
		echo "switched to old pic lib"
	else
		echo "current link didn't removed,do nothing"
	fi
fi
	
