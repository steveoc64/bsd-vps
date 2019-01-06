# bsd-vps
Settings for BSD based VPS

## Setup base system with all the things golang

```
pkg update
pkg install go git htop doas vim-console tmux
```

Make a special zfs volume for all the go code, and link it to the user's home dir. We are going to
mount this from inside the jails where needed, so there will be 1 only go repo on the whole box.

```
zfs create -o mountpoint=/usr/home/$USER/go zroot/go
chmod g+w /usr/home/$USER/go
su - $USER
go get github.com/steveoc64/bsd-vps
```

and check that all the code has been loaded into the $USER/go dir, and that the whole go src tree 
is on a zfs volume of its own.

## /etc/group

> Add self to wheel and operator groups

## /etc/ssh/sshd_config

Lockdown `/etc/ssh/sshd_config` - set port, turn off ChallengeResponseAuthentication, ensure PubkeyAuthentication is on

PermitRootlogin=no !!!

cp public keys to $HOME/.ssh/authorized_keys

then `service sshd restart` from the console.

## /root/.cshrc and $USER/.cshrc

Using .cshrc, just copy it to the home dir, and comment out the prompt that applies

## /etc/rc.conf

Using file `rc.conf` 

> set hostname
> set vtnet1 base IP address

## /etc/pf.conf

Using file pf.conf

Set all the specific jails

`service pf start` from the console to enable proper NAT'ing from inside the jails, and ssh back in to the box.

## Doas

/usr/local/etc/doas.conf

permit persist $USER as root

## Setup iocell

https://iocell.readthedocs.io

`pkg install iocell`

then hack iocell to remove doc.txz from /usr/local/lib/iocell/ioc-globals

then `iocell fetch` to grab 12.0-RELEASE, and you are ready to go

## Test jail networking

Creatiocell create tag=myjail boot=on allow_mount_zfs=1 allow_raw_sockets=1 mount_devfs=1 vnet=off ip4_addr='vtnet1|10.240.X.X/16'
iocell start myjail
iocell console myjail 
```

check that the prompt looks good, the aliases all work, ifconfig shows only what it should, netstat -nr doesnt show much, and that ping google.com is good.

## Jail settings

```
allow_raw_sockets=1
vnet=off
boot=on
ip4_addr='vtnet1|10.240.X.X/16'
mount_devfs=1   // if you need /dev/urandom support, ala grafana and some other tools
allow_mount=1
allow_mount_devfs=1
allow_mount_zfs=1
```

## Do some go dev inside the jail

```
ic myjail
pkg install go git
go version << check that go is accessible
```

Now lets mount the go source tree

```
???????????????
```

Lets try something complicated
```
go get github.com/koding/kite
```

That should fail, because the base package lacks some freebsd-isms. We fix !

```
cd ~/go/src/github.com/koding/kite
git remote rename origin upstream
git remote add origin https://github.com/steveoc64/kite # being a fork of the above with bsd fixes in place
git fetch origin
git checkout freebsd-support
git pull
cd kontrol
go get -u .
go install .
e a dummy jail first

```
iocell create tag=myjail boot=on allow_mount_zfs=1 allow_raw_sockets=1 mount_devfs=1 vnet=off ip4_addr='vtnet1|10.240.X.X/16'
iocell start myjail
iocell console myjail 
```

check that the prompt looks good, the aliases all work, ifconfig shows only what it should, netstat -nr doesnt show much, and that ping google.com is good.

## Jail settings

```
allow_raw_sockets=1
vnet=off
boot=on
ip4_addr='vtnet1|10.240.X.X/16'
mount_devfs=1   // if you need /dev/urandom support, ala grafana and some other tools
allow_mount=1
allow_mount_devfs=1
allow_mount_zfs=1
```

## Do some go dev inside the jail

```
ic myjail
pkg install go git
go version << check that go is accessible
```

Now lets mount the go source tree

```
???????????????
```

Lets try something complicated
```
go get github.com/koding/kite
```

That should fail, because the base package lacks some freebsd-isms. We fix !

```
cd ~/go/src/github.com/koding/kite
git remote rename origin upstream
git remote add origin https://github.com/steveoc64/kite # being a fork of the above with bsd fixes in place
git fetch origin
git checkout freebsd-support
git pull
cd kontrol
go get -u .
go install .
```

That should work, so now its ok to get rid of the test jail, and start building a real basejail.

`iocell stop myjail && iocell destroy myjail`

done !

## Setup a Kontrol jail

Host:
```
iocell create tag=kontrol boot=on allow_mount_zfs=1 allow_raw_sockets=1 mount_devfs=1 vnet=off ip4_addr='vtnet1|10.240.X.X/16'
iocell start kontrol
iocell console kontrol
```

Kontrol jail:

add `kontrol.csh` to csh env
then ... log back in to the jail to take affect

```
pkg install go git tmux
go get -u github.com/koding/kite
cd ~/go/src/github.com/koding/kite
git remote rename origin upstream
git remote add origin https://github.com/steveoc64/kite # being a fork of the above with bsd fixes in place
git fetch origin
git checkout freebsd-support
git pull

cd kontrol/kontrol
go get -u .
go install .

cd ../../kitectl
go get -u .
go install .

cd
mkdir certs
cd certs
openssl genrsa -out key.pem 2048
openssl rsa -in key.pem -pubout > key_pub.pem
cd
kontrol -initial

pkg install coreos-etcd(3.3.10)
pkg install htop
```

Now, use tmux to split into 5 panes on this jail .. then do

Mux 0
```
htop
```

Mux1
```
etcd
```

Mux2
```
kontrol
```

Mux 3
```
cd ~/go/src/github.com/koding/kite/examples/math-register
go run .
```

So now you have 3 things all running and chatting inside the jail, a kontrol system using etcd,
and a microservice running, and 1 pane watching the CPU and memory usage and process isolation.

Mux 4
```
cd ~/go/src/github.com/koding/kite/examples/exp2-query
// hack the code to reduce the delay from time.Second down to time.Millisecond, for great speed !
go run .
```

The jail should now be spinning out of control, thats good, stop Mux3 and Mux4 and on to the next bit

## Make the kontrol run on boot

Next step - lets get the kontrol jail to run etcd and kontrol on bootup, this involves writing some rc files.

just add the file `kontroller.sh` to /usr/local/etc/rc.d, and chmod a+x it to make sure it runs.

Test this by restarting the kontrol jail, and check that both etcd and kontrol are running in the background
and that log files are accumulating in /root

from the host:
```
iocell restart kontrol   # note the slight pause in startup - thats the sleep 1 in the startup script
iocell console kontrol
ps aux  # note that 2 daemons are running, one for etcd and one for kontrol
tail -f *.log
```

## Split the tasks into new jails

Back on the host, stop the kontrol jail, and lets clone it to create 2 new jails - one for the microservice, and one for the client


```
iocell stop kontrol
iocell clone kontrol tag=kite-math allow_raw_sockets=1 vnet=off boot=on ip4_addr='vtnet1|10.240.13.20/16'
iocell clone kontrol tag=kite-client allow_raw_sockets=1 vnet=off boot=on ip4_addr='vtnet1|10.240.13.21/16'
iocell start kite-math kite-client
```

Now you can `iocell console` into those 2, and remove the boot file in `/usr/local/etc/rc.d/kontroller.sh`

then restart them back from the host  `iocell restart kite-math kite-client`



Now, setup 3 tmux's

Mux1 - `iocell console kontrol` - watch etcd and kontrol running
Mux2 - `iocell console kite-math`
Mux3 - `iocell console kite-client`

Because the kontrol env vars still point to the original IP address, it should run, across jails

