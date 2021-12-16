# -*- mode: ruby -*-
# vi: set ft=ruby :

ENV['VAGRANT_DEFAULT_PROVIDER'] ||= 'libvirt'

# Allow for passing test versions with env vars
if ENV['QA_VAGRANT_VERSION'].nil? || ENV['QA_VAGRANT_VERSION'] == "latest"
  # If not specified, fetch the latest version using built-in 'version' plugin
  #
  # NOTE: we 'cd /tmp' to avoid invoking Vagrant against this very Vagrantfile but
  # that may not always work. There is probably a better way by leveraging
  # VagrantPlugins::CommandVersion::Command and using 'version-latest'
  #
  latest = `cd /tmp; vagrant version | grep Latest | awk '{ print $3 }'`
  QA_VAGRANT_VERSION = latest.strip
else
  QA_VAGRANT_VERSION = ENV['QA_VAGRANT_VERSION']
end

if ENV['QA_VAGRANT_LIBVIRT_VERSION'].nil?
  # If not specified, we just install latest published version
  QA_VAGRANT_LIBVIRT_INSTALL_OPTS = "vagrant-libvirt"
  QA_VAGRANT_LIBVIRT_VERSION = "latest"
elsif ENV['QA_VAGRANT_LIBVIRT_VERSION'] == "master"
  QA_VAGRANT_LIBVIRT_INSTALL_OPTS = "../vagrant-libvirt/vagrant-libvirt-*.gem"
  QA_VAGRANT_LIBVIRT_VERSION = "master"
else
  QA_VAGRANT_LIBVIRT_VERSION = ENV['QA_VAGRANT_LIBVIRT_VERSION']
  QA_VAGRANT_LIBVIRT_INSTALL_OPTS = "vagrant-libvirt --plugin-version #{QA_VAGRANT_LIBVIRT_VERSION}"
end

APT_ENV_VARS = {
  'DEBIAN_FRONTEND': 'noninteractive',
  'DEBCONF_NONINTERACTIVE_SEEN': true,
}

INSTALL_ENV_VARS = {
  'VAGRANT_LIBVIRT_VERSION': QA_VAGRANT_LIBVIRT_VERSION,
}

BOXES = {
  'ubuntu-18.04' => {
    :libvirt => {
      :box => "generic/ubuntu1804",
      :provision => [
        {:inline => 'ln -sf ../run/systemd/resolve/resolv.conf /etc/resolv.conf'},
      ],
    },
  },
  'ubuntu-20.04' => {
    :libvirt => {
      :box => "generic/ubuntu2004",
    },
  },
  'debian-10' => {
    :libvirt => {
      :box => "generic/debian10",
      :provision => [
        {:inline => 'sed -i -e "/^dns-nameserver/g" /etc/network/interfaces', :reboot => true},
        # restarting dnsmasq can require a retry after everything else to come up correctly.
        {:inline => 'apt update && apt install -y dnsmasq && systemctl restart dnsmasq', :env => APT_ENV_VARS},
      ],
    },
  },
  'centos-7' => {
    :libvirt => {
      :box => "generic/centos7",
      :provision => [
        {:inline => 'ln -sf ../run/systemd/resolve/resolv.conf /etc/resolv.conf'},
      ],
    },
  },
  'centos-8' => {
    :libvirt => {
      :box => "generic/centos8",
      :provision => [
        {:inline => 'ln -sf ../run/systemd/resolve/resolv.conf /etc/resolv.conf'},
      ],
    },
  },
  'fedora-33' => {
    :libvirt => {
      :box => "generic/fedora33",
    },
  },
  'fedora-34' => {
    :libvirt => {
      :box => "generic/fedora34",
    },
  },
  'archlinux' => {
    :libvirt => {
      :box => "archlinux/archlinux",
    },
  },
}

DEFAULT_PROVISION = [
  {:privileged => false, :path => './scripts/install.bash', :args => QA_VAGRANT_VERSION, :env => INSTALL_ENV_VARS},
  {:reset => true, :inline => 'usermod -a -G libvirt vagrant'},
]

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
        docker.has_ssh = true
        docker.volumes = ["/sys/fs/cgroup:/sys/fs/cgroup"]
        docker.create_args = ["--privileged"]
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

      add_test_provisions(machine.vm)
    end
  end
end
