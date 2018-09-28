#!/bin/bash

cp -f ./slurm.conf /etc/slurm/slurm.conf
cp -f ./slurm.conf /share/installs/slurm/slurm.conf

pdsh "cp -f /share/installs/slurm/slurm.conf /etc/slurm/slurm.conf"
pdsh "cp -f /share/installs/slurm/slurmd.service /usr/lib/systemd/system/slurmd.service"

pdsh killall slurmd

pdsh systemctl daemon-reload
pdsh systemctl start slurmd.service

scontrol reconfigure
