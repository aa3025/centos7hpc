#!/bin/bash
# this is 2nd stage of SLURM install: 1st is munge install, see "01_munge_master.sh"


# uncomment for 1st time munge installation
#./01_munge_master.sh


# SLURM rpms building on master

## prerequisites
yum -y install openssl openssl-devel pam-devel numactl numactl-devel hwloc hwloc-devel lua lua-devel readline-devel rrdtool-devel ncurses-devel man2html libibmad libibumad perl-ExtUtils-MakeMaker readline-devel pam-devel

yum -y install mariadb-server mariadb-devel 

# Getting last version of slurm
wget https://download.schedmd.com/slurm/slurm-18.08.0.tar.bz2

# you can also get bleeding edge source from github
# git clone git://github.com/SchedMD/slurm.git

rpmbuild -ta slurm-*.*.*.tar.bz2

# the rpms are in /root/rpmbuild/RPMS/x86_64/*.rpm

mkdir -p /share/installs/slurm

cp /root/rpmbuild/RPMS/x86_64/*.rpm /share/installs/slurm/

cp -f ./nodes/slurm_install_nodes.sh /share/installs/slurm/
chmod +x /share/installs/slurm/slurm_install_nodes.sh

pdsh /share/installs/slurm/slurm_install_nodes.sh
