################################################################################
#
# NH7020 IIO FM RADIO MAKE
#
################################################################################

SOFTFM_VERSION = c32bd381935d50b6abe7d8dbf8d42f2847bcd8db
SOFTFM_SITE = https://github.com/gridrf/softfm_nh7020.git
SOFTFM_SITE_METHOD = git
SOFTFM_LICENSE = GPLv2
SOFTFM_LICENSE_FILES = LICENSE
SOFTFM_INSTALL_STAGING = YES
SOFTFM_DEPENDENCIES = libiio

$(eval $(cmake-package))

