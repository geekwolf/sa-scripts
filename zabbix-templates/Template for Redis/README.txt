Zabbix Agent增加如下配置:
UnsafeUserParameters=1
UserParameter=Redis.Info[*],/home/opt/scripts/zabbix/redismonitor.sh $1 $2
