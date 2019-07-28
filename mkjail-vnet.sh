#!/bin/sh
iocell list
echo -n "Tag: "
read tag
echo -n "IP: "
read ip

doas iocell create tag=$tag boot=on allow_mount_zfs=1 allow_raw_sockets=1 mount_devfs=1 vnet=on ip4_addr="vnet0|10.240.$ip/16"
doas iocell start $tag
doas iocell console $tag
