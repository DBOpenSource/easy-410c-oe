# easy-410c-oe
Generate a kernel and system image for the DB410C using
a simple make command:

``` shell
git clone https://github.com/DBOpenSource/easy-410c-oe.git
cd easy-410c-oe
make core-image
```

or to create a rootfs with a graphical UI:

``` shell
make core-image-x11
```

You may then want to make coffee... or breakfast...
or lunch... or potentially all of these depending on the speed of
your machine and your internet connection.


The root image will be located at:

build/tmp-eglibc/deploy/images/dragonboard-410c/core-image-minimal-dragonboard-410c.tar.gz


The kernel image will be located at:

build/tmp-eglibc/deploy/images/dragonboard-410c/Image
