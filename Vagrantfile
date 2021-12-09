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

APT_ENV_VARS = {
  'DEBIAN_FRONTEND': 'noninteractive',
  'DEBCONF_NONINTERACTIVE_SEEN': true,
}

INSTALL_ENV_VARS = {
  'VAGRANT_LIBVIRT_VERSION': QA_VAGRANT_LIBVIRT_VERSION,
}

def setup_vm_provider(vm)
  vm.provider :libvirt do |domain|
    domain.driver = 'qemu'
    domain.memory = 2048
    domain.cpus = 2
    domain.nested = true
    #domain.cpu_mode = 'host-model'
  end
end

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
    vagrant destroy -f 2>/dev/null 1>/dev/null
    vagrant up --provider=libvirt
    vagrant halt
    vagrant destroy -f
  EOC
end

Vagrant.configure(2) do |config|

  config.vm.define "ubuntu-18.04" do |v|
    v.vm.hostname = "ubuntu-18.04"
    v.vm.box = "generic/ubuntu1804"
    setup_vm_provider(v.vm)
    v.vm.provision :shell, :inline => 'ln -sf ../run/systemd/resolve/resolv.conf /etc/resolv.conf'
    v.vm.provision :shell, :privileged => false, :path => './scripts/install.bash', :args => QA_VAGRANT_VERSION, :env => INSTALL_ENV_VARS
    v.vm.provision :shell, :reset => true, :inline => 'usermod -a -G libvirt vagrant'
    add_test_provisions(v.vm)
  end

  config.vm.define "ubuntu-20.04" do |v|
    v.vm.hostname = "ubuntu-20.04"
    v.vm.box = "generic/ubuntu2004"
    setup_vm_provider(v.vm)
    v.vm.provision :shell, :inline => 'ln -sf ../run/systemd/resolve/resolv.conf /etc/resolv.conf'
    v.vm.provision :shell, :privileged => false, :path => './scripts/install.bash', :args => QA_VAGRANT_VERSION, :env => INSTALL_ENV_VARS
    v.vm.provision :shell, :reset => true, :inline => 'usermod -a -G libvirt vagrant'
    add_test_provisions(v.vm)
  end

  config.vm.define "debian-10" do |v|
    v.vm.hostname = "debian-10"
    v.vm.box = "generic/debian10"
    setup_vm_provider(v.vm)
    v.vm.provision :shell, :inline => 'sed -i -e "/^dns-nameserver/g" /etc/network/interfaces', :reboot => true
    # restarting dnsmasq can require a retry after everything else to come up correctly.
    v.vm.provision :shell, :inline => 'apt update && apt install -y dnsmasq && systemctl restart dnsmasq', :env => APT_ENV_VARS
    v.vm.provision :shell, :privileged => false, :path => './scripts/install.bash', :args => QA_VAGRANT_VERSION, :env => INSTALL_ENV_VARS
    v.vm.provision :shell, :reset => true, :inline => 'usermod -a -G libvirt vagrant'
    add_test_provisions(v.vm)
  end

  config.vm.define "centos-7" do |v|
    v.vm.hostname = "centos-7"
    v.vm.box = "centos/7"
    setup_vm_provider(v.vm)
    v.vm.provision :shell, :privileged => false, :path => './scripts/install.bash', :args => QA_VAGRANT_VERSION, :env => INSTALL_ENV_VARS
    v.vm.provision :shell, :reset => true, :inline => 'usermod -a -G libvirt vagrant'
    add_test_provisions(v.vm)
  end

  config.vm.define "centos-8" do |v|
    v.vm.hostname = "centos-8"
    v.vm.box = "centos/8"
    setup_vm_provider(v.vm)
    v.vm.provision :shell, :privileged => false, :path => './scripts/install.bash', :args => QA_VAGRANT_VERSION, :env => INSTALL_ENV_VARS
    v.vm.provision :shell, :reset => true, :inline => 'usermod -a -G libvirt vagrant'
    add_test_provisions(v.vm)
  end

  config.vm.define "fedora-33" do |v|
    v.vm.hostname = "fedora-33"
    v.vm.box = "generic/fedora33"
    setup_vm_provider(v.vm)
    v.vm.provision :shell, :privileged => false, :path => './scripts/install.bash', :args => QA_VAGRANT_VERSION, :env => INSTALL_ENV_VARS
    v.vm.provision :shell, :reset => true, :inline => 'usermod -a -G libvirt vagrant'
    add_test_provisions(v.vm)
  end

  config.vm.define "fedora-34" do |v|
    v.vm.hostname = "fedora-34"
    v.vm.box = "generic/fedora34"
    setup_vm_provider(v.vm)
    v.vm.provision :shell, :privileged => false, :path => './scripts/install.bash', :args => QA_VAGRANT_VERSION, :env => INSTALL_ENV_VARS
    v.vm.provision :shell, :reset => true, :inline => 'usermod -a -G libvirt vagrant'
    add_test_provisions(v.vm)
  end

  config.vm.define "arch" do |v|
    v.vm.hostname = "arch"
    v.vm.box = "archlinux/archlinux"
    setup_vm_provider(v.vm)
    v.vm.provision :shell, :privileged => false, :path => './scripts/install.bash', :args => QA_VAGRANT_VERSION, :env => INSTALL_ENV_VARS
    v.vm.provision :shell, :privileged => false, :reset => true, :inline => 'sudo usermod -G kvm $(whoami)'
    add_test_provisions(v.vm)
  end
end
