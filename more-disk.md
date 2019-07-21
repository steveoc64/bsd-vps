## More Diskspace

Add more disk allocation whenever you want, then use gpart and zfs to add it into the pool.

```bash
gpart show
```

shows the partition table, initially it should show as 'corrupt'

```bash
gpart recover vtbd0
gpart show
```

Brings the partition table back into line with the new reality.

The ZFS partition should be number 3, followed by an unallocated section of X Gb.

So lets resize partition 3 to take over the empty space :

```bash
gpart resize -i 3 -s XXg vtbd0
gpart show
zfs list
zpool list
zpool online -e zroot vtbd0p3
zfs list
```

And then it should be all done !
