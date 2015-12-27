
Blog：[http://www.simlinux.com](http://www.simlinux.com)<br>
Weibo:[http://weibo.com/geekwolf](http://weibo.com/geekwolf)<br>


**Bootstrapping：**&emsp;Kickstart、Cobbler、rpmbuild/xen、kvm、lxc、Openstack、 Cloudstack、Opennebula、Eucalyplus、RHEV<br>
**配置类工具:**&emsp;Capistrano、Chef、puppet、func、salstack、Ansible、rundeck、CFengine、Rudder<br>
**自动化构建和测试:**&emsp;Ant、Maven、Selenium、PyUnit、QUnit、JMeter、Gradle、PHPUnit<br>
**监控类工具:**&emsp;Cacti、Nagios(Icinga)、Zabbix、基于时间监控前端Grafana、Mtop、MRTG(网络流量监控图形工具)、[Monit](https://mmonit.com/) 、Diamond+Graphite+Grafana<br>
**微服务平台:**&emsp;OpenShift、Cloud Foundry、Kubernetes、Mesosphere<br>
**性能监控工具:**&emsp;dstat(多类型资源统计)、atop(htop/top)、nmon(类Unix系统性能监控)、slabtop(内核slab缓存信息)、sar(性能监控和瓶颈检查)、sysdig(系统进程高级视图)、tcpdump(网络抓包)、iftop(类似top的网络连接工具)、iperf(网络性能工具)、smem)(高级内存报表工具)、collectl(性能监控工具)<br>
**免费APM工具:**&emsp;&emsp;[mmtrix(见过的最全面的分析工具)](http://www.mmtrix.com/evaluate/result)、[alibench](http://alibench.com/)<br>
**进程监控:**&emsp;&emsp;[mmonit](http://mmonit.com/monit/documentation/monit.html)、Supervisor、[frigga](https://github.com/xiaomi-sa/frigga)、 [StrongLoop Process Manager](http://strong-pm.io/compare/)<br>
**日志系统:**&emsp;&emsp;Logstash、Scribe<br>
**绘图工具:**&emsp;&emsp;RRDtool、Gnuplot<br>
**流控系统:**&emsp;&emsp;Panabit、[在线数据包分析工具Pcap Analyzer](http://le4f.net/post/post/pcap-online-analyzer)<br>
**安全检查:**&emsp;&emsp;chrootkit、rkhunter<br>
**PaaS：**&emsp;&emsp;&emsp;Cloudify、Cloudfoundry、Openshift、[Deis](http://www.deis.io/) （Docker、CoreOS、[Atomic](https://access.redhat.com/articles/rhel-atomic-getting-started)、[ubuntu core/Snappy](http://www.ubuntu.com/cloud/tools/snappy)、[RancherOS](http://rancher.com)） <br>
**Troubleshooting:**[Sysdig](http://www.sysdig.org/) 、Systemtap、Perf<br>
**服务发现：**&emsp;&emsp;&emsp;[SmartStack](http://nerds.airbnb.com)、etcd <br>
**持续集成:**&emsp;&emsp;[Go](http://www.go.cd)、Jenkins、Gitlab、[facebook代码审查工具phabricator](http://phabricator.org/)、[spinnaker](http://spinnaker.io/)<br>
**APP CD:**&emsp;&emsp;[fastlane](https://fastlane.tools/#tools)</br>
**磁盘压测:**&emsp;&emsp;fio、iozone、IOMeter(win)<br>
**Memcache**&emsp;&emsp;[Mcrouter(scaling memcached)](https://github.com/facebook/mcrouter)<br>
**Redis**&emsp;&emsp;[Dynomite](https://github.com/Netflix/dynomite)、Twemproxy、codis/SSDB/Aerospike、Redis Cluster<br>
**MySQL 监控:**&emsp;mytop、orzdba、Percona-toolkit、Maatkit、[innotop](http://www.percona.com/blog/2013/10/14/innotop-real-time-advanced-investigation-tool-mysql/)、[myawr](https://github.com/noodba/myawr)、[SQL级监控mysqlpcap](https://github.com/hoterran/tcpcollect)、[拓扑可视化工具](https://github.com/outbrain/orchestrator) <br>
**MySQL基准测试:**&emsp;mysqlsla、sql-bench、Super Smack、Percona's TPCC-MYSQL Tool、sysbench <br>
**MySQL Proxy:**&emsp;[SOHU-DBProxy](https://github.com/SOHUDBA/SOHU-DBProxy)、[Mycat](http://www.mycat.org.cn/)、[Altas](https://github.com/Qihoo360/Atlas)、[cobar](https://github.com/alibaba/cobar)、[58同城Oceanus](https://github.com/58code/Oceanus)、[kingshard](https://github.com/flike/kingshard)<br>
**MySQL逻辑备份工具**:&emsp;mysqldump、mysqlhotcopy、mydumper、MySQLDumper 、mk-parallel-dump/mk-parallel-restore<br>
**MySQL物理备份工具**:&emsp;Xtrabackup、LVM Snapshot<br>
**MongoDB压测:**&emsp;[iibench&sysbench](https://github.com/tmcallaghan)<br>

**DevOps**<br>
![DevOps](http://cdn2.hubspot.net/hubfs/381387/Blog-image-tracking/ElasticBox-DevOps_Open_Source_Tools.png?utm_campaign=Wordpress&utm_medium=social&utm_source=mybloglog)<br>
**Capistrano**

Capistrano是一种在多台服务器上运行脚本的开源工具，它主要用于部署web应用。它自动完成多台服务器上新版本的同步更新，包括数据库的改变。Capistrano最初由Jamis Buck用Ruby开发，并用RubyGems部署渠道部署。现在Capistrano不仅限于应用Ruby on Rails的 web应用框架，而且可以用于部署用其他框架的web应用程序，比如用PHP开发的。（ [项目详情](https://code.csdn.net/openkb/p-capistrano)）

**代码托管地址**： https://github.com/capistrano/capistrano

**推荐相关文档**：

[Capistrano开发日记（1）（ 2）](http://blog.csdn.net/optman/article/details/1773731)<br>
[自动化部署实践capistrano](http://blog.csdn.net/hexudong08/article/details/7915333)<br>
[用 Capistrano 边写 Ruby 边部署迭代 ](http://blog.csdn.net/qzier_go/article/details/35971091)<br>
[用capistrano写一个简单的deploy脚本 ](http://blog.csdn.net/passionboyxie/article/details/7328104)<br>
[使用 Capistrano —— Rails应用快速部署工具 ](http://blog.csdn.net/shoyer/article/details/9173121)<br>
[使用Capistrano部署apache+mongrel cluster](http://blog.csdn.net/pwlazy/article/details/1899731)<br>

**Chef**

一个系统集成框架，为您的整个基础设备提供配置管理。使用Chef，你可以：

编写代码来管理你的服务器，而不是运行命令（通过Cookbooks）<br>
集成tightly到你的应用程序，数据库，LDAP目录等……（通过类库）；<br>
轻松的配置应用程序，但需要了解您的基础设备（运行的什么系统？当前的主数据库服务 器是什么？）<br>
基本上，Chef就是一个Ruby配置管理引擎。您提供配方，希望您的系统如何去配置，然后交给厨师Chef，它将会为您配置你所希望的一切。你可以编写可爱的Ruby代码来管理你的服务器，而不需要使用命令去执行。（ 项目详情）<br>

**代码托管地址**： https://github.com/opscode/chef

**推荐下载资源**：

[chef详细配置](http://download.csdn.net/detail/fengzhongfei123/4552153)<br>
[chef fundamental](http://download.csdn.net/detail/brianhu2006/5628477) <br>
[Chef-Infrastructure-Automation-Cookbook-eBook.pdf](http://download.csdn.net/detail/philipx41/7470387)<br>
[ Automated Chef cookbook testing with Drone.io and github](http://download.csdn.net/detail/fengzhu1234/7669479) <br>

**Docker**
  
Docker是dotCloud开源的、可以将任何应用包装在Linux Container中运行的工具，2013年3月发布首个版本。当应用被打包成Docker Image后，部署和运维就变得极其简单。可以使用统一的方式下载、启动、扩展、删除、迁移。Docker可以用来：自动化打包和部署任何应用、创建一个轻量级私有PaaS云、搭建开发测试环境、部署可扩展的Web应用。（ [项目详情](https://code.csdn.net/openkb/p-Docker)）

项目主页： http://docker.io

代码托管地址： https://github.com/dotcloud/docker

推荐相关文档：

[从coreos到docker到golang](http://blog.csdn.net/leonzhouwei/article/details/38380917)<br>
[[Docker]初次接触](http://blog.csdn.net/lzz957748332/article/details/38648075)
[Docker 介绍: 相关技术(LXC) ](http://blog.csdn.net/chenliujiang1989/article/details/17679691)<br>
[Docker创建MySQL容器 ](http://blog.csdn.net/junjun16818/article/details/30696295)
[一些 Docker 的技巧与秘诀 ](http://blog.csdn.net/junjun16818/article/details/30696295)<br>
[轻轻松松在centos上部署docker服务](http://blog.csdn.net/junjun16818/article/details/30696295)<br>

**推荐下载资源：**

[Docker on Google App Engine](http://download.csdn.net/detail/u010702509/7559553)<br>
[Docker 入门教程](http://download.csdn.net/detail/javet/7754195) <br>
[Docker_MongoDB ](https://code.csdn.net/u010702509/docker_mongodb)<br>
[Docker the road ahead](http://download.csdn.net/detail/u010702509/7559149)<br>
[Docker中文社区：Docker with OpenStack.pdf ](http://download.csdn.net/detail/fengzhu1234/7669431)<br>
[七牛云存储的首席布道师徐立：the docker way ](http://download.csdn.net/detail/imsingo/7420209)<br>
[桂阳：通过工作流实现Docker在CoreOS自动化部署](http://download.csdn.net/detail/fengzhu1234/7669387)<br>

**Logstash**

  
Logstash 是一个应用程序日志、事件的传输、处理、管理和搜索的平台。（ [项目详情](https://code.csdn.net/openkb/p-Logstash)）

项目主页： http://logstash.net/

代码托管地址： https://github.com/elasticsearch/logstash

推荐相关文档：

[使用logstash分析Apache日志](http://blog.csdn.net/wdt3385/article/details/15812353)<br>
[日志文件监控利器 - logstash](http://blog.csdn.net/hljlzc2007/article/details/17392815)<br>
[Logback和Logstash的集成](http://blog.csdn.net/kmtong/article/details/38920327)<br>
[用 elasticsearch 和 logstash 为数十亿次客户搜索提供服务](http://blog.csdn.net/adermxl/article/details/27219031)<br>
[使用logstash+elasticsearch+kibana快速搭建日志平台](http://blog.csdn.net/cnbird2008/article/details/38762795)<br>
[logstash开源日志管理系统-2-logstash配置语言介绍](http://blog.csdn.net/u010287559/article/details/18409547)<br>

**OpenStack**

OpenStack是由Rackspace与NASA于2010年7月共同推出的云计算开源项目，目的是提供大规模云操作系统，支持类似AWS功能的IaaS平台。目前已经成为仅次于Linux的最大的开源社区，其会员覆盖几乎所有主流的IT供应商。OpenStack广泛在互联网公司和传统企业间部署，并因经诞生了许多创业公司。OpenStack拥有非常好的架构，这体现在所有功能全部模块和API化，模块之间松耦合。（ [项目详情](https://code.csdn.net/openkb/p-OpenStack)）

项目主页： http://www.openstack.org/

代码托管地址： https://github.com/openstack/openstack 
推荐相关文档：

[如何学习OpenStack，如何成为OpenStack工程师？](http://blog.csdn.net/z_lstone/article/details/14127227)<br>
[Openstack能走多远——Openstack、VMware浅析](http://blog.csdn.net/u012620688/article/details/13743517)<br>
[【OpenStack】Openstack之Cinder服务初探](http://blog.csdn.net/lynn_kong/article/details/8659145)<br>
[【OpenStack】在OpenStack上搭建OpenStack UT环境](http://blog.csdn.net/lynn_kong/article/details/9665027)<br>
[OpenStack学习笔记之--OpenStack Nova 架构](http://blog.csdn.net/xiangmin2587/article/details/7737778)<br>
**推荐下载资源：**

[openstack快速进阶](http://download.csdn.net/detail/bilyyang/5810571)<br>
[OpenStack运维指南](http://download.csdn.net/detail/adela_09/5130471)<br>
[Openstack基础讲解](http://download.csdn.net/detail/necessary8/4474697)<br>
[openstack 安装以及配置教程超详细](http://download.csdn.net/detail/zhenxi537/4427341)<br>
[OpenStack云计算平台管理教程下载 OpenStack入门教程](http://download.csdn.net/detail/u010973404/6580117)<br>

**Puppet**

  
你可以使用Puppet集中管理每一个重要方面，您的系统使用的是跨平台的规范语言，管理所有的单独的元素通常聚集在不同的文件，如用户， CRON作业，和主机一起显然离散元素，如包装，服务和文件。Puppet的简单陈述规范语言的能力提供了强大的classing制定了主机之间的相似之处，同时使他们能够提供尽可能具体的必要的，它依赖的先决条件和对象之间的关系清楚和明确。（ [项目详情](https://code.csdn.net/openkb/p-Puppet)）

**代码托管地址**： https://github.com/puppetlabs/puppet

**推荐相关文档**：

[puppet配置之puppet.conf详解中英文对照](http://blog.csdn.net/yzhou86/article/details/7008711)<br>
[开源自动化部署管理工具Puppet安装](http://blog.csdn.net/tianxw1209/article/details/6259712)<br>
[集中化运维管理——Puppet管理之路](http://blog.csdn.net/wenhuiqiao/article/details/7998715)<br>
[puppet核心资源类型及其常见属性学习笔记](http://blog.csdn.net/iloveyin/article/details/7764310)<br>
[自动化运维之puppet](http://blog.csdn.net/blade2001/article/details/8966674)
<br>

**推荐下载资源：**

[使用Puppet框架管理基础设施](http://download.csdn.net/detail/huzhouhzy/4901619)<br>
[puppet最经典中文手册资料](http://download.csdn.net/detail/machen_smiling/7642493)<br>
[[精通Puppet配置管理工具].高永超.扫描版](http://download.csdn.net/detail/jackjiaxiong/7334873)<br>
[puppet服务端安装流程](http://download.csdn.net/detail/wzs803/4607944)<br>
[Puppet在集群上的安装与测试](http://download.csdn.net/detail/wangfeinilin/5399065)<br>

**StatsD**

StatsD是一款运行在Node.js平台之上的网络应用，可以用来监听UDP端口的信息，并将监听到的数据生成实时图表。StatsD 0.1.0版本由Etsy发布于2012年2月16日。（ [项目详情](https://code.csdn.net/openkb/p-statsd)）

**代码托管地址**： https://github.com/etsy/statsd

**推荐相关文档**：

[StatsD学习](http://blog.csdn.net/puncha/article/details/9083061)<br>
[StatsD与Graphite联合作战](http://blog.csdn.net/puncha/article/details/9112293)<br>
[WEB监控系列第四篇：statsd指南](http://blog.csdn.net/crazyhacking/article/details/8446350)<br>
[在CentOS6上，statsD和Graphite的部署过程](http://blog.csdn.net/cnweike/article/details/36862847)<br>

**Vagrant**
  
Vagrant是一款用来构建和部署虚拟开发环境的工具，非常适合 PHP/Python/Ruby/Java这类语言开发Web应用，可通过Vagrant封装一个Linux开发环境，分发给团队成员，成员可以在自己喜欢的桌面系统（Mac/Windows/Linux）上开发程序，代码却能统一在封装好的环境里运行。它使用VirtualBox虚拟化系统，使用Chef创建自动化虚拟环境。（ [项目详情](https://code.csdn.net/openkb/p-Vagrant)）

**代码托管地址**： https://github.com/mitchellh/vagrant

**推荐相关文档**：

[Vagrant实践](https://github.com/astaxie/Go-in-Action/blob/master/ebook/zh/01.0.md)<br>
[Vagrant: Up and Running](http://download.csdn.net/detail/xmlredice/6842355)<br>
[使用Vagrant打造跨平台开发环境](http://blog.segmentfault.com/fenbox/1190000000264347)<br>
[Vagrant：程序员的VirtualBox（一）](http://fungo.me/linux/vagrant-for-programmer-ch1.html)<br>

**Ansible**

Ansible 是一个模型驱动的配置管理器，支持多节点发布、远程任务执行。默认使用 SSH 进行远程连接。无需在被管理节点上安装附加软件，可使用各种编程语言进行扩展。Ansible 提供一种最简单的方式用于发布、管理和编排计算机系统的工具，你可在数分钟内搞定。（ [项目详情](https://code.csdn.net/openkb/p-Ansible)） 
**代码托管地址**： https://github.com/ansible/ansible

**推荐相关文档**：

[tornado+ansible+twisted+mongodb运维自动化系统开发（ 一）（ 二）（ 三）](http://blog.csdn.net/qcpm1983/article/details/38078019)<br>
[在Puppet/Ansible中使用PPA](http://blog.csdn.net/kiwi_coder/article/details/38145633)<br>
[Ansible@一个高效的配置管理工具（系列文章](http://blog.csdn.net/qcpm1983/article/category/2388429)）<br>

**Salt**

Salt是一个大型分布式的配置管理系统（安装升级卸载软件，检测环境），也是一个远程命令执行系统。作为一个强大的远程执行管理器，Salt 用于快速和高效的服务器管理。比func 更强大。扩展更为方便。（ [项目详情](https://code.csdn.net/openkb/p-salt)） 
**代码托管地址**：https://github.com/saltstack/salt

**推荐相关文档**：

[salt的快速开始](http://blog.csdn.net/highkay/article/details/10124273)<br>
[salt的安装和配置](http://blog.csdn.net/highkay/article/details/10124129)<br>
[Salt 翻译之Grains](http://blog.csdn.net/qingchn/article/details/8985214)<br>
[Salt实战之自动安装部署MooseFS](http://blog.csdn.net/shanliangliuxing/article/details/8986731)<br>
[使用 Salt + Hash 来为密码加密](http://blog.csdn.net/wxwzy738/article/details/16839339)<br>

**Graphite-web**

Graphite-web 是 graphite组件之一, 提供一个django的可以高度扩展的实时画图系统。（ [项目详情](https://code.csdn.net/openkb/p-Graphite-web)）

**代码托管地址**： https://github.com/graphite-project/graphite-web

**官方文档**： http://graphite.readthedocs.org/en/latest/

**fabric**

Fabric 是一个 Python (2.5 或更高) 库和命令行工具，用于连接到 SSH 服务器并执行命令。（ 项目详情）<br>
**代码托管地址**： https://github.com/fabric/fabric

**推荐相关文档**：

[Python Fabric实现远程操作和部署](http://blog.csdn.net/jazywoo123/article/details/19152465)<br>
[MySQL原生HA方案 – Fabric体验之旅](http://blog.csdn.net/njchenyi/article/details/38739779)<br>
[MySQL Fabric部署](http://blog.csdn.net/wengjixi/article/details/37601045)
[使用Fabric部署Hadoop和HBase](http://blog.csdn.net/winsonyuan/article/details/7559744)<br>
[python fabric实现远程操作和部署 ](http://blog.csdn.net/climb_up/article/details/23293857)<br>

