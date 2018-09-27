#!/bin/bash

# Execute once all nodes are installed, rebooted themselves, NAT, pdsh working etc.
# This script adds some final touches
# check lines below and disable what you don't need

# make sure SELINUX is dead.
pdsh -w $1 "sed 's/^SELINUX=.*/SELINUX=disabled/' /etc/selinux/config > /etc/selinux/config.tmp; mv -f /etc/selinux/config.tmp /etc/selinux/config"

pdsh -w $1 yum -y update
pdsh -w $1 yum -y install epel-release
pdsh -w $1 yum -y groupinstall "Development Tools"

# you can add below any extra RPMs you want on the nodes. Also can install them later with pdsh

pdsh -w $1 yum -y install octave psmisc ganglia-gmond kernel-devel kernel-headers environment-modules

# we will compile openmpi with knem (infiniband) support later
# on server as well:
#yum -y groupinstall "Development Tools"
#yum -y install octave psmisc ganglia ganglia-web ganglia-gmond ganglia-gmetad environment-modules
#cp /etc/hosts /share/installs/hosts

pdsh -w $1 cp /share/installs/hosts /etc/hosts




#### OR to compile knem (openfabrics alternative) and knem-enabled openmpi on the headnode in the shared location leave next line uncommented:

pdsh -w $1 /share/apps/knem-1.1.2/sbin/knem_local_install
pdsh -w $1 modprobe knem
pdsh -w $1 "echo export MODULEPATH=/share/apps/modulefiles >> /etc/bashrc"

