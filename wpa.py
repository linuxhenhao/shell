#!/usr/bin/env python 
#-*-code:utf-8 -*-

import os,re,sys

def getSSIDS():
    searcher=re.compile('ESSID:(.*)')

    tool=os.popen('which iwlist').read()
    if(tool==''):
       print('Cannot find iwlist,Please make sure you have installed it!') 
       exit()

    scanCommand=tool.replace('\n',' ')+'wlan0 scan'

    results=os.popen(scanCommand)

    ssids=list()
    for line in results.readlines():
        searchResult=searcher.search(line)   
        if(searchResult!=None):
            ssid=searchResult.groups()[0]
    #do some judgement for none english and numerit charactors
            print 'ssid',ssid.find('\\x')
            if(ssid.find('\\x')!=-1):
                ssid=gbk2utf8(ssid)
            ssids.append(ssid)
    return ssids


def gbk2utf8(string):
    return string.decode('gb2312')


if __name__ == '__main__':
    for i in getSSIDS():
        print i




