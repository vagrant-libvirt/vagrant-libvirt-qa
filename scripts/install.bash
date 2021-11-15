#!/bin/bash

set -eu -o pipefail

DPKG_OPTS=(
    -o Dpkg::Options::="--force-confold"
)
VAGRANT_LIBVIRT_VERSION=${VAGRANT_LIBVIRT_VERSION:-"latest"}

function restart_libvirt() {
    service_name=${1:-libvirtd}
    # it appears there can be issues with libvirt being started before certain
    # packages that are required for create behaviour on first run. Restart to
    # ensure the daemon picks up the latest environment and can create a VM
    # on the first attempt. Otherwise will need to reboot
    sudo systemctl restart ${service_name}
}

function setup_apt() {
    export DEBIAN_FRONTEND=noninteractive
    export DEBCONF_NONINTERACTIVE_SEEN=true

    sudo sed -i "s/# deb-src/deb-src/" /etc/apt/sources.list
    sudo -E apt-get update
    sudo -E apt-get -y "${DPKG_OPTS[@]}" upgrade
    sudo -E apt-get -y build-dep vagrant ruby-libvirt
}

function setup_arch() {
    sudo pacman -Suyu --noconfirm --noprogressbar
    sudo pacman -Rd --nodeps --noconfirm iptables
    # need to remove iptables to allow ebtables to be installed
    sudo pacman -S --needed --noprogressbar --noconfirm  \
        autoconf \
        automake \
        binutils \
        bridge-utils \
        dnsmasq \
        git \
        gcc \
        iptables-nft \
        libvirt \
        libxml2 \
        libxslt \
        make \
        openbsd-netcat \
        pkg-config \
        qemu \
        ruby \
        ;
    sudo systemctl enable --now libvirtd
}

function setup_centos_7() {
    sudo yum -y update
    sudo yum -y install \
        autoconf \
        automake \
        binutils \
        cmake \
        gcc \
        git \
        libguestfs-tools \
        libvirt \
        libvirt-devel \
        make \
        qemu \
        qemu-kvm \
        ruby-devel \
        wget \
        ;
    sudo systemctl restart libvirtd
}

function setup_centos() {
    sudo dnf -y update
    sudo dnf -y install \
        @virt \
        autoconf \
        automake \
        binutils \
        byacc \
        cmake \
        gcc \
        gcc-c++ \
        git \
        make \
        rpm-build \
        ruby-devel \
        wget \
        zlib-devel \
        ;
    sudo systemctl restart libvirtd
}

function setup_debian() {
    setup_apt
    sudo -E apt-get -y "${DPKG_OPTS[@]}" install \
        dnsmasq \
        ebtables \
        git \
        libvirt-clients \
        libvirt-daemon \
        libvirt-daemon-system \
        qemu \
        qemu-system-x86 \
        qemu-utils \
        wget \
        ;
}

function setup_fedora() {
    sudo dnf -y update
    sudo dnf -y install \
        autoconf \
        automake \
        binutils \
        cmake \
        gcc \
        git \
        libguestfs-tools \
        libvirt \
        libvirt-daemon-driver-qemu \
        libvirt-devel \
        make \
        qemu-kvm \
        ruby-devel \
        wget \
        ;
    sudo systemctl restart libvirtd
}

function setup_ubuntu_1804() {
    setup_apt
    sudo -E apt-get -y "${DPKG_OPTS[@]}" install \
        git \
        libvirt-bin \
        qemu \
        wget \
        ;
    restart_libvirt
}

function setup_ubuntu() {
    setup_apt
    sudo -E apt-get -y "${DPKG_OPTS[@]}" install \
        git \
        libvirt-clients \
        libvirt-daemon \
        libvirt-daemon-system \
        qemu \
        qemu-system-x86 \
        qemu-utils \
        wget \
        ;
}

function setup_distro() {
    local distro=${1}
    local version=${2:-}

    if [[ -n "${version}" ]] && [[ $(type -t setup_${distro}_${version} 2>/dev/null) == 'function' ]]
    then
        eval setup_${distro}_${version}
    else
        eval setup_${distro}
    fi
}


function download_vagrant() {
    local version=${1}
    local pkgext=${2}
    local pkg="vagrant_${1}_x86_64.${pkgext}"

    wget --no-verbose https://releases.hashicorp.com/vagrant/${version}/${pkg} -O /tmp/${pkg}.tmp
    mv /tmp/${pkg}.tmp /tmp/${pkg}
}

function install_vagrant_arch() {
    sudo pacman -S --needed --noprogressbar --noconfirm  \
        vagrant
}

function install_vagrant_centos() {
    local version=$1

    download_vagrant ${version} rpm
    sudo -E rpm -Uh --force /tmp/vagrant_${version}_x86_64.rpm
}

function install_vagrant_debian() {
    local version=$1

    download_vagrant ${version} deb
    sudo -E dpkg -i /tmp/vagrant_${version}_x86_64.deb
}

function install_vagrant_fedora() {
    install_vagrant_centos $@
}

function install_vagrant_ubuntu() {
    install_vagrant_debian $@
}

function build_libssh() {
    local dir=${1}

    mkdir -p ${dir}-build
    pushd ${dir}-build
    cmake ../${dir} -DOPENSSL_ROOT_DIR=/opt/vagrant/embedded/
    make
    sudo cp lib/libssh* /opt/vagrant/embedded/lib64
    popd
}

function build_krb5() {
    local dir=${1}

    pushd ${dir}/src
    ./configure
    make
    sudo cp -P lib/crypto/libk5crypto.* /opt/vagrant/embedded/lib64/
    popd
}

function setup_rpm_sources_centos() {
    typeset -n basedir=$1
    pkg="$2"
    rpmname="${3:-${pkg}}"

    [[ ! -d ${pkg} ]] && git clone https://git.centos.org/rpms/${pkg}
    cd ${pkg}
    nvr=$(rpm -q --queryformat "${pkg}-%{version}-%{release}" ${rpmname})
    nv=$(rpm -q --queryformat "${pkg}-%{version}" ${rpmname})
    git checkout $(git tag -l | grep "${nvr}\$" | tail -n1)
    into_srpm.sh -d c8s
    cd BUILD
    tar xf ../SOURCES/${nv}.tar.*z

    basedir=${nv}
}

function patch_vagrant_centos_8() {
    mkdir -p patches
    pushd patches
    [[ ! -d centos-git-common ]] && git clone https://git.centos.org/centos-git-common
    export PATH=$(readlink -f ./centos-git-common):$PATH

    setup_rpm_sources_centos LIBSSH_DIR libssh
    build_libssh ${LIBSSH_DIR}

    setup_rpm_sources_centos KRB5_DIR krb5 krb5-libs
    build_krb5 ${KRB5_DIR}

    popd
}

function setup_rpm_sources_fedora() {
    typeset -n basedir=$1
    pkg="$2"
    rpmname="${3:-${pkg}}"

    nvr=$(rpm -q --queryformat "${pkg}-%{version}-%{release}" ${rpmname})
    nv=$(rpm -q --queryformat "${pkg}-%{version}" ${rpmname})
    mkdir -p ${pkg}
    cd ${pkg}

    [[ ! -e ${nvr}.src.rpm ]] && dnf download --source ${rpmname}
    rpm2cpio ${nvr}.src.rpm | cpio -imdV
    rm -rf ${nv}
    tar xf ${nv}.tar.*z

    basedir=${nv}
}

function patch_vagrant_fedora() {
    mkdir -p patches
    pushd patches

    setup_rpm_sources_fedora LIBSSH_DIR libssh
    build_libssh ${LIBSSH_DIR}

    setup_rpm_sources_fedora KRB5_DIR krb5 krb5-libs
    build_krb5 ${KRB5_DIR}

    popd
}

function install_vagrant() {
    local version=${1}
    local distro=${2}
    local distro_version=${3:-}

    eval install_vagrant_${distro} ${version}

    if [[ -n "${distro_version}" ]] && [[ $(type -t patch_vagrant_${distro}_${distro_version} 2>/dev/null) == 'function' ]]
    then
        echo "running patch_vagrant_${distro}_${distro_version}"
        eval patch_vagrant_${distro}_${distro_version}
    elif [[ $(type -t patch_vagrant_${distro} 2>/dev/null) == 'function' ]]
    then
        echo "running patch_vagrant_${distro}"
        eval patch_vagrant_${distro}
    else
        echo "no patch functions configured for ${distro} ${distro_version}"
    fi
}

function install_vagrant_libvirt() {
    if [[ "${VAGRANT_LIBVIRT_VERSION}" == "master" ]]
    then
        rm -rf build
        mkdir build
        git clone https://github.com/vagrant-libvirt/vagrant-libvirt.git
        cd vagrant-libvirt
        bundle install
        bundle exec rake build
        vagrant plugin install ./pkg/vagrant-libvirt-*.gem
        cd -
    elif [[ "${VAGRANT_LIBVIRT_VERSION}" == "latest" ]]
    then
        vagrant plugin install vagrant-libvirt
    else
        vagrant plugin install vagrant-libvirt --plugin-version ${VAGRANT_LIBVIRT_VERSION}
    fi
}


VAGRANT_VERSION=$1
DISTRO=${DISTRO:-$(awk -F= '/^ID=/{print $2}' /etc/os-release | tr -d '"' | tr '[A-Z]' '[a-z]')}
DISTRO_VERSION=${DISTRO_VERSION:-$(awk -F= '/^VERSION_ID/{print $2}' /etc/os-release | tr -d '"' | tr '[A-Z]' '[a-z]' | tr -d '.')}

setup_distro ${DISTRO} ${DISTRO_VERSION}

install_vagrant ${VAGRANT_VERSION} ${DISTRO} ${DISTRO_VERSION}

install_vagrant_libvirt
