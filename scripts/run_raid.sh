#!/usr/bin/env bash
mkdir -p ~root/.ssh
cp ~vagrant/.ssh/auth* ~root/.ssh
yum install -y mdadm smartmontools hdparm gdisk
sudo mdadm --zero-superblock --force /dev/sd{b,c,d,e,f,g}
sudo mdadm --create --verbose /dev/md0 --level=10 --raid-devices=6 /dev/sd{b,c,d,e,f,g}
sudo mkdir /etc/mdadm
sudo echo "DEVICE partitions" > /etc/mdadm/mdadm.conf
sudo mdadm --detail --scan --verbose | awk '/ARRAY/ {print}' >> /etc/mdadm/mdadm.conf
sudo parted -s /dev/md0 mklabel gpt
sudo parted /dev/md0 mkpart primary ext4 0% 20%
sudo parted /dev/md0 mkpart primary ext4 20% 40%
sudo parted /dev/md0 mkpart primary ext4 40% 60%
sudo parted /dev/md0 mkpart primary ext4 60% 80%
sudo parted /dev/md0 mkpart primary ext4 80% 100%
for i in $(seq 1 5); do sudo mkfs.ext4 /dev/md0p$i; done
sudo mkdir -p /raid/part{1,2,3,4,5}
for i in $(seq 1 5); do sudo mount /dev/md0p$i /raid/part$i; done
echo "#NEW DEVICE" >> /etc/fstab
for i in $(seq 1 5); do echo `sudo blkid /dev/md0p$i | awk '{print $2}'` /u0$i ext4 defaults 0 0 >> /etc/fstab; done
sed -i '65s/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
systemctl restart sshd
