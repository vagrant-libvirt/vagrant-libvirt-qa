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
  QA_VAGRANT_LIBVIRT_INSTALL_OPTS = "./vagrant-libvirt/vagrant-libvirt-*.gem"
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


Vagrant.configure(2) do |config|

  config.vm.define "ubuntu-12.04" do |v|
    v.vm.hostname = "ubuntu-12.04"
    v.vm.box = "alxgrh/ubuntu-precise-x86_64"
    v.vm.synced_folder ".", "/vagrant", disabled: true
    v.vm.provider :libvirt do |domain|
      domain.memory = 1024
      domain.cpus = 1
      domain.nested = true
      domain.cpu_mode = 'host-passthrough'
    end
    v.vm.provision :shell, :inline => 'sed -i "s/# deb-src/deb-src/" /etc/apt/sources.list'
    v.vm.provision :shell, :inline => 'DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true apt-get update'
    v.vm.provision :shell, :inline => 'DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true apt-get -y -o Dpkg::Options::="--force-confold" dist-upgrade'
    v.vm.provision :shell, :inline => 'DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true apt-get -y build-dep vagrant ruby-libvirt'
    v.vm.provision :shell, :inline => 'DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true apt-get -y -o Dpkg::Options::="--force-confold" install qemu libvirt-bin wget git'
    v.vm.provision :reload
    v.vm.provision :shell, :inline => "wget --no-check-certificate --no-verbose https://releases.hashicorp.com/vagrant/#{QA_VAGRANT_VERSION}/vagrant_#{QA_VAGRANT_VERSION}_x86_64.deb"
    v.vm.provision :shell, :inline => "DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true dpkg -i vagrant_#{QA_VAGRANT_VERSION}_x86_64.deb"
    if QA_VAGRANT_LIBVIRT_VERSION == "master"
      v.vm.provision :shell, :inline => "git clone https://github.com/vagrant-libvirt/vagrant-libvirt.git"
      v.vm.provision :shell, :inline => "cd vagrant-libvirt && gem build vagrant-libvirt.gemspec"
    end  
    v.vm.provision :shell, :inline => "vagrant plugin install #{QA_VAGRANT_LIBVIRT_INSTALL_OPTS}"
    # Workarond for Vagrant bug
    if QA_VAGRANT_VERSION == "1.8.7" || QA_VAGRANT_VERSION == "1.9.0" || QA_VAGRANT_VERSION == "1.9.1"
      v.vm.provision :shell, :inline => 'for i in /opt/vagrant/embedded/gems/gems/vagrant-*/plugins/guests/tinycore/guest.rb; do sed -i "s/Core Linux/Core.*Linux/" $i; done'
    end
    # Testing nested VM provisioning via nested kvm 
    v.vm.provision "shell", inline: <<-EOC
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
    v.vm.provision :shell, :inline => 'vagrant destroy -f 2>/dev/null 1>/dev/null;vagrant up --provider=libvirt'
    v.vm.provision :shell, :inline => 'vagrant halt'
  end

  config.vm.define "ubuntu-14.04" do |v|
    v.vm.hostname = "ubuntu-14.04"
    v.vm.box = "alxgrh/ubuntu-trusty-x86_64"
    v.vm.synced_folder ".", "/vagrant", disabled: true
    v.vm.provider :libvirt do |domain|
      domain.memory = 1024
      domain.cpus = 1
      domain.nested = true
      domain.cpu_mode = 'host-passthrough'
    end
    v.vm.provision :shell, :inline => 'sed -i "s/# deb-src/deb-src/" /etc/apt/sources.list'
    v.vm.provision :shell, :inline => 'DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true apt-get update'
    v.vm.provision :shell, :inline => 'DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true apt-get -y -o Dpkg::Options::="--force-confold" dist-upgrade'
    v.vm.provision :shell, :inline => 'DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true apt-get -y build-dep vagrant ruby-libvirt'
    v.vm.provision :shell, :inline => 'DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true apt-get -y -o Dpkg::Options::="--force-confold" install qemu libvirt-bin wget git'
    v.vm.provision :reload
    v.vm.provision :shell, :inline => "wget --no-check-certificate --no-verbose https://releases.hashicorp.com/vagrant/#{QA_VAGRANT_VERSION}/vagrant_#{QA_VAGRANT_VERSION}_x86_64.deb"
    v.vm.provision :shell, :inline => "DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true dpkg -i vagrant_#{QA_VAGRANT_VERSION}_x86_64.deb"
    if QA_VAGRANT_LIBVIRT_VERSION == "master"
      v.vm.provision :shell, :inline => "git clone https://github.com/vagrant-libvirt/vagrant-libvirt.git"
      v.vm.provision :shell, :inline => "cd vagrant-libvirt && gem build vagrant-libvirt.gemspec"
    end  
    # Workaround for ruby bug
    v.vm.provision :shell, :inline => "REALLY_GEM_UPDATE_SYSTEM=y gem update --system"
    v.vm.provision :shell, :inline => "vagrant plugin install #{QA_VAGRANT_LIBVIRT_INSTALL_OPTS}"
    # Workarond for Vagrant bug
    if QA_VAGRANT_VERSION == "1.8.7" || QA_VAGRANT_VERSION == "1.9.0" || QA_VAGRANT_VERSION == "1.9.1"
      v.vm.provision :shell, :inline => 'for i in /opt/vagrant/embedded/gems/gems/vagrant-*/plugins/guests/tinycore/guest.rb; do sed -i "s/Core Linux/Core.*Linux/" $i; done'
    end
    # Workarond for Vagrant bug
    if QA_VAGRANT_VERSION == "1.8.7" || QA_VAGRANT_VERSION == "1.9.0" || QA_VAGRANT_VERSION == "1.9.1"
      v.vm.provision :shell, :inline => 'for i in /opt/vagrant/embedded/gems/gems/vagrant-*/plugins/guests/tinycore/guest.rb; do sed -i "s/Core Linux/Core.*Linux/" $i; done'
    end
    # Testing nested VM provisioning via nested kvm 
    v.vm.provision "shell", inline: <<-EOC
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
    v.vm.provision :shell, :inline => 'vagrant destroy -f 2>/dev/null 1>/dev/null;vagrant up --provider=libvirt'
    v.vm.provision :shell, :inline => 'vagrant halt'
  end

  config.vm.define "ubuntu-16.04" do |v|
    v.vm.hostname = "ubuntu-16.04"
    v.vm.box = "mkutsevol/xenial"
    v.vm.synced_folder ".", "/vagrant", disabled: true
    v.vm.provider :libvirt do |domain|
      domain.memory = 1024
      domain.cpus = 1
      domain.nested = true
      domain.cpu_mode = 'host-passthrough'
    end
    v.vm.provision :shell, :inline => 'sed -i "s/# deb-src/deb-src/" /etc/apt/sources.list'
    v.vm.provision :shell, :inline => 'DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true apt-get update'
    v.vm.provision :shell, :inline => 'DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true apt-get -y -o Dpkg::Options::="--force-confold" dist-upgrade'
    v.vm.provision :shell, :inline => 'DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true apt-get -y build-dep vagrant ruby-libvirt'
    v.vm.provision :shell, :inline => 'DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true apt-get -y -o Dpkg::Options::="--force-confold" install qemu libvirt-bin wget git'
    v.vm.provision :reload
    v.vm.provision :shell, :inline => "wget --no-check-certificate --no-verbose https://releases.hashicorp.com/vagrant/#{QA_VAGRANT_VERSION}/vagrant_#{QA_VAGRANT_VERSION}_x86_64.deb"
    v.vm.provision :shell, :inline => "DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true dpkg -i vagrant_#{QA_VAGRANT_VERSION}_x86_64.deb"
    if QA_VAGRANT_LIBVIRT_VERSION == "master"
      v.vm.provision :shell, :inline => "git clone https://github.com/vagrant-libvirt/vagrant-libvirt.git"
      v.vm.provision :shell, :inline => "cd vagrant-libvirt && gem build vagrant-libvirt.gemspec"
    end  
    v.vm.provision :shell, :inline => "vagrant plugin install #{QA_VAGRANT_LIBVIRT_INSTALL_OPTS}"
    # Workarond for Vagrant bug
    if QA_VAGRANT_VERSION == "1.8.7" || QA_VAGRANT_VERSION == "1.9.0" || QA_VAGRANT_VERSION == "1.9.1"
      v.vm.provision :shell, :inline => 'for i in /opt/vagrant/embedded/gems/gems/vagrant-*/plugins/guests/tinycore/guest.rb; do sed -i "s/Core Linux/Core.*Linux/" $i; done'
    end
    # Testing nested VM provisioning via nested kvm 
    v.vm.provision "shell", inline: <<-EOC
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
    v.vm.provision :shell, :inline => 'vagrant destroy -f 2>/dev/null 1>/dev/null;vagrant up --provider=libvirt'
    v.vm.provision :shell, :inline => 'vagrant halt'
  end

  config.vm.define "debian-8" do |v|
    v.vm.hostname = "debian-8"
    v.vm.box = "debian/jessie64"
    v.vm.synced_folder ".", "/vagrant", disabled: true
    v.vm.provider :libvirt do |domain|
      domain.memory = 1024
      domain.cpus = 1
      domain.nested = true
      domain.cpu_mode = 'host-passthrough'
    end
    v.vm.provision "shell", inline: <<-EOC
cat <<-'EOF' >/etc/apt/sources.list
 deb http://httpredir.debian.org/debian jessie main contrib non-free
 deb-src http://httpredir.debian.org/debian jessie main contrib non-free
 deb http://security.debian.org/ jessie/updates main contrib non-free
 deb-src http://security.debian.org/ jessie/updates main contrib non-free
 deb http://httpredir.debian.org/debian jessie-updates main contrib non-free
 deb-src http://httpredir.debian.org/debian jessie-updates main contrib non-free
EOF
EOC
    v.vm.provision :shell, :inline => "wget --no-check-certificate --no-verbose https://releases.hashicorp.com/vagrant/#{QA_VAGRANT_VERSION}/vagrant_#{QA_VAGRANT_VERSION}_x86_64.deb"
    v.vm.provision :shell, :inline => 'DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true apt-get update'
    v.vm.provision :shell, :inline => 'DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true apt-get -y -o Dpkg::Options::="--force-confold" dist-upgrade'
    v.vm.provision :shell, :inline => 'DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true apt-get -y build-dep vagrant ruby-libvirt'
    v.vm.provision :shell, :inline => 'DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true apt-get -y -o Dpkg::Options::="--force-confold" install qemu libvirt-bin wget ebtables dnsmasq git'
    v.vm.provision :reload
    v.vm.provision :shell, :inline => "DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true dpkg -i vagrant_#{QA_VAGRANT_VERSION}_x86_64.deb"
    if QA_VAGRANT_LIBVIRT_VERSION == "master"
      v.vm.provision :shell, :inline => "git clone https://github.com/vagrant-libvirt/vagrant-libvirt.git"
      v.vm.provision :shell, :inline => "cd vagrant-libvirt && gem build vagrant-libvirt.gemspec"
    end  
    v.vm.provision :shell, :inline => "vagrant plugin install #{QA_VAGRANT_LIBVIRT_INSTALL_OPTS}"
    # Workarond for Vagrant bug
    if QA_VAGRANT_VERSION == "1.8.7" || QA_VAGRANT_VERSION == "1.9.0" || QA_VAGRANT_VERSION == "1.9.1"
      v.vm.provision :shell, :inline => 'for i in /opt/vagrant/embedded/gems/gems/vagrant-*/plugins/guests/tinycore/guest.rb; do sed -i "s/Core Linux/Core.*Linux/" $i; done'
    end
    # Testing nested VM provisioning via nested kvm 
    v.vm.provision "shell", inline: <<-EOC
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
    v.vm.provision :shell, :inline => 'vagrant destroy -f 2>/dev/null 1>/dev/null;vagrant up --provider=libvirt'
    v.vm.provision :shell, :inline => 'vagrant halt'
  end

  config.vm.define "debian-9" do |v|
    v.vm.hostname = "debian-9"
    v.vm.box = "debian/stretch64"
    v.vm.synced_folder ".", "/vagrant", disabled: true
    v.vm.provider :libvirt do |domain|
      domain.memory = 1024
      domain.cpus = 1
      domain.nested = true
      domain.cpu_mode = 'host-passthrough'
    end
    v.vm.provision "shell", inline: <<-EOC
cat <<-'EOF' >/etc/apt/sources.list
 deb http://httpredir.debian.org/debian stretch main contrib non-free
 deb-src http://httpredir.debian.org/debian stretch main contrib non-free
 deb http://security.debian.org/ stretch/updates main contrib non-free
 deb-src http://security.debian.org/ stretch/updates main contrib non-free
 deb http://httpredir.debian.org/debian stretch-updates main contrib non-free
 deb-src http://httpredir.debian.org/debian stretch-updates main contrib non-free
EOF
EOC
    v.vm.provision :shell, :inline => "wget --no-check-certificate --no-verbose https://releases.hashicorp.com/vagrant/#{QA_VAGRANT_VERSION}/vagrant_#{QA_VAGRANT_VERSION}_x86_64.deb"
    v.vm.provision :shell, :inline => 'DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true apt-get update'
    v.vm.provision :shell, :inline => 'DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true apt-get -y -o Dpkg::Options::="--force-confold" dist-upgrade'
    v.vm.provision :shell, :inline => 'DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true apt-get -y build-dep vagrant ruby-libvirt'
    v.vm.provision :shell, :inline => 'DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true apt-get -y -o Dpkg::Options::="--force-confold" install qemu libvirt-clients libvirt-daemon libvirt-daemon-system wget ebtables dnsmasq git'
    v.vm.provision :reload
    v.vm.provision :shell, :inline => "DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true dpkg -i vagrant_#{QA_VAGRANT_VERSION}_x86_64.deb"
    if QA_VAGRANT_LIBVIRT_VERSION == "master"
      v.vm.provision :shell, :inline => "git clone https://github.com/vagrant-libvirt/vagrant-libvirt.git"
      v.vm.provision :shell, :inline => "cd vagrant-libvirt && gem build vagrant-libvirt.gemspec"
    end  
    v.vm.provision :shell, :inline => "vagrant plugin install #{QA_VAGRANT_LIBVIRT_INSTALL_OPTS}"
    # Workarond for Vagrant bug
    if QA_VAGRANT_VERSION == "1.8.7" || QA_VAGRANT_VERSION == "1.9.0" || QA_VAGRANT_VERSION == "1.9.1"
      v.vm.provision :shell, :inline => 'for i in /opt/vagrant/embedded/gems/gems/vagrant-*/plugins/guests/tinycore/guest.rb; do sed -i "s/Core Linux/Core.*Linux/" $i; done'
    end
    # Testing nested VM provisioning via nested kvm 
    v.vm.provision "shell", inline: <<-EOC
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
    v.vm.provision :shell, :inline => 'vagrant destroy -f 2>/dev/null 1>/dev/null;vagrant up --provider=libvirt'
    v.vm.provision :shell, :inline => 'vagrant halt'
  end


  config.vm.define "centos-6" do |v|
    v.vm.hostname = "centos-6"
    v.vm.box = "dliappis/centos65minlibvirt"
    v.vm.synced_folder ".", "/vagrant", disabled: true
    v.vm.provider :libvirt do |domain|
      domain.memory = 1024
      domain.cpus = 1
      domain.nested = true
      domain.cpu_mode = 'host-passthrough'
    end
    v.vm.provision :shell, :inline => 'yum -y update'
    v.vm.provision :shell, :inline => 'yum -y install qemu libvirt libvirt-devel ruby-devel wget gcc acpid qemu-kvm git rubygems'
    v.vm.provision :shell, :inline => 'chkconfig acpid on; service acpid restart'
    v.vm.provision :reload
    v.vm.provision :shell, :inline => "wget --no-check-certificate --no-verbose https://releases.hashicorp.com/vagrant/#{QA_VAGRANT_VERSION}/vagrant_#{QA_VAGRANT_VERSION}_x86_64.rpm"
    v.vm.provision :shell, :inline => "rpm -Uvh --force vagrant_#{QA_VAGRANT_VERSION}_x86_64.rpm | sed 's/#//g'"
    if QA_VAGRANT_LIBVIRT_VERSION == "master"
      v.vm.provision :shell, :inline => "git clone https://github.com/vagrant-libvirt/vagrant-libvirt.git"
      v.vm.provision :shell, :inline => "cd vagrant-libvirt && gem build vagrant-libvirt.gemspec"
    end  
    v.vm.provision :shell, :inline => "vagrant plugin install #{QA_VAGRANT_LIBVIRT_INSTALL_OPTS}"
    # Workarond for Vagrant bug
    if QA_VAGRANT_VERSION == "1.8.7" || QA_VAGRANT_VERSION == "1.9.0" || QA_VAGRANT_VERSION == "1.9.1"
      v.vm.provision :shell, :inline => 'for i in /opt/vagrant/embedded/gems/gems/vagrant-*/plugins/guests/tinycore/guest.rb; do sed -i "s/Core Linux/Core.*Linux/" $i; done'
    end
    # Testing nested VM provisioning via nested kvm 
    v.vm.provision "shell", inline: <<-EOC
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
    v.vm.provision :shell, :inline => 'vagrant destroy -f 2>/dev/null 1>/dev/null;vagrant up --provider=libvirt'
    v.vm.provision :shell, :inline => 'vagrant halt'
  end


  config.vm.define "centos-7" do |v|
    v.vm.hostname = "centos-7"
    v.vm.box = "centos/7"
    v.vm.synced_folder ".", "/vagrant", disabled: true
    v.vm.provider :libvirt do |domain|
      domain.memory = 1024
      domain.cpus = 1
      domain.nested = true
      domain.cpu_mode = 'host-passthrough'
    end
    v.vm.provision :shell, :inline => 'yum -y update'
    v.vm.provision :shell, :inline => 'yum -y install qemu libvirt libvirt-devel ruby-devel wget gcc qemu-kvm git'
    v.vm.provision :reload
    v.vm.provision :shell, :inline => "wget --no-check-certificate --no-verbose https://releases.hashicorp.com/vagrant/#{QA_VAGRANT_VERSION}/vagrant_#{QA_VAGRANT_VERSION}_x86_64.rpm"
    v.vm.provision :shell, :inline => "rpm -Uvh --force vagrant_#{QA_VAGRANT_VERSION}_x86_64.rpm | sed 's/#//g'"
    if QA_VAGRANT_LIBVIRT_VERSION == "master"
      v.vm.provision :shell, :inline => "git clone https://github.com/vagrant-libvirt/vagrant-libvirt.git"
      v.vm.provision :shell, :inline => "cd vagrant-libvirt && gem build vagrant-libvirt.gemspec"
    end  
    v.vm.provision :shell, :inline => "vagrant plugin install #{QA_VAGRANT_LIBVIRT_INSTALL_OPTS}"
    # Workarond for Vagrant bug
    if QA_VAGRANT_VERSION == "1.8.7" || QA_VAGRANT_VERSION == "1.9.0" || QA_VAGRANT_VERSION == "1.9.1"
      v.vm.provision :shell, :inline => 'for i in /opt/vagrant/embedded/gems/gems/vagrant-*/plugins/guests/tinycore/guest.rb; do sed -i "s/Core Linux/Core.*Linux/" $i; done'
    end
    # Testing nested VM provisioning via nested kvm 
    v.vm.provision "shell", inline: <<-EOC
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
    v.vm.provision :shell, :inline => 'vagrant destroy -f 2>/dev/null 1>/dev/null;vagrant up --provider=libvirt'
    v.vm.provision :shell, :inline => 'vagrant halt'
  end

  config.vm.define "fedora-23" do |v|
    v.vm.hostname = "fedora-23"
    v.vm.box = "ansiwen/fedora-23"
    v.vm.synced_folder ".", "/vagrant", disabled: true
    v.vm.provider :libvirt do |domain|
      domain.memory = 1024
      domain.cpus = 1
      domain.nested = true
      domain.cpu_mode = 'host-passthrough'
    end
    v.vm.provision :shell, :inline => 'dnf -y update'
    v.vm.provision :shell, :inline => 'dnf -y install qemu libvirt libvirt-devel ruby-devel wget gcc git'
    v.vm.provision :reload
    v.vm.provision :shell, :inline => "wget --no-check-certificate --no-verbose https://releases.hashicorp.com/vagrant/#{QA_VAGRANT_VERSION}/vagrant_#{QA_VAGRANT_VERSION}_x86_64.rpm"
    v.vm.provision :shell, :inline => "rpm -Uvh --force vagrant_#{QA_VAGRANT_VERSION}_x86_64.rpm | sed 's/#//g'"
    if QA_VAGRANT_LIBVIRT_VERSION == "master"
      v.vm.provision :shell, :inline => "git clone https://github.com/vagrant-libvirt/vagrant-libvirt.git"
      v.vm.provision :shell, :inline => "cd vagrant-libvirt && gem build vagrant-libvirt.gemspec"
    end  
    v.vm.provision :shell, :inline => "vagrant plugin install #{QA_VAGRANT_LIBVIRT_INSTALL_OPTS}"
    # Workarond for Vagrant bug
    if QA_VAGRANT_VERSION == "1.8.7" || QA_VAGRANT_VERSION == "1.9.0" || QA_VAGRANT_VERSION == "1.9.1"
      v.vm.provision :shell, :inline => 'for i in /opt/vagrant/embedded/gems/gems/vagrant-*/plugins/guests/tinycore/guest.rb; do sed -i "s/Core Linux/Core.*Linux/" $i; done'
    end
    # Testing nested VM provisioning via nested kvm 
    v.vm.provision "shell", inline: <<-EOC
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
    v.vm.provision :shell, :inline => 'vagrant destroy -f 2>/dev/null 1>/dev/null;vagrant up --provider=libvirt'
    v.vm.provision :shell, :inline => 'vagrant halt'
  end

  config.vm.define "fedora-24" do |v|
    v.vm.hostname = "fedora-24"
    v.vm.box = "fedora/24-cloud-base"
    v.vm.box_url = "http://archives.fedoraproject.org/pub/archive/fedora/linux/releases/24/CloudImages/x86_64/images/Fedora-Cloud-Base-Vagrant-24-1.2.x86_64.vagrant-libvirt.box"
    v.vm.synced_folder ".", "/vagrant", disabled: true
    v.vm.provider :libvirt do |domain|
      domain.memory = 1024
      domain.cpus = 1
      domain.nested = true
      domain.cpu_mode = 'host-passthrough'
    end
    v.vm.provision :shell, :inline => 'dnf -y update'
    v.vm.provision :shell, :inline => 'dnf -y install qemu libvirt libvirt-devel ruby-devel wget gcc git make'
    v.vm.provision :shell, :inline => "wget --no-check-certificate --no-verbose https://releases.hashicorp.com/vagrant/#{QA_VAGRANT_VERSION}/vagrant_#{QA_VAGRANT_VERSION}_x86_64.rpm"
    v.vm.provision :reload
    v.vm.provision :shell, :inline => "rpm -Uvh --force vagrant_#{QA_VAGRANT_VERSION}_x86_64.rpm | sed 's/#//g'"
    if QA_VAGRANT_LIBVIRT_VERSION == "master"
      v.vm.provision :shell, :inline => "git clone https://github.com/vagrant-libvirt/vagrant-libvirt.git"
      v.vm.provision :shell, :inline => "cd vagrant-libvirt && gem build vagrant-libvirt.gemspec"
    end  
    v.vm.provision :shell, :inline => "vagrant plugin install #{QA_VAGRANT_LIBVIRT_INSTALL_OPTS}"
    # Workarond for Vagrant bug
    if QA_VAGRANT_VERSION == "1.8.7" || QA_VAGRANT_VERSION == "1.9.0" || QA_VAGRANT_VERSION == "1.9.1"
      v.vm.provision :shell, :inline => 'for i in /opt/vagrant/embedded/gems/gems/vagrant-*/plugins/guests/tinycore/guest.rb; do sed -i "s/Core Linux/Core.*Linux/" $i; done'
    end
    # Testing nested VM provisioning via nested kvm 
    v.vm.provision "shell", inline: <<-EOC
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
    v.vm.provision :shell, :inline => 'vagrant destroy -f 2>/dev/null 1>/dev/null;vagrant up --provider=libvirt'
    v.vm.provision :shell, :inline => 'vagrant halt'
  end

  config.vm.define "fedora-25" do |v|
    v.vm.hostname = "fedora-25"
    v.vm.box = "fedora/25-cloud-base"
    v.vm.synced_folder ".", "/vagrant", disabled: true
    v.vm.provider :libvirt do |domain|
      domain.memory = 1024
      domain.cpus = 1
      domain.nested = true
      domain.cpu_mode = 'host-passthrough'
    end
    v.vm.provision :shell, :inline => 'dnf -y update'
    v.vm.provision :shell, :inline => 'dnf -y install qemu libvirt libvirt-devel ruby-devel wget gcc git'
    v.vm.provision :shell, :inline => "wget --no-check-certificate --no-verbose https://releases.hashicorp.com/vagrant/#{QA_VAGRANT_VERSION}/vagrant_#{QA_VAGRANT_VERSION}_x86_64.rpm"
    v.vm.provision :reload
    v.vm.provision :shell, :inline => "rpm -Uvh --force vagrant_#{QA_VAGRANT_VERSION}_x86_64.rpm | sed 's/#//g'"
    if QA_VAGRANT_LIBVIRT_VERSION == "master"
      v.vm.provision :shell, :inline => "git clone https://github.com/vagrant-libvirt/vagrant-libvirt.git"
      v.vm.provision :shell, :inline => "cd vagrant-libvirt && gem build vagrant-libvirt.gemspec"
    end  
    v.vm.provision :shell, :inline => "vagrant plugin install #{QA_VAGRANT_LIBVIRT_INSTALL_OPTS}"
    # Workarond for Vagrant bug
    if QA_VAGRANT_VERSION == "1.8.7" || QA_VAGRANT_VERSION == "1.9.0" || QA_VAGRANT_VERSION == "1.9.1"
      v.vm.provision :shell, :inline => 'for i in /opt/vagrant/embedded/gems/gems/vagrant-*/plugins/guests/tinycore/guest.rb; do sed -i "s/Core Linux/Core.*Linux/" $i; done'
    end
    # Testing nested VM provisioning via nested kvm 
    v.vm.provision "shell", inline: <<-EOC
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
    v.vm.provision :shell, :inline => 'vagrant destroy -f 2>/dev/null 1>/dev/null;vagrant up --provider=libvirt'
    v.vm.provision :shell, :inline => 'vagrant halt'
  end

  config.vm.define "fedora-26" do |v|
    v.vm.hostname = "fedora-26"
    v.vm.box = "fedora/26-cloud-base"
    v.vm.synced_folder ".", "/vagrant", disabled: true
    v.vm.provider :libvirt do |domain|
      domain.memory = 1024
      domain.cpus = 1
      domain.nested = true
      domain.cpu_mode = 'host-passthrough'
    end
    v.vm.provision :shell, :inline => 'dnf -y update'
    v.vm.provision :shell, :inline => 'dnf -y install qemu libvirt libvirt-devel ruby-devel wget gcc git'
    v.vm.provision :shell, :inline => "wget --no-check-certificate --no-verbose https://releases.hashicorp.com/vagrant/#{QA_VAGRANT_VERSION}/vagrant_#{QA_VAGRANT_VERSION}_x86_64.rpm"
    v.vm.provision :reload
    v.vm.provision :shell, :inline => "rpm -Uvh --force vagrant_#{QA_VAGRANT_VERSION}_x86_64.rpm | sed 's/#//g'"
    if QA_VAGRANT_LIBVIRT_VERSION == "master"
      v.vm.provision :shell, :inline => "git clone https://github.com/vagrant-libvirt/vagrant-libvirt.git"
      v.vm.provision :shell, :inline => "cd vagrant-libvirt && gem build vagrant-libvirt.gemspec"
    end  
    v.vm.provision :shell, :inline => "vagrant plugin install #{QA_VAGRANT_LIBVIRT_INSTALL_OPTS}"
    # Workarond for Vagrant bug
    if QA_VAGRANT_VERSION == "1.8.7" || QA_VAGRANT_VERSION == "1.9.0" || QA_VAGRANT_VERSION == "1.9.1"
      v.vm.provision :shell, :inline => 'for i in /opt/vagrant/embedded/gems/gems/vagrant-*/plugins/guests/tinycore/guest.rb; do sed -i "s/Core Linux/Core.*Linux/" $i; done'
    end
    # Testing nested VM provisioning via nested kvm 
    v.vm.provision "shell", inline: <<-EOC
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
    v.vm.provision :shell, :inline => 'vagrant destroy -f 2>/dev/null 1>/dev/null;vagrant up --provider=libvirt'
    v.vm.provision :shell, :inline => 'vagrant halt'
  end


  config.vm.define "fedora-27" do |v|
    v.vm.hostname = "fedora-27"
    v.vm.box = "fedora/27-cloud-base"
    v.vm.synced_folder ".", "/vagrant", disabled: true
    v.vm.provider :libvirt do |domain|
      domain.memory = 1024
      domain.cpus = 1
      domain.nested = true
      domain.cpu_mode = 'host-passthrough'
    end
    v.vm.provision :shell, :inline => 'dnf -y update'
    v.vm.provision :shell, :inline => 'dnf -y install qemu libvirt libvirt-devel ruby-devel wget gcc git'
    v.vm.provision :shell, :inline => "wget --no-check-certificate --no-verbose https://releases.hashicorp.com/vagrant/#{QA_VAGRANT_VERSION}/vagrant_#{QA_VAGRANT_VERSION}_x86_64.rpm"
    v.vm.provision :reload
    v.vm.provision :shell, :inline => "rpm -Uvh --force vagrant_#{QA_VAGRANT_VERSION}_x86_64.rpm | sed 's/#//g'"
    if QA_VAGRANT_LIBVIRT_VERSION == "master"
      v.vm.provision :shell, :inline => "git clone https://github.com/vagrant-libvirt/vagrant-libvirt.git"
      v.vm.provision :shell, :inline => "cd vagrant-libvirt && gem build vagrant-libvirt.gemspec"
    end  
    v.vm.provision :shell, :inline => "vagrant plugin install #{QA_VAGRANT_LIBVIRT_INSTALL_OPTS}"
    # Workarond for Vagrant bug
    if QA_VAGRANT_VERSION == "1.8.7" || QA_VAGRANT_VERSION == "1.9.0" || QA_VAGRANT_VERSION == "1.9.1"
      v.vm.provision :shell, :inline => 'for i in /opt/vagrant/embedded/gems/gems/vagrant-*/plugins/guests/tinycore/guest.rb; do sed -i "s/Core Linux/Core.*Linux/" $i; done'
    end
    # Testing nested VM provisioning via nested kvm 
    v.vm.provision "shell", inline: <<-EOC
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
    v.vm.provision :shell, :inline => 'vagrant destroy -f 2>/dev/null 1>/dev/null;vagrant up --provider=libvirt'
    v.vm.provision :shell, :inline => 'vagrant halt'
  end

  config.vm.define "arch" do |v|
    v.vm.hostname = "arch"
    v.vm.box = "archlinux/archlinux"
    v.vm.synced_folder ".", "/vagrant", disabled: true
    v.vm.provider :libvirt do |domain|
      domain.driver = 'kvm'
      domain.memory = 1024
      domain.cpus = 1
      domain.nested = true
      domain.cpu_mode = 'host-passthrough'
    end
    v.vm.provision :shell, :inline => 'pacman -Suyu --noconfirm --noprogressbar'
    v.vm.provision :shell, :inline => 'pacman -S --noconfirm --noprogressbar vagrant git ruby make gcc binutils autoconf automake libxml2 libxslt pkg-config libvirt qemu openbsd-netcat bridge-utils ebtables iptables dnsmasq firewalld'
    v.vm.provision :shell, :inline => 'systemctl enable libvirtd; systemctl start libvirtd; systemctl enable firewalld; systemctl start firewalld'
    v.vm.provision :shell, :inline => 'usermod -G kvm nobody'
    v.vm.provision :reload
    if QA_VAGRANT_LIBVIRT_VERSION == "master"
      v.vm.provision :shell, :inline => "git clone https://github.com/vagrant-libvirt/vagrant-libvirt.git"
      v.vm.provision :shell, :inline => "cd vagrant-libvirt && gem build vagrant-libvirt.gemspec"
    end  
    v.vm.provision :shell, :inline => "vagrant plugin install #{QA_VAGRANT_LIBVIRT_INSTALL_OPTS}"
    # Workarond for Vagrant bug
    if QA_VAGRANT_VERSION == "1.8.7" || QA_VAGRANT_VERSION == "1.9.0" || QA_VAGRANT_VERSION == "1.9.1"
      v.vm.provision :shell, :inline => 'for i in /opt/vagrant/embedded/gems/gems/vagrant-*/plugins/guests/tinycore/guest.rb; do sed -i "s/Core Linux/Core.*Linux/" $i; done'
    end
    # Testing nested VM provisioning via nested kvm 
    v.vm.provision "shell", inline: <<-EOC
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
    v.vm.provision :shell, :inline => 'vagrant destroy -f 2>/dev/null 1>/dev/null;vagrant up --provider=libvirt'
    v.vm.provision :shell, :inline => 'vagrant halt'
  end


end