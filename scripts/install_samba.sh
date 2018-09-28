#!/bin/bash

yum install samba* -y


cp -f ../configs/smb.conf /etc/samba/smb.conf

firewall-cmd --permanent --zone=external --add-service=samba
firewall-cmd --permanent --zone=external --add-port=137/tcp
firewall-cmd --permanent --zone=external --add-port=138/tcp
firewall-cmd --permanent --zone=external --add-port=139/tcp
firewall-cmd --permanent --zone=external --add-port=445/tcp
firewall-cmd --permanent --zone=external --add-port=901/tcp




firewall-cmd --reload



systemctl start smb
systemctl start nmb
systemctl enable smb
systemctl enable nmb


echo "Now you can add users to samba:    smbpasswd -a username"
