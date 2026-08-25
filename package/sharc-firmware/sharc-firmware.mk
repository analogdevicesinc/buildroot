################################################################################
#
# sharc-firmware
#
################################################################################

SHARC_FIRMWARE_VERSION = 1.1.0
SHARC_FIRMWARE_SOURCE = sharc-firmware-v$(SHARC_FIRMWARE_VERSION).tar.xz
SHARC_FIRMWARE_SITE = https://github.com/analogdevicesinc/rpmsg-examples/releases/download/v$(SHARC_FIRMWARE_VERSION)
SHARC_FIRMWARE_LICENSE = BSD-4-Clause

define SHARC_FIRMWARE_INSTALL_TARGET_CMDS
	$(MAKE) -C $(@D) DESTDIR=$(TARGET_DIR) install
endef

$(eval $(generic-package))
