#!/bin/sh

# usage: find . -name '*.scad' | prepend.sh

cat - | while read file
do
	cat $1 $file >> $file.temp
	mv $file.temp $file
done
