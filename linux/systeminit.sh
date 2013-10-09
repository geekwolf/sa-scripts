#!/bin/bash
#Modify by Geekwolf
#Blog:http://www.linuxhonker.com
#CentOS6.4 x64 system initalization script
#Release:1.0
#适合测试环境：最小化安装Centos6.4 X64
cat << EOF
+---------------------------------------+
|   CentOS6.4 x64 system initalization   |
|        start optimizing.......         |
+---------------------------------------
EOF
#修改默认yum源，更改为163或者sohu
rm -rf /etc/yum.repo.d/*
wget http://mirrors.163.com/.help/CentOS6-Base-163.repo -O /etc/yum.repos.d/CentOS-Base.repo
#增加EPEL源（很多常用的软件，是专门针对RHEL的一个补充）
rpm -Uvh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-6
#增加RPMForge源，是CentOS推荐的源
rpm -Uvh http://pkgs.repoforge.org/rpmforge-release/rpmforge-release-0.5.2-2.el6.rf.x86_64.rpm
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-rpmforge-dag
rm -rf /etc/yum.repo.d/mirrors*
rm -rf /etc/yum.repo.d/epel-testing.repo
#安装yum -y install priorities,用于配置调用yum源时的优先级，此处设置CentOS-Base.repo源优先级最高
#（priority=[1],1为最高，99为最低）
sed -i  's#^gpgkey=http://mirror.centos.org/centos/RPM-GPG-KEY-CentOS-6#& \npriority=1#g' /etc/yum.repos.d/CentOS-Base.repo
sed -i  's#^gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-6#& \npriority=2#g'	/etc/yum.repos.d/epel.repo
sed -i  's#^gpgkey = file:///etc/pki/rpm-gpg/RPM-GPG-KEY-rpmforge-dag#& \npriority=3#g'   /etc/yum.repos.d/rpmforge.repo
/usr/bin/yum makecache

cat <<	EOF
+---------------------------------------+
|   	SNMP Monitor & sysstat          |
|        install.......                 |
+---------------------------------------
EOF
#安装net-snmp,sysstat
yum -y install net-snmp sysstat vim >/dev/null 2>&1
echo "alias vi='vim'">>/etc/bashrc
echo "\033[40;33mSNMP&Sysstat has been installed!\n \033[0m"

sed -i -e s#'com2sec notConfigUser  default       public'#'com2sec notConfigUser  192.168.1.73       public'#g  /etc/snmp/snmpd.conf
echo 'pass .1.3.6.1.3.1 /usr/bin/perl /usr/local/bin/iostat.pl'>/etc/snmp/snmpd.conf
 /sbin/service snmpd restart
echo -e "\033[40;33mSNMP Start Sucessfully!\n \033[0m"

#sync time
yum -y install ntp
echo "0 0 * * *  root  /usr/sbin/ntpdate ntp.fudan.edu.cn;hwclock -w">>/etc/crontab
/usr/sbin/ntpdate ntp.fudan.edu.cn;hwclock -w
#设置默认字符集语言字体等
cat >/etc/sysconfig/i18n <<EOF
LANG="zh_CN.UTF-8"
SUPPORTED="zh_CN.UTF-8:zh_CN.GBK:zh:en_US.UTF-8:en_US:en"
SYSFONT="latarcyrheb-sun16"
EOF
echo -e "\033[40;33msync time &LAN set OK!\n \033[0m"

#文件句柄及会话进程限制
cat >> /etc/security/limits.conf <<EOF
*	soft	nofile	65535
*	hard	nofile	65535
*	soft	nproc	65535
*	hard	nproc	65535
EOF
sed -i 's#1024#65535#' /etc/security/limits.d/90-nproc.conf
#内核优化配置（基础系统内核优化)
cat >> /etc/sysctl.conf << EOF
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_syn_retries = 1
net.ipv4.tcp_tw_recycle = 1
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_fin_timeout = 1
net.ipv4.tcp_keepalive_time = 1200
net.ipv4.ip_local_port_range = 1024 65535
EOF
/sbin/sysctl -p

#禁止ipv6
sysctl -w  net.ipv6.conf.all.disable_ipv6=1 >/dev/null 2>&1

#ssh默认端口更改
sed -i 's#\#Port 22#Port 22222#' /etc/ssh/sshd_config
sed -i 's#\#Banner none#Banner /etc/ssh/banner#' /etc/ssh/sshd_config
echo "Welcome to the TWOS! Proceed with caution!">/etc/ssh/banner
/sbin/service sshd restart
echo -e "\033[40;33mSSH Port has been changed to 22222!!\n \033[0m"

#tcpwrapper配置
cat >> /etc/hosts.allow <<EOF
sshd:192.168.1.*:allow
EOF
echo "sshd:ALL:deny">>/etc/hosts.deny
sed -i 's#SELINUX=enforcing#SELINUX=disabled#' /etc/selinux/config

#关闭ipv6tables并配置iptables
echo "alias net-pf-10 off">>/etc/modprobe.conf
echo "alias ipv6 off" >>/etc/modprobe.conf
/sbin/chkconfig ip6tables off
echo "\033[40;33mDisable Ipv6 set OK!!\n \033[0m"

IPTABLES=/sbin/iptables
ICMP_IP=222.111.111.111/32
SSH_IP=222.111.111.111/32

$IPTABLES -F
$IPTABLES -X
$IPTABLES -Z
$IPTABLES -P INPUT DROP
$IPTABLES -P FORWARD DROP
$IPTABLES -P OUTPUT ACCEPT
$IPTABLES -A INPUT -m state --stat RELATED,ESTABLISHED -j ACCEPT
#124.172.207.192/27为IDC监控机IP
$IPTABLES -A INPUT -i lo -j ACCEPT

$IPTABLES -A INPUT -s $ICMP_IP -p icmp -j ACCEPT 
$IPTABLES -A INPUT -s $SSH_IP  -p tcp  -m tcp --dport 22222 -j ACCEPT
#$IPTABLES -A INPUT -p tcp -m tcp --dport 80 -j ACCEPT
echo -e "\033[40;33mTcpwrapper&Iptables&Selinux set OK!!\n \033[0m"

#删除不必要的账户
NO_USERS='adm lp news uucp operator  sync ftp gopher games postfix'
for i in  $NO_USERS
do 
	userdel $i
done

#关闭不比要的服务
NO_SERVICES='cups ip6tables netfs nslock postfix'
for j in $NO_SERVICES
do
	chkconfig --level 012345  $j off
done
#设置历史命令条数
echo "HISTSIZE=200">>/etc/profile