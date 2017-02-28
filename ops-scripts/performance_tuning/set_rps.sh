#!/bin/bash
#
### BEGIN INIT INFO
# Provides:          set_rps
# Required-Start:    $remote_fs $network $time $syslog
# Required-Stop:     $remote_fs $network $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Set rps
# Description:       Script for open rps
### END INIT INFO
#

RETCODE=0

# kernel version must be >= 2.6.37
kernel_ver=`uname -r`
case "$kernel_ver" in
    2.6.*)
        kernel_ver=`uname -r|sed -n 's/2.6.\([0-9]\+\).*/\1/p'`
        [ -z $kernel_ver ] && echo "$0:Kernel version is not 2.6.x, no need to run this script." && exit 0
        [ $kernel_ver -lt 37 ] && echo "$0:Kernel version is lower than 2.6.37, no need to run this script." && exit 9
        ;;
    3.*|4.*)
        :
        ;;
    *)
        echo "Kernel version unsupport."
        exit $RETCODE
        ;;
esac

# get cpu count
cpu_count=`head -n1 /proc/interrupts|awk '{print NF}'`

# get interface name
interfaces=`route -n | awk 'NR>2 && !a[$NF]++{print $NF}' | grep '^eth[0-9]\|bond[0-9]$'`

set_rps(){
    interface="$@"

    #convert cpu_bits into hex format: 10 -> 16
    rps_cpus=`printf "%x" $((2**$cpu_count-1))`
    rps_flow_cnt=4096
    rps_sock_flow_entries=0
    for int in $interface
    do
        for rxdir in /sys/class/net/"$int"/queues/rx-*
        do
            echo $rps_cpus >$rxdir/rps_cpus
            echo $rps_flow_cnt >$rxdir/rps_flow_cnt
            rps_sock_flow_entries=$(($rps_sock_flow_entries+$rps_flow_cnt))
        done
    done
    echo $rps_sock_flow_entries >/proc/sys/net/core/rps_sock_flow_entries
}

clr_rps(){
    interface="$@"
    for int in $interface
    do
        for rxdir in /sys/class/net/"$int"/queues/rx-*
        do
            echo 0 >$rxdir/rps_cpus
            echo 0 >$rxdir/rps_flow_cnt
        done
    done
    echo 0 >/proc/sys/net/core/rps_sock_flow_entries
}

dsp_rps(){
    interface="$@"
    for int in $interface
    do
        for rxdir in /sys/class/net/"$int"/queues/rx-*
        do
            awk '{print FILENAME,$0}' $rxdir/rps_cpus
            awk '{print FILENAME,$0}' $rxdir/rps_flow_cnt
        done
    done
    awk '{print FILENAME,$0}' /proc/sys/net/core/rps_sock_flow_entries
}

case $1 in
    start)
        set_rps $interfaces
        ;;
    stop)
        clr_rps $interfaces
        ;;
    status)
        dsp_rps $interfaces
        ;;
    *)
        echo "Usage: $0 [start|stop|status]"
        ;;
esac
