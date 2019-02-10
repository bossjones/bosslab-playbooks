#!/usr/bin/env bash

# Change hostname and resize root partition on SD card
# Written by Dany Pinoy

if [[ ! $(whoami) =~ "root" ]]; then
  echo ""
  echo "**********************************"
  echo "*** This should be run as root ***"
  echo "**********************************"
  echo ""
  exit
fi

# if [[ -z $1 || -z $2 ]]; then
#   echo "Usage: rpi_configure.sh scarlett-k8-master-01"
#   exit
# fi

if [[ -z $1 ]]; then
  echo "Usage: rpi_configure.sh scarlett-k8-master-01"
  exit
fi

# For Raspbian Stretch Lite
# wget https://raw.githubusercontent.com/pindanet/Raspberry/master/softap-install.sh

KEYMAP="us"
WIFI_COUNTRY="US"
LOCALE="en_US.UTF-8"
TIMEZONE="UTC"
COUNTRY="US"
DOCKER_VERSION="17.12.1"
NEW_HOSTNAME="$1"

mkdir -p /opt/raspberry

# Step 1 doesn't exist
if [ ! -f /opt/raspberry/step1 ]; then

    echo '# This file lists locales that you wish to have built. You can find a list'  | sudo tee /etc/locale.gen
    echo '# of valid supported locales at /usr/share/i18n/SUPPORTED, and you can add'  | sudo tee -a /etc/locale.gen
    echo '# user defined locales to /usr/local/share/i18n/SUPPORTED. If you change'  | sudo tee -a /etc/locale.gen
    echo '# this file, you need to rerun locale-gen.'  | sudo tee -a /etc/locale.gen
    echo '#'  | sudo tee -a /etc/locale.gen
    echo "${LOCALE} UTF-8"  | sudo tee -a /etc/locale.gen

    # sudo sed 's/#\sen_GB\.UTF-8\sUTF-8/en_GB\.UTF-8 UTF-8/g' /etc/locale.gen | sudo tee /tmp/locale && sudo cat /tmp/locale | sudo tee /etc/locale.gen && sudo rm -f /tmp/locale
    # sudo sed 's/#\sja_JP\.EUC-JP\sEUC-JP/ja_JP\.EUC-JP EUC-JP/g' /etc/locale.gen  | sudo tee /tmp/locale && sudo cat /tmp/locale | sudo tee /etc/locale.gen && sudo rm -f /tmp/locale
    # sudo sed 's/#\sja_JP\.UTF-8\sUTF-8/ja_JP\.UTF-8 UTF-8/g' /etc/locale.gen  | sudo tee /tmp/locale && sudo cat /tmp/locale | sudo tee /etc/locale.gen && sudo rm -f /tmp/locale
    sudo locale-gen ${LOCALE}
    sudo update-locale LANG=${LOCALE}

    cat <<EOF >/boot/config.txt
# ----------------------------------------------------------------------------------------
# /boot/config.txt
# ----------------------------------------------------------------------------------------
# For more options and information see
# http://rpf.io/configtxt
# Some settings may impact device functionality. See link above for details

# uncomment if you get no picture on HDMI for a default "safe" mode
#hdmi_safe=1

# uncomment this if your display has a black border of unused pixels visible
# and your display can output without overscan
#disable_overscan=1

# uncomment the following to adjust overscan. Use positive numbers if console
# goes off screen, and negative if there is too much border
#overscan_left=16
#overscan_right=16
#overscan_top=16
#overscan_bottom=16

# uncomment to force a console size. By default it will be display's size minus
# overscan.
#framebuffer_width=1280
#framebuffer_height=720

# uncomment if hdmi display is not detected and composite is being output
#hdmi_force_hotplug=1

# uncomment to force a specific HDMI mode (this will force VGA)
#hdmi_group=1
#hdmi_mode=1

# uncomment to force a HDMI mode rather than DVI. This can make audio work in
# DMT (computer monitor) modes
#hdmi_drive=2

# uncomment to increase signal to HDMI, if you have interference, blanking, or
# no display
#config_hdmi_boost=4

# uncomment for composite PAL
#sdtv_mode=2

#uncomment to overclock the arm. 700 MHz is the default.
#arm_freq=800

# Uncomment some or all of these to enable the optional hardware interfaces
#dtparam=i2c_arm=on
#dtparam=i2s=on
#dtparam=spi=on

# Uncomment this to enable the lirc-rpi module
#dtoverlay=lirc-rpi

# Additional overlays and parameters are documented /boot/overlays/README

# Enable audio (loads snd_bcm2835)
dtparam=audio=on

EOF


    echo Adding " cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory" to /boot/cmdline.txt

    sudo cp /boot/cmdline.txt /boot/cmdline_backup.txt
    orig="$(head -n1 /boot/cmdline.txt) cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory"
    echo $orig | sudo tee /boot/cmdline.txt

    # echo "Do anything in raspi-config that's non-interactive when possible"
    # echo "Enable ssh, set wifi country, set keyboard, and set timezone"
    # # https://raspberrypi.stackexchange.com/a/66939
    # # https://github.com/RPi-Distro/raspi-config/blob/master/raspi-config
    # sudo raspi-config nonint do_ssh 0
    # sudo raspi-config nonint do_wifi_country "US"
    # sudo raspi-config nonint do_configure_keyboard "us"
    # sudo raspi-config nonint do_change_timezone "US/Central"

    # Change Keyboard
    sudo raspi-config nonint do_configure_keyboard "$KEYMAP"

    # Change locale
    sudo raspi-config nonint do_change_locale "$LOCALE"

    # Change timezone
    sudo raspi-config nonint do_change_timezone "$TIMEZONE"

    # Change WiFi country
    sudo raspi-config nonint do_wifi_country "$COUNTRY"

    # Change hostname
    sudo raspi-config nonint do_hostname "$NEW_HOSTNAME"

    # Expand root filesystem
    sudo raspi-config nonint do_expand_rootfs

    # enable vnc
    sudo raspi-config nonint do_vnc 0

    # Change password
    # sudo raspi-config nonint do_change_pass

    # enable ssh
    sudo raspi-config nonint do_ssh 0

    # Upgrade
    sudo apt update
    # sudo apt dist-upgrade -y
    sudo apt-get -y install ttf-kochi-gothic fonts-noto uim uim-mozc nodejs npm apache2 vim emacs libnss3-tools
    # インストール失敗しやすいので2回
    sudo apt-get -y install ttf-kochi-gothic fonts-noto uim uim-mozc nodejs npm apache2 vim emacs libnss3-tools nfs-common zsh python-minimal python-apt python-six python-pip

    # node.jsのインストール
    sudo npm cache clean
    sudo npm install n -g
    sudo n 10.3.0

    # hostnamectl set-hostname ${NEW_HOSTNAME}

    touch /opt/raspberry/step1

    echo Please reboot

    sudo shutdown -r now

else
    echo "Step1 is already finished"
fi



if [ ! -f /opt/raspberry/step2 ]; then

    apt-get update
    apt-get install -y apt-transport-https ca-certificates curl software-properties-common
    # curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
    curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg | sudo apt-key add -
    #add-apt-repository "deb [arch=armhf] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") $(lsb_release -cs) stable"

    cat <<EOF >/etc/apt/sources.list.d/docker.list
deb [arch=armhf] https://download.docker.com/linux/raspbian $(lsb_release -cs) stable
EOF

    # dry run: get.docker.com
    # Executing docker install script, commit: 4957679
    # apt-get update -qq >/dev/null
    # apt-get install -y -qq apt-transport-https ca-certificates curl >/dev/null
    # curl -fsSL "https://download.docker.com/linux/raspbian/gpg" | apt-key add -qq - >/dev/null
    # echo "deb [arch=armhf] https://download.docker.com/linux/raspbian stretch edge" > /etc/apt/sources.list.d/docker.list
    # apt-get update -qq >/dev/null
    # # WARNING: VERSION pinning is not supported in DRY_RUN
    # apt-get install -y -qq --no-install-recommends docker-ce >/dev/null


    apt-get update && apt-get install -y docker-ce=$(apt-cache madison docker-ce | grep ${DOCKER_VERSION} | head -1 | awk '{print $3}') --allow-downgrades
    # apt-mark hold docker-ce
    echo "docker-ce hold" | sudo dpkg --set-selections

    # run docker commands as vagrant user (sudo not required)
    sudo usermod pi -aG docker

    # install kubeadm
    apt-get install -y apt-transport-https curl

    # curl -sSL get.docker.com | sh && \
    #   sudo usermod pi -aG docker

    sudo dphys-swapfile swapoff && \
    sudo dphys-swapfile uninstall && \
    sudo update-rc.d dphys-swapfile remove

    # curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add - && \
    #   echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list && \
    #   sudo apt-get update -q && \
    #   sudo apt-get install -qy kubeadm


    # curl -sSL get.docker.com | sh && \
    # sudo usermod pi -aG docker
    # newgrp docker

    # sudo dphys-swapfile swapoff && \
    #   sudo dphys-swapfile uninstall && \
    #   sudo update-rc.d dphys-swapfile remove

    curl -L 'https://github.com/openfaas/faas-cli/releases/download/0.8.2/faas-cli-armhf' > /usr/local/bin/faas-cli
    chmod +x /usr/local/bin/faas-cli

    sudo swapon --summary

    sudo apt autoremove -y

    mkdir -p /etc/systemd/system/systemd-journald.service.d
    cat <<EOF >/etc/systemd/system/systemd-journald.service.d/perf.conf
[Journal]
MaxLevelConsole=warning
RateLimitInterval=1s
RateLimitBurst=20000
EOF
    systemctl daemon-reload


    cat <<EOF >/usr/local/bin/retry_download
#!/bin/bash

while ! wget $1 -O $2; do echo "Downloading $1 failed. Retrying in 3s..."; sleep 3; done

EOF
    chmod +x /usr/local/bin/retry_download

    touch /opt/raspberry/step2
    sudo shutdown -r now
else
    echo "Step2 is already finished"
fi


# ENABLE ME
# ENABLE ME
# ENABLE ME
# ENABLE ME
# ENABLE ME
# ENABLE ME
# ENABLE ME
# ENABLE ME
# apt-get update
# apt-get install -y kubelet kubeadm kubectl
# apt-mark hold kubelet kubeadm kubectl

if [ ! -f /opt/raspberry/step3 ]; then

    modprobe ip_vs_wrr
    modprobe ip_vs_rr
    modprobe ip_vs_sh
    modprobe ip_vs
    modprobe nf_conntrack_ipv4
    modprobe bridge
    modprobe br_netfilter

    cat <<EOF >/etc/modules-load.d/k8s_ip_vs.conf
    ip_vs_wrr
    ip_vs_rr
    ip_vs_sh
    ip_vs
    nf_conntrack_ipv4
EOF

    cat <<EOF >/etc/modules-load.d/k8s_bridge.conf
    bridge
EOF

    cat <<EOF >/etc/modules-load.d/k8s_br_netfilter.conf
    br_netfilter
EOF
    # NOTE: https://medium.com/@muhammadtriwibowo/set-permanently-ulimit-n-open-files-in-ubuntu-4d61064429a
    # TODO: Put into playbook
    # 93881
    # echo "93881" | sudo tee /proc/sys/fs/file-max
    # echo "session required pam_limits.so" | sudo tee -a /etc/pam.d/common-session

    # sudo sysctl -w vm.min_free_kbytes=1024000
    # sudo sync; sudo sysctl -w vm.drop_caches=3; sudo sync

    curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
    cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
    deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF

    apt-get update -q
    apt-get install -y kubeadm=1.13.1-00 kubectl=1.13.1-00 kubelet=1.13.1-00



    mkdir -p /etc/systemd/system/docker.service.d
    cat <<EOF >/etc/systemd/system/docker.service.d/perf.conf
[Service]
StandardOutput=journal+console
StandardError=journal+console
Environment="DOCKER_OPTS=--log-driver=json-file --log-opt max-size=50m --log-opt max-file=5"
LimitMEMLOCK=infinity
EOF
    systemctl daemon-reload

    sudo systemctl restart docker

    touch /opt/raspberry/step3
else
    echo "Step3 is already finished"
fi

apt-get install -y build-essential libssl-dev libffi-dev libffi6
# python3-dev
apt-get install -y libzbar-dev libzbar0
ldconfig
pip install ansible==2.5.14


# apt-get install -y make build-essential libssl-dev zlib1g-dev
# apt-get install -y libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm
# apt-get install -y libncurses5-dev libncursesw5-dev xz-utils tk-dev
# apt-get install -y libsecret-1-dev

# curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add - && \
#   echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list && \
#   sudo apt-get update -q && \
#   sudo apt-get install -qy kubeadm

# Webserver
#sudo apt install apache2 php libapache2-mod-php -y
# sudo systemctl restart apache2.service

# sudo wget -O /var/www/html/index.html https://raw.githubusercontent.com/pindanet/Raspberry/master/softap/index.html
# sudo wget -O /var/www/html/pinda.png https://raw.githubusercontent.com/pindanet/Raspberry/master/softap/pinda.png
# sudo wget -O /var/www/html/koffer.png https://raw.githubusercontent.com/pindanet/Raspberry/master/softap/koffer.png
# sudo wget -O /var/www/html/brugge.svg https://raw.githubusercontent.com/pindanet/Raspberry/master/softap/brugge.svg
# sudo wget -O /var/www/html/fileshare.svg https://raw.githubusercontent.com/pindanet/Raspberry/master/softap/fileshare.svg
# sudo wget -O /var/www/html/guest_wifi.svg https://raw.githubusercontent.com/pindanet/Raspberry/master/softap/guest_wifi.svg
# sudo wget -O /var/www/html/system.php https://raw.githubusercontent.com/pindanet/Raspberry/master/softap/system.php

# echo "www-data ALL = NOPASSWD: /sbin/shutdown -h now" | sudo tee -a /etc/sudoers

# # Automount
# echo 'ACTION=="add", KERNEL=="sd*", TAG+="systemd", ENV{SYSTEMD_WANTS}="usbstick-handler@%k"' | sudo tee /etc/udev/rules.d/usbstick.rules
# sudo wget -O /lib/systemd/system/usbstick-handler@.service https://raw.githubusercontent.com/pindanet/Raspberry/master/softap/usbstick-handler
# sudo wget -O /usr/local/bin/automount https://raw.githubusercontent.com/pindanet/Raspberry/master/softap/automount
# sudo chmod +x /usr/local/bin/automount
# sudo apt install exfat-fuse -y

# # Share automounted USB-sticks
# sudo apt install samba samba-common-bin -y
# echo "[Media]" | sudo tee -a /etc/samba/smb.conf
# echo "  comment = SoftAP-Network-Attached Storage" | sudo tee -a /etc/samba/smb.conf
# echo "  path = /media" | sudo tee -a /etc/samba/smb.conf
# echo "  public = yes" | sudo tee -a /etc/samba/smb.conf
# echo "  force user = pi" | sudo tee -a /etc/samba/smb.conf
# sudo systemctl restart smbd.service

# # SoftAP
# sudo apt install hostapd bridge-utils -y
# sudo systemctl stop hostapd

# echo "denyinterfaces wlan0" | sudo tee -a /etc/dhcpcd.conf
# echo "denyinterfaces eth0" | sudo tee -a /etc/dhcpcd.conf
# sudo brctl addbr br0
# sudo brctl addif br0 eth0
# echo "# Bridge setup" | sudo tee -a /etc/network/interfaces
# echo "auto br0" | sudo tee -a /etc/network/interfaces
# echo "iface br0 inet manual" | sudo tee -a /etc/network/interfaces
# echo "bridge_ports eth0 wlan0" | sudo tee -a /etc/network/interfaces

# cat > hostapd.conf <<EOF
# interface=wlan0
# bridge=br0
# #driver=nl80211
# ssid=snt-guest
# country_code=BE
# hw_mode=g
# channel=7
# # Wireless Multimedia Extension/Wi-Fi Multimedia needed for
# # IEEE 802.11n (HT)
# wmm_enabled=1
# # 1 to enable 802.11n
# ieee80211n=1
# ht_capab=[HT20][SHORT-GI-20][DSSS_CK-HT40]
# macaddr_acl=0
# auth_algs=1
# ignore_broadcast_ssid=0
# wpa=2
# wpa_passphrase=snt-guest
# wpa_key_mgmt=WPA-PSK
# wpa_pairwise=TKIP
# rsn_pairwise=CCMP
# EOF
# sudo mv hostapd.conf /etc/hostapd/hostapd.conf

# sudo systemctl disable hostapd
# cat > hostapd.service <<EOF
# [Unit]
# Description=advanced IEEE 802.11 management
# Wants=network-online.target
# After=network.target network-online.target
# [Service]
# ExecStart=/usr/sbin/hostapd  /etc/hostapd/hostapd.conf
# PIDFile=/run/hostapd.pid
# RestartSec=5
# Restart=on-failure
# [Install]
# WantedBy=multi-user.target
# EOF
# sudo mv hostapd.service /etc/systemd/system/
# sudo systemctl daemon-reload
# sudo systemctl enable hostapd.service

#sudo sed -i 's/^#DAEMON_OPTS=""/DAEMON_OPTS="\/etc\/hostapd\/hostapd.conf"/' /etc/default/hostapd

#sudo sed -i '/^#.*net\.ipv4\.ip_forward=/s/^#//' /etc/sysctl.conf
#sudo sed -i '/^#.*net\.ipv6\.conf\.all\.forwarding=/s/^#//' /etc/sysctl.conf

# Restart Raspberry Pi
# sudo shutdown -r now


# # sudo rm /etc/localtime
# # sudo ln -s /usr/share/zoneinfo/US/Pacific /etc/localtime
# # sudo rm /etc/timezone
# # echo "US/Pacific" | sudo tee /etc/timezone


# # Clear manpages and prevent from future installs for space saving
# # From: https://askubuntu.com/questions/129566/remove-documentation-to-save-hard-drive-space/401144#401144
# sudo cp config/man/01_nodoc  /etc/dpkg/dpkg.cfg.d/01_nodoc
# find /usr/share/doc -depth -type f ! -name copyright| sudo xargs rm || true
# find /usr/share/doc -empty|xargs sudo rmdir || true
# sudo rm -rf /usr/share/man/* /usr/share/groff/* /usr/share/info/*
# sudo rm -rf /usr/share/lintian/* /usr/share/linda/* /var/cache/man/*

# # Install additional software

# # Remove unused packages or problematic packages
# ## Bluetooth
# sudo apt-get purge -y bluez \
#   bluez-firmware \
#   pi-bluetooth \
#   samba-common \
#   nfs-common \
#   libnss-mdns

# ## Compilers
# sudo apt-get purge -y gcc \
#   gcc-6 \
#   gdb

# ## Compilers
# sudo apt-get purge -y gcc \
#   gcc-6 \
#   gdb

# #sudo apt-get autoremove --purge
# sudo apt autoremove -y

# sudo apt-get update

# # For TV status
# sudo apt-get -y install \
#   cec-utils

# # For Web Browser
# sudo apt-get -y install \
#   git-core \
#   matchbox \
#   uzbl \
#   x11-xserver-utils \
#   xserver-xorg \
#   x11-utils \
#   x11-common \
#   xinit

# # Configure the hostname
# _HOST=$(cat /proc/sys/kernel/random/uuid | awk -F'-' '{ print $5 }')
# sudo raspi-config nonint do_hostname $_HOST

# # Configure Raspian
# ## Locale and Keyboard
# _LOCALE=en_US.UTF-8
# _LAYOUT=us
# sudo raspi-config nonint do_change_locale $_LOCALE
# sudo raspi-config nonint do_configure_keyboard $_LAYOUT

# ## Timezone
# _TIMEZONE=CST6CDT
# sudo raspi-config nonint do_change_timezone $_TIMEZONE

# ## Fix bug in allowing ssh logins over wireless on Pi Zero W
# sudo rm /etc/ssh/ssh_host_* && sudo dpkg-reconfigure openssh-server
# # Can't just echo the data to sshd_config as it's protected so we copy
# sudo cp config/raspian/sshd_config /etc/ssh/sshd_config
# #sudo raspi-config nonint do_ssh

# ## Wireless Configuration
# # If you're not using the wpa_supplicant.conf on /boot update this
# # Wireless Configuration
# #_COUNTRY=US
# #sudo raspi-config nonint do_wifi_country $_COUNTRY
# #_SSID=__XYZZY__
# #_PASSPHRASE=__xyzzy__
# #sudo raspi-config nonint do_wifi_ssid_passphrase $_SSID
# #sudo raspi-config nonint do_wifi_ssid_passphrase $_PASSPHRASE

# # Boot Behavior - Kiosk mode requires X11 at boot
# export SUDO_USER=pi
# #export _OPTION=B4  # Multi-user auto-login graphical interface
# #sudo raspi-config nonint do_boot_behaviour $_OPTION
# sudo systemctl set-default graphical.target
# sudo ln -fs /etc/systemd/system/autologin@.service /etc/systemd/system/getty.target.wants/getty@tty1.service
# sudo sed /etc/systemd/system/autologin@.service -i -e "s#^ExecStart=-/sbin/agetty --autologin [^[:space:]]*#ExecStart=-/sbin/agetty --autologin $SUDO_USER#"
# sudo sed /etc/X11/Xwrapper.config -i -e "s#allowed_users=console#allowed_users=anybody#"

# # Specific to the kiosk - uzbl web browser and X11 init file
# mkdir -p $HOME/.config/uzbl
# cp config/uzbl/config $HOME/.config/uzbl/
# cp config/X11/xinitrc $HOME/.xinitrc
# sudo cp config/X11/Xwrapper.config /etc/X11/Xwrapper.config

# cat config/pi/profile >> $HOME/.profile
