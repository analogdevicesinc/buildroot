################################################################################
#
# adsp-ldr
#
################################################################################

ADSP_LDR_VERSION = 1.0.3
ADSP_LDR_SOURCE = adsp-ldr-v$(ADSP_LDR_VERSION).tar.xz
ADSP_LDR_SITE = https://github.com/analogdevicesinc/adsp-ldr/releases/download/v$(ADSP_LDR_VERSION)
ADSP_LDR_LICENSE = BSD-3-Clause
ADSP_LDR_LICENSE_FILES = LICENSE
HOST_ADSP_LDR_DEPENDENCIES = host-libusb

$(eval $(host-meson-package))
