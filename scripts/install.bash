#!/bin/bash

set -o errexit -o pipefail -o noclobber -o nounset

DPKG_OPTS=(
    -o Dpkg::Options::="--force-confold"
)
VAGRANT_LIBVIRT_VERSION=${VAGRANT_LIBVIRT_VERSION:-"latest"}

function version_compare() {
    [[ $1 == $2 ]] && return 0

    local IFS=.
    local v1=(${1})
    local v2=(${2})
    local i

    for (( i=0; i<${#v1[@]} || i<${#v2[@]}; i++ ))
    do
        if [[ ${v1[i]:-0} -gt ${v2[i]:-0} ]]
        then
            return 1
        elif [[ ${v1[i]:-0} -lt ${v2[i]:-0} ]]
        then
            return 2
        fi
    done

    return 0
}

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
    sudo pacman -Qs 'iptables' | grep "local" | grep "iptables " && sudo pacman -Rd --nodeps --noconfirm iptables
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
        wget \
        ;
    sudo systemctl enable --now libvirtd
}

function setup_centos_7() {
    sudo yum -y update
    sudo yum -y install centos-release-qemu-ev
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
        qemu-kvm-ev \
        ruby-devel \
        wget \
        ;
    restart_libvirt
}

function setup_centos_8() {
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
        libguestfs-tools \
        libvirt \
        libvirt-devel \
        make \
        qemu-kvm \
        rpm-build \
        ruby-devel \
        wget \
        zlib-devel \
        ;
    restart_libvirt
}

function setup_centos() {
    sudo dnf config-manager --set-enabled crb
    sudo dnf -y update
    sudo dnf -y install \
        @virtualization-host-environment \
        autoconf \
        automake \
        binutils \
        byacc \
        cmake \
        gcc \
        gcc-c++ \
        git \
        libguestfs-tools \
        libvirt \
        libvirt-devel \
        make \
        qemu-kvm \
        rpm-build \
        ruby-devel \
        wget \
        zlib-devel \
        ;
    restart_libvirt
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
    restart_libvirt
}

function setup_fedora() {
    sudo dnf -y update
    sudo dnf -y install \
        @virtualization \
        autoconf \
        automake \
        binutils \
        byacc \
        cmake \
        gcc \
        gcc-c++ \
        git \
        libguestfs-tools \
        libvirt-devel \
        make \
        wget \
        zlib-devel \
        ;
    restart_libvirt
}

function setup_opensuse-leap() {
    # perl-XML-XPath is used for getting information from zypper
    # for package details to download the src.rpm's.
    sudo zypper modifyrepo --enable repo-source
    sudo zypper refresh
    # blocks install of libvirt qemu system package
    if rpm -q busybox-gzip 2>/dev/null 2>&1
    then
        sudo zypper remove --no-confirm busybox-gzip
    fi
    sudo zypper install --no-confirm \
        byacc \
        cmake \
        gcc \
        gcc-c++ \
        git \
        libguestfs \
        libssh4 \
        libvirt \
        libvirt-devel \
        make \
        qemu-kvm \
        perl-XML-XPath \
        polkit \
        ruby-devel \
        wget \
        zlib-devel \
        ;
    restart_libvirt
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
    restart_libvirt
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
    local pkgversion=${version}
    local arch="x86_64"
    # package name format for releases < 2.3.0
    local pkg="vagrant_${pkgversion}_${arch}.${pkgext}"

    local version_comparison=0
    version_compare ${version} "2.3.0" || version_comparison=$?

    # for version 2.3.0 (and newer?) the package version is different
    # and debs now use the amd64 arch.
    if [[ ${version_comparison} -le 1 ]]
    then
        # for rpm, deb, and zst the version number now appends '-1'
        pkgversion="${version}-1"
        if [[ "${pkgext}" == "rpm" ]]
        then
            pkg="vagrant-${pkgversion}.${arch}.${pkgext}"
        elif [[ "${pkgext}" == "deb" ]]
        then
            arch="amd64"
            pkg="vagrant_${pkgversion}_${arch}.${pkgext}"
        fi
    fi


    wget --no-verbose https://releases.hashicorp.com/vagrant/${version}/${pkg} -O /tmp/${pkg}.tmp
    mv /tmp/${pkg}.tmp /tmp/${pkg}

    DOWNLOADED_VAGRANT_PKG=${pkg}
}

function install_rake_arch() {
    sudo pacman -S --needed --noprogressbar --noconfirm  \
        ruby-bundler \
        rake
}

function install_rake_centos() {
    sudo yum -y install \
        rubygem-bundler \
        rubygem-rake
}

function install_rake_debian() {
    sudo apt install -y \
        bundler \
        rake
}

function install_rake_fedora() {
    sudo dnf -y install \
        rubygem-rake
}

function install_rake_opensuse-leap() {
    sudo zypper install --no-confirm \
        ruby2.5-rubygem-bundler \
        ruby2.5-rubygem-rake
}

function install_rake_ubuntu() {
    install_rake_debian $@
}

function install_vagrant_arch() {
    sudo pacman -S --needed --noprogressbar --noconfirm  \
        vagrant
}

function install_vagrant_centos() {
    local version=$1

    download_vagrant ${version} rpm
    sudo -E rpm -Uh --force /tmp/${DOWNLOADED_VAGRANT_PKG}
}

function install_vagrant_debian() {
    local version=$1

    download_vagrant ${version} deb
    sudo -E dpkg -i /tmp/${DOWNLOADED_VAGRANT_PKG}
}

function install_vagrant_fedora() {
    install_vagrant_centos $@
}

function install_vagrant_opensuse-leap() {
    local version=$1

    download_vagrant ${version} rpm
    sudo zypper install --allow-unsigned-rpm --no-confirm /tmp/${DOWNLOADED_VAGRANT_PKG}
}

function install_vagrant_ubuntu() {
    install_vagrant_debian $@
}

function build_libssh() {
    local dir=${1}

    mkdir -p ${dir}-build
    pushd ${dir}-build
    cmake ${dir} -DOPENSSL_ROOT_DIR=/opt/vagrant/embedded/
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
    pushd ${pkg}
    nvr=$(rpm -q --queryformat "${pkg}-%{version}-%{release}" ${rpmname} | uniq)
    nv=$(rpm -q --queryformat "${pkg}-%{version}" ${rpmname} | uniq)
    git checkout $(git tag -l | grep "${nvr}\$" | tail -n1)
    into_srpm.sh -d c8s
    pushd BUILD
    tar xf ../SOURCES/${nv}.tar.*z

    basedir=$(realpath ${nv})
    popd
    popd
}

function patch_vagrant_centos_8() {
    mkdir -p patches
    pushd patches
    [[ ! -d centos-git-common ]] && git clone https://git.centos.org/centos-git-common
    export PATH=$(readlink -f ./centos-git-common):$PATH
    chmod a+x ./centos-git-common/*.sh

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

    nvr=$(rpm -q --queryformat "${pkg}-%{version}-%{release}\n" ${rpmname} | uniq)
    nv=$(rpm -q --queryformat "${pkg}-%{version}\n" ${rpmname} | uniq)
    mkdir -p ${pkg}
    pushd ${pkg}

    [[ ! -e ${nvr}.src.rpm ]] && dnf download --source ${rpmname}
    rpm2cpio ${nvr}.src.rpm | cpio -imdV
    rm -rf ${nv}
    tar xf ${nv}.tar.*z

    basedir=$(realpath ${nv})
    popd
}

function patch_vagrant_fedora() {
    mkdir -p patches
    pushd patches

    setup_rpm_sources_fedora KRB5_DIR krb5 krb5-libs
    build_krb5 ${KRB5_DIR}

    setup_rpm_sources_fedora LIBSSH_DIR libssh
    build_libssh ${LIBSSH_DIR}

    popd
}

function setup_rpm_sources_opensuse-leap() {
    typeset -n basedir=$1
    pkg="$2"
    rpmname="${3:-${pkg}}"

    nvr=$(rpm -q --queryformat "${pkg}-%{version}-%{release}\n" ${rpmname} | uniq)
    nv=$(rpm -q --queryformat "${pkg}-%{version}\n" ${rpmname} | uniq)
    mkdir -p ${pkg}
    pushd ${pkg}

    repository=$(zypper --quiet --no-refresh --xmlout search --type srcpackage --match-exact --details ${pkg} | xpath -q -e 'string(//solvable/@repository)')
    url=$(zypper --quiet --xmlout repos | xpath -q -e "//repo[@name='${repository}']/url/text()")

    [[ ! -e ${nvr}.src.rpm ]] && wget ${url}/src/${nvr}.src.rpm
    rpm2cpio ${nvr}.src.rpm | cpio -imdV
    rm -rf ${nv}
    tar xf ${nv}.tar.*z

    basedir=$(realpath ${nv})
    popd
}

function patch_vagrant_opensuse-leap() {
    set -x
    mkdir -p patches
    pushd patches

    setup_rpm_sources_opensuse-leap KRB5_DIR krb5
    build_krb5 ${KRB5_DIR}

    setup_rpm_sources_opensuse-leap LIBSSH_DIR libssh libssh4
    build_libssh ${LIBSSH_DIR}

    popd
}

function install_vagrant() {
    local version=${1}
    local distro=${2}
    local distro_version=${3:-}

    echo "Installing vagrant version '${version}'"

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
    local distro=${1}

    echo "Testing vagrant-libvirt version: '${VAGRANT_LIBVIRT_VERSION}'"
    if [[ "${VAGRANT_LIBVIRT_VERSION:0:4}" == "git-" ]]
    then
        eval install_rake_${distro}
        if [[ ! -d "./vagrant-libvirt" ]]
        then
            git clone https://github.com/vagrant-libvirt/vagrant-libvirt.git
        fi
        pushd vagrant-libvirt
        git checkout ${VAGRANT_LIBVIRT_VERSION#git-}
        rm -rf ./pkg
        rake build
        vagrant plugin install ./pkg/vagrant-libvirt-*.gem
        popd
    elif [[ "${VAGRANT_LIBVIRT_VERSION}" == "latest" ]]
    then
        vagrant plugin install vagrant-libvirt
    else
        vagrant plugin install vagrant-libvirt --plugin-version ${VAGRANT_LIBVIRT_VERSION}
    fi
}


OPTIONS=o
LONGOPTS=vagrant-only,vagrant-version:

# -pass arguments only via   -- "$@"   to separate them correctly
! PARSED=$(getopt --options=$OPTIONS --longoptions=$LONGOPTS --name "$0" -- "$@")
if [[ ${PIPESTATUS[0]} -ne 0 ]]
then
    echo "Invalid options provided"
    exit 2
fi

eval set -- "$PARSED"

VAGRANT_ONLY=0

while true; do
    case "$1" in
        -o|--vagrant-only)
            VAGRANT_ONLY=1
            shift
            ;;
        --vagrant-version)
            VAGRANT_VERSION=$2
            shift 2
            ;;
        --)
            shift
            break
            ;;
        *)
            echo "Programming error"
            exit 3
            ;;
    esac
done

echo "Starting vagrant-libvirt installation script"

DISTRO=${DISTRO:-$(awk -F= '/^ID=/{print $2}' /etc/os-release | tr -d '"' | tr '[A-Z]' '[a-z]')}
DISTRO_VERSION=${DISTRO_VERSION:-$(awk -F= '/^VERSION_ID/{print $2}' /etc/os-release | tr -d '"' | tr '[A-Z]' '[a-z]' | tr -d '.')}

[[ ${VAGRANT_ONLY} -eq 0 ]] && setup_distro ${DISTRO} ${DISTRO_VERSION}

if [[ -z ${VAGRANT_VERSION+x} ]]
then
    VAGRANT_VERSION="$(
        wget -qO - https://checkpoint-api.hashicorp.com/v1/check/vagrant 2>/dev/null | \
            tr ',' '\n' | grep current_version | cut -d: -f2 | tr -d '"'
        )"
fi

install_vagrant ${VAGRANT_VERSION} ${DISTRO} ${DISTRO_VERSION}

[[ ${VAGRANT_ONLY} -eq 0 ]] && install_vagrant_libvirt ${DISTRO}

echo "Finished vagrant-libvirt installation script"
