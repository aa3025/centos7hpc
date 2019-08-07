#!/bin/bash

# Run as sh ./install.sh <full_path_to_centos7_dvd.iso>

# Note: your external network interface must be configuured, up and running
# It will be put in "external zone" of firewalld by this script


#################### Do we have an ISO? ##########################

if [ "$1" = "-h" ]; then
    echo "Usage: `basename $0` /path/to/CentOS_DVD.iso"
    echo "If you need to download CentOS DVD, use just `basename $0 ` -d"
    exit 0
elif [ "$1" = "-d" ]; then
    echo "Downloading 4+GB ISO file"
    wget http://anorien.csc.warwick.ac.uk/mirrors/centos/7/isos/x86_64/CentOS-7-x86_64-DVD-1804.iso -O CentOS-7-x86_64-DVD.iso
    isoname="CentOS-7-x86_64-DVD.iso"
elif [ "$1" = "" ]; then
    echo "You have to supply the location if the CentOS 7 ISO file see `basename $0 -h`"
    exit 0
elif [ ! -z "$1" ]; then
    if [ -f $1 ]; then isoname=$1; fi
fi


### Prerequisites #### 
chmod -R +x ./scripts/*

yum install epel-release mc nano net-tools nfs-utils dhcp tftp httpd openssh-server firewalld tftp-server git xinetd tftp-server syslinux syslinux-tftpboot wget vsftpd opensm pdsh infiniband-diags -y

ln -s /var/lib/tftpboot /tftpboot
#mkdir -p /tftpboot/netboot

# nodes will write their macs to:
chmod -R 777 /tftpboot

# services
systemctl enable sshd.service
systemctl enable dhcpd.service
systemctl enable nfs.service
systemctl enable tftp.service
systemctl enable firewalld.service


echo ""
echo ""
echo "We will configure some network first"
echo ""
echo "Here is the list of your network interfaces:"

ip link show
echo "Enter your INTERNAL network interface here: (e.g. enp4s0), it will be configured with IP: 172.16.0.254 (zone internal):"
    read eth_int

echo "Enter your EXTERNAL network interface name: (e.g. enp4s1):"
    read eth_ext

###################### HOSTNAME of headnode #################
echo NETWORKING=yes > /etc/sysconfig/network
echo HOSTNAME=master > /etc/sysconfig/network

# disable SELINUX temporarely
setenforce 0
# Disable SELINUX permanently in /etc/sysconfig/selinux:
sed 's/^SELINUX=.*/SELINUX=disabled/' /etc/selinux/config > /etc/selinux/config.tmp; mv -f /etc/selinux/config.tmp /etc/selinux/config

# ssh client
echo "   StrictHostKeyChecking no" >> /etc/ssh/ssh_config

# disable yum auto updates
systemctl disable packagekitd 

cp ./configs/ifcfg-server /etc/sysconfig/network-scripts/ifcfg-$eth_int
echo DEVICE=\"$eth_int\" >> /etc/sysconfig/network-scripts/ifcfg-$eth_int
echo ZONE=\"internal\" >>  /etc/sysconfig/network-scripts/ifcfg-$eth_int

ifconfig $eth_int down
ifconfig $eth_int 172.16.0.254 netmask 255.255.255.0 broadcast 172.16.0.255
ifconfig $eth_int up
ifup $eth_int
ifup $eth_ext

###################### Attempt to configure NAT #########################

./scripts/firewall.sh $eth_int $eth_ext

###################### NFS-shares config ################################
mkdir -p /share

echo "/home            *(rw,sync,no_root_squash,no_all_squash)" > /etc/exports
echo "/share           *(rw,sync,no_root_squash,no_all_squash)" >> /etc/exports

systemctl restart rpcbind
systemctl restart nfs-server

#################### TFTP business #######################################

cp -f ./configs/dhcpd.conf /etc/dhcp/
cp -f ./configs/tftp /etc/xinetd.d/

sed -i 's|eth_int|'"${eth_int}"'|g' ./configs/ks-bios.cfg
sed -i 's|eth_ext|'"${eth_ext}"'|g' ./configs/ks-efi.cfg
sed -i 's|eth_int|'"${eth_int}"'|g' ./configs/ks-bios.cfg
sed -i 's|eth_ext|'"${eth_ext}"'|g' ./configs/ks-efi.cfg

cp -f ./configs/ks-bios.cfg /var/www/html/
cp -f ./configs/ks-efi.cfg /var/www/html/
cp -f ./scripts/post.sh /var/www/html/
cp -f ./configs/ifcfg-node /var/www/html/
cp -f ./configs/sshd_config /var/www/html/

#################### BIOS-based nodes ####################################
mkdir -p /tftpboot/pxelinux.cfg

cp -f ./configs/default /tftpboot/pxelinux.cfg/
cp -f ./configs/localboot /tftpboot/pxelinux.cfg/
cp -v /usr/share/syslinux/pxelinux.0 /tftpboot/
cp -v /usr/share/syslinux/menu.c32 /tftpboot/
cp -v /usr/share/syslinux/memdisk /tftpboot/
cp -v /usr/share/syslinux/mboot.c32 /tftpboot/
cp -v /usr/share/syslinux/chain.c32 /tftpboot/

## ##################### CentOS7 ISO image is mounted in the http docs tree #################
echo ISO is $isoname ...
installpath="/var/www/html/centos"
mkdir -p $installpath
umount $installpath # if previous install left it there

echo "Mounting "$isoname "...."
mount -o loop -t iso9660 ${isoname} ${installpath}

#################### TFTP EFI-based nodes #####################################

cp $installpath/EFI/BOOT/*.efi /tftpboot/
cp $installpath/EFI/BOOT/*.EFI /tftpboot/
cp /boot/efi/EFI/centos/shim.efi /tftpboot/
cp ./configs/grub.cfg /tftpboot/

cp $installpath/images/pxeboot/vmlinuz /tftpboot/
cp $installpath/images/pxeboot/initrd.img /tftpboot/

chmod -R o+r /var/lib/tftpboot/

service dhcpd restart
service tftp restart
service httpd restart

#### for post-intall on the nodes need to copy over their MACs to /tftpboot to avoid going ito install after 1st reboot
#### we give it access to server with ssh key: it will grab via http, see post-install script post.sh executed from ks.cfg

ssh-keygen -f /var/www/html/id_rsa.tmp -t rsa -N """"
chmod o+r /var/www/html/id*

# delete previous temp keys

mkdir -p ~/.ssh
rm -f ~/.ssh/authorized_keys

cat /var/www/html/id_rsa.tmp.pub >> ~/.ssh/authorized_keys
cp -f /var/www/html/id_rsa.tmp ~/.ssh/id_rsa
cp -f /var/www/html/id_rsa.tmp.pub ~/.ssh/id_rsa.pub
rm ~/.ssh/known_hosts
chmod -R 600 ~/.ssh/

echo "Now go and switch on the compute nodes(they must be connected to the internal LAN of master node)!"
echo "After nodes are deployed, remove the rsa keys from /var/www/html/ folder for security !"

# pdsh stuff
cp -f ./scripts/pdsh.sh /etc/profile.d/
mkdir -p /etc/pdsh
touch /etc/pdsh/machines
source /etc/profile.d/pdsh.sh
echo source /etc/profile.d/pdsh.sh >> /etc/bashrc

echo "Also check optional ./scripts/postinstall_from_server.sh script!"

