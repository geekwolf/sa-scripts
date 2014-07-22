#!/usr/bin/env python 
# coding=utf8 
# Author:Geekwolf
# Blog:http://www.simlinux.com
# Des:Get ip's owner
# 可使用nali软件:https://qqwry.googlecode.com/files/nali-0.2.tar.gz

import sys, urllib, simplejson 

#ip.txt格式每行一个ip
file = open("ip.txt")
for ip in file.readlines():
	ipstr=ip.split()[0]
	url='http://ip.taobao.com/service/getIpInfo.php?ip=%s' % ipstr
	f=  urllib.urlopen(url).read()
	s=  simplejson.loads(f)
	print ipstr+" \t "+s['data']['country']+s['data']['area']+s['data']['region']+s['data']['city']+s['data']['isp']

file.close()


#接收IP输入 python  ipget.py  8.8.8.8
#ip=sys.argv[1]
#url='http://ip.taobao.com/service/getIpInfo.php?ip=%s' % ip
#f=  urllib.urlopen(url).read()
#s=  simplejson.loads(f)
#print ip+" \t "+s['data']['country']+s['data']['area']+s['data']['region']+s['data']['city']+s['data']['isp']

