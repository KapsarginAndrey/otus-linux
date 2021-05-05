# Инструкции

1.  Если внесли изменения в Vagrantfile, надо выполнить
    >vagrant halt
    >vagrant reload

Если проблема создание дисков:

>vboxmanage list hdds
>vboxmanage closemedium disk e22b1d01-9349-4eb8-a3aa-83635a4608cb --delete

## otus-linux

Используйте этот [Vagrantfile](Vagrantfile) - для тестового стенда.



# создание RAID 10

sudo lshw -short | grep disk

sudo mdadm --zero-superblock --force /dev/sd{b,c,d,e,f,g}

sudo mdadm --create --verbose /dev/md0 --level=10 --raid-devices=6 /dev/sd{b,c,d,e,f,g}

cat /proc/mdstat

# Создаем mdadm.conf

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

