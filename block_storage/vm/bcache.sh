#!/bin/bash
echo "Install jq"
sudo apt install jq -y
CACHE_DEV=$(lsblk -J | jq --arg SIZE ${cache_size} -r '.blockdevices[] | select(.size == $SIZE+"G") | .name')
echo "Cache disk $CACHE_DEV"
BACK_DEV=$(lsblk -J | jq --arg SIZE ${back_size} -r '.blockdevices[] | select(.size == $SIZE+"G") | .name')
echo "backend disk $BACK_DEV"
sudo -E sgdisk -n 0:0:0 /dev/$CACHE_DEV 
sudo -E sgdisk -n 0:0:0 /dev/$BACK_DEV
CHILD_CACHE_DEV=$(lsblk -J | jq --arg NAME $CACHE_DEV -r '.blockdevices[] | select(.name == $NAME).children | .[0].name')
CHILD_BACK_DEV=$(lsblk -J | jq --arg NAME $BACK_DEV -r '.blockdevices[] | select(.name == $NAME).children | .[0].name')
sudo -E make-bcache -C /dev/$CHILD_CACHE_DEV
sudo -E make-bcache -B /dev/$CHILD_BACK_DEV
CSET_UUID=$(bcache-super-show /dev/$CHILD_CACHE_DEV | grep cset.uuid | grep -oE "[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}") 
until ls /dev/bcache0; do echo bcahce not ready;sudo -E make-bcache -B /dev/$CHILD_BACK_DEV --wipe-bcache;sleep 1; done
sleep 5
sudo -E sh -c "echo $CSET_UUID > /sys/block/bcache0/bcache/attach"
sudo -E sh -c "echo writeback > /sys/block/bcache0/bcache/cache_mode"
sudo -E sh -c "echo 0 > /sys/block/bcache0/bcache/sequential_cutoff"
sudo -E apt update; sudo apt install fio -y