#!/usr/bin/env bash

# required for authentication
PVE_HOST=192.168.2.10
# user and password must be set in the ticket section

#####################################################
# static files, don't touch
TEMPFILE_DNS=/tmp/lan.list.temp
TEMPFILE_PVE=/tmp/pve_nodes
HOSTSLIST_PVE=/opt/pve_nodes
PIHOLE_DNS=/etc/pihole/lan.list
DNSMASQ_DNS=/etc/dnsmasq.d/02-lan.conf
#####################################################
#functions

write_dns(){
  echo -e "$1" >> $TEMPFILE_DNS
}

write_pve(){
  echo -e "$1" >> $TEMPFILE_PVE
}

fetch_lxc_data(){
  write_dns "# - LXC: -"

  # get lxc_vmids (lxc)
  lxc_vmids=$(curl -k -b "PVEAuthCookie=$pve_ticket" https://$PVE_HOST:8006/api2/json/nodes/$current_pve_node/lxc 2> /dev/null  | grep -o '"vmid":"[^"]*' | grep -o '[^"]*$')

  for lxc_vmid in $lxc_vmids; do
    vmconfig=$(curl -k -b "PVEAuthCookie=$pve_ticket" https://$PVE_HOST:8006/api2/json/nodes/$current_pve_node/lxc/$lxc_vmid/config 2> /dev/null)
    # get ip
    ip=$(echo $vmconfig | grep -o 'ip=[^=]*' | cut -d'/' -f1 | cut -d'=' -f2)
    # get name
    hostname=$(echo $vmconfig | grep -o '"hostname":"[^"]*' | grep -o '[^"]*$')
    # get searchdomain
    searchdomain=$(echo $vmconfig | grep -o '"searchdomain":"[^"]*' | grep -o '[^"]*$')

    # make output
    write_dns "$ip\t\t$hostname.$searchdomain"
  done
}

fetch_host_data(){
  write_dns "# - PVE Node: -"
  ip=$(curl -k -b "PVEAuthCookie=$pve_ticket" https://$PVE_HOST:8006/api2/json/nodes/$current_pve_node/network 2> /dev/null | grep -o '"address":"[^"]*' | grep -o '[^"]*$')

  hosts_data=$(curl -k -b "PVEAuthCookie=$pve_ticket" https://$PVE_HOST:8006/api2/json/nodes/$current_pve_node/hosts 2> /dev/null | grep -o '"data":"[^"]*' | grep -o '[^"]*$')

  # convert it to a line for the dns list
  entry=$(echo -e $hosts_data | grep $ip)

  write_dns "$entry"
  write_pve "$ip"
}

tell_pihole(){
  # restart dns-resolver
  /usr/local/bin/pihole restartdns
}

get_pve_node(){
  # just use the given host when online
  ping -c 3 $PVE_HOST > /dev/null 2>&1 && return

  # if not find another active host
  hosts=$(cat $HOSTSLIST_PVE)
  for host in $hosts; do
    if [ $(ping -c 3 $host > /dev/null 2>&1; echo $?) == 0 ]; then
      #statements
      PVE_HOST=$host
      break
    fi
  done
}

arrange_files(){
    # prepare resolution by dnsmasq
    echo "addn-hosts=$PIHOLE_DNS" > $DNSMASQ_DNS

    # replace old lan.list file
    mv $TEMPFILE_DNS $PIHOLE_DNS

    # replace old pve hostlist
    mv $TEMPFILE_PVE $HOSTSLIST_PVE
}

#####################################################
# start

get_pve_node

# get ticket -> this is necessary every 2 hours
pve_ticket=$(curl -k -d 'username=root@pam' --data-urlencode 'password=super-secret' https://$PVE_HOST:8006/api2/json/access/ticket 2> /dev/null| grep -o '"ticket":"[^"]*' | grep -o '[^"]*$')

# get all node names
pve_nodes=$(curl -k -b "PVEAuthCookie=$pve_ticket" https://$PVE_HOST:8006/api2/json/nodes 2> /dev/null| grep -o '"node":"[^"]*' | grep -o '[^"]*$')

for current_pve_node in $pve_nodes; do
  write_dns "# --- $current_pve_node: ---"

  fetch_host_data
  fetch_lxc_data
done

# cleanup

arrange_files
tell_pihole
