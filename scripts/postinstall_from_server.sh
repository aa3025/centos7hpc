#!/bin/bash

# Execute once all nodes are installed, rebooted themselves, NAT, pdsh working etc.
# This script adds some final touches

# make sure SELINUX is dead.
pdsh "sed 's/^SELINUX=.*/SELINUX=disabled/' /etc/selinux/config > /etc/selinux/config.tmp; mv -f /etc/selinux/config.tmp /etc/selinux/config"

pdsh yum -y update
pdsh yum -y install epel-release
pdsh yum -y groupinstall "Development Tools"

# you can add below any extra RPMs you want on the nodes. Also can install them later with pdsh
pdsh yum -y install octave psmisc ganglia-gmond kernel-devel kernel-headers environment-modules openmpi atlas blas lapack mpich2 atlas-devel mpich2-devel gcc gcc-c++ make  blas-devel liblas liblas-devel compat-libstdc++-33


# we will compile openmpi with knem (infiniband) support later

# on server as well:

yum -y groupinstall "Development Tools"

yum -y install octave psmisc ganglia ganglia-web ganglia-gmond ganglia-gmetad environment-modules  atlas blas lapack mpich2 atlas-devel mpich2-devel gcc gcc-c++ make  blas-devel liblas liblas-devel compat-libstdc++-33

mkdir -p /share/installs
cp /etc/hosts /share/installs/hosts

pdsh cp /share/installs/hosts /etc/hosts


# update master
yum -y update

# update ganglia's gmond and gmetad conf files
./update_ganglias.sh 
# check http://master/ganglia afterwards

#### openmpi ####

####if you do not have infinipath hardware, you can just uncomment the next line:

yum -y install openmpi openmpi-devel

#### OR to compile knem (openfabrics alternative) and knem-enabled openmpi on the headnode in the shared location leave next line uncommented:

#./openmpi_knem_compile-master.sh
