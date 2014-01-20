#!/bin/bash
#pssh.txt:Host IP
while read line 
do
a=`mkpasswd -l 16 -c 2 -C 2 -s 1 -v`
echo  -e  "$line \t  $a">>nowpassw.txt
pssh -H $line   -P  -p 1 "echo $a|passwd --stdin root"
echo $line
done < pssh.txt
