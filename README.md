# bsd-vps
Settings for BSD based VPS

## /etc/group

> Add self to wheel and operator groups

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
