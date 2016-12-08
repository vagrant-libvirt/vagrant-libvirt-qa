# vagrant-libvirt-qa
Scripts for QA


Thanks for vagrant libvirt. I have it working on a large fedora libvirt box and have installed kubernetes on it using multiple libvirt vagrant VMs :)

I want to run this qa repo so I cloned this and ran

    git clone https://github.com/vagrant-libvirt/vagrant-libvirt-qa.git
    cd vagrant-libvirt-qa/
    sh vagrant-libvirt-test-cycle.sh 

and I see this.

    There are errors in the configuration of this machine. Please fix
    the following errors and try again:

    vm:
    * The 'reload' provisioner could not be found.

I also added

    vagrant plugin install vagrant-hosts
    vagrant plugin install vagrant-vbox-snapshot
   
but the issue persists.  What am I missing?
