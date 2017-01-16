#!/bin/bash
#Description:LNMP
#Author:Geekwolf
#Blog:www.linuxhonker.com
# Check if user is root
[ $(id -u) != "0" ] && echo "Error: You must be root to run this script, please use root to install lnmp" && exit 1

# Set password
while :
do
    read -p "Please input the root password of MySQL:" mysqlrootpwd
#   read -p "Please input the manager password of Pureftpd:" ftpmanagerpwd
    if (( ${#mysqlrootpwd} >= 5 ));then
#&& ${#ftpmanagerpwd} >=5
        break
    else
       echo "least 5 characters"
    fi
done

yum -y install gcc gcc-c++ autoconf libjpeg libjpeg-devel libpng libpng-devel freetype freetype-devel libxml2 libxml2-devel zlib zlib-devel glibc glibc-devel glib2 glib2-devel bzip2 bzip2-devel ncurses ncurses-devel curl curl-devel e2fsprogs e2fsprogs-devel krb5-devel libidn libidn-devel openssl openssl-devel nss_ldap openldap openldap-devel openldap-clients openldap-servers libxslt-devel libevent-devel ntp libtool-ltdl bison gd-devel libtool vim-enhanced zip unzip wget

# install MySQL 
directory=`pwd`

mkdir -p $directory/lnmp/{source,conf}
cd $directory/lnmp/source
wget -c http://www.cmake.org/files/v2.8/cmake-2.8.10.2.tar.gz
wget -c http://fossies.org/linux/misc/mysql-5.5.32.tar.gz
useradd -M -s /sbin/nologin mysql
mkdir -p /data/data /usr/local/mysql/etc/ /data/run /data/logs;
chown mysql.mysql -R /data/{data,run,logs} /usr/local/mysql/etc/
cd $directory/lnmp/source

tar xf cmake-2.8.10.2.tar.gz
cd cmake-2.8.10.2
./configure
make && make install
cd ../
tar zxf mysql-5.5.32.tar.gz
cd mysql-5.5.32
cmake . -DCMAKE_INSTALL_PREFIX=/usr/local/mysql/ \
-DMYSQL_DATADIR=/data/data  \
-DMYSQL_UNIX_ADDR=/data/run/mysqld.sock \
-DWITH_INNOBASE_STORAGE_ENGINE=1 \
-DENABLED_LOCAL_INFILE=1 \
-DMYSQL_TCP_PORT=3306 \
-DEXTRA_CHARSETS=all \
-DDEFAULT_CHARSET=utf8 \
-DDEFAULT_COLLATION=utf8_general_ci \
-DMYSQL_UNIX_ADDR=/data/data/mysql.sock \
-DWITH_DEBUG=0
make && make install

# Modify my.cf
sed -i '38a ##############' /usr/local/mysql/etc/my.cnf
/bin/cp support-files/my-medium.cnf /usr/local/mysql/etc/my.cnf
cp support-files/mysql.server /etc/rc.d/init.d/mysqld
chmod 755 /etc/rc.d/init.d/mysqld
chkconfig --add mysqld
chkconfig mysqld on
cd ..
sed -i s#conf=#conf=/usr/local/mysql/etc# /etc/rc.d/init.d/mysqld
# Modify my.cf

sed -i '28a pid-file=/data/run/mysqld.pid' /usr/local/mysql/etc/my.cnf
sed -i '38a ##############' /usr/local/mysql/etc/my.cnf
sed -i '39a skip-name-resolve' /usr/local/mysql/etc/my.cnf
sed -i '40a basedir=/usr/local/mysql' /usr/local/mysql/etc/my.cnf
sed -i '41a datadir=/data/data' /usr/local/mysql/etc/my.cnf
sed -i '42a general-log'  /usr/local/mysql/etc/my.cnf
sed -i '43a general-log-file=/data/logs/access.log'  /usr/local/mysql/etc/my.cnf
sed -i '44a log-error=/data/logs/error.log'  /usr/local/mysql/etc/my.cnf
sed -i '44a user=mysql' /usr/local/mysql/etc/my.cnf
sed -i '45a #lower_case_table_names = 1' /usr/local/mysql/etc/my.cnf
sed -i '46a max_connections=1000' /usr/local/mysql/etc/my.cnf
sed -i '47a ft_min_word_len=1' /usr/local/mysql/etc/my.cnf
sed -i '48a expire_logs_days = 7' /usr/local/mysql/etc/my.cnf
sed -i '48a query_cache_size=64M' /usr/local/mysql/etc/my.cnf
sed -i '49a query_cache_type=1' /usr/local/mysql/etc/my.cnf
sed -i '50a ##############' /usr/local/mysql/etc/my.cnf
#日志回滚
cat > /etc/logrotate.d/mysqld <<EOF
/data/logs/*.log {
        daily
        rotate 7
        dateext
        create 0664 mysql mysql
        sharedscripts
        postrotate
                /bin/kill -HUP \`cat /data/run/mysqld.pid  2>/dev/null\`' || true
         endscript
}
EOF

/usr/local/mysql/scripts/mysql_install_db --user=mysql --basedir=/usr/local/mysql/ --datadir=/data/data

chown mysql.mysql -R /data/data
export PATH=$PATH:/usr/local/mysql/bin
echo 'export PATH=$PATH:/usr/local/mysql/bin' >> /etc/profile
source /etc/profile
 
/usr/local/mysql/bin/mysql -e "grant all privileges on *.* to root@'localhost' identified by \"$mysqlrootpwd\" with grant option;"
/usr/local/mysql/bin/mysql -uroot -p$mysqlrootpwd -e "delete from mysql.user where Password='';"
/sbin/service mysqld restart


# install PHP 
cd $directory/lnmp/source/
wget -c http://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.14.tar.gz
tar xzf libiconv-1.14.tar.gz
cd libiconv-1.14
./configure --prefix=/usr/local
make && make install
cd ../

wget -c http://iweb.dl.sourceforge.net/project/mcrypt/Libmcrypt/2.5.8/libmcrypt-2.5.8.tar.gz
tar xzf libmcrypt-2.5.8.tar.gz
cd libmcrypt-2.5.8
./configure
make && make install
/sbin/ldconfig
cd libltdl/
./configure --enable-ltdl-install
make && make install
cd ../../

wget -c http://iweb.dl.sourceforge.net/project/mhash/mhash/0.9.9.9/mhash-0.9.9.9.tar.gz
tar xzf mhash-0.9.9.9.tar.gz
cd mhash-0.9.9.9
./configure
make && make install
cd ../

if [ `getconf WORD_BIT` = '32' ] && [ `getconf LONG_BIT` = '64' ] ; then
	ln -s /usr/local/lib/libmcrypt.la /usr/lib64/libmcrypt.la
	ln -s /usr/local/lib/libmcrypt.so /usr/lib64/libmcrypt.so
	ln -s /usr/local/lib/libmcrypt.so.4 /usr/lib64/libmcrypt.so.4
	ln -s /usr/local/lib/libmcrypt.so.4.4.8 /usr/lib64/libmcrypt.so.4.4.8
	ln -s /usr/local/lib/libmhash.a /usr/lib64/libmhash.a
	ln -s /usr/local/lib/libmhash.la /usr/lib64/libmhash.la
	ln -s /usr/local/lib/libmhash.so /usr/lib64/libmhash.so
	ln -s /usr/local/lib/libmhash.so.2 /usr/lib64/libmhash.so.2
	ln -s /usr/local/lib/libmhash.so.2.0.1 /usr/lib64/libmhash.so.2.0.1
	ln -s /usr/local/bin/libmcrypt-config /usr/bin/libmcrypt-config
	ln -s /usr/local/mysql/lib/libmysqlclient.so.18 /lib64/libmysqlclient.so.18
        ln -s /lib64/libpcre.so.0.0.1 /lib64/libpcre.so.1
        ln -s /usr/local/include/ImageMagick-6 /usr/local/include/ImageMagick
        cp -frp /usr/lib64/libldap* /usr/lib
else
	ln -s /usr/local/lib/libmcrypt.la /usr/lib/libmcrypt.la
	ln -s /usr/local/lib/libmcrypt.so /usr/lib/libmcrypt.so
	ln -s /usr/local/lib/libmcrypt.so.4 /usr/lib/libmcrypt.so.4
	ln -s /usr/local/lib/libmcrypt.so.4.4.8 /usr/lib/libmcrypt.so.4.4.8
	ln -s /usr/local/lib/libmhash.a /usr/lib/libmhash.a
	ln -s /usr/local/lib/libmhash.la /usr/lib/libmhash.la
	ln -s /usr/local/lib/libmhash.so /usr/lib/libmhash.so
	ln -s /usr/local/lib/libmhash.so.2 /usr/lib/libmhash.so.2
	ln -s /usr/local/lib/libmhash.so.2.0.1 /usr/lib/libmhash.so.2.0.1
	ln -s /usr/local/bin/libmcrypt-config /usr/bin/libmcrypt-config
	ln -s /usr/local/mysql/lib/libmysqlclient.so.18 /lib/libmysqlclient.so.18
        ln -s /usr/local/include/ImageMagick-6 /usr/local/include/ImageMagick
        ln -s /lib/libpcre.so.0.0.1 /lib/libpcre.so.1
fi

wget -c http://vps.googlecode.com/files/mcrypt-2.6.8.tar.gz
tar xzf mcrypt-2.6.8.tar.gz
cd mcrypt-2.6.8
/sbin/ldconfig
./configure
make && make install
cd ../

wget -c http://kr1.php.net/distributions/php-5.3.24.tar.gz
tar xzf php-5.3.24.tar.gz
useradd -M -s /sbin/nologin www
cd php-5.3.24
./configure  --prefix=/usr/local/php --with-config-file-path=/usr/local/php/etc --with-mysql=/usr/local/mysql  --enable-inline-optimization --with-mysqli=/usr/local/mysql/bin/mysql_config --with-iconv-dir=/usr/local --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir=/usr --enable-xml --disable-rpath --enable-safe-mode --enable-bcmath --enable-shmop --enable-sysvsem --enable-inline-optimization --with-curl --with-curlwrappers --enable-mbregex --enable-fpm --enable-mbstring --with-mcrypt --with-gd --enable-gd-native-ttf --with-openssl --with-mhash --enable-pcntl --enable-sockets --with-ldap --with-ldap-sasl --with-xmlrpc --enable-ftp --with-gettext --enable-zip --enable-soap --disable-debug
make ZEND_EXTRA_LIBS='-liconv'
make install
cp php.ini-production /usr/local/php/etc/php.ini

#php-fpm Init Script
cp sapi/fpm/init.d.php-fpm /etc/rc.d/init.d/php-fpm
chmod +x /etc/rc.d/init.d/php-fpm
chkconfig --add php-fpm
chkconfig php-fpm on
cd ../

wget -c http://pecl.php.net/get/memcache-2.2.5.tgz
tar xzf memcache-2.2.5.tgz
cd memcache-2.2.5
/usr/local/php/bin/phpize
./configure --with-php-config=/usr/local/php/bin/php-config
make && make install
cd ../

wget -c  http://superb-dca2.dl.sourceforge.net/project/eaccelerator/eaccelerator/eAccelerator%200.9.6.1/eaccelerator-0.9.6.1.tar.bz2
tar xjf eaccelerator-0.9.6.1.tar.bz2
cd eaccelerator-0.9.6.1
/usr/local/php/bin/phpize
./configure --enable-eaccelerator=shared --with-php-config=/usr/local/php/bin/php-config
make && make install
cd ../

wget -c http://pecl.php.net/get/PDO_MYSQL-1.0.2.tgz
tar xzf PDO_MYSQL-1.0.2.tgz
cd PDO_MYSQL-1.0.2
/usr/local/php/bin/phpize
./configure --with-php-config=/usr/local/php/bin/php-config --with-pdo-mysql=/usr/local/mysql
make && make install
cd ../

wget -c http://www.imagemagick.org/download/legacy/ImageMagick-6.8.3-10.tar.gz
tar xzf ImageMagick-6.8.3-10.tar.gz
cd ImageMagick-6.8.3-10
./configure
make && make install
cd ../

wget -c http://pecl.php.net/get/imagick-3.0.1.tgz
tar xzf imagick-3.0.1.tgz
cd imagick-3.0.1
export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig
/usr/local/php/bin/phpize
./configure --with-php-config=/usr/local/php/bin/php-config
make && make install
cd ../

# Support HTTP request curls
wget -c http://pecl.php.net/get/pecl_http-1.7.5.tgz
tar xzf pecl_http-1.7.5.tgz
cd pecl_http-1.7.5 
/usr/local/php/bin/phpize
./configure --with-php-config=/usr/local/php/bin/php-config
make && make install
cd ../

# Modify php.ini
mkdir /tmp/eaccelerator
/bin/chown -R www.www /tmp/eaccelerator/
sed -i '808a extension_dir = "/usr/local/php/lib/php/extensions/no-debug-non-zts-20090626/"' /usr/local/php/etc/php.ini 
sed -i '809a extension = "memcache.so"' /usr/local/php/etc/php.ini 
sed -i '810a extension = "pdo_mysql.so"' /usr/local/php/etc/php.ini 
sed -i '811a extension = "imagick.so"' /usr/local/php/etc/php.ini 
sed -i '812a extension = "http.so"' /usr/local/php/etc/php.ini 
sed -i '135a output_buffering = On' /usr/local/php/etc/php.ini 
sed -i '848a cgi.fix_pathinfo=0' /usr/local/php/etc/php.ini 
sed -i 's@short_open_tag = Off@short_open_tag = On@g' /usr/local/php/etc/php.ini
sed -i 's@expose_php = On@expose_php = Off@g' /usr/local/php/etc/php.ini
sed -i 's@;date.timezone =@date.timezone = Asia/Shanghai@g' /usr/local/php/etc/php.ini
sed -i 's@#sendmail_path.*@#sendmail_path = /usr/sbin/sendmail -t@g' /usr/local/php/etc/php.ini
echo '[eaccelerator]
zend_extension="/usr/local/php/lib/php/extensions/no-debug-non-zts-20090626/eaccelerator.so"
eaccelerator.shm_size="64"
eaccelerator.cache_dir="/tmp/eaccelerator"
eaccelerator.enable="1"
eaccelerator.optimizer="1"
eaccelerator.check_mtime="1"
eaccelerator.debug="0"
eaccelerator.filter=""
eaccelerator.shm_max="0"
eaccelerator.shm_ttl="0"
eaccelerator.shm_prune_period="0"
eaccelerator.shm_only="0"
eaccelerator.compress="0"
eaccelerator.compress_level="9"
eaccelerator.keys = "disk_only"
eaccelerator.sessions = "disk_only"
eaccelerator.content = "shm_only"' >> /usr/local/php/etc/php.ini
#shm_only 只存放在共享内存  disk_only 只存放在硬盘 none 不缓存数据
cat > /usr/local/php/etc/php-fpm.conf <<EOF 
;;;;;;;;;;;;;;;;;;;;;
; FPM Configuration ;
;;;;;;;;;;;;;;;;;;;;;

; All relative paths in this configuration file are relative to PHP's install
; prefix.

; Include one or more files. If glob(3) exists, it is used to include a bunch of
; files from a glob(3) pattern. This directive can be used everywhere in the
; file.
;include=/usr/local/php/etc/fpm.d/*.conf

;;;;;;;;;;;;;;;;;;
; Global Options ;
;;;;;;;;;;;;;;;;;;

[global]
; Pid file
; Default Value: none
pid = /usr/local/php/var/run/php-fpm.pid

; Error log file
; Default Value: /usr/local/php/var/log/php-fpm.log
error_log = /usr/local/php/var/log/php-fpm.log

; Log level
; Possible Values: alert, error, warning, notice, debug
; Default Value: notice
;log_level = notice

; If this number of child processes exit with SIGSEGV or SIGBUS within the time
; interval set by emergency_restart_interval then FPM will restart. A value
; of '0' means 'Off'.
; Default Value: 0
;emergency_restart_threshold = 0

; Interval of time used by emergency_restart_interval to determine when 
; a graceful restart will be initiated.  This can be useful to work around
; accidental corruptions in an accelerator's shared memory.
; Available Units: s(econds), m(inutes), h(ours), or d(ays)
; Default Unit: seconds
; Default Value: 0
;emergency_restart_interval = 0

; Time limit for child processes to wait for a reaction on signals from master.
; Available units: s(econds), m(inutes), h(ours), or d(ays)
; Default Unit: seconds
; Default Value: 0
;process_control_timeout = 0

; Send FPM to background. Set to 'no' to keep FPM in foreground for debugging.
; Default Value: yes
;daemonize = yes

;;;;;;;;;;;;;;;;;;;;
; Pool Definitions ; 
;;;;;;;;;;;;;;;;;;;;

; Multiple pools of child processes may be started with different listening
; ports and different management options.  The name of the pool will be
; used in logs and stats. There is no limitation on the number of pools which
; FPM can handle. Your system will tell you anyway :)

; Start a new pool named 'php-fpm'.
[php-fpm]

; The address on which to accept FastCGI requests.
; Valid syntaxes are:
;   'ip.add.re.ss:port'    - to listen on a TCP socket to a specific address on
;                            a specific port;
;   'port'                 - to listen on a TCP socket to all addresses on a
;                            specific port;
;   '/path/to/unix/socket' - to listen on a unix socket.
; Note: This value is mandatory.
listen = 127.0.0.1:9000

; Set listen(2) backlog. A value of '-1' means unlimited.
; Default Value: -1
;listen.backlog = -1
 
; List of ipv4 addresses of FastCGI clients which are allowed to connect.
; Equivalent to the FCGI_WEB_SERVER_ADDRS environment variable in the original
; PHP FCGI (5.2.2+). Makes sense only with a tcp listening socket. Each address
; must be separated by a comma. If this value is left blank, connections will be
; accepted from any ip address.
; Default Value: any
;listen.allowed_clients = 127.0.0.1

; Set permissions for unix socket, if one is used. In Linux, read/write
; permissions must be set in order to allow connections from a web server. Many
; BSD-derived systems allow connections regardless of permissions. 
; Default Values: user and group are set as the running user
;                 mode is set to 0666
listen.owner = nobody
listen.group = nobody
;listen.mode = 0666

; Unix user/group of processes
; Note: The user is mandatory. If the group is not set, the default user's group
;       will be used.
user = nobody
group = nobody

; Choose how the process manager will control the number of child processes.
; Possible Values:
;   static  - a fixed number (pm.max_children) of child processes;
;   dynamic - the number of child processes are set dynamically based on the
;             following directives:
;             pm.max_children      - the maximum number of children that can
;                                    be alive at the same time.
;             pm.start_servers     - the number of children created on startup.
;             pm.min_spare_servers - the minimum number of children in 'idle'
;                                    state (waiting to process). If the number
;                                    of 'idle' processes is less than this
;                                    number then some children will be created.
;             pm.max_spare_servers - the maximum number of children in 'idle'
;                                    state (waiting to process). If the number
;                                    of 'idle' processes is greater than this
;                                    number then some children will be killed.
; Note: This value is mandatory.
pm = dynamic

; The number of child processes to be created when pm is set to 'static' and the
; maximum number of child processes to be created when pm is set to 'dynamic'.
; This value sets the limit on the number of simultaneous requests that will be
; served. Equivalent to the ApacheMaxClients directive with mpm_prefork.
; Equivalent to the PHP_FCGI_CHILDREN environment variable in the original PHP
; CGI.
; Note: Used when pm is set to either 'static' or 'dynamic'
; Note: This value is mandatory.
pm.max_children = 20

; The number of child processes created on startup.
; Note: Used only when pm is set to 'dynamic'
; Default Value: min_spare_servers + (max_spare_servers - min_spare_servers) / 2
pm.start_servers = 10

; The desired minimum number of idle server processes.
; Note: Used only when pm is set to 'dynamic'
; Note: Mandatory when pm is set to 'dynamic'
pm.min_spare_servers = 8

; The desired maximum number of idle server processes.
; Note: Used only when pm is set to 'dynamic'
; Note: Mandatory when pm is set to 'dynamic'
pm.max_spare_servers = 12
 
; The number of requests each child process should execute before respawning.
; This can be useful to work around memory leaks in 3rd party libraries. For
; endless request processing specify '0'. Equivalent to PHP_FCGI_MAX_REQUESTS.
; Default Value: 0
;pm.max_requests = 500

; The URI to view the FPM status page. If this value is not set, no URI will be
; recognized as a status page. By default, the status page shows the following
; information:
;   accepted conn    - the number of request accepted by the pool;
;   pool             - the name of the pool;
;   process manager  - static or dynamic;
;   idle processes   - the number of idle processes;
;   active processes - the number of active processes;
;   total processes  - the number of idle + active processes.
; The values of 'idle processes', 'active processes' and 'total processes' are
; updated each second. The value of 'accepted conn' is updated in real time.
; Example output:
;   accepted conn:   12073
;   pool:             www
;   process manager:  static
;   idle processes:   35
;   active processes: 65
;   total processes:  100
; By default the status page output is formatted as text/plain. Passing either
; 'html' or 'json' as a query string will return the corresponding output
; syntax. Example:
;   http://www.foo.bar/status
;   http://www.foo.bar/status?json
;   http://www.foo.bar/status?html
; Note: The value must start with a leading slash (/). The value can be
;       anything, but it may not be a good idea to use the .php extension or it
;       may conflict with a real PHP file.
; Default Value: not set 
;pm.status_path = /status
 
; The ping URI to call the monitoring page of FPM. If this value is not set, no
; URI will be recognized as a ping page. This could be used to test from outside
; that FPM is alive and responding, or to
; - create a graph of FPM availability (rrd or such);
; - remove a server from a group if it is not responding (load balancing);
; - trigger alerts for the operating team (24/7).
; Note: The value must start with a leading slash (/). The value can be
;       anything, but it may not be a good idea to use the .php extension or it
;       may conflict with a real PHP file.
; Default Value: not set
;ping.path = /ping

; This directive may be used to customize the response of a ping request. The
; response is formatted as text/plain with a 200 response code.
; Default Value: pong
;ping.response = pong
 
; The timeout for serving a single request after which the worker process will
; be killed. This option should be used when the 'max_execution_time' ini option
; does not stop script execution for some reason. A value of '0' means 'off'.
; Available units: s(econds)(default), m(inutes), h(ours), or d(ays)
; Default Value: 0
;request_terminate_timeout = 0
 
; The timeout for serving a single request after which a PHP backtrace will be
; dumped to the 'slowlog' file. A value of '0s' means 'off'.
; Available units: s(econds)(default), m(inutes), h(ours), or d(ays)
; Default Value: 0
request_slowlog_timeout = 1s
 
; The log file for slow requests
; Default Value: /usr/local/php/var/log/php-fpm.log.slow
slowlog = /usr/local/php/var/log/php-fpm.log.slow
 
; Set open file descriptor rlimit.
; Default Value: system defined value
rlimit_files = 65535
 
; Set max core size rlimit.
; Possible Values: 'unlimited' or an integer greater or equal to 0
; Default Value: system defined value
;rlimit_core = 0
 
; Chroot to this directory at the start. This value must be defined as an
; absolute path. When this value is not set, chroot is not used.
; Note: chrooting is a great security feature and should be used whenever 
;       possible. However, all PHP paths will be relative to the chroot
;       (error_log, sessions.save_path, ...).
; Default Value: not set
;chroot = 
 
; Chdir to this directory at the start. This value must be an absolute path.
; Default Value: current directory or / when chroot
;chdir = /var/www
 
; Redirect worker stdout and stderr into main error log. If not set, stdout and
; stderr will be redirected to /dev/null according to FastCGI specs.
; Default Value: no
;catch_workers_output = yes
 
; Pass environment variables like LD_LIBRARY_PATH. All $VARIABLEs are taken from
; the current environment.
; Default Value: clean env
;env[HOSTNAME] = $HOSTNAME
;env[PATH] = /usr/local/bin:/usr/bin:/bin
;env[TMP] = /tmp
;env[TMPDIR] = /tmp
;env[TEMP] = /tmp

; Additional php.ini defines, specific to this pool of workers. These settings
; overwrite the values previously defined in the php.ini. The directives are the
; same as the PHP SAPI:
;   php_value/php_flag             - you can set classic ini defines which can
;                                    be overwritten from PHP call 'ini_set'. 
;   php_admin_value/php_admin_flag - these directives won't be overwritten by
;                                     PHP call 'ini_set'
; For php_*flag, valid values are on, off, 1, 0, true, false, yes or no.

; Defining 'extension' will load the corresponding shared extension from
; extension_dir. Defining 'disable_functions' or 'disable_classes' will not
; overwrite previously defined php.ini values, but will append the new value
; instead.

; Default Value: nothing is defined by default except the values in php.ini and
;                specified at startup with the -d argument
;php_admin_value[sendmail_path] = /usr/sbin/sendmail -t -i -f www@my.domain.com
;php_flag[display_errors] = off
;php_admin_value[error_log] = /var/log/fpm-php.www.log
;php_admin_flag[log_errors] = on
;php_admin_value[memory_limit] = 32M
EOF
##php-fpm start
service php-fpm start


# install Nginx
wget -c  http://iweb.dl.sourceforge.net/project/pcre/pcre/8.32/pcre-8.32.tar.gz
tar xzf pcre-8.32.tar.gz
cd pcre-8.32
./configure
make && make install
cd ../
#wget -c http://labs.frickle.com/files/ngx_cache_purge-2.1.tar.gz
#tar xzf ngx_cache_purge-2.1.tar.gz 
wget -c http://nginx.org/download/nginx-1.4.1.tar.gz
tar xzf nginx-1.4.1.tar.gz
cd nginx-1.4.1

# Modify Nginx version
sed -i 's@#define NGINX_VERSION.*$@#define NGINX_VERSION      "1.1.0"@g' src/core/nginx.h
sed -i 's@#define NGINX_VER.*NGINX_VERSION$@#define NGINX_VER          "TWS/" NGINX_VERSION@g' src/core/nginx.h
#./configure --prefix=/usr/local/nginx --user=www --group=www --with-http_stub_status_module --with-http_ssl_module --add-module=../ngx_cache_purge-2.1
./configure --prefix=/usr/local/nginx --user=www --group=www --with-http_stub_status_module --with-http_ssl_module
make && make install
########Nginx简单优化配置##################
cores_number=`cat /proc/cpuinfo | grep processor|wc -l`
cat > /usr/local/nginx/conf/nginx.conf <<EOF
user  nobody nobody;
worker_processes ${cores_number};
##8核心可配置worker_cpu_affinity 00000001 00000010 00000100 00001000 00010000 00100000 01000000 10000000;
error_log  logs/nginx_error.log  crit;
pid        /usr/local/nginx/run/nginx.pid;
 
#Specifies the value for maximum file descriptors that can be opened by this process.
worker_rlimit_nofile 51200;

events 
{
 use epoll;
 worker_connections 51200;
}
 
http
{
 include       mime.types;
 default_type  application/octet-stream;
 server_tokens off;
 #charset  gb2312; 
     
 server_names_hash_bucket_size 128;
 client_header_buffer_size 32k;
 large_client_header_buffers 4 32k;
 
 client_max_body_size 16M;
     
 sendfile on;
 tcp_nopush     on;
 
 keepalive_timeout 60;
 
 tcp_nodelay on;
 
 fastcgi_connect_timeout 300;
 fastcgi_send_timeout 300;
 fastcgi_read_timeout 300;
 fastcgi_buffer_size 64k;
 fastcgi_buffers 4 64k;
 fastcgi_busy_buffers_size 128k;
 
 gzip on;
 gzip_min_length  1k;
 gzip_buffers     4 16k;
 gzip_http_version 1.0;
 gzip_comp_level 2;
 gzip_types       text/plain application/x-javascript text/css application/xml;
 gzip_vary on;
 #limit_zone  crawler  $binary_remote_addr  10m;

 proxy_next_upstream error timeout invalid_header http_500 http_503;
 log_format  http_access  '\$remote_addr - \$remote_user [\$time_local] "\$request" '
             '\$status \$body_bytes_sent "\$http_referer" '
             '"\$http_user_agent" \$http_x_forwarded_for';
 server
 {
   listen       80;
   index index.html index.php;
   root  /data/wwwroot;
   
   location ~ .*\.(php|php5)?$
   {
     fastcgi_pass  127.0.0.1:9000;
     fastcgi_index index.php;
     include fastcgi.conf;
   }
   access_log  logs/ip_access.log  http_access;
 }
}
EOF
cat >/etc/rc.d/init.d/nginx <<EOF
#!/bin/bash
#Author:Geekwolf
#Email:gzgeekwolf@teamtop.com
#Blog:www.linuxhonker.com
# chkconfig: 12345 13 99
# description:  Nginx-1.4.1
function_start_nginx(){
printf "Starting Nginx ...\n"

/usr/local/nginx/sbin/nginx 2>&1 > /dev/null &
}

function_stop_nginx(){
printf "Stoping Nginx ...\n"
ps -ef | grep "nginx:" | grep -v grep | awk '{print "kill -9 " \$2}' | /bin/sh
}

function_reload_nginx(){
printf "Reloading Nginx ...\n"
ps -ef | grep "nginx: master process" | grep -v grep | awk '{print "kill -HUP " \$2}' | /bin/sh
}

function_restart_nginx(){
printf "Restarting Nginx ...\n"
function_stop_nginx
sleep 3
function_start_nginx
}

if [ "\$1" = "start" ]; then
function_start_nginx
elif [ "\$1" = "stop" ]; then
function_stop_nginx
elif [ "\$1" = "reload" ]; then
function_reload_nginx
elif [ "\$1" = "restart" ]; then
function_restart_nginx
else
printf "Usage: nginx {start|stop|reload|restart} \n"
fi 
EOF
chmod +x /etc/rc.d/init.d/nginx
chkconfig --add nginx
chkconfig nginx on
mkdir /usr/local/nginx/run
sed -i s#logs/nginx.pid#run/nginx.pid#g  /usr/local/nginx/conf/nginx.conf
#logrotate nginx log
cat > /etc/logrotate.d/nginx << EOF
/usr/local/nginx/logs/*.log {
        daily
        rotate 7
        dateext
        create 0664 daemon daemon
        sharedscripts
        postrotate
        /bin/kill -USR1 \`/bin/cat /usr/local/nginx/run/nginx.pid\`
        endscript
}
EOF

###网站根目录###
mkdir /data/wwwroot
echo '<?php
phpinfo()
?>' > /data/wwwroot/index.php
service nginx restart


## install Pureftpd and pureftpd_php_manager 
#cd ../source
#wget -c ftp://ftp.pureftpd.org/pub/pure-ftpd/releases/pure-ftpd-1.0.36.tar.gz
#tar xzf pure-ftpd-1.0.36.tar.gz
#cd pure-ftpd-1.0.36
#./configure --prefix=/usr/local/pureftpd CFLAGS=-O2 --with-mysql=/usr/local/mysql --with-quotas --with-cookie --with-virtualhosts --with-virtualchroot --with-diraliases --with-sysquotas --with-ratios --with-altlog --with-paranoidmsg --with-shadow --with-welcomemsg  --with-throttling --with-uploadscript --with-language=simplified-chinese
#make && make install
#cp configuration-file/pure-config.pl /usr/local/pureftpd/sbin
#chmod +x /usr/local/pureftpd/sbin/pure-config.pl
#cp contrib/redhat.init /etc/init.d/pureftpd
#sed -i 's@fullpath=.*@fullpath=/usr/local/pureftpd/sbin/$prog@' /etc/init.d/pureftpd
#sed -i 's@pureftpwho=.*@pureftpwho=/usr/local/pureftpd/sbin/pure-ftpwho@' /etc/init.d/pureftpd
#sed -i 's@/etc/pure-ftpd.conf@/usr/local/pureftpd/pure-ftpd.conf@' /etc/init.d/pureftpd
#chmod +x /etc/init.d/pureftpd
#chkconfig --add pureftpd
#chkconfig pureftpd on
#
#cd ../../conf
#wget -c https://raw.github.com/lj2007331/lnmp/master/conf/pure-ftpd.conf
#wget -c https://raw.github.com/lj2007331/lnmp/master/conf/pureftpd-mysql.conf
#wget -c https://raw.github.com/lj2007331/lnmp/master/conf/script.mysql 
#/bin/cp pure-ftpd.conf /usr/local/pureftpd/
#/bin/cp pureftpd-mysql.conf /usr/local/pureftpd/
#mysqlftppwd=`cat /dev/urandom | head -1 | md5sum | head -c 8`
#sed -i 's/tmppasswd/'$mysqlftppwd'/g' /usr/local/pureftpd/pureftpd-mysql.conf
#sed -i 's/mysqlftppwd/'$mysqlftppwd'/g' script.mysql
#sed -i 's/ftpmanagerpwd/'$ftpmanagerpwd'/g' script.mysql
#/usr/local/mysql/bin/mysql -uroot -p$mysqlrootpwd< script.mysql
#service pureftpd start
#
#mkdir -p /data/admin
#cd ../source
#wget -c http://acelnmp.googlecode.com/files/ftp_v2.1.tar.gz
#tar xzf ftp_v2.1.tar.gz
#mv ftp /data/admin;chown -R www.www /data/admin
#sed -i 's/tmppasswd/'$mysqlftppwd'/g' /data/admin/ftp/config.php
#IP=`ifconfig | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}'`
#sed -i 's/myipaddress.com/'$IP'/g' /data/admin/ftp/config.php
#sed -i 's/127.0.0.1/localhost/g' /data/admin/ftp/config.php
#sed -i 's@iso-8859-1@UTF-8@' /data/admin/ftp/language/english.php
#rm -rf  /data/admin/ftp/install.php
#
echo "################Congratulations####################"
echo "The path of some dirs:"
echo "Nginx dir:                     /usr/local/nginx"
echo "MySQL dir:                     /usr/local/mysql"
echo "PHP dir:                       /usr/local/php"
#echo "Pureftpd dir:                  /usr/local/pureftpd"
#echo "Pureftp_php_manager  dir :     /data/admin"
echo "MySQL Password:                $mysqlrootpwd"
#echo "Pureftp_manager  url :         http://$IP/ftp"
#echo "Pureftp_manager Password:      $ftpmanagerpwd"
echo "###################################################"
EOF
