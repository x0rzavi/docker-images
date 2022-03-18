#!/usr/bin/env bash

# Exit mechanism
trap "exit" INT
set -e

# Author: https://github.com/x0rzavi
# Description: Build xanmod kernel on gentoo
# Dependencies: 7z, lz4

workdir=$(pwd)
verbosity () {
    echo -e "\n\n***********************************************"
    echo -e "$1"
    echo -e "***********************************************\n\n"
}

deps_setup () {
    env USE="-wxwidgets" emerge app-arch/lz4 app-arch/p7zip --noreplace
    verbosity "DEPENDENCY SETUP COMPLETED SUCCESSFULLY"
}

package_setup () {
    emerge sys-kernel/xanmod-sources --noreplace
    eselect kernel set 1
    ls -l /usr/src/linux
    verbosity "KERNEL PACKAGE SETUP COMPLETED SUCCESSFULLY"
}

kernel_prepare () {
    cd /usr/src/linux
    make -j$(nproc) mrproper
    #cp CONFIGS/xanmod/gcc/config .config
    wget -O .config https://raw.githubusercontent.com/x0rzavi/gentoo-bits/main/config-5.16.14-gentoo-x0rzavi
    make -j$(nproc) olddefconfig
    verbosity "KERNEL PREPARATION COMPLETED SUCCESSFULLY"
}

kernel_build () {
    time make -j$(nproc)
    verbosity "KERNEL BUILD COMPLETED SUCCESSFULLY"
}

kernel_package () {
    time 7z a -t7z linux.7z /usr/src/linux-*
    verbosity "KERNEL PACKING COMPLETED SUCCESSFULLY"
}

kernel_tag () {
    version=$(grep 'Linux/x86' /usr/src/linux/.config | sed 's/# Linux\/x86 /Xanmod-/;s/ Kernel Configuration//')
    seconds=$(stat -c '%W' /usr/src/linux/.config)
    tag="$version-$seconds"
    echo $tag > $workdir/release_tag
    verbosity "KERNEL BUILD RELEASE TAG WAS SET SUCCESSFULLY"
}

deps_setup
package_setup
kernel_prepare
kernel_build
kernel_package
kernel_tag
