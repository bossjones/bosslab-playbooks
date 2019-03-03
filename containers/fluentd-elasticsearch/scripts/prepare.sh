#!/bin/bash
# SOURCE: https://github.com/christiansteier/moodle-docker/blob/591b24642dc5c0988b5512746ecffd45f19f24d5/scripts/prepare.sh
set -e

echo -e "\n[i] Prepare System\n"
# Do not cache apt packages
# https://wiki.ubuntu.com/ReducingDiskFootprint
echo 'Acquire::http {No-Cache=True;};' > /etc/apt/apt.conf.d/no-cache
echo 'Dir::Cache { srcpkgcache ""; pkgcache ""; }' > /etc/apt/apt.conf.d/02nocache
echo 'Acquire::GzipIndexes "true"; Acquire::CompressionTypes::Order:: "gz";' > /etc/apt/apt.conf.d/02compress-indexes

## Temporarily disable dpkg fsync to make building faster.
if [[ ! -e /etc/dpkg/dpkg.cfg.d/docker-apt-speedup ]]; then
	echo force-unsafe-io > /etc/dpkg/dpkg.cfg.d/docker-apt-speedup
fi

## Prevent initramfs updates from trying to run grub and lilo.
## https://journal.paul.querna.org/articles/2013/10/15/docker-ubuntu-on-rackspace/
## http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=594189
export INITRD=no
mkdir -p /etc/container_environment
echo -n no > /etc/container_environment/INITRD

## Fix some issues with APT packages.
## See https://github.com/dotcloud/docker/issues/1024
dpkg-divert --local --rename --add /sbin/initctl
ln -sf /bin/true /sbin/initctl

## Replace the 'ischroot' tool to make it always return true.
## Prevent initscripts updates from breaking /dev/shm.
## https://journal.paul.querna.org/articles/2013/10/15/docker-ubuntu-on-rackspace/
## https://bugs.launchpad.net/launchpad/+bug/974584
dpkg-divert --local --rename --add /usr/bin/ischroot
ln -sf /bin/true /usr/bin/ischroot

## The following security actions are recommended by some security scans.
## https://console.bluemix.net/docs/services/va/va_index.html
sed -i 's/^PASS_MAX_DAYS.*/PASS_MAX_DAYS    90/' /etc/login.defs
sed -i 's/^PASS_MIN_DAYS.*/PASS_MIN_DAYS    1/' /etc/login.defs
sed -i 's/sha512/sha512 minlen=8/' /etc/pam.d/common-password

apt-get update
apt-get upgrade -y -o Dpkg::Options::="--force-confdef"

## Install HTTPS support for APT.
$minimal_apt_get_install apt-transport-https ca-certificates

## Install add-apt-repository
$minimal_apt_get_install software-properties-common

## Upgrade all packages.
apt-get dist-upgrade -y --no-install-recommends

## Fix locale.
$minimal_apt_get_install locales
dpkg-reconfigure locales
locale-gen "en_US.UTF-8"
echo -n en_US.UTF-8 > /etc/container_environment/LANG

exit 0
