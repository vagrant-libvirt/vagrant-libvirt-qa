#!/bin/bash

distros="ubuntu-18.04 debian-9 centos-7 fedora-29 arch"
vagrants="2.2.7"
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
            echo -n "[![Build Status](https://jenkins.infernix.net/job/vagrant-libvirt-qa/qa_vagrant_libvirt_version=${vagrantlibvirt},qa_vagrant_version=${vagrant},distro=${distro}/badge/icon)](https://jenkins.infernix.net/job/vagrant-libvirt-qa/qa_vagrant_libvirt_version=${vagrantlibvirt},qa_vagrant_version=${vagrant},distro=${distro}/)|"
        done
        echo ""
    done
done



echo ""

