#!/bin/bash
#
echo "==================> zeroize storages"
mdadm --zero-superblock --force /dev/sd{b,c,d,e,f}
echo "==================> create raid"
mdadm --create --verbose /dev/md0 -l 6 -n 5 /dev/sd{b,d,c,e,f}
echo "==================> check raid"
cat /proc/mdstat
echo "==================> create partion table"
parted -s /dev/md0 mklabel gpt
echo "==================> create five partions"
parted /dev/md0 mkpart primary ext4 0% 20%
parted /dev/md0 mkpart primary ext4 20% 40%
parted /dev/md0 mkpart primary ext4 40% 60%
parted /dev/md0 mkpart primary ext4 60% 80%
parted /dev/md0 mkpart primary ext4 80% 100%
echo "==================> format "
for i in $(seq 1 5); do sudo mkfs.ext4 /dev/md0p$i; done
echo "==================> create folders for mounting"
mkdir -p /raid/part{1,2,3,4,5}
echo "==================> mounting"
for i in $(seq 1 5); do mount /dev/md0p$i /raid/part$i; done
echo "==================> check partions"
df -Th
