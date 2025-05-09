################################################################################
#
# PSPi6 drivers
#
################################################################################

PSPI6_VERSION = main
PSPI6_SITE = https://github.com/othermod/PSPi-Version-6/archive/refs/heads
PSPI6_SOURCE = main.tar.gz
PSPI6_SITE_METHOD = git
PSPI6_GIT_SUBMODULES = YES
PSPI6_INSTALL_TARGET = YES

define PSPI6_BUILD_CMDS
	# Nothing to build, just install configs and overlays
	tar -xzf $(DL_DIR)/$(PSPI6_SOURCE) -C $(BUILD_DIR)
    mv $(BUILD_DIR)/PSPi-Version-6-main $(BUILD_DIR)/pspi6
endef

define PSPI6_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0644 $(@D)/rpi/config.txt $(TARGET_DIR)/boot/config.txt
	$(INSTALL) -D -m 0644 $(@D)/rpi/cmdline.txt $(TARGET_DIR)/boot/cmdline.txt
	cp -r $(@D)/rpi/overlays $(TARGET_DIR)/boot/
endef

$(eval $(generic-package))