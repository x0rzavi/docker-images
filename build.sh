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
    cp CONFIGS/xanmod/gcc/config .config
    patch < $workdir/patches/patch1_localversion.diff
    patch < $workdir/patches/patch2_kernel_comp.diff
    patch < $workdir/patches/patch3_kernel_config.diff
    patch < $workdir/patches/patch4_zen_optimize.diff
    patch < $workdir/patches/patch5_O3_optimize.diff
    patch < $workdir/patches/patch6_bfq_builtin.diff
    patch < $workdir/patches/patch7_btrfs_builtin.diff
    #wget -O .config https://raw.githubusercontent.com/x0rzavi/gentoo-bits/main/config-5.16.14-gentoo-x0rzavi
    make -j$(nproc) olddefconfig
    verbosity "KERNEL PREPARATION COMPLETED SUCCESSFULLY"
}

kernel_build () {
    time make -j$(nproc)
    verbosity "KERNEL BUILD COMPLETED SUCCESSFULLY"
}

kernel_package () {
    time zip -rq linux.zip *
    verbosity "KERNEL PACKING COMPLETED SUCCESSFULLY"
}

kernel_tag () {
    version=$(grep 'Linux/x86' /usr/src/linux/.config | sed 's/# Linux\/x86 /Xanmod-/;s/ Kernel Configuration//')
    seconds=$(stat -c '%X' /usr/src/linux/.config)
    tag="$version-$seconds"
    echo $tag > $workdir/release_tag
    verbosity "KERNEL BUILD RELEASE TAG WAS SET SUCCESSFULLY"
}

kernel_prepare
kernel_build
kernel_package
kernel_tag
