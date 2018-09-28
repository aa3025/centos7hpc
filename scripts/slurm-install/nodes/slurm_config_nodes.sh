#!/bin/bash


systemctl stop firewalld
systemctl disable firewalld

mkdir -p /var/spool/slurmd
mkdir -p /var/log/slurm

chown -R slurm: /var/spool/slurmd
chown -R slurm: /var/log/slurm
chmod 755 /var/spool/slurmd

touch /var/log/slurm/slurmd.log
chown slurm: /var/log/slurm/slurmd.log

systemctl enable slurmd.service
systemctl start slurmd.service
systemctl status slurmd.service



