# -*- mode: ruby -*-
# vi: set ft=ruby :

ENV['VAGRANT_DEFAULT_PROVIDER'] = 'libvirt'

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

# Some boilerplate to allow local shell commands on host
module LocalCommand
    class Config < Vagrant.plugin("2", :config)
        attr_accessor :command
    end

    class Plugin < Vagrant.plugin("2")
        name "local_shell"

        config(:local_shell, :provisioner) do
            Config
        end

        provisioner(:local_shell) do
            Provisioner
        end
    end

    class Provisioner < Vagrant.plugin("2", :provisioner)
        def provision
            result = system "#{config.command}"
        end
    end
end

# some common commands
WGET_VAGRANT_DEB = "wget --no-check-certificate --no-verbose https://releases.hashicorp.com/vagrant/#{QA_VAGRANT_VERSION}/vagrant_#{QA_VAGRANT_VERSION}_x86_64.deb"
WGET_VAGRANT_RPM = "wget --no-check-certificate --no-verbose https://releases.hashicorp.com/vagrant/#{QA_VAGRANT_VERSION}/vagrant_#{QA_VAGRANT_VERSION}_x86_64.rpm"

APT_UPDATE = 'DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true apt-get update'
APT_DIST_UPGRADE = 'DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true apt-get -y -o Dpkg::Options::="--force-confold" dist-upgrade'
APT_GET_RUBY_LIBVIRT = 'DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true apt-get -y build-dep vagrant ruby-libvirt'

UBUNTU_GET_DEPS = 'DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true apt-get -y -o Dpkg::Options::="--force-confold" install qemu libvirt-bin wget git'
DEBIAN_GET_DEPS = 'DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true apt-get -y -o Dpkg::Options::="--force-confold" install qemu libvirt-clients libvirt-daemon libvirt-daemon-system wget ebtables dnsmasq git'

DPKG_INSTALL_VAGRANT = "DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true dpkg -i vagrant_#{QA_VAGRANT_VERSION}_x86_64.deb"

BUILD_FROM_GIT = 'git clone https://github.com/vagrant-libvirt/vagrant-libvirt.git && cd vagrant-libvirt && gem build vagrant-libvirt.gemspec'
INSTALL_PLUGIN = "vagrant plugin install #{QA_VAGRANT_LIBVIRT_INSTALL_OPTS}"
INFERNIX_VAGRANTFILE = <<-EOC
cat <<-'EOF' > Vagrantfile
ENV['VAGRANT_DEFAULT_PROVIDER'] = 'libvirt'
Vagrant.configure(2) do |config|
  config.vm.define "tiny" do |v|
    v.vm.box = "infernix/tinycore"
    v.vm.synced_folder ".", "/vagrant", disabled: true
    v.vm.provider :libvirt do |domain|
      domain.management_network_address = '172.31.254.0/24'
      domain.memory = 64
      domain.cpus = 1
      domain.cpu_mode = 'host-passthrough'
    end
    v.ssh.insert_key = false
  end
end
EOF
EOC
PATCH_VAGRANT_CORE_LINUX = 'for i in /opt/vagrant/embedded/gems/gems/vagrant-*/plugins/guests/tinycore/guest.rb; do sed -i "s/Core Linux/Core.*Linux/" $i; done'
VAGRANT_DESTROY = 'vagrant destroy -f 2>/dev/null 1>/dev/null;vagrant up --provider=libvirt && vagrant halt'

def setup_vm_provider(vm)
  vm.provider :libvirt do |domain|
    domain.driver = 'kvm'
    domain.memory = 1024
    domain.cpus = 1
    domain.nested = true
    domain.cpu_mode = 'host-passthrough'
  end
end

def add_test_provisions(vm)
  if QA_VAGRANT_LIBVIRT_VERSION == "master"
    vm.provision :shell, :inline => BUILD_FROM_GIT
  end
  vm.provision :shell, :inline => INSTALL_PLUGIN
  # Workarond for Vagrant bug
  if QA_VAGRANT_VERSION == "1.8.7" || QA_VAGRANT_VERSION == "1.9.0" || QA_VAGRANT_VERSION == "1.9.1"
    vm.provision :shell, :inline => PATCH_VAGRANT_CORE_LINUX
  end
  # Testing nested VM provisioning via nested kvm
  vm.provision :shell, :inline => INFERNIX_VAGRANTFILE
  vm.provision :shell, :inline => VAGRANT_DESTROY
end

Vagrant.configure(2) do |config|

  config.vm.define "ubuntu-18.04" do |v|
    v.vm.hostname = "ubuntu-18.04"
    v.vm.box = "generic/ubuntu1804"
    v.vm.synced_folder ".", "/vagrant", disabled: true
    setup_vm_provider(v.vm)
    v.vm.provision :shell, :inline => 'sed -i "s/# deb-src/deb-src/" /etc/apt/sources.list'
    v.vm.provision :shell, :inline => APT_UPDATE
    v.vm.provision :shell, :inline => APT_DIST_UPGRADE
    v.vm.provision :shell, :inline => APT_GET_RUBY_LIBVIRT
    v.vm.provision :shell, :inline => UBUNTU_GET_DEPS
    v.vm.provision :reload
    v.vm.provision :shell, :inline => WGET_VAGRANT_DEB
    v.vm.provision :shell, :inline => DPKG_INSTALL_VAGRANT
    add_test_provisions(v.vm)
  end

  config.vm.define "debian-9" do |v|
    v.vm.hostname = "debian-9"
    v.vm.box = "debian/stretch64"
    v.vm.synced_folder ".", "/vagrant", disabled: true
    setup_vm_provider(v.vm)
    v.vm.provision :shell, inline: <<-EOC
cat <<-'EOF' >/etc/apt/sources.list
 deb http://httpredir.debian.org/debian stretch main contrib non-free
 deb-src http://httpredir.debian.org/debian stretch main contrib non-free
 deb http://security.debian.org/ stretch/updates main contrib non-free
 deb-src http://security.debian.org/ stretch/updates main contrib non-free
 deb http://httpredir.debian.org/debian stretch-updates main contrib non-free
 deb-src http://httpredir.debian.org/debian stretch-updates main contrib non-free
EOF
EOC
    v.vm.provision :shell, :inline => APT_UPDATE
    v.vm.provision :shell, :inline => APT_DIST_UPGRADE
    v.vm.provision :shell, :inline => APT_GET_RUBY_LIBVIRT
    v.vm.provision :shell, :inline => DEBIAN_GET_DEPS
    v.vm.provision :reload
    v.vm.provision :shell, :inline => WGET_VAGRANT_DEB
    v.vm.provision :shell, :inline => DPKG_INSTALL_VAGRANT
    add_test_provisions(v.vm)
  end

  config.vm.define "centos-7" do |v|
    v.vm.hostname = "centos-7"
    v.vm.box = "centos/7"
    v.vm.synced_folder ".", "/vagrant", disabled: true
    setup_vm_provider(v.vm)
    v.vm.provision :shell, :inline => 'yum -y update'
    v.vm.provision :shell, :inline => 'yum -y install qemu libvirt libvirt-devel ruby-devel wget gcc qemu-kvm git'
    v.vm.provision :reload
    v.vm.provision :shell, :inline => WGET_VAGRANT_RPM
    v.vm.provision :shell, :inline => "rpm -Uvh --force vagrant_#{QA_VAGRANT_VERSION}_x86_64.rpm | sed 's/#//g'"
    add_test_provisions(v.vm)
  end

  config.vm.define "fedora-29" do |v|
    v.vm.hostname = "fedora-29"
    v.vm.box = "fedora/29-cloud-base"
    v.vm.synced_folder ".", "/vagrant", disabled: true
    setup_vm_provider(v.vm)
    v.vm.provision :shell, :inline => 'dnf -y update'
    v.vm.provision :shell, :inline => 'dnf -y install qemu libvirt libvirt-devel ruby-devel wget make gcc binutils autoconf automake git'
    v.vm.provision :reload
    v.vm.provision :shell, :inline => WGET_VAGRANT_RPM
    v.vm.provision :shell, :inline => "rpm -Uvh --force vagrant_#{QA_VAGRANT_VERSION}_x86_64.rpm | sed 's/#//g'"
    add_test_provisions(v.vm)
  end

  config.vm.define "arch" do |v|
    v.vm.hostname = "arch"
    v.vm.box = "archlinux/archlinux"
    v.vm.synced_folder ".", "/vagrant", disabled: true
    setup_vm_provider(v.vm)
    v.vm.provision :shell, :inline => 'pacman -Suyu --noconfirm --noprogressbar'
    v.vm.provision :shell, :inline => 'pacman -S --noconfirm --noprogressbar vagrant git ruby make gcc binutils autoconf automake libxml2 libxslt pkg-config libvirt qemu openbsd-netcat bridge-utils ebtables iptables dnsmasq firewalld'
    v.vm.provision :shell, :inline => 'systemctl enable libvirtd; systemctl start libvirtd; systemctl enable firewalld; systemctl start firewalld'
    v.vm.provision :shell, :inline => 'usermod -G kvm nobody'
    v.vm.provision :reload
    add_test_provisions(v.vm)
  end
end
