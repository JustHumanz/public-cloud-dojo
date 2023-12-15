### AWS Bcache

IOPS baseline for SSD or General Purpose SSD (gp3) volumes is 16,000 IOPS with 4000 MiB. every 1 GiB in gp3 the iops can increased by 500 but max IOPS is 16.000

SSD Spec :
- 36 GiB
- 16.000 IOPS (500 * 36)
- 1000 MiB (0.25 * 16.000) *in theory it's will be 4000 but aws limit it into 1000 MiB

IOPS on HDD or Optimized HDD volumes have diffrent behaveor since they have IOPS bonus or "Throughput credits and burst performance", the Throughput credits calculated by
```
            40 MiB/s
12.5 TiB × ---------- = 500 MiB/s
             1 TiB
```

HDD Spec :
- 1 TB
- 500 IOPS
- 250 MiB (40 MiB after Throughput credits) 




### Resize bcache
- umount <mount path>
- growpart /dev/nvme1n1 1
- echo 1 > /sys/block/<BACKING DEV PARENT>/<BACKING DEV CHILD>/bcache/stop
- lsblk #make sure bcache0 was missing
- make-bcache -B /dev/<BACKING DEV>
- lsblk #make sure bcache0 was apper
- mount /dev/bcache0 /mnt/<mount path>
- resize2fs /dev/bcache0

Ref:
- https://www.spinics.net/lists/linux-bcache/msg03203.html
