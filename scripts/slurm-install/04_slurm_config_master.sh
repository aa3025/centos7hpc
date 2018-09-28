#!/bin/bash

mkdir /var/spool/slurmctld
chown slurm: /var/spool/slurmctld
chmod 755 /var/spool/slurmctld

touch /var/log/slurmctld.log
chown slurm: /var/log/slurmctld.log

touch /var/log/slurm_jobacct.log /var/log/slurm_jobcomp.log
chown slurm: /var/log/slurm_jobacct.log /var/log/slurm_jobcomp.log

systemctl enable slurmctld.service
systemctl start slurmctld.service
systemctl status slurmctld.service

### open firewall for slurm 
sh slurm_firewall.sh

cp -f ./nodes/slurm_config_nodes.sh /share/installs/slurm/
chmod +x /share/installs/slurm/slurm_config_nodes.sh

pdsh /share/installs/slurm/slurm_config_nodes.sh