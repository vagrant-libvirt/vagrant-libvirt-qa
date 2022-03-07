#!/usr/bin/ruby
#
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

APT_ENV_VARS = {
  'DEBIAN_FRONTEND': 'noninteractive',
  'DEBCONF_NONINTERACTIVE_SEEN': true,
}

INSTALL_ENV_VARS = {
  'VAGRANT_LIBVIRT_VERSION': ENV.fetch('QA_VAGRANT_LIBVIRT_VERSION', 'latest'),
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
        {:name => 'disable dns-nameservers', :inline => 'sed -i -e "/^dns-nameserver/g" /etc/network/interfaces', :reboot => true},
        # restarting dnsmasq can require a retry after everything else to come up correctly.
        {:name => 'install dnsmasq', :inline => 'apt update && apt install -y dnsmasq && systemctl restart dnsmasq', :env => APT_ENV_VARS},
      ],
    },
  },
  'centos-7' => {
    :libvirt => {
      :box => "generic/centos7",
    },
  },
  'centos-8' => {
    :libvirt => {
      :box => "generic/centos8",
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
  {:name => 'install script', :privileged => false, :path => './scripts/install.bash', :args => "--vagrant-version #{QA_VAGRANT_VERSION}", :env => INSTALL_ENV_VARS},
  {:name => 'setup group', :reset => true, :inline => 'usermod -a -G libvirt vagrant'},
  {:name => 'debug system capabilities', :privileged => false, :inline => 'virsh --connect qemu:///system capabilities'},
  {:name => 'debug uri', :privileged => false, :inline => 'virsh uri'},
]

if __FILE__ == $0
  require 'json'
  puts JSON.pretty_generate(BOXES)
end
