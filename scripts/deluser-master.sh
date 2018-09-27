#!/bin/bash

userdel $1
groupdel $1

rm -fr /home/$1

pdsh userdel $1
pdsh groupdel $1

