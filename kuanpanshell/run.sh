#! /bin/bash
f=`date +%Y%m%d`
mysqldump --opt --lock-tables=false -h127.0.0.1 -u"root" -p"root" initcom_einit09com > /home/initcom/backup-script/tmp/e_init09_com.sql
mysqldump --opt --lock-tables=false -h127.0.0.1 -u"root" -p"root" initcom_wrdp1 > /home/initcom/backup-script/tmp/initcom_wrdp1.sql
mysqldump --opt --lock-tables=false -h127.0.0.1 -u"root" -p"root" initcom_brainy > /home/initcom/backup-script/tmp/initcom_brainy.sql
cd /home/initcom/backup-script/tmp/
tar  -czvf  /home/initcom/backup-script/tmp/database_backup_$f.tar.gz  /home/initcom/backup-script/tmp/*.sql
echo 'Upload dropbox';
filelist=`ls /home/initcom/backup-script/tmp/*.gz`
for filename in $filelist
do
        sleep 1s
        bash /home/initcom/backup-script/dropbox_uploader.sh upload  $filename /backup/database_backup_$f.tar.gz
done
rm /home/initcom/backup-script/tmp/* -rf
echo 'ok';
