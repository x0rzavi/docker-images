#!/usr/bin/env bash

# Exit mechanism
trap "exit" INT
set -e

# Author: https://github.com/x0rzavi
# Description: Build xanmod kernel on gentoo
# Dependencies: 7z, lz4

directory=$(pwd)
deps_setup () {
    env USE="-wxwidgets" emerge app-arch/lz4 app-arch/p7zip --noreplace
    echo -e "\nDEPENDENCY SETUP COMPLETED SUCCESSFULLY\n"
}

package_setup () {
    emerge sys-kernel/xanmod-sources --noreplace
    eselect kernel set 1
    ls -l /usr/src/linux
    echo -e "\nKERNEL PACKAGE SETUP COMPLETED SUCCESSFULLY\n"
}

kernel_prepare () {
    cd /usr/src/linux
    make -j$(nproc) mrproper
    #cp CONFIGS/xanmod/gcc/config .config
    wget -O .config https://raw.githubusercontent.com/x0rzavi/gentoo-bits/main/config-5.16.14-gentoo-x0rzavi
    make -j$(nproc) olddefconfig
    echo -e "\nKERNEL PREPARATION COMPLETED SUCCESSFULLY\n"
}

kernel_build () {
    time make -j$(nproc)
    echo -e "\nKERNEL BUILD COMPLETED SUCCESSFULLY\n"
}

kernel_package () {
    time 7z a -t7z linux.7z /usr/src/linux-*
    echo -e "\nKERNEL PACKING COMPLETED SUCCESSFULLY\n"
}

kernel_tag () {
    version=$(grep 'Linux/x86' /usr/src/linux/.config | sed 's/# Linux\/x86 /Xanmod-/;s/ Kernel Configuration//')
    seconds=$(stat -c '%W' /usr/src/linux/.config)
    tag="$version-$seconds"
    export KERNEL_TAG="$tag"
    echo -e "\nKERNEL TAG WAS SET SUCCESSFULLY\n"
}

deps_setup
package_setup
kernel_prepare
kernel_build
kernel_package
kernel_tag
