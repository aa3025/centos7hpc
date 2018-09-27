#!/bin/bash

mkdir -p /share/installs/ganglia

cp -f gmond.conf_nodes /share/installs/ganglia/gmond.conf

cp -f gmond.conf_server /etc/ganglia/gmond.conf


cp -f gmetad.conf /etc/ganglia/gmetad.conf

pdsh "cp -f /share/installs/ganglia/gmond.conf /etc/ganglia/gmond.conf; service gmond restart"

service gmond restart; 
service gmetad restart;

