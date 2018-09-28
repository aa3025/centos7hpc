#!/bin/bash

chmod +x *.sh nodes/*.sh

export MUNGEUSER=9991
groupadd -g $MUNGEUSER munge
useradd  -m -c "MUNGE Uid 'N' Gid Emporium" -d /var/lib/munge -u $MUNGEUSER -g munge  -s /sbin/nologin munge

export SLURMUSER=9992
groupadd -g $SLURMUSER slurm
useradd  -m -c "SLURM workload manager" -d /var/lib/slurm -u $SLURMUSER -g slurm  -s /bin/bash slurm


yum -y install munge munge-libs munge-devel

dd if=/dev/urandom bs=1 count=1024 > /etc/munge/munge.key
chown munge: /etc/munge/munge.key
chmod 400 /etc/munge/munge.key


systemctl enable munge
systemctl start  munge
chkconfig munge on

mkdir -p /share/installs/munge
cp -f ./nodes/munge_nodes.sh /share/installs/munge/

#chmod +x /share/installs/munge/munge_nodes.sh

cp /etc/munge/munge.key /share/installs/munge/

pdsh /share/installs/munge/munge_nodes.sh

echo "Some Tests:"
#munge -n
#munge -n | unmunge          # Displays information about the MUNGE key
#munge -n | ssh node101 unmunge
#remunge

