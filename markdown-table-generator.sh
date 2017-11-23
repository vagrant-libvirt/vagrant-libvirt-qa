#!/bin/bash

distros="ubuntu-12.04 ubuntu-14.04 ubuntu-16.04 debian-8 debian-9 centos-6 centos-7 fedora-21 fedora-22 fedora-23 fedora-24 arch"
vagrants="2.0.1"
vagrantlibvirts="master"

echo -n "|Vagrant|Vagrant-libvirt|"
for i in $distros; do echo -n "$i|"; done
echo ""
# Now the table header separator line
echo -n "|---|---|"
for i in $distros; do echo -n "---|"; done
echo ""

for vagrant in $vagrants; do
    for vagrantlibvirt in $vagrantlibvirts; do
        echo -n "|$vagrant|$vagrantlibvirt|"
        for distro in $distros; do
            echo -n "[![Build Status](https://jenkins.infernix.net/job/vagrant-libvirt-qa/QA_VAGRANT_LIBVIRT_VERSION=${vagrantlibvirt},QA_VAGRANT_VERSION=${vagrant},distro=${distro}/badge/icon)](https://jenkins.infernix.net/job/vagrant-libvirt-qa/QA_VAGRANT_LIBVIRT_VERSION=${vagrantlibvirt},QA_VAGRANT_VERSION=${vagrant},distro=${distro}/)|"
        done
        echo ""
    done
done



echo ""

