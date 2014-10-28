#!/bin/bash
Author:Geekwolf
Blog:http://www.simlinux.com

rm -rf /var/log/nova/*.log
mkdir /var/log/nova/
service mysqld start
service rabbitmq-server start
 
/usr/bin/glance-registry --config-file=/etc/glance/glance-registry.conf > /var/log/nova/glance-registry.log 2>&1 &
 
/usr/bin/glance-api --config-file=/etc/glance/glance-api.conf > /var/log/nova/glance-api.log 2>&1 &
echo "Waiting for g-api to start..."
if ! timeout 60 sh -c "while ! wget --no-proxy -q -O- http://127.0.0.1:9292;
do sleep 1; done"; then
        echo "g-api did not start"
        exit 1
fi
echo "Done."
 
/usr/bin/keystone-all --config-file /etc/keystone/keystone.conf --log-config /etc/keystone/logging.conf -d --debug > /var/log/nova/keystone-all.log 2>&1 &
echo "Waiting for keystone to start..."
if ! timeout 60 sh -c "while ! wget --no-proxy -q -O- http://127.0.0.1:5000;
do sleep 1; done"; then
        echo "keystone did not start"
        exit 1
fi
echo "Done."
 
/usr/bin/cinder-api --config-file /etc/cinder/cinder.conf > /var/log/nova/cinder-api.log 2>&1 &
 
/usr/bin/cinder-volume --config-file /etc/cinder/cinder.conf > /var/log/nova/cinder-volume.log 2>&1 &
 
/usr/bin/cinder-scheduler --config-file /etc/cinder/cinder.conf > /var/log/nova/cinder-scheduler.log 2>&1 &
 
/usr/bin/nova-api > /var/log/nova/nova-api.log 2>&1 &
echo "Waiting for nova-api to start..."
if ! timeout 60 sh -c "while ! wget --no-proxy -q -O- http://127.0.0.1:8774;
do sleep 1; done"; then
        echo "nova-api did not start"
        exit 1
fi
echo "Done."
 
/usr/bin/nova-scheduler > /var/log/nova/nova-scheduler.log 2>&1 &
 
/usr/bin/nova-cert > /var/log/nova/nova-cert.log 2>&1 &
 
/usr/bin/nova-objectstore > /var/log/nova/nova-objectstore.log 2>&1 &

/usr/bin/nova-network > /var/log/nova/nova-network.log 2>&1 &
 
/usr/bin/nova-compute > /var/log/nova/nova-compute.log 2>&1 &
 
/opt/stack/noVNC/utils/nova-novncproxy --config-file /etc/nova/nova.conf  --web . > /var/log/nova/nova-novncproxy.log 2>&1 &
 
/usr/bin/nova-xvpvncproxy --config-file /etc/nova/nova.conf > /var/log/nova/nova-xvpvncproxy.log 2>&1 &
 
/usr/bin/nova-consoleauth > /var/log/nova/nova-consoleauth.log 2>&1 &
 
service httpd  restart
