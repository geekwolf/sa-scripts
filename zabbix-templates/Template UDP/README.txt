1.≈‰÷√Zabbix Agent
UnsafeUserParameters=1
UserParameter=custom.udp.conn.stat[*],cat /proc/net/sockstat|grep UDP:|cut -d' ' -f 2,3,4,5,6 |xargs -n2|grep $1|awk '{print $NF}' 

2.÷ÿ∆Ùzabbix agent
