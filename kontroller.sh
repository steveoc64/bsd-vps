#! /bin/sh

export KONTROL_PORT=4099
export KONTROL_USERNAME="kontrol"
export KONTROL_STORAGE="etcd"
export KONTROL_KONTROLURL="http://10.240.13.11:4099/kite"
export KONTROL_PUBLICKEYFILE=/root/certs/key_pub.pem
export KONTROL_PRIVATEKEYFILE=/root/certs/key.pem
 
echo starting etcd
daemon -o /root/etcd.log /usr/local/bin/etcd &
echo .. waiting for startup
sleep 1
echo starting kontrol
daemon -o /root/kontrol.log /root/go/bin/kontrol
~


