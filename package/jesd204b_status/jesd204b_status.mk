################################################################################
#
# jesd204b_status
#
################################################################################


JESD204B_STATUS_VERSION = 45a0eb36c480f11bc0799991a6663d5ff8fb3936
JESD204B_STATUS_SITE = https://github.com/analogdevicesinc/jesd-eye-scan-gtk.git
JESD204B_STATUS_SITE_METHOD = git
JESD204B_STATUS_LICENSE = BSD
JESD204B_STATUS_LICENSE_FILES = LICENSE
JESD204B_STATUS_DEPENDENCIES = ncurses

define JESD204B_STATUS_BUILD_CMDS
	$(TARGET_CC) $(TARGET_CFLAGS) $(TARGET_LDFLAGS) \
		$(@D)/jesd_status.c $(@D)/jesd_common.c -o $(@D)/jesd_status -lncurses
endef

define JESD204B_STATUS_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 755 $(@D)/jesd_status $(TARGET_DIR)/usr/sbin/jesd_status
endef

$(eval $(generic-package))
