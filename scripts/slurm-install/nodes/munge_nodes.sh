#!/bin/bash



export MUNGEUSER=9991

groupadd -g $MUNGEUSER munge

useradd  -m -c "MUNGE Uid 'N' Gid Emporium" -d /var/lib/munge -u $MUNGEUSER -g munge  -s /sbin/nologin munge

export SLURMUSER=9992

groupadd -g $SLURMUSER slurm

useradd  -m -c "SLURM workload manager" -d /var/lib/slurm -u $SLURMUSER -g slurm  -s /bin/bash slurm


yum -y install munge munge-libs munge-devel

cp /share/installs/munge/munge.key /etc/munge/munge.key

chown munge: /etc/munge/munge.key
chmod 400 /etc/munge/munge.key


chkconfig munge on
systemctl enable munge
systemctl start  munge


# Tests:
#munge -n
#munge -n | unmunge          # Displays information about the MUNGE key
#munge -n | ssh node150 unmunge

#remunge

