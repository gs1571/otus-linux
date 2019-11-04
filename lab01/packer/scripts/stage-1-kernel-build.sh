#!/bin/bash

# Install elrepo
# yum install -y http://www.elrepo.org/elrepo-release-7.0-3.el7.elrepo.noarch.rpm
# Install new kernel
# yum --enablerepo elrepo-kernel install kernel-ml -y
# Remove older kernels (Only for demo! Not Production!)
# rm -f /boot/*3.10*

# install required packets
yum install -y ncurses-devel make gcc bc bison flex elfutils-libelf-devel openssl-devel grub2 wget perl
# download and extract sources
cd /usr/src/ 
wget https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.3.8.tar.xz 
tar -xf linux-5.3.8.tar.xz 
cd linux-5.3.8 
# copy config
cp -v /boot/config-3.10.0-957.12.2.el7.x86_64 ./.config
# create config
make olddefconfig
# compile and install kernel
date && make -j20 && sleep 2m && date && make -j20 modules && sleep 2m && date && make modules_install && sleep 2m && date && make install && date
# Update GRUB
grub2-mkconfig -o /boot/grub2/grub.cfg
grub2-set-default 0
echo "Grub update done."
# Reboot VM
shutdown -r now
