TOP := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

BUILDDIR = $(TOP)build
MACHINE ?= "dragonboard-410c"

all: core-image

get-repos: .repos_fetched
	touch $@

.repos_fetched: openembedded-core openembedded-core/bitbake meta-qualcomm meta-openembedded

openembedded-core:
	[ -d $@ ] || git clone https://github.com/openembedded/oe-core $@

openembedded-core/bitbake: openembedded-core
	[ -d $@ ] || git clone https://github.com/openembedded/bitbake $@

meta-qualcomm: 
	[ -d $@ ] || git clone https://github.com/ndechesne/$@.git

meta-openembedded:	
	[ -d $@ ] || git clone https://github.com/openembedded/$@

meta-android:
	[ -d $@ ] || git clone git://github.com/shr-distribution/meta-smartphone.git $@

update-repos: openembedded-core openembedded-core/bitbake meta-qualcomm meta-openembedded
	cd openembedded-core && git pull
	cd openembedded-core/bitbake && git pull
	cd meta-qualcomm && git pull
	cd meta-openembedded && git pull

firmware: meta-easy-oe/recipes-firmware/files/linux-ubuntu-board-support-package-v1.zip
meta-easy-oe/recipes-firmware/files/linux-ubuntu-board-support-package-v1.zip:
	@echo "Paste the following link in your browser and after accpting the EULA, save the file to $(TOP)$@"
	@echo "   https://developer.qualcomm.com/download/db410c/linux-ubuntu-board-support-package-v1.zip"

.PHONY builddir: $(BUILDDIR)
$(BUILDDIR): .repos_fetched
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
