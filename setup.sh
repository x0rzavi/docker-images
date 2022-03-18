#!/usr/bin/env bash

# Exit mechanism
trap "exit" INT
set -e

# Author: https://github.com/x0rzavi
# Description: Prepare gentoo for building kernel
# Dependencies: git, eselect-repository

verbosity () {
    echo -e "\n\n***********************************************"
    echo -e "$1"
    echo -e "***********************************************\n\n"
}

locale_setup () {
    sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
    locale-gen &>/dev/null
    eselect locale set en_US.utf8 
    env-update && source /etc/profile
    verbosity "LOCALE SETUP COMPLETED SUCCESSFULLY"
}

repo_setup () {
    #num_cpus=$(nproc)
    num_cpus=8
    echo -e '\nACCEPT_KEYWORDS="~amd64"\nACCEPT_LICENSE="*"' >> /etc/portage/make.conf
    echo -e '\nMAKEOPTS="-j'"$num_cpus"' -l'"$num_cpus"'"\nEMERGE_DEFAULT_OPTS="--jobs='"$num_cpus"' --load-average='"$num_cpus"' --quiet"' >> /etc/portage/make.conf
    echo -e '\nFEATURES="parallel-install parallel-fetch"' >> /etc/portage/make.conf
    mkdir --parents /etc/portage/repos.conf
    cp /usr/share/portage/config/repos.conf /etc/portage/repos.conf/gentoo.conf
    emerge-webrsync
    eselect news read &>/dev/null
    emerge dev-vcs/git app-eselect/eselect-repository --noreplace
    wget -O /etc/portage/repos.conf/gentoo.conf https://raw.githubusercontent.com/x0rzavi/gentoo-bits/main/gentoo.conf
    rm -fr /var/db/repos/gentoo
    eselect repository enable src_prepare-overlay
    emerge --sync
    verbosity "REPO SETUP COMPLETED SUCCESSFULLY"
}

timezone_setup () {
    echo "Asia/Kolkata" > /etc/timezone
    emerge --config sys-libs/timezone-data
    verbosity "TIMEZONE SETUP COMPLETED SUCCESSFULLY"
}

locale_setup
repo_setup
timezone_setup
