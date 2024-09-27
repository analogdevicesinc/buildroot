################################################################################
#
# ad936x_ref_cal
#
################################################################################

#AD936X_REF_CAL_VERSION = 7eaf3f65f92b38a6ef6a5f04a84e94a6b24d1bc7
#AD936X_REF_CAL_SITE = https://github.com/analogdevicesinc/plutosdr_scripts.git
#AD936X_REF_CAL_SITE_METHOD = git

AD936X_REF_CAL_VERSION = 0.1
AD936X_REF_CAL_SITE = $(call github,analogdevicesinc,plutosdr_scripts,v$(AD936X_REF_CAL_VERSION))

AD936X_REF_CAL_LICENSE = GPLv2
AD936X_REF_CAL_LICENSE_FILES = LICENSE
AD936X_REF_CAL_DEPENDENCIES = libiio fftw-double

define AD936X_REF_CAL_BUILD_CMDS
	$(TARGET_CC) $(TARGET_CFLAGS) $(TARGET_LDFLAGS) \
		$(@D)/cal_ad9361.c -o $(@D)/ad936x_ref_cal -lm -lpthread -lfftw3 -liio
endef

define AD936X_REF_CAL_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 755 $(@D)/ad936x_ref_cal $(TARGET_DIR)/usr/sbin/ad936x_ref_cal
endef

$(eval $(generic-package))
