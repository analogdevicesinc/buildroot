################################################################################
#
# jesd204b_status
#
################################################################################


#JESD204B_STATUS_VERSION = 90cad36a2c09e0fbea9763aca4ae0f72f1677bbc
#JESD204B_STATUS_SITE = https://github.com/analogdevicesinc/jesd-eye-scan-gtk.git
#JESD204B_STATUS_SITE_METHOD = git

JESD204B_STATUS_VERSION = 0.1
JESD204B_STATUS_SITE = $(call github,analogdevicesinc,jesd-eye-scan-gtk,v$(JESD204B_STATUS_VERSION))

JESD204B_STATUS_LICENSE = BSD
JESD204B_STATUS_LICENSE_FILES = LICENSE.txt
JESD204B_STATUS_DEPENDENCIES = ncurses

define JESD204B_STATUS_BUILD_CMDS
	$(TARGET_CC) $(TARGET_CFLAGS) $(TARGET_LDFLAGS) \
		$(@D)/jesd_status.c $(@D)/jesd_common.c -o $(@D)/jesd_status -lncurses
endef

define JESD204B_STATUS_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 755 $(@D)/jesd_status $(TARGET_DIR)/usr/sbin/jesd_status
endef

$(eval $(generic-package))
