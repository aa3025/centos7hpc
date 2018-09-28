#!/bin/bash

 
firewall-cmd --permanent --direct --add-rule ipv4 filter INPUT_direct 0 -s 172.16.0.0/24 -j ACCEPT

firewall-cmd --reload
