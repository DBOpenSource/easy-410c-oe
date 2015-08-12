TOP := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

BUILDDIR = $(TOP)build
MACHINE ?= "dragonboard-410c"

all: core-image

# Uncomments lines in scripts/local_addtions.conf to use external toolchain
toolchain: gcc-linaro-aarch64-linux-gnu-4.8-2013.09_linux

downloads/gcc-linaro-4.9-2015.02-3-x86_64_aarch64-linux-gnu.tar.xz:
	mkdir -p downloads
	cd downloads && wget https://releases.linaro.org/15.02/components/toolchain/binaries/aarch64-linux-gnu/gcc-linaro-4.9-2015.02-3-x86_64_aarch64-linux-gnu.tar.xz

gcc-linaro-aarch64-linux-gnu-4.8-2013.09_linux: downloads/gcc-linaro-4.9-2015.02-3-x86_64_aarch64-linux-gnu.tar.xz
	tar xJf @<

.repo:
	repo init -u https://github.com/DBOpenSource/db410c-manifest

.updated: .repo
	repo sync
	touch .updated

update: .repo
	repo sync

firmware: meta-db410c/recipes-firmware/files/linux-ubuntu-board-support-package-v1.zip
meta-db410c/recipes-firmware/files/linux-ubuntu-board-support-package-v1.zip:
	@echo
	@echo "*** YOU NEED TO DOWNLOAD THE FIRMWARE FROM QDN ***"
	@echo "*** Paste the following link in your browser and after accepting the EULA, save the file to:
	@echo "\t$(TOP)$@"
	@echo
	@echo "\thttps://developer.qualcomm.com/download/db410c/linux-ubuntu-board-support-package-v1.zip"
	@echo
	@false

.PHONY builddir: $(BUILDDIR)
$(BUILDDIR): .updated
	mkdir -p $@
	./scripts/init_builddir.sh $@

.PHONY bblayers: $(BUILDDIR) .conf_patched
.conf_patched:
	./scripts/update_bblayers.py $(BUILDDIR)/conf/bblayers.conf $(TOP)
	sed -i 's/^MACHINE .*/MACHINE ?= $(MACHINE)/' $(BUILDDIR)/conf/local.conf
	./scripts/update_local_conf.py $(BUILDDIR)/conf/local.conf $(TOP)
	touch $@
	
core-image: bblayers firmware
	./scripts/make_bbtarget.sh $(BUILDDIR) core-image-minimal

core-image-x11: bblayers firmware
	./scripts/make_bbtarget.sh $(BUILDDIR) core-image-x11
