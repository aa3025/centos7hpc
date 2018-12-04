#!/bin/bash

# run as e.g. "./rmnode.sh node7", where node7 is the node hostname we want to remove from configs to e.g. reinstall it
# after that node7 supposed to boot into installation, and not to localboot (from hdd)

# pass the node name from 1st parameter:
node=$1

# to reinstall the node we need to delete its files from /tftpboot

rm -f `readlink -f /var/lib/tftpboot/$node.bios`
rm -f `readlink -f /var/lib/tftpboot/$node.efi`

# and symlinks:
rm -f /var/lib/tftpboot/$node.bios
rm -f /var/lib/tftpboot/$node.efi

# removing node's records from pdsh, hosts, dhcpd.conf:
sed -i.bak '/$node/d' /etc/pdsh/machines
sed -i.bak '/$node/d' /etc/hosts
sed -i.bak '/$node/d' /etc/dhcp/dhcpd.conf
