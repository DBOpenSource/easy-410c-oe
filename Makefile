TOP := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

BUILDDIR = $(TOP)build
MACHINE ?= "dragonboard-410c"

all: boot-db410c.img

# Add skales to the path
PATH:=$(TOP)skales:$(PATH)
TMP=$(TOP)tmp

IMG_DIR=$(TOP)build/tmp-glibc/deploy/images/dragonboard-410c/

# OE Layers are managed via repo
.repo:
	@repo init -u https://github.com/DBOpenSource/db410c-manifest

.updated: .repo
	@repo sync
	@touch .updated

update: .repo
	@repo sync

downloads:
	@mkdir -p $@

# Initrd image
downloads/initrd.img-4.0.0-linaro-lt-qcom: downloads
	@cd downloads && wget http://builds.96boards.org/snapshots/dragonboard410c/linaro/ubuntu/latest/initrd.img-4.0.0-linaro-lt-qcom

firmware: meta-db410c/recipes-firmware/files/linux-ubuntu-board-support-package-v1.zip
meta-db410c/recipes-firmware/files/linux-ubuntu-board-support-package-v1.zip:
	@echo
	@echo "*** YOU NEED TO DOWNLOAD THE FIRMWARE FROM QDN ***"
	@echo "*** Paste the following link in your browser and after accepting the EULA, save the file to:"
	@echo "\t$(TOP)$@"
	@echo
	@echo "\thttps://developer.qualcomm.com/download/db410c/linux-ubuntu-board-support-package-v1.zip"
	@echo
	@echo "Afterward, retry running make"
	@echo
	@false

.PHONY builddir: $(BUILDDIR)
$(BUILDDIR): .updated
	@mkdir -p $@
	@./scripts/init_builddir.sh $@

.PHONY bblayers: $(BUILDDIR) .conf_patched
.conf_patched:
	@./scripts/update_bblayers.py $(BUILDDIR)/conf/bblayers.conf $(TOP)
	@sed -i 's/^MACHINE .*/MACHINE ?= $(MACHINE)/' $(BUILDDIR)/conf/local.conf
	@./scripts/update_local_conf.py $(BUILDDIR)/conf/local.conf $(TOP)
	@touch $@
	
core-image: $(IMG_DIR)/core-image-minimal-dragonboard-410c.ext4
$(IMG_DIR)/core-image-minimal-dragonboard-410c.ext4: bblayers firmware
	@[ -f $@ ] || @./scripts/make_bbtarget.sh $(BUILDDIR) core-image-minimal

core-image-x11: bblayers firmware
	@./scripts/make_bbtarget.sh $(BUILDDIR) core-image-x11

$(IMG_DIR)/Image $(IMG_DIR)/Image-apq8016-sbc.dtb:
	@./scripts/make_bbtarget.sh $(BUILDDIR) linux-dragonboard

$(TMP):
	mkdir -p $@

$(TMP)/dt.img: $(TMP) $(IMG_DIR)/Image-apq8016-sbc.dtb
	cp $(IMG_DIR)/Image-apq8016-sbc.dtb $(TMP)
	dtbTool -o $@ -s 2048 $(TMP)

boot-db410c.img: $(IMG_DIR)/Image downloads/initrd.img-4.0.0-linaro-lt-qcom $(TMP)/dt.img
	mkbootimg --kernel $(IMG_DIR)/Image \
          --ramdisk downloads/initrd.img-4.0.0-linaro-lt-qcom \
          --output boot-db410c.img \
          --dt $(TMP)/dt.img \
          --pagesize 2048 \
          --base 0x80000000 \
          --cmdline "root=/dev/disk/by-partlabel/rootfs rw rootwait console=tty0 console=ttyMSM0,115200n8"
	
flash-bootimg: boot-db410c.img
	sudo fastboot flash boot $<

flash-rootimg: $(IMG_DIR)/core-image-minimal-dragonboard-410c.ext4
	sudo fastboot flash rootfs $<
