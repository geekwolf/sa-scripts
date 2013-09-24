#!/bin/bash
#Welcome to NAGIOS for CentOS6.x Installation!
#This Installation Released Geekwolf
#Author:Geekwolf
#Date:2013-06-14
#Blog:www.linuxhonker.com

function Nagios_Install(){
yum -y install  gcc gcc-c++ glibc glibc-common gd gd-devel httpd-tools
useradd  nagios 
groupadd nagcmd 
usermod  -G nagcmd nagios 
#将web用户加入nagcmd组
usermod  -G nagcmd nobody 
mkdir /usr/src/nagios
cd /usr/src/nagios
wget http://prdownloads.sourceforge.net/sourceforge/nagios/nagios-3.5.0.tar.gz
wget http://prdownloads.sourceforge.net/sourceforge/nagiosplug/nagios-plugins-1.4.16.tar.gz
wget http://downloads.sourceforge.net/project/nagios/nrpe-2.x/nrpe-2.14/nrpe-2.14.tar.gz?r=http%3A%2F%2Fexchange.nagios.org%2Fdirectory%2FAddons%2FMonitoring-Agents%2FNRPE--2D-Nagios-Remote-Plugin-Executor%2Fdetails&ts=1371189057&use_mirror=nchc
tar zxvf nagios-3.5.0.tar.gz
cd nagios
./configure --with-command-group=nagcmd --prefix=/usr/local/nagios
make all
make install
make install-init
make install-config
make install-commandmode
make install-webconf
cd ../ 
tar zxvf nagios-plugins-1.4.16.tar.gz
cd nagios-plugins-1.4.16
./configure --prefix=/usr/local/nagios --with-nagios-user=nagios --with-nagios-group=nagios
make && make install
cd ../
tar zxvf nrpe-2.14.tar.gz
cd nrpe-2.14
./configure
make all
make install-plugin
make install-daemon
make install-daemon-config

htpasswd -bc /usr/local/nagios/etc/htpasswd  nagiosadmin nagiosadmin
echo "alias nagioscheck='/usr/local/nagios/bin/nagios -v /usr/local/nagios/etc/nagios.cfg'" >>/etc/bashrc
source /etc/bashrc

chkconfig nagios on 
service nagios start

cat >>/usr/local/nginx/conf/nginx.conf <<EOF

server
  {
    listen       10002;
    server_name  `ifconfig eth0|grep 'inet addr'|awk '{print $2}'|awk -F : '{print $2}'`;
    index index.html index.htm index.php;

    root  /usr/local/nagios/share;
    location ~ .*\.(php|php5)?$
    {
      fastcgi_pass  127.0.0.1:9000;
      fastcgi_index index.php;
      include fcgi.conf;
    }

    location ~ .*\.(cgi|pl)?$
    {
    gzip off;
    root   /usr/local/nagios/sbin;
    rewrite ^/nagios/cgi-bin/(.*)\.cgi /$1.cgi break;
    fastcgi_pass  127.0.0.1:10000;
    fastcgi_param SCRIPT_FILENAME /usr/local/nagios/sbin$fastcgi_script_name;
    fastcgi_index index.cgi;
    fastcgi_read_timeout   60;
    fastcgi_param  REMOTE_USER        $remote_user;
    include fcgi.conf;
    auth_basic "Nagios Access";
    auth_basic_user_file /usr/local/nagios/etc/htpasswd;
    }

}

EOF
service nginx reload

}
echo -e "\t\tPlease select:"
echo -e "\t\t\t1.Nagios_Install"
read number
case $number in
       1)
         echo "Begin To Install The Nagios"
         Nagios_Install
       ;;
esac
