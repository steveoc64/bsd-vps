## VNET jails

Lets try building an iocell setup with VNET on a binarylane server

- Load up a new VPS
- Use bootonly iso, ignore kernel-dbg and lib32
- Add self to wheel and operator groups
- After install, set to dual nics, reboot (src/dest check - select no check, and dual nics)

Setup 2nd NIC

```bash
sysrc ifconfig_vtnet1="inet 10.240.0.XX/16"
ifconfig vtnet1 inet 10.240.0.XX/16
```

Get some code

```bash
pkg update
pkg install htop doas vim-console tmux iocell
```

Give me doas access
```bash
echo 'permit persist steve as root' > /usr/local/etc/doas.conf
```

Check that VIMAGE is in the kernel (should be for 12.0-RELEASE onwards)

```bash
sysctl -a | grep -i vimage
```

## Setup our networking stack properly

Set it up

```bash
iocell activate zroot
iocell fetch ftpfiles=base.txz
```

Enable gateways
```bash
sysrc enable_gateway="YES"
```

Add to /etc/sys.conf
```bash
net.inet.ip.forwarding=1       # Enable IP forwarding between interfaces
net.link.bridge.pfil_onlyip=0  # Only pass IP packets when pfil is enabled
net.link.bridge.pfil_bridge=0  # Packet filter on the bridge interface
net.link.bridge.pfil_member=0  # Packet filter on the member interface
```

## Create our Virtual Datacentre !!

For our in-house Network that can only see our internal VPS
we are going to use bridge0/1 for that LAN

Create the bridge, and connect only vtnet1 into it (thats the NIC that sits inside the private network)
```
ifconfig bridge create
ifconfig bridge0 addm vtnet1 up
ifconfig vtnet1 up
```

First Jail
```bash
iocell create tag=test1
iocell set ip4_addr='vnet0|10.240.X.Y/16' test1
iocell set defaultrouter=10.240.0.X test1
iocell start test1
iocell console test1
```

From inside there - check `ifconfig` and `netstat -nr4` for sanity

You will see that you can ping all the jails on this network, and other jails on other machines 
that are on the private LAN

## Jails connected to the public internet - needs NAT

For our jails to communicate outside of the private lan, use pf to nat them across

```
scrub in all

#########################################################################
# LAN Config
public_ip = "103.16.130.XX"
internaL_ip = "10.240.0.XX"
ext_if = "vtnet0"
int_if = "vtnet1"
jail_net = $int_if:network

#########################################################################
# Define the NAT for the jails
nat on $ext_if from $jail_net to any -> ($ext_if)

#########################################################################
# Block all the things
block all

#########################################################################
# Allow the jail traffic to be translated
pass from { lo0, $jail_net } to any keep state

#########################################################################
# Allow SSH in to the host
ssh_port = "22"
pass in inet proto tcp to $ext_if port $ssh_port

#########################################################################
# Allow OB traffic
pass out all keep state
```


