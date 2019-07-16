# iRedMail setup

## Host setup to share ports
- `doas iocell update -p 12.0-RELEASE` 

## Setup new mail jail

- mkjail mail[x]
- cp across .cshrc to /root
- set hostname in /etc/rc.d
- pkg install bash-static
- logout / login .. check `hostname -f`

## download and build iRedMail

```bash
cd /root
fetch --no-verify-peer https://bitbucket.org/zhb/iredmail/downloads/iRedMail-0.9.9.tar.bz2
tar xvfj iRedMail-0.9.9.tar.bz2
cd iRedMail-0.9.9
bash iRedMail.sh
```


Set the hostname to the base domain name for all the mail
ie - `mymail.com`

Choose Postgresql for the data.

Dont bother with SoGO

.. let it run.

.. this will take a while as it downloads all the things, and builds all the apps.


## Manual fixes

Need to manually accept the licences on some ports

```bash
cd /usr/ports/mail/dcc-dccd
cd /usr/ports/mail/spamassassin
make
```

and then jumping back to complete the install

```bash
cd /root/iRedMail-0.9.9
bash iRedMail.sh
```

Total runtime on 1 CPU - 35mins compile time

Once that is all working, might be a good idea to snapshot the cell.

`iocell snap mailXXX`

## Setup

Get the certbot first

```bash
pkg install certbot
service nginx stop
certbot certonly
service nginx start
```

And do the symlinks
