# centos7hpc
This project is collection of bash scripts and config files to automatically deploy CentOS7-based HPC with PXE-install and kickstart files. Supports both BIOS-based and EFI PXE scenarios. Project's webpage is here: https://centoshpc.wordpress.com/

Deployment steps:

1) install the master node (a.k.a. server, head node) using default CenOS Live or Minimal ISO, boot it, make sure the network is up, proceed further from its terminal.

Do not add any users during initial installation of the head node (only root). You will add other users after deployment of the HPC (using ./scripts/newuser).

2) get the updated version of this repository

    2.1 From  https://github.com/aa3025/centos7hpc/
    
    2.2 Uncompress the archive or clone our project's git tree "git clone https://github.com/aa3025/centos7hpc.git"
    
    2.3 If you failed to do above steps do not proceed further.
    
Please do not e-mail me asking for support. These scripts are not guaranteed to work and are provided for your self-development. However if you are interested, you can to join this project and contribute to its development on GitHub.

3) cd centos7hpc

4) Your installed master node must have the external network adapter configured, up and running, e.g. with NetworkManager or any other way. 

5) The 2nd network adapter must be connected to the internal network of HPC (i.e. via switch or hub), where all the "compute" nodes will be booting up from. All compute nodes must be connected to the same hub with their (not necessarily) 1st network adapter and configured to boot from LAN (PXE boot).

4) Download CentOS7 install DVD and run "./install.sh CentOS7xxxx.iso" from this folder. Or run it with "./install.sh -d"  to download ISO during the installation. You will be prompted in a minute to enter internal and external LAN interface names. This is the only input required form user.

5) Once install.sh finishes, go and power up all your compute nodes (its better to do it one-by-one in an orderly fasion, their hostnames will be based on their DHCP addresses (101-200), so if you want any kind of "system" in their naming make sure they boot with interval, so that previous one already obtained IP before the next one boots). They must be BIOS-configured to boot from network (PXE boot).

6) The nodes will install, post-configure themselves, and each will modify the master's dhcpd.conf, /etc/hosts file, /etc/pdsh/machines file and add their grub.cfg-xxx to /lib/var/tftpboot on master, so that on the next boot they don't go into PXE install again.

7) Once PXE-install finishes, the nodes will reboot themselves and will mount /home and /share from server via NFS. If you want to share pre-existing /home folder with user files inside, its better to call it some different name during this installation, and when everyithing finishes, rename it to /home and restart nfs server.

8) Check if HPC is deployed by doing e.g. "pdsh hostname" -> the nodes must report back their hostnames. Its a good idea to restart dhcpd on master for it to swallow /etc/dhcp/dhcpd.conf the modified by nodes.
If you want to repeat install of a node already deployed previosly, you just need to delete its /tftpboot/grub.cfg-01-xx-xx-xx-xx-xx-xx file and its records from /etc/pdsh/machines and /etc/dhcp/dhcpd.conf and restart it without re-running ./install.sh ! Server configuration is permanent, so it still must be able to serve new deployments after reboot (perhaps you want to check if centos iso file is still mounted after reboot of the master node and mount it if it isn't in /var/www/html/centos).

9) Then you can run optional "./postinstall_from_server.sh" script to add additional rpm's on the master and compute nodes and sync "/etc/hosts" file between the nodes". 

10) New users can be deployed with the script (cd ./configs)  './newuser username "real user name (comments)". Script will create a local user and group on the master and nodes, create ssh-keys for paswordless connection to the nodes.

11) You can use pdsh to install missing packages on the nodes in parallel or mass-copying files etc.

12) addedd UEFI PXE boot support, September, 2018. #centos7hpc

Alex Pedcenko, September 2018,  aa3025(at)live.co.uk , http://centoshpc.wordpress.com 



