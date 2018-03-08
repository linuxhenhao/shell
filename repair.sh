#!/bin/bash
aPATH=/var/cache/apt/archives/
for  i in  $aPATH/*.deb
do
	echo $i
	dpkg-deb --extract $i .
	cp -r * /
	rm -r *
done
