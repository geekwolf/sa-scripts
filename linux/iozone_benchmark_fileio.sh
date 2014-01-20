#!/bin/sh
##
## 执行IOZONE 基准测试
##


PATH=$PATH:/usr/local/bin
export PATH

#set -u
#set -x
#set -e

# {{{ 各种参数
WORKDIR=/data/iozone
cd ${WORKDIR}

exec 3>&1 4>&2 1>> iozone_benchmark_fileio-`date +'%Y%m%d%H%M%S'`.log 2>&1

SLEEP_SEC=120
#文件块大小：4 ~ 64k
FILEIO_BLK_SIZE="4k 8k 16k"
#每个文件大小：1 ~ 16G
FILEIO_TOTAL_SIZE="1024M 2048M 4096M"
#并发请求书：1 ~ 16
NUM_THREADS="1 2 4 8 "
#测试设备名，6SAS_RAID10意为6块SAS盘组成RAID 1+0，2SSD_RAID1意为2块SSD盘组成RAID 1
#DEVICE="6SAS_RAID10"
DEVICE="2SAS_RAID1"

# }}}

# {{{ SLEEP
SLEEP()
{
 sleep $SLEEP_SEC
}
# }}}

# {{{ MUTEX
FILEIO()
{
for FILEIO_SIZE in ${FILEIO_TOTAL_SIZE}
do
  for FILEIO_BLK in ${FILEIO_BLK_SIZE}
  do
    for THREADS in ${NUM_THREADS}
    do
      iozone -R -E -s ${FILEIO_SIZE} -l ${THREADS} -r ${FILEIO_BLK} >> iozone_{${DEVICE}}_R_E_s_{${FILEIO_SIZE}}_l_{${THREADS}}_r_{${FILEIO_BLK}}_{`date +'%Y%m%d%H%M%S'`}.log
    done
  done
done
}
# }}}

#while [ 1 ]
#do

FILEIO
SLEEP


#done
