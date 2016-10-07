#!/bin/bash

BOXES=`vagrant status | grep libvirt | awk '{ print $1 }'`

for box in $BOXES; do
    vagrant destroy -f $box
    echo "vagrant-libvirt distro test for $box - `date`" > $box.log
    vagrant up $box 2>&1 | tee -a $box.log
    vagrant halt
done
