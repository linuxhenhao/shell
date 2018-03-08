#!/bin/bash
#Description:
# download national geographic photo of the day and set it as background

# wait for network connection to be established
[[ -n $1 ]] && sleep $1

resolution=$(xrandr |grep -o 'current [^,]*'|tr -d " "|sed 's:current::')

rss=`wget -q -O - http://feeds.nationalgeographic.com/ng/photography/photo-of-the-day/`

img_url=$(echo $rss|grep -o "http://[^\"]*exposure[^\"]*"|head -1)

img_url=$(echo $img_url|sed "s:360x270:$resolution:")

img=/tmp/pod.jpg

wget -q -O $img $img_url

feh --bg-scale $img
