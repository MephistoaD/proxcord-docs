---
title: PiHole
weight: 20
---

*For PVE-7.x*

**Table of Contents**
{{< toc >}}

## Resolve Hostnames of LXCs in PiHole

If you like to resolve the Hostnames of a Linux Container, the usual steps to do are always the same:

- Go to the "Local DNS" section and enter the name there
- On removal of the container, delete the DNS record again

This relatively easy steps can be automated entirely in two steps to perform on the PiHole-System:

### 1. Install the script

To download the script, simply run:
```bash
wget -qO- https://proxcord.duckdns.org/media/apps/pihole/pve-resolve.sh > /usr/local/bin/pve-resolve
```

In this case we still like to make some adjustments to the script:

- [x] Change the value of `PVE_HOST` to your Proxmox servers IP-address.
- [x] Search for `password`, remove `super-secret` and replace it with your Proxmox servers root password.
- [x] Save the changes.

Make the file executable by running:

```bash
chmod +x /usr/local/bin/pve-resolve
```

### 2. Setup a crontab

To run the script every two minutes, run the following command:

```bash
echo "*/2 *   * * *   root    /usr/local/bin/pve-resolve >/dev/null 2>&1" >> /etc/crontab
```

Great, now your PiHole is already resolving your Proxmox servers and your LXCs FQDNs to their IPs.

### How the script works

It connects to the PVE-Hosts API and get's each LXCs (and each PVE-Hosts) IP-address and it's respective FQDN.
There is not even one PUSH connection to the API, so it doesn't change your Proxmox clusters state at all.

### How to use this?

That's pretty straight forward:

Let's say you have a container called "proxcord-docs", which you expect to be available at [http://proxcord-docs](http://proxcord-docs), then you don't need to change anything at all. It already is available on this URL.

Let's say you like it's URL to be http://proxcord-docs.home.lab. In this case go the containers DNS-settings and change the "DNS-domain" to "home.lab":

![set the DNS-domain to define the LXCs FQDN](/media/apps/pihole/set-dns-domain.png)
