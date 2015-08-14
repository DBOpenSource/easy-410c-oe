# easy-410c-oe

Generate a kernel and system image for the DB410C using
simple make commands.

These instructions require Linaro Ubuntu based release to have been
previously installed on the board. That will set up the required
partitions on the eMMC.

``` shell
git clone https://github.com/DBOpenSource/easy-410c-oe.git
cd easy-410c-oe
make 
```

Follow instructions to download the firmware, then:

```
make 
```

You may then want to make coffee... or breakfast...
or lunch... or potentially all of these depending on the speed of
your machine and your internet connection.


Once the build completes, you can flash the images to the device:

```
make flash-bootimg
make flash-rootfs
```

The DB410C uses Android boot images so there is some conversion required for the
kernel and DTB file and this is handled in the Makefile.


The boot image is located at

./boot-db410c.img


The rootfs image is located at:

build/tmp-eglibc/deploy/images/dragonboard-410c/core-image-minimal-dragonboard-410c.ext4
