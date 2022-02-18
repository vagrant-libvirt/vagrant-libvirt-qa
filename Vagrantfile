# -*- mode: ruby -*-
# vi: set ft=ruby :

ENV['VAGRANT_DEFAULT_PROVIDER'] ||= 'libvirt'

require_relative './boxes.rb'

def add_test_provisions(vm)
  # Workarond for Vagrant bug
  if Gem::Version.new(QA_VAGRANT_VERSION) < Gem::Version.new('1.9.1')
    vm.provision :shell, :inline => <<-EOC
    for i in /opt/vagrant/embedded/gems/gems/vagrant-*/plugins/guests/tinycore/guest.rb
    do
      sed -i "s/Core Linux/Core.*Linux/" $i
    done
    EOC
  end
  # Testing nested VM provisioning via nested kvm
  vm.provision :file, :source => './Vagrantfile.test', :destination => '~/Vagrantfile'
  vm.provision :shell, :privileged => false, :inline => <<-EOC
    set -e
    vagrant destroy -f
    vagrant up --provider=libvirt
    vagrant halt
    vagrant destroy -f
  EOC
end

Vagrant.configure(2) do |config|

  BOXES.each_pair do |name, settings|
    config.vm.define name do |machine|
      machine.vm.hostname = name

      machine.vm.provider :docker do |docker, override|
        docker.build_dir = "docker/#{name}"
        docker.build_args = "--pull"
        docker.has_ssh = true
        docker.volumes = [
          "/sys/fs/cgroup:/sys/fs/cgroup:ro",
          "/sys/fs/cgroup/systemd:/sys/fs/cgroup/systemd:rw",
        ]
        docker.create_args = [
          "--privileged",
          "--security-opt", "apparmor=unconfined",
          "--tmpfs=/run",
          "--tmpfs=/tmp:exec",
        ]
        settings.fetch(:docker,{}).fetch(:provision, []).each do |p|
          override.vm.provision :shell, **p
        end
      end

      machine.vm.provider :libvirt do |domain, override|
        override.vm.box = settings[:libvirt][:box]
        domain.driver = 'kvm'
        domain.memory = 2048
        domain.cpus = 2
        domain.nested = true
        domain.disk_driver :io => 'threads', :cache => 'unsafe'
        settings.fetch(:libvirt, {}).fetch(:provision, []).each do |p|
          override.vm.provision :shell, **p
        end
      end

      settings.fetch(:provision, DEFAULT_PROVISION).each do |p|
        machine.vm.provision :shell, **p
      end

      machine.vm.provider :docker do |domain, override|
        settings.fetch(:docker, {}).fetch(:post_install, []).each do |p|
          override.vm.provision :shell, **p
        end
      end

      add_test_provisions(machine.vm)
    end
  end
end
