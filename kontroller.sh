#! /bin/sh
cd /root
echo starting etcd
daemon -o /root/etcd.log /usr/local/bin/etcd &
echo .. waiting for startup
sleep 2
echo starting kontrol
daemon -o /root/kontrol.log /root/go/bin/kontrol &

