---
title: "Error: Dataset already exists"
weight: 20
---

This is one of the errors resolvable from the CLI:

```
ERROR: Backup of VM 230 failed - zfs error: cannot create snapshot 'pve-replication/subvol-230-disk-1@vzdump': dataset already exists
```

**Table of contents**
{{< toc >}}

## What's the problem?

In this case the snapshot used to backup the guest is still left over from not completing the backup job the last time you ran it.

Have a look at your datasets on that node:

```bash
root@pve:~# zfs list -t snapshot
NAME                                                               USED  AVAIL     REFER  MOUNTPOINT
pve-replication/subvol-222-disk-1@vzdump                          47.2M      -     2.45G  -
pve-replication/subvol-222-disk-1@__replicate_222-0_1673463600__   920K      -     2.45G  -
pve-replication/subvol-230-disk-1@vzdump                          1.95M      -      826M  -
pve-replication/subvol-230-disk-1@__replicate_230-0_1673137891__   736K      -      826M  -
pve-replication/subvol-230-disk-1@__replicate_230-0_1673140466__  1.72M      -      826M  -
```

As you see there are two snapshots (marked with the `@vzdump` keyword) which are (not of use anymore) assuming there is no backup job running right now.

## Fix

Go ahead deleting them:

```bash
root@pve:~# zfs destroy pve-replication/subvol-222-disk-1@vzdump
root@pve:~# zfs destroy pve-replication/subvol-230-disk-1@vzdump
```

This should resolve that matter and make further backups possible again. :-)

## References

- [Remove Zfs Snapshot - Best Practice](https://forum.proxmox.com/threads/remove-zfs-snapshot-best-practise.42723/)
