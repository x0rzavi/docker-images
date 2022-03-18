#!/usr/bin/env bash

# Exit mechanism
trap "exit" INT
set -e

# Author: https://github.com/x0rzavi
# Description: Build xanmod kernel on gentoo
# Dependencies: zip, lz4

workdir=$(pwd)
verbosity () {
    echo -e "\n\n***********************************************"
    echo -e "$1"
    echo -e "***********************************************\n\n"
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
    time zip -r linux.zip /usr/src/linux-*
    verbosity "KERNEL PACKING COMPLETED SUCCESSFULLY"
}

kernel_tag () {
    version=$(grep 'Linux/x86' /usr/src/linux/.config | sed 's/# Linux\/x86 /xanmod-/;s/ Kernel Configuration//')
    seconds=$(stat -c '%x' /usr/src/linux/.config | sed 's/\..*$//;s/ /+/g')
    tag="$version-$seconds"
    echo $tag > $workdir/release_tag
    verbosity "KERNEL BUILD RELEASE TAG WAS SET SUCCESSFULLY"
}

kernel_prepare
kernel_build
kernel_package
kernel_tag
