TOP := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

BUILDDIR = $(TOP)build
MACHINE ?= "dragonboard-410c"

all: core-image


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
	cat ./scripts/local_additions.conf >> $(BUILDDIR)/conf/local.conf
	touch $@
	
core-image: bblayers firmware
	./scripts/make_bbtarget.sh $(BUILDDIR) core-image-minimal

core-image-x11: bblayers firmware
	./scripts/make_bbtarget.sh $(BUILDDIR) core-image-x11
