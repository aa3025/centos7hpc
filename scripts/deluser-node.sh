#!/bin/bash
#Usage e.g.  ./deluser-node.sh USERNAME node149

pdsh -w $2 userdel $1
pdsh -w $2 groupdel $1

