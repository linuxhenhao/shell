#!/bin/bash
workdir=$(pwd);

IFS='
'
for i in $(find "$workdir" -iname "[0-9]*.mp3" );
	do
	dir=$(dirname $i)
	file=$(basename $i)
	number=$(echo $file|cut -d "." -f1)
	dst=$(echo $file |sed "s/$number\.//")
	mv "$dir/$file" "$dir/$dst"
	done

