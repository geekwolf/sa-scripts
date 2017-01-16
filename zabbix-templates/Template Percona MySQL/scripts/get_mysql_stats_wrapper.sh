#!/bin/sh
# The wrapper for Cacti PHP script.
# It runs the script every 5 min. and parses the cache file on each following run.
# Version: 1.1.6
#
# This program is part of Percona Monitoring Plugins
# License: GPL License (see COPYING)
# Copyright: 2016 Percona
# Authors: Roman Vynar

ITEM=$1
HOST=localhost
DIR=`dirname $0`
CMD="/usr/bin/php -q $DIR/ss_get_mysql_stats.php --host $HOST --items gg"
CACHEFILE="/tmp/$HOST-mysql_cacti_stats.txt"

USER='dba_monitor'
PASS='xxxx'

if [ "$ITEM" = "running-slave" ]; then
    # Check for running slave
    RES=`HOME=~zabbix mysql -h localhost -u $USER -p$PASS -e 'SHOW SLAVE STATUS\G' | egrep '(Slave_IO_Running|Slave_SQL_Running):' | awk -F: '{print $2}' | tr '\n' ','`
    if [ "$RES" = " Yes, Yes," ]; then
        echo 1
    else
        echo 0
    fi
    exit
elif [ -e $CACHEFILE ]; then
    # Check and run the script
    TIMEFLM=`stat -c %Y /tmp/$HOST-mysql_cacti_stats.txt`
    TIMENOW=`date +%s`
    if [ `expr $TIMENOW - $TIMEFLM` -gt 300 ]; then
        rm -f $CACHEFILE
        $CMD 2>&1 > /dev/null
    fi
else
    $CMD 2>&1 > /dev/null
fi

# Parse cache file
if [ -e $CACHEFILE ]; then
    cat $CACHEFILE | sed 's/ /\n/g; s/-1/0/g'| grep $ITEM | awk -F: '{print $2}'
else
    echo "ERROR: run the command manually to investigate the problem: $CMD"
fi
