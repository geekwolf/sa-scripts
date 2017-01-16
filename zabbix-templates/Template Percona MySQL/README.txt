1.数据库授权监控账号dba_monitor
GRANT SELECT, PROCESS, SUPER ON *.* TO 'dba_monitor'@'%' IDENTIFIED BY 'xxxx';
GRANT ALL PRIVILEGES ON `mysql`.`slow_log` TO 'dba_monitor'@'%';

2.配置get_mysql_stats_wrapper.sh和ss_get_mysql_stats.php两个文件监控账号信息

3.配置Zabbix Agent

UnsafeUserParameters=1
Include=/var/lib/zabbix/percona/templates/userparameter_percona_mysql.conf

4.重启zabbix agent

详细参考:
https://www.percona.com/doc/percona-monitoring-plugins/1.1/zabbix/index.html