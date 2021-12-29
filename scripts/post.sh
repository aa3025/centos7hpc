##### POST INSTALL FILE FOR THE NODES #######
# do not launch it manually!
# this script is executed by the end of kickstart install from the nodes automatically

sed 's/^SELINUX=.*/SELINUX=disabled/' /etc/selinux/config > /etc/selinux/config.tmp; mv -f /etc/selinux/config.tmp /etc/selinux/config

extDNS="8.8.8.8" # external DNS server IP (put your own if you like)
masterIP="172.16.0.254"

# My eth0 MAC-ADDRESS

IFS=' ' read -r -a mymacs <<< $(cat /sys/class/net/e*/address)

# get temp rsa keys
mkdir -p /root/.ssh

wget http://${masterIP}/id_rsa.tmp -O /root/.ssh/id_rsa 
wget http://${masterIP}/id_rsa.tmp.pub -O /root/.ssh/id_rsa.pub

cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys
chmod -R 600 /root/.ssh


################# Updating my MAC record in the server's PXE boot file ####################

in="/var/lib/tftpboot/pxelinux.cfg/localboot"

echo $mymacs

for mac in ${mymacs[@]};
do
	out_efi="/var/lib/tftpboot/grub.cfg-01-${mac//:/-}"
	out_bios="/var/lib/tftpboot/pxelinux.cfg/01-${mac//:/-}"
	echo "$mac to $out"
	ssh -v -o "StrictHostKeyChecking no" -i /root/.ssh/id_rsa ${masterIP} "cp -f $in  $out_bios;exit"
	scp -v -o "StrictHostKeyChecking no" -i /root/.ssh/id_rsa /boot/efi/EFI/centos/grub.cfg root@${masterIP}:${out_efi}
	ssh -v -o "StrictHostKeyChecking no" -i /root/.ssh/id_rsa ${masterIP} "chmod o+r /var/lib/tftpboot/*01-*"
done 

################### Configure NETWORK #####################
# get active net device
device=$( ip addr | awk '/state UP/ {print $2}' | sed 's/.$//' )

wget http://${masterIP}/ifcfg-node -O /etc/sysconfig/network-scripts/ifcfg-$device

# My IP address
IP=$(ip route get 8.8.8.8 | grep src | sed 's/.*src \(.*\)$/\1/g')

echo "DEVICE=$device" >> /etc/sysconfig/network-scripts/ifcfg-$device
echo "ZONE=internal" >> /etc/sysconfig/network-scripts/ifcfg-$device

echo "StrictHostKeyChecking	no" >> /etc/ssh/ssh_config




################# UPDATING my DHCP record in server's /etc/dhcp/dhcpd.conf #####################

# constructing dhcpd.conf for server

oldIP=${IP##*.}
# strip whitespace
N=$(( oldIP * 1 ))

SIP="172.16.0.$N" # this will be my new static IP issued by dhcpd on reboot
#SIP=${IP}
HOSTNAME="node$N"
echo $HOSTNAME > /etc/hostname

ssh -i /root/.ssh/id_rsa -o "StrictHostKeyChecking no " root@${masterIP} "echo $IP	$HOSTNAME.local	$HOSTNAME >>/etc/hosts"
ssh -i /root/.ssh/id_rsa -o "StrictHostKeyChecking no " root@${masterIP} "mkdir -p /etc/pdsh; touch /etc/pdsh/machines; echo $HOSTNAME >>/etc/pdsh/machines; echo export WCOLL=/etc/pdsh/machines >> /etc/bashrc; echo export PDSH_RCMD_TYPE=ssh >> /etc/bashrc;"

mac=`cat /sys/class/net/$(ip addr | awk '/state UP/ {print $2}' | sed 's/.$//')/address`


mydhcp="host $HOSTNAME { hardware ethernet $mac; option host-name \"\"$HOSTNAME\"\"; fixed-address $SIP;}"
ssh -i /root/.ssh/id_rsa -o "StrictHostKeyChecking no " root@${masterIP} "echo \"$mydhcp\" >>/etc/dhcp/dhcpd.conf"
ssh -i /root/.ssh/id_rsa -o "StrictHostKeyChecking no " root@${masterIP} "ln -s $out_efi /var/lib/tftpboot/pxelinux.cfg/node$N.efi"
ssh -i /root/.ssh/id_rsa -o "StrictHostKeyChecking no " root@${masterIP} "ln -s $out_bios /var/lib/tftpboot/pxelinux.cfg/node$N.bios"

################# NFS-shares #############################

rm -fr /home

mkdir /home
mkdir /share

echo "${masterIP}:/home /home  nfs     rw      0       0" >> /etc/fstab
echo "${masterIP}:/share /share  nfs     rw      0       0" >> /etc/fstab

echo "mount /home" >> /etc/rc.local
echo "mount /share" >> /etc/rc.local

chmod +x /etc/rc.d/rc.local
systemctl start rc-local

#sync clock
date --set="$(curl -s --head http://${masterIP}/ | grep ^Date: | sed 's/Date: //g')"
hwclock --systohc

wget http://${masterIP}/sshd_config -O /etc/ssh/sshd_config

# setting headnode's hostname
masterlong=$(ssh -i /root/.ssh/id_rsa ${masterIP} hostname)
mastershort=${masterlong%%.*}

echo "${masterIP}	$mastershort	$masterlong" >> /etc/hosts

#### DNS resolution on nodes ####

echo "search $masterlong" > /etc/resolv.conf
echo "nameserver ${extDNS}" >> /etc/resolv.conf # external DNS server

# ssh -i /root/.ssh/id_rsa -o "StrictHostKeyChecking no " root@${masterIP} "service dhcpd restart"

