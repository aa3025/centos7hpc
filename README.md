# centos7hpc
This project is collection of bash scripts and config files to automatically deploy CentOS7-based HPC with PXE-install and kickstart file. It allows to automatically deploy Centos7-based HPC. Project's webpage is here: https://centoshpc.wordpress.com/

Deployment steps:

1) install the master node (a.k.a. server, head node) using default CenOS Live or Minimal ISO, boot the server, make sure the network is up, proceed further from its terminal.
Do not add any users during initial installation of the head node (only root). You will add other users after deployment of the HPC (with scripts/newuser).

2) get the updated version of this archive

    2.1 From  https://centoshpc.wordpress.com  or https://github.com/aa3025/centos7hpc-efi/
    
    2.2 Uncompress the archive or clone our project's git tree "git clone https://github.com/aa3025/centos7hpc-efi.git"
    
    2.3 If you failed to do above steps do not proceed further.
    
    Please do not e-mail me asking for support. These scripts are not guaranteed to work and are provided for your self-development. E-mail me though if you are interested to join this project and contribute to its development on GitHub.

3) cd HPC

4) Your installed master node (server from step (1)) must have external network adapter configured, up and running, e.g. with NetworkManager or any other way. 

5) The 2nd network adapter must be connected to the internal network of HPC (i.e. via switch or hub), where all the nodes will be booting from. All compute nodes must be connected to the same hub with their (not necessarily) 1st network adapter.

4) Download CentOS7 install DVD (minimal is OK) and run "./start.sh CentOS7xxxx.iso" from this folder. Or run it with "./start.sh -d"  to download ISO during the installation.

5) Once start.sh finishes, go and power up all your compute nodes (its better to do it one-by-one in an orderly fasion, their hostnames will be based on theur DHCP addresses, so if you want any kind of "system" in their naming make sure they boot with interval, so that previous one already obtained IP before the next one boots). They must be BIOS-configured to boot from network (PXE boot).

6) The nodes will install, post-configure themselves, and each will modify the master's   dhcpd.conf, /etc/hosts file, /etc/pdsh/machines files.

7) Once PXE-install finishes, the nodes will reboot themselves and will mount /home and /share from server via NFS. If you want to share pre-existing /home folder with user files inside, its better to call it some different name during this installation, and when everyithing finishes, rename it to /home and restart nfs server.

8) Check if HPC is deployed by doing e.g. "pdsh hostname" -> the nodes must report back their hostnames.

9) Then run "./postinstall_from_server.sh" script to add additional rpm's on the master and compute nodes and sync "/etc/hosts" file between the nodes"

10) New users can be deployed with the script  './newuser username "real user name (comments)". Script will create local user on the master and nodes, create ssh-keys for paswordless user connection to the nodes.

13) "./etherwake.sh <internal_eth_dev>" will power-awake powered-off nodes using their MAC addresses collected during installation.

14) rc.local_nodes script will update rc.local files on the nodes for automatic mounting of NFS shares, bringing up ib0 adapters, etc.

Alex Pedcenko, November 2017,  aa3025@live.co.uk , http://centoshpc.wordpress.com 






15) addedd UEFI PXE boot support, September, 2018.# centos7hpc-efi
