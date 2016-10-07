# -*- mode: ruby -*-
# vi: set ft=ruby :

ENV['VAGRANT_DEFAULT_PROVIDER'] = 'libvirt'

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
      domain.memory = 512
      domain.cpus = 1
      domain.nested = true
      domain.cpu_mode = 'host-passthrough'
    end
    v.vm.provision :shell, :inline => 'sed -i "s/# deb-src/deb-src/" /etc/apt/sources.list'
    v.vm.provision :shell, :inline => 'apt-get update'
    v.vm.provision :shell, :inline => 'apt-get -y dist-upgrade'
    v.vm.provision :shell, :inline => 'apt-get -y build-dep vagrant ruby-libvirt'
    v.vm.provision :shell, :inline => 'apt-get -y install qemu libvirt-bin wget'
    v.vm.provision :reload
    v.vm.provision :shell, :inline => 'wget -q https://releases.hashicorp.com/vagrant/1.8.6/vagrant_1.8.6_x86_64.deb'
    v.vm.provision :shell, :inline => 'dpkg -i vagrant_1.8.6_x86_64.deb'
    v.vm.provision :shell, :inline => 'vagrant plugin install vagrant-libvirt'
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
      domain.memory = 512
      domain.cpus = 1
      domain.nested = true
      domain.cpu_mode = 'host-passthrough'
    end
    v.vm.provision :shell, :inline => 'sed -i "s/# deb-src/deb-src/" /etc/apt/sources.list'
    v.vm.provision :shell, :inline => 'apt-get update'
    v.vm.provision :shell, :inline => 'apt-get -y dist-upgrade'
    v.vm.provision :shell, :inline => 'apt-get -y build-dep vagrant ruby-libvirt'
    v.vm.provision :shell, :inline => 'apt-get -y install qemu libvirt-bin wget'
    v.vm.provision :reload
    v.vm.provision :shell, :inline => 'wget -q https://releases.hashicorp.com/vagrant/1.8.6/vagrant_1.8.6_x86_64.deb'
    v.vm.provision :shell, :inline => 'dpkg -i vagrant_1.8.6_x86_64.deb'
    v.vm.provision :shell, :inline => 'vagrant plugin install vagrant-libvirt'
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
      domain.memory = 512
      domain.cpus = 1
      domain.nested = true
      domain.cpu_mode = 'host-passthrough'
    end
    v.vm.provision :shell, :inline => 'sed -i "s/# deb-src/deb-src/" /etc/apt/sources.list'
    v.vm.provision :shell, :inline => 'apt-get update'
    v.vm.provision :shell, :inline => 'apt-get -y dist-upgrade'
    v.vm.provision :shell, :inline => 'apt-get -y build-dep vagrant ruby-libvirt'
    v.vm.provision :shell, :inline => 'apt-get -y install qemu libvirt-bin wget'
    v.vm.provision :reload
    v.vm.provision :shell, :inline => 'wget -q https://releases.hashicorp.com/vagrant/1.8.6/vagrant_1.8.6_x86_64.deb'
    v.vm.provision :shell, :inline => 'dpkg -i vagrant_1.8.6_x86_64.deb'
    v.vm.provision :shell, :inline => 'vagrant plugin install vagrant-libvirt'
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
      domain.memory = 512
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
    v.vm.provision :shell, :inline => 'apt-get update'
    v.vm.provision :shell, :inline => 'apt-get -y dist-upgrade'
    v.vm.provision :shell, :inline => 'apt-get -y build-dep vagrant ruby-libvirt'
    v.vm.provision :shell, :inline => 'apt-get -y install qemu libvirt-bin wget ebtables dnsmasq'
    v.vm.provision :reload
    v.vm.provision :shell, :inline => 'wget -q https://releases.hashicorp.com/vagrant/1.8.6/vagrant_1.8.6_x86_64.deb'
    v.vm.provision :shell, :inline => 'dpkg -i vagrant_1.8.6_x86_64.deb'
    v.vm.provision :shell, :inline => 'vagrant plugin install vagrant-libvirt'
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
      domain.memory = 512
      domain.cpus = 1
      domain.nested = true
      domain.cpu_mode = 'host-passthrough'
    end
    v.vm.provision :shell, :inline => 'yum -y update'
    v.vm.provision :shell, :inline => 'yum -y install qemu libvirt libvirt-devel ruby-devel wget gcc acpid qemu-kvm'
    v.vm.provision :shell, :inline => 'chkconfig --enable acpid; service acpid restart'
    v.vm.provision :reload
    v.vm.provision :shell, :inline => 'wget -q https://releases.hashicorp.com/vagrant/1.8.6/vagrant_1.8.6_x86_64.rpm'
    v.vm.provision :shell, :inline => 'rpm -Uvh --force vagrant_1.8.6_x86_64.rpm | sed "s/#//g"'
    v.vm.provision :shell, :inline => 'vagrant plugin install vagrant-libvirt'
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
      domain.memory = 512
      domain.cpus = 1
      domain.nested = true
      domain.cpu_mode = 'host-passthrough'
    end
    v.vm.provision :shell, :inline => 'yum -y update'
    v.vm.provision :shell, :inline => 'yum -y install qemu libvirt libvirt-devel ruby-devel wget gcc qemu-kvm'
    v.vm.provision :reload
    v.vm.provision :shell, :inline => 'wget -q https://releases.hashicorp.com/vagrant/1.8.6/vagrant_1.8.6_x86_64.rpm'
    v.vm.provision :shell, :inline => 'rpm -Uvh --force vagrant_1.8.6_x86_64.rpm | sed "s/#//g"'
    v.vm.provision :shell, :inline => 'vagrant plugin install vagrant-libvirt'
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


  config.vm.define "fedora-21" do |v|
    v.vm.hostname = "fedora-21"
    v.vm.box = "uvsmtid/fedora-21-server-minimal"
    v.vm.synced_folder ".", "/vagrant", disabled: true
    v.vm.provider :libvirt do |domain|
      domain.memory = 512
      domain.cpus = 1
      domain.nested = true
      domain.cpu_mode = 'host-passthrough'
    end
    v.vm.provision :shell, :inline => 'yum -y update'
    v.vm.provision :shell, :inline => 'yum -y install qemu libvirt libvirt-devel ruby-devel wget gcc'
    v.vm.provision :reload
    v.vm.provision :shell, :inline => 'wget -q https://releases.hashicorp.com/vagrant/1.8.6/vagrant_1.8.6_x86_64.rpm'
    v.vm.provision :shell, :inline => 'rpm -Uvh --force vagrant_1.8.6_x86_64.rpm | sed "s/#//g"'
    v.vm.provision :shell, :inline => 'vagrant plugin install vagrant-libvirt'
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

  config.vm.define "fedora-22" do |v|
    v.vm.hostname = "fedora-22"
    v.vm.box = "rarguello/fedora-22"
    v.vm.synced_folder ".", "/vagrant", disabled: true
    v.vm.provider :libvirt do |domain|
      domain.memory = 512
      domain.cpus = 1
      domain.nested = true
      domain.cpu_mode = 'host-passthrough'
    end
    v.vm.provision :shell, :inline => 'dnf -y update'
    v.vm.provision :shell, :inline => 'dnf -y install qemu libvirt libvirt-devel ruby-devel wget gcc'
    v.vm.provision :reload
    v.vm.provision :shell, :inline => 'wget -q https://releases.hashicorp.com/vagrant/1.8.6/vagrant_1.8.6_x86_64.rpm'
    v.vm.provision :shell, :inline => 'rpm -Uvh --force vagrant_1.8.6_x86_64.rpm | sed "s/#//g"'
    v.vm.provision :shell, :inline => 'vagrant plugin install vagrant-libvirt'
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
    v.vm.box = "fedora/23-cloud-base"
    v.vm.synced_folder ".", "/vagrant", disabled: true
    v.vm.provider :libvirt do |domain|
      domain.memory = 512
      domain.cpus = 1
      domain.nested = true
      domain.cpu_mode = 'host-passthrough'
    end
    v.vm.provision :shell, :inline => 'dnf -y update'
    v.vm.provision :shell, :inline => 'dnf -y install qemu libvirt libvirt-devel ruby-devel wget gcc'
    v.vm.provision :reload
    v.vm.provision :shell, :inline => 'wget -q https://releases.hashicorp.com/vagrant/1.8.6/vagrant_1.8.6_x86_64.rpm'
    v.vm.provision :shell, :inline => 'rpm -Uvh --force vagrant_1.8.6_x86_64.rpm | sed "s/#//g"'
    v.vm.provision :shell, :inline => 'vagrant plugin install vagrant-libvirt'
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
    v.vm.box = "fedora/23-cloud-base"
    v.vm.synced_folder ".", "/vagrant", disabled: true
    v.vm.provider :libvirt do |domain|
      domain.memory = 512
      domain.cpus = 1
      domain.nested = true
      domain.cpu_mode = 'host-passthrough'
    end
    v.vm.provision :shell, :inline => 'dnf -y update'
    v.vm.provision :shell, :inline => 'dnf -y install qemu libvirt libvirt-devel ruby-devel wget gcc'
    v.vm.provision :reload
    v.vm.provision :shell, :inline => 'wget -q https://releases.hashicorp.com/vagrant/1.8.6/vagrant_1.8.6_x86_64.rpm'
    v.vm.provision :shell, :inline => 'rpm -Uvh --force vagrant_1.8.6_x86_64.rpm | sed "s/#//g"'
    v.vm.provision :shell, :inline => 'vagrant plugin install vagrant-libvirt'
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
    v.vm.synced_folder ".", "/vagrant", disabled: true
    v.vm.provider :libvirt do |domain|
      domain.memory = 512
      domain.cpus = 1
      domain.nested = true
      domain.cpu_mode = 'host-passthrough'
    end
# outdated, no more need for release upgrading
#    v.vm.provision :shell, :inline => 'dnf -y upgrade --refresh; exit 0'
#    v.vm.provision :shell, :inline => 'dnf -y install dnf-plugin-system-upgrade; exit 0'
#    v.vm.provision :shell, :inline => 'dnf -y system-upgrade download --releasever=24; exit 0'
#    v.vm.provision :shell, :inline => 'dnf -y system-upgrade reboot; exit 0'
#    # We need to wait a bit here since the above command does a full reboot
#    v.vm.provision "wait-upgrade", type: "local_shell", command: "sleep 4m"
    v.vm.provision :shell, :inline => 'dnf -y update'
    v.vm.provision :shell, :inline => 'dnf -y install qemu libvirt libvirt-devel ruby-devel wget gcc'
    v.vm.provision :shell, :inline => 'wget -q https://releases.hashicorp.com/vagrant/1.8.6/vagrant_1.8.6_x86_64.rpm'
    v.vm.provision :reload
    v.vm.provision :shell, :inline => 'rpm -Uvh --force vagrant_1.8.6_x86_64.rpm | sed "s/#//g"'
    v.vm.provision :shell, :inline => 'vagrant plugin install vagrant-libvirt'
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
    v.vm.provision :shell, :inline => 'vagrant up --provider=libvirt'
  end

  config.vm.define "arch" do |v|
    v.vm.hostname = "arch"
    v.vm.box = "wholebits/arch-64"
    v.vm.synced_folder ".", "/vagrant", disabled: true
    v.vm.provider :libvirt do |domain|
      domain.memory = 512
      domain.cpus = 1
      domain.nested = true
      domain.cpu_mode = 'host-passthrough'
    end
# outdated, no more need for release upgrading
#    v.vm.provision :shell, :inline => 'dnf -y upgrade --refresh; exit 0'
#    v.vm.provision :shell, :inline => 'dnf -y install dnf-plugin-system-upgrade; exit 0'
#    v.vm.provision :shell, :inline => 'dnf -y system-upgrade download --releasever=24; exit 0'
#    v.vm.provision :shell, :inline => 'dnf -y system-upgrade reboot; exit 0'
#    # We need to wait a bit here since the above command does a full reboot
#    v.vm.provision "wait-upgrade", type: "local_shell", command: "sleep 4m"
    v.vm.provision :shell, :inline => 'pacman -Suyu --noconfirm --noprogressbar'
    v.vm.provision :reload
    v.vm.provision :shell, :inline => 'pacman -S --noconfirm --noprogressbar vagrant'
    v.vm.provision :shell, :inline => 'vagrant plugin install vagrant-libvirt'
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
    v.vm.provision :shell, :inline => 'vagrant up --provider=libvirt'
  end


end
