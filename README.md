# bsd-vps
Settings for BSD based VPS

## Setup iocell

`pkg install iocell`

then hack iocell to remove doc.txz from /usr/local/lib/iocell/ioc-globals

then `iocell fetch` to grab 12.0-RELEASE, and you are ready to go

## /etc/group

> Add self to wheel and operator groups

## /etc/ssh/sshd_config

Do the secure thing in here ....

## /root/.cshrc and $USER/.cshrc

Using .cshrc, just copy it to the home dir, and comment out the prompt that applies

## /etc/rc.conf

Using file `rc.conf` 

> set hostname
> set vtnet1 base IP address

## /etc/pf.conf

Using pf.conf

Set all the specific jails

`service pf start` to enable proper NAT'ing from inside the jails

