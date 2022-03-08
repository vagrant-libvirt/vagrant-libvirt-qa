# -*- mode: ruby -*-
# vi: set ft=ruby :

ENV['VAGRANT_DEFAULT_PROVIDER'] = 'libvirt'

Vagrant.configure(2) do |config|
  config.vm.boot_timeout = 1200
  config.vm.define "tiny" do |v|
    v.vm.box = "infernix/tinycore"
    v.vm.synced_folder ".", "/vagrant", disabled: true
    v.vm.provider :libvirt do |domain|
      # attempting to nest here will likely cause issues
      domain.driver = 'qemu'
      domain.management_network_address = '172.31.254.0/24'
      domain.memory = 64
      domain.cpus = 1
    end
    v.ssh.shell = "/bin/sh"
    v.ssh.insert_key = false
  end
end
