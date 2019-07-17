# iRedMail setup

## Host setup to share ports
- `doas iocell update -p 12.0-RELEASE` 

## Setup new mail jail

- mkjail mail[x]
- cp across .cshrc to /root
- set hostname in /etc/rc.d
- pkg install bash-static
- logout / login .. check `hostname -f`

## Add stuff to /etc/rc.conf

```bash
# iRedMail

postgresql_enable="YES"
postfix_enable="YES"
iredamin_enable="YES"
iredapd_enable="YES"
#roundcube_enable="YES"
php_fpm_enable="YES"
```

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
pkg install py36-certbot
service nginx stop
certbot certonly
```


And do the symlinks

```bash
mv /etc/ssl/certs/iRedMail.crt{,.bak}       # Backup. Rename iRedMail.crt to iRedMail.crt.bak
mv /etc/ssl/private/iRedMail.key{,.bak}     # Backup. Rename iRedMail.key to iRedMail.key.bak
ln -s /usr/local/etc/letsencrypt/live/XXX/fullchain.pem /etc/ssl/certs/iRedMail.crt
ln -s /usr/local/etc/letsencrypt/live/XXX/privkey.pem /etc/ssl/private/iRedMail.key
```

Get the services up and running again
```
service postgresql restart
service postfix restart
service dovecot restart
service nginx start
```

Then login to `XXX.com/iredadmin` and create the domains, add the users.

Might be a good time to snapshot the cell now.

## Roundcube

PHP-FPM is cactus out of the box

Fix /usr/local/etc/php-fpm.d/www.conf - comment out the listen restriction

```bash
[inet]
user = www
group = www

listen = 127.0.0.1:9999
listen.owner = www
listen.group = www
listen.mode = 0660
;listen.allowed_clients = 127.0.0.1
```

## Last Bits

Seem to be some issues with clamav / amavisd with IP addresses here and there

Appending the jail's IP address to places where its expecting 127.0.0.1 seems to be needed to fix it.


