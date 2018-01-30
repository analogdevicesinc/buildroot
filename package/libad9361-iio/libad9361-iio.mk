################################################################################
#
# libad9361-iio
#
################################################################################
LIBAD9361_IIO_VERSION = b98b1cd2280d73ced04cb4cf9482b2d2d91e31a2
LIBAD9361_IIO_SITE = https://github.com/analogdevicesinc/libad9361-iio.git
LIBAD9361_IIO_SITE_METHOD = git

LIBAD9361_IIO_INSTALL_STAGING = YES
LIBAD9361_IIO_LICENSE = LGPL-2.1+
LIBAD9361_IIO_LICENSE_FILE = LICENSE
LIBAD9361_IIO_DEPENDENCIES = libiio

$(eval $(cmake-package))
