#!/bin/bash

echo "Now you have to create slurm.conf file and put it in this folder as slurm.conf, example provoded, you can edit it, e.g. change your comnpute nodes specs in the last sections."
echo "As a workaround slurmd pid problem, make sure to replace the respective line in slurm.conf with this: \"SlurmdPidFile=/var/log/slurm/slurmd.pid\""
echo "then run ./05_update_slurm.sh"
master=$(hostname)
sed -i 's|=master|='"${master}"'|g' ./slurm.conf
