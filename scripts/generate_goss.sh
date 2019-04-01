#!/usr/bin/env bash

mkdir -p /etc/goss/goss.d
cd /etc/goss

# 406  cat /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
# 407  cd ~/
# 408  curl -fsSL https://goss.rocks/install | sh
# 409  clear
# 410  goss a file /etc/sysctl.conf
# 411  goss autoadd docker
# 412  goss a file /etc/fstab
# 413  cat /etc/fstab
# 414  man sysctl
# 415  sysctl -n net.bridge.bridge-nf-call-ip6tables
# 416  goss add command 'sysctl -n net.bridge.bridge-nf-call-ip6tables'
# 417  history

# INFO: kernel tuning
sysctl_array=( net.bridge.bridge-nf-call-iptables net.bridge.bridge-nf-call-ip6tables net.ipv4.ip_forward net.ipv4.ip_nonlocal_bind vm.swappiness )

for i in "${sysctl_array[@]}"; do goss add command "sysctl -n ${i}"; done

# INFO: kubelet config
# cat /etc/default/kubelet
# KUBELET_EXTRA_ARGS=--node-ip=192.168.205.10 --authentication-token-webhook=true --authorization-mode=Webhook --read-only-port=10255

for i in $(cat /etc/default/kubelet | sed 's,KUBELET_EXTRA_ARGS=,,g' | tr " " "\n"); do goss add command "grep -- ${i} /etc/default/kubelet | wc -l"; done

# INFO: files exists with correct permissions
files_array=( /etc/default/kubelet /etc/modules-load.d/k8s_ip_vs.conf /etc/modules-load.d/k8s_bridge.conf /etc/modules-load.d/k8s_br_netfilter.conf )

for i in "${files_array[@]}"; do goss add --exclude-attr size file "${i}"; done

# INFO: users
goss a --exclude-attr home --exclude-attr shell user nobody

# INFO: kernel modules
lsmod_array=( ip_vs_wrr ip_vs_rr ip_vs_sh ip_vs nf_conntrack_ipv4 bridge br_netfilter bridge br_netfilter )

for i in "${lsmod_array[@]}"; do goss add command "lsmod | grep -- \"^${i}\" | wc -l"; done

# root@k8s-head:/etc# ls -lta
# total 1100
# drwxr-xr-x   2 root root       4096 Apr  1 00:18 netplan
# drwxr-xr-x  24 root root       4096 Apr  1 00:18 ..
# drwxr-xr-x   3 root root       4096 Mar 31 20:23 default
# drwxr-xr-x 121 root root      12288 Mar 31 17:45 .
# -rw-r--r--   1 root root      53345 Mar 31 17:45 ld.so.cache
# drwxr-xr-x   2 root root       4096 Mar 31 17:45 logrotate.d
# drwxr-xr-x   2 root root       4096 Mar 31 17:45 init.d
# drwxr-xr-x   2 root root       4096 Mar 31 17:45 cron.daily
# drwxr-xr-x   2 root root       4096 Mar 31 17:45 bash_completion.d
# drwxr-xr-x   3 root root       4096 Mar 31 17:45 apport
# drwxr-xr-x   2 root root       4096 Mar 31 17:45 vim
# drwxr-xr-x   2 root root       4096 Mar 31 17:45 rsyslog.d
# drwxr-xr-x   2 root root       4096 Mar 31 17:45 profile.d
# drwxr-xr-x   4 root root       4096 Mar 31 17:45 cloud
# drwxr-xr-x   4 root root       4096 Mar 31 17:45 resolvconf
# -rw-r--r--   1 root root       3688 Mar 31 17:44 mailcap
# drwxr-xr-x   7 root root       4096 Mar 31 17:43 apt
# drwxr-xr-x   9 root root       4096 Mar 31 02:42 apparmor.d
# drwxr-xr-x   2 root root       4096 Mar 13 03:26 alternatives
# drwxr-xr-x   5 root root       4096 Mar 12 18:45 kubernetes
# drwxr-xr-x   2 root root       4096 Mar 12 18:34 pam.d
# drwxr-xr-x   4 root root       4096 Mar 12 18:33 udev
# drwxr-xr-x   5 root root       4096 Mar 12 18:33 systemd
# drwxr-xr-x   2 root root       4096 Mar 12 18:33 modules-load.d
# drwxr-xr-x   2 root root       4096 Mar 12 18:33 sysctl.d
# drwxr-xr-x   4 root root       4096 Mar 12 18:33 security
# -rw-r--r--   1 root root       2225 Mar 12 03:44 sysctl.conf
# drwxr-xr-x   2 root root       4096 Mar  6 19:04 fluent-bit
# drwxr-xr-x   5 root root       4096 Mar  6 18:52 initramfs-tools
# drwxr-xr-x   2 root root       4096 Mar  6 18:52 update-motd.d
# drwxr-xr-x   2 root root       4096 Mar  6 00:40 ssh
# drwxr-xr-x   2 root root       4096 Mar  6 00:40 init
# drwxr-xr-x   2 root root       4096 Mar  4 01:57 gtk-3.0
# drwxr-xr-x   2 root root      12288 Feb 15 09:23 sane.d
# drwxr-xr-x   2 root root       4096 Feb 15 09:23 rc0.d
# drwxr-xr-x   2 root root       4096 Feb 15 09:23 rc1.d
# drwxr-xr-x   2 root root       4096 Feb 15 09:23 rc2.d
# drwxr-xr-x   2 root root       4096 Feb 15 09:23 rc3.d
# drwxr-xr-x   2 root root       4096 Feb 15 09:23 rc4.d
# drwxr-xr-x   2 root root       4096 Feb 15 09:23 rc5.d
# drwxr-xr-x   2 root root       4096 Feb 15 09:23 rc6.d
# drwxr-xr-x   2 root root       4096 Feb 15 09:23 rcS.d
# drwxr-xr-x   3 root root       4096 Feb 15 09:22 lvm
# drwxr-xr-x   2 root root       4096 Feb 15 09:22 dnsmasq.d
# drwxr-xr-x   2 root root       4096 Feb 15 09:22 dnsmasq.d-available
# drwxr-xr-x   2 root root       4096 Feb 15 09:22 cron.weekly
# drwxr-xr-x   3 root root       4096 Feb 15 09:22 update-manager
# drwxr-xr-x   2 root root       4096 Feb 15 09:22 console-setup
# drwxr-xr-x   2 root root       4096 Feb 15 09:22 xml
# drwxr-xr-x   2 root root       4096 Feb 15 09:22 sgml
# drwxr-xr-x   4 root root       4096 Feb 15 09:22 vmware-tools
# drwxr-xr-x   2 root root       4096 Feb 15 09:22 thermald
# drwxr-xr-x   2 root root       4096 Feb 15 09:22 sysstat
# drwxr-xr-x   2 root root       4096 Feb 15 09:22 cron.d
# -rw-r--r--   1 root root        103 Feb 15 09:22 shells
# -rw-r--r--   1 root root        917 Feb 15 09:22 group
# -rw-r-----   1 root shadow      774 Feb 15 09:22 gshadow
# -rw-r-----   1 root shadow     1100 Feb 15 09:22 shadow
# -rw-r--r--   1 root root       1881 Feb 15 09:22 passwd
# -rw-r--r--   1 root root        912 Feb 15 09:22 group-
# -rw-r-----   1 root shadow      769 Feb 15 09:22 gshadow-
# -rw-r--r--   1 root root       1881 Feb 15 09:22 passwd-
# -rw-r-----   1 root shadow     1100 Feb 15 09:22 shadow-
# drwxr-xr-x   2 root root       4096 Feb 15 09:21 pollinate
# drwxr-xr-x   2 root root       4096 Feb 15 09:21 request-key.d
# drwxr-xr-x   2 root root       4096 Feb 15 09:20 insserv.conf.d
# drwxr-xr-x   2 root root       4096 Feb 15 09:20 modprobe.d
# drwxr-xr-x   3 root root       4096 Feb 15 09:20 mysql
# drwxr-xr-x   2 root root       4096 Feb 15 09:20 ld.so.conf.d
# drwxr-xr-x   4 root root       4096 Feb 15 09:20 dkms
# drwxr-xr-x   2 root root       4096 Feb 15 09:20 cryptsetup-initramfs
# drwxr-xr-x   2 root root       4096 Feb 15 09:20 libnl-3
# drwxr-xr-x   2 root root       4096 Feb 15 09:20 byobu
# drwxr-xr-x   2 root root       4096 Feb 15 09:20 at-spi2
# drwxr-xr-x   3 root root       4096 Feb 15 09:20 acpi
# drwxr-xr-x   3 root root       4096 Feb 15 09:20 ufw
# drwxr-xr-x   4 root root       4096 Feb 15 09:20 xdg
# drwxr-x---   2 root root       4096 Feb 15 09:20 sudoers.d
# -rw-r--r--   1 root root        513 Feb 15 09:20 nsswitch.conf
# drwxr-xr-x   3 root root       4096 Feb 15 09:19 apparmor
# drwxr-xr-x   2 root root       4096 Feb 15 09:19 iscsi
# -rw-r--r--   1 root root         66 Feb 15 09:19 popularity-contest.conf
# drwxr-xr-x   2 root root       4096 Feb 15 09:19 groff
# drwxr-xr-x   2 root root       4096 Feb 15 09:19 gtk-2.0
# drwxr-xr-x   6 root root       4096 Feb 15 09:19 X11
# drwxr-xr-x   2 root root       4096 Feb 15 09:18 sensors.d
# drwxr-xr-x   4 root root       4096 Feb 15 09:18 fonts
# lrwxrwxrwx   1 root root         27 Feb 15 09:18 localtime -> /usr/share/zoneinfo/Etc/UTC
# -rw-r--r--   1 root root          8 Feb 15 09:18 timezone
# -rw-r--r--   1 root root       6864 Feb 15 09:18 ca-certificates.conf
# drwxr-xr-x   4 root root       4096 Feb 15 09:18 ssl
# drwxr-xr-x   2 root root       4096 Feb 15 09:18 depmod.d
# drwxr-xr-x   4 root root       4096 Feb 15 09:18 dhcp
# drwxr-xr-x   2 root root       4096 Feb 15 09:18 mdadm
# drwxr-xr-x   4 root root       4096 Feb 15 09:18 iproute2
# drwxr-xr-x   2 root root       4096 Feb 15 09:18 grub.d
# drwxr-xr-x   2 root root       4096 Feb 15 09:18 cron.hourly
# drwxr-xr-x   2 root root       4096 Feb 15 09:18 cron.monthly
# drwxr-xr-x   4 root root       4096 Feb 15 09:18 dpkg
# drwxr-xr-x   2 root root       4096 Feb 15 09:18 ldap
# drwxr-xr-x   2 root root       4096 Feb 15 09:18 newt
# drwxr-xr-x   2 root root       4096 Feb 15 09:18 calendar
# drwxr-xr-x   2 root root       4096 Feb 15 09:18 tmpfiles.d
# drwxr-xr-x   8 root root       4096 Feb 15 09:17 kernel
# drwxr-xr-x   6 root root       4096 Feb 15 09:17 networkd-dispatcher
# drwxr-xr-x   3 root root       4096 Feb 15 09:16 glvnd
# drwxr-xr-x   2 root root       4096 Feb 15 09:16 terminfo
# drwxr-xr-x   2 root root       4096 Feb 15 09:15 python2.7
# drwxr-xr-x   2 root root       4096 Feb 15 09:14 selinux
# drwxr-xr-x   2 root root       4096 Feb 15 09:14 python3.6
# drwxr-xr-x   2 root root       4096 Feb 15 09:14 skel
# -rw-r--r--   1 root root       9555 Feb 15 09:13 locale.gen
# drwxr-xr-x   2 root root       4096 Feb 15 09:05 containerd
# -rw-r--r--   1 root root      14726 Feb  8 22:02 drirc
# -rw-r--r--   1 root root         26 Feb  5 07:32 issue
# -rw-r--r--   1 root root         19 Feb  5 07:32 issue.net
# lrwxrwxrwx   1 root root         21 Feb  5 07:32 os-release -> ../usr/lib/os-release
# -rw-r--r--   1 root root        105 Feb  5 07:32 lsb-release
# -rw-r--r--   1 root root        812 Jan 24 23:11 mke2fs.conf
# drwxr-xr-x   2 root root       4096 Jan 14 11:02 powerline
# -rw-r--r--   1 root root        229 Jan  8 17:31 logrotate.conf
# drwxr-xr-x   7 root netdata    4096 Jan  8 17:30 netdata
# -rw-r--r--   1 root root        224 Jan  7 03:04 idmapd.conf
# -rw-r--r--   1 root root        155 Jan  7 03:04 fstab
# -rw-r--r--   1 root root        289 Jan  4 16:32 hosts
# drwxr-xr-x   3 root root       4096 Jan  3 23:55 emacs
# drwxr-xr-x   4 root root       4096 Jan  3 23:50 lighttpd
# drwxr-xr-x   3 root root       4096 Jan  3 23:50 apache2
# -rw-r--r--   1 root root          2 Jan  3 23:42 motd
# drwxr-xr-x   3 root root       4096 Jan  3 23:34 cni
# -rwxr-xr-x   1 root root        168 Jan  3 23:33 kubeadm_join_cmd.sh
# drwxr-xr-x   2 root root       4096 Jan  3 23:32 python
# -rw-r--r--   1 root root         43 Jan  3 23:32 fstab.29883.2019-01-07@03:04:24~
# drwx------   2 root root       4096 Jan  3 23:32 docker
# -rw-r--r--   1 root root          9 Jan  3 23:30 mailname
# -rw-r--r--   1 root root          9 Jan  3 23:30 hostname
# -rw-r--r--   1 root root         76 Jan  3 23:30 subgid
# -rw-r--r--   1 root root         76 Jan  3 23:30 subuid
# -r--r--r--   1 root root         33 Jan  3 23:30 machine-id
# drwxrwxr-x   2 root landscape  4096 Nov 27 14:24 landscape
# -rw-------   1 root root         56 Nov 27 08:45 subgid-
# -rw-------   1 root root         56 Nov 27 08:45 subuid-
# -rw-r--r--   1 root root        112 Nov 27 08:29 overlayroot.local.conf
# -rw-r--r--   1 root root         34 Nov 27 08:28 ec2_version
# drwxr-xr-x   7 root root       4096 Nov 27 08:28 network
# -rw-r--r--   1 root root       6488 Nov 27 08:27 ca-certificates.conf.dpkg-old
# -rw-r--r--   1 root root        411 Nov 27 08:27 hosts.allow
# -rw-r--r--   1 root root        711 Nov 27 08:27 hosts.deny
# drwxr-xr-x   3 root root       4096 Nov 27 08:27 NetworkManager
# drwxr-xr-x   5 root root       4096 Nov 27 08:27 polkit-1
# drwxr-xr-x   4 root root       4096 Nov 27 08:27 logcheck
# -rw-r--r--   1 root root         54 Nov 27 08:26 crypttab
# drwxr-xr-x   3 root root       4096 Nov 27 08:26 apm
# drwxr-xr-x   3 root root       4096 Nov 27 08:26 gss
# drwxr-xr-x   3 root root       4096 Nov 27 08:26 ca-certificates
# drwxr-xr-x   4 root root       4096 Nov 27 08:26 perl
# drwxr-xr-x   3 root root       4096 Nov 27 08:26 pm
# drwxr-xr-x   4 root root       4096 Nov 27 08:26 dbus-1
# -rw-r--r--   1 root root        110 Nov 27 08:25 kernel-img.conf
# drwxr-xr-x   2 root root       4096 Nov 27 08:25 python3.5
# lrwxrwxrwx   1 root root         19 Nov 27 08:25 mtab -> ../proc/self/mounts
# drwxr-xr-x   2 root root       4096 Nov 27 08:24 python3
# lrwxrwxrwx   1 root root         23 Nov 27 08:24 vtrgb -> /etc/alternatives/vtrgb
# lrwxrwxrwx   1 root root         29 Nov 27 08:24 resolv.conf -> ../run/resolvconf/resolv.conf
# -rw-r--r--   1 root root        195 Nov 27 08:24 modules
# drwxr-xr-x   4 root root       4096 Nov 27 08:24 ppp
# -rw-r--r--   1 root root       3028 Nov 27 08:24 adduser.conf
# -rw-------   1 root root          0 Nov 27 08:24 .pwd.lock
# -rw-r--r--   1 root root         96 Nov 27 08:24 environment
# drwxr-xr-x   2 root root       4096 Nov 27 08:23 opt
# -rw-r--r--   1 root root       6920 Oct  1 17:50 overlayroot.conf
# -rw-r--r--   1 root root        767 Sep  4  2018 netconfig
# -rw-r--r--   1 root root         11 Aug  6  2018 debian_version
# -rw-r--r--   1 root root        581 Aug  6  2018 profile
# -rw-r--r--   1 root root       5174 Aug  4  2018 manpath.config
# -rw-r--r--   1 root root       1317 Jun 28  2018 ethertypes
# -rw-r--r--   1 root root        100 Jun 25  2018 sos.conf
# drwxr-xr-x   2 root root       4096 Jun 20  2018 update-notifier
# drwxr-xr-x   2 root root       4096 May 25  2018 osquery
# -rw-r--r--   1 root root       4942 May  8  2018 wgetrc
# -rw-r--r--   1 root root       2995 Apr 16  2018 locale.alias
# -rw-r--r--   1 root root      31974 Apr  8  2018 matplotlibrc
# -rw-r--r--   1 root root       2319 Apr  4  2018 bash.bashrc
# -rw-r--r--   1 root root        403 Mar  1  2018 updatedb.conf
# -rw-r--r--   1 root root       4861 Feb 22  2018 hdparm.conf
# -rw-r--r--   1 root root       9048 Feb 13  2018 nanorc
# -rw-r--r--   1 root root       1358 Jan 30  2018 rsyslog.conf
# -rw-r--r--   1 root root      10550 Jan 25  2018 login.defs
# -rw-r--r--   1 root root       4141 Jan 25  2018 securetty
# -rw-r--r--   1 root root       2683 Jan 17  2018 sysctl.conf.dpkg-dist
# -rw-r--r--   1 root root        206 Aug  3  2017 idmapd.conf.ucf-dist
# -r--r-----   1 root root        755 Jul  4  2017 sudoers
# -rw-r--r--   1 root root      19183 Dec 26  2016 services
# -rw-r--r--   1 root root      24301 Jul 15  2016 mime.types
# drwxr-xr-x   2 root root       4096 Apr 12  2016 binfmt.d
# -rw-r--r--   1 root root      14867 Apr 12  2016 ltrace.conf
# -rw-r--r--   1 root root        722 Apr  5  2016 crontab
# -rw-rw-r--   1 root root       4597 Mar 16  2016 cczerc
# -rw-r--r--   1 root root       1260 Mar 16  2016 ucf.conf
# -rw-r--r--   1 root root        552 Mar 16  2016 pam.conf
# -rw-r--r--   1 root root       2584 Feb 18  2016 gai.conf
# -rw-r--r--   1 root root        459 Feb  7  2016 sntoprc
# -rw-r--r--   1 root root       1748 Feb  4  2016 inputrc
# -rw-r--r--   1 root root        367 Jan 27  2016 bindresvport.blacklist
# -rw-r--r--   1 root root         34 Jan 27  2016 ld.so.conf
# -rw-r--r--   1 root root        191 Jan 18  2016 libaudit.conf
# -rw-r-----   1 root daemon      144 Jan 14  2016 at.deny
# -rw-r--r--   1 root root       1889 Dec 10  2015 request-key.conf
# -rw-r--r--   1 root root        111 Nov 20  2015 magic
# -rw-r--r--   1 root root        111 Nov 20  2015 magic.mime
# -rw-r--r--   1 root root       2969 Nov 10  2015 debconf.conf
# -rwxr-xr-x   1 root root        268 Nov 10  2015 rmt
# -rw-r--r--   1 root root        449 Oct 30  2015 mailcap.order
# -rw-r--r--   1 root root         92 Oct 22  2015 host.conf
# -rw-r--r--   1 root root        267 Oct 22  2015 legal
# -rw-r--r--   1 root root         91 Oct 22  2015 networks
# -rw-r--r--   1 root root      10368 Oct  2  2015 sensors3.conf
# -rw-r--r--   1 root root         45 Aug 12  2015 bash_completion
# -rw-r--r--   1 root root        477 Jul 19  2015 zsh_command_not_found
# -rw-r--r--   1 root root        604 Jul  2  2015 deluser.conf
# -rw-r--r--   1 root root       3663 Jun  9  2015 screenrc
# -rw-r--r--   1 root root        771 Mar  6  2015 insserv.conf
# -rw-r--r--   1 root root       2932 Oct 25  2014 protocols
# -rw-r--r--   1 root root        887 Oct 25  2014 rpc
# -rw-r--r--   1 root root        280 Jun 20  2014 fuse.conf
# -rw-r--r--   1 root root        389 Oct 10  2012 exports
# root@k8s-head:/etc#
