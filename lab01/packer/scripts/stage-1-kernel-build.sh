#!/bin/bash

# Install elrepo
# yum install -y http://www.elrepo.org/elrepo-release-7.0-3.el7.elrepo.noarch.rpm
# Install new kernel
# yum --enablerepo elrepo-kernel install kernel-ml -y
# Remove older kernels (Only for demo! Not Production!)
# rm -f /boot/*3.10*

# install required packets
yum install -y ncurses-devel make gcc bc bison flex elfutils-libelf-devel openssl-devel grub2 wget perl bzip2
# download and extract sources
cd /usr/src/ 
wget https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.3.8.tar.xz 
tar -xf linux-5.3.8.tar.xz 
cd linux-5.3.8 
# copy config
cp -v /boot/config-* .config
# create config
make olddefconfig
# compile and install kernel
date && make -j12 && sleep 1m && date && make -j12 modules && sleep 1m && date && make modules_install && sleep 1m && date && make install && date
# Update GRUB
grub2-mkconfig -o /boot/grub2/grub.cfg
grub2-set-default 0
echo "Grub update done."
sleep 1m 
# Reboot VM
shutdown -r now
echo "Going to reboot"
