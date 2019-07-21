## Mail Server

as root -
```
iocell fetch -p release=12.0-RELEASE
set pr=/iocell/releases/12.0-RELEASE/root
set pp=$pr/usr/ports
echo $pp
cd $pp

make all install clean -C $pp/ports-mgmt/portmaster/

cat << EOF >> $pr/etc/make.conf
? CLAMAVUSER=vscan
? CLAMAVGROUP=vscan
? OPTIONS_UNSET= X11 GUI CUPS NLS HAL GSSAPI_BASE KRB_BASE KERBEROS
? OPTIONS_SET=GSSAPI_NONE KRB_NONE
? WITHOUT_X=YES
? WITH_X=NO
? ENABLE_GUI=NO
? EOF

echo Aside from defaults, be sure "PEAR_AUTH_SASL" is selected.
make config -C $pr/usr/ports/net/pear-Net_SMTP

echo Aside from defaults, be sure "PEAR_DB" and "PEAR_LOG" are selected.
make config -C $pr/usr/ports/security/pear-Auth

echo Aside from defaults, be sure "PEAR_DB" is selected.
make config -C $pr/usr/ports/sysutils/pear-Log

echo Aside from defaults, be sure "MYSQL" is selected.
make config -C $pr/usr/ports/mail/dovecot

echo Aside from defaults, be sure "BDB", "MYSQL" and "TLS" are selected.
make config -C $pr/usr/ports/mail/postfix

echo Aside from defaults, be sure "MYSQL" is selected and "PGSQL" is NOT selected.
make config -C $pr/usr/ports/mail/postfixadmin

echo Aside from defaults, be sure "MYSQL", "DKIM", "RAZOR", "RELAY_COUNTRY" and "SPF_QUERY" are selected.
make config -C $pr/usr/ports/mail/spamassassin

echo Aside from defaults, be sure the "APACHE", "DOVECOT2", "MYSQLSERVER", "PFA", "POSTFIX" and "WEBHOST" options are selected.
echo Feel free to select any additional options you may want.
make config -C $pr/usr/ports/security/maia

iocell create tag=mail boot=on allow_mount_zfs=1 allow_raw_sockets=1 mount_devfs=1 vnet=off ip4_addr='vtnet1|10.240.50.2/16'
il
ic mail





```