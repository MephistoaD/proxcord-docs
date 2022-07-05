---
title: Import old zpool
weight: 10
---

This little guide is about how to import an existing zpool on a new node.

As an exemplary situation you can imagine the following:

You just reinstalled your host, but have your data conserved on a fully working zpool from the previous install. Now you like to continue using it further.

**Table of contents**
{{< toc >}}

## Detect an existing zpool

Once the disks of the pool are plugged in, you like zfs to detect it. To do this run the command `zpool import`.

Example:
```bash
root@pve:~# zpool import
   pool: node-local
     id: 4357772725555539736
  state: ONLINE
status: The pool was last accessed by another system.
 action: The pool can be imported using its name or numeric identifier and
	the '-f' flag.
   see: https://openzfs.github.io/openzfs-docs/msg/ZFS-8000-EY
 config:

	node-local                            ONLINE
	  ata-SAMSUNG_HD204UI_S2HGJ1BZ816517  ONLINE
```

The returned output informs you about the pools which were detected. In case of the example this has been the pool named "node-local", featuring the single disk listed below.

## Make the zpool available for the local zfs instance

Now that you already know it's exact name and complete status, you can continue to import the pool.
This can be done by running `zpool import <pool-name>`.

Example:
```bash
root@pve:~# zpool import node-local
```

In case this doesn't work because the last access from the pool was done by another host, you probably need to add the `-f` option:

Example:
```bash
root@pve:~# zpool import -f node-local
```

List the zpools which are available to zfs now.

Example:
```bash
root@pve:~# zpool list
NAME         SIZE  ALLOC   FREE  CKPOINT  EXPANDSZ   FRAG    CAP  DEDUP    HEALTH  ALTROOT
node-local  1.81T  10.6M  1.81T        -         -     0%     0%  1.00x    ONLINE  -
```

## Import the zpool in proxmox

Go to *Datacenter* > *Storage* there you need to click *Add* and select *ZFS*.

The easiest thing to do would be to name it like the previously imported zpool, but of course you are free in the choice of the *ID*. Select the zpool and click *Add*.

![the menu to add the zpool to proxmox](/media/storage/zfs/import-old-zpool/add-to-proxmox.png)

Congrats! You got it 😉

## References

- [Storage](https://pve.proxmox.com/wiki/Storage) in the pve [wiki](https://pve.proxmox.com/wiki)
- [zpool-import](https://openzfs.github.io/openzfs-docs/man/8/zpool-import.8.html) in the docs of [openzfs](https://openzfs.github.io/openzfs-docs/)
