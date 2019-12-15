################################################################################
#
# nh7020 projects
#
################################################################################


IIO_RF_SWAP_VERSION = c9aee0b37463c949224aa6287543f585d1e8eb33
IIO_RF_SWAP_SITE = https://github.com/gridrf/iio_rf_swap.git
IIO_RF_SWAP_SITE_METHOD = git
IIO_RF_SWAP_LICENSE = GPLv2
IIO_RF_SWAP_LICENSE_FILES = LICENSE
IIO_RF_SWAP_DEPENDENCIES = libiio

define IIO_RF_SWAP_BUILD_CMDS
	$(TARGET_CC) $(TARGET_CFLAGS) $(TARGET_LDFLAGS) \
		$(@D)/ad9361-iiostream.c -o $(@D)/iio_rf_swap -lm -lpthread -liio
endef

define IIO_RF_SWAP_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 755 $(@D)/iio_rf_swap $(TARGET_DIR)/usr/sbin/iio_rf_swap
endef

$(eval $(generic-package))
