# bsd-vps
Settings for BSD based VPS

## Setup base system with all the things golang

```
pkg update
pkg install go git htop doas vim-console
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

Create a dummy jail first

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
git rename origin upstream
git remote add origin https://github.com/steveoc64/kite # being a fork of the above with bsd fixes in place
git fetch origin
git checkout freebsd-support
git pull
go install .
```

## Cleanup the test jail

That should work, so now its ok to get rid of the test jail, and start building a real basejail.

`iocell stop myjail && iocell destroy myjail`

done !

