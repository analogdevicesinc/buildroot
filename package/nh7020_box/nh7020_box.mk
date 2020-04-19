################################################################################
#
# nh7020 projects
#
################################################################################


NH7020_BOX_VERSION = a7f070a7e21bfb2e23a833dc692ae259e855f395
NH7020_BOX_SITE = https://github.com/gridrf/rfsom-box-gui.git
NH7020_BOX_SITE_METHOD = git
NH7020_BOX_LICENSE = GPLv2
NH7020_BOX_LICENSE_FILES = LICENSE
NH7020_BOX_DEPENDENCIES = qt5base

define NH7020_BOX_CONFIGURE_CMDS        
	cd $(@D); $(TARGET_MAKE_ENV) $(QT5_QMAKE)
endef

define NH7020_BOX_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D)
        $(TARGET_CC) $(TARGET_CFLAGS) $(TARGET_LDFLAGS) \
		$(@D)/fft-plot/main.c $(@D)/fft-plot/basic_graph.c -D_LARGEFILE_SOURCE -D_LARGEFILE64_SOURCE -D_FILE_OFFSET_BITS=64 -O2 -std=gnu99 -rdynamic -o $(@D)/fft-plot/fft_plot -lm -lfftw3 -liio    
        $(TARGET_CC) $(TARGET_CFLAGS) $(TARGET_LDFLAGS) \
	$(@D)/tun_tap/modemd.c $(@D)/tun_tap/mac.c -std=gnu99 -Wall -pthread -o $(@D)/tun_tap/modemd -lm
        $(TARGET_CC) $(TARGET_CFLAGS) $(TARGET_LDFLAGS) \
	$(@D)/tun_tap/ip_reg.c -std=gnu99 -Wall -D_POSIX_SOURCE -pthread -o $(@D)/tun_tap/ip_reg -lm
        $(TARGET_CC) $(TARGET_CFLAGS) $(TARGET_LDFLAGS) \
	$(@D)/tun_tap/ip_monitor.c -std=gnu99 -Wall -D_POSIX_SOURCE -pthread -o $(@D)/tun_tap/ip_monitor -lm
endef

define NH7020_BOX_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 755 $(@D)/rfsom-box-gui $(TARGET_DIR)/usr/sbin/rfsom-box-gui
	$(INSTALL) -D -m 755 $(@D)/bin/* $(TARGET_DIR)/usr/sbin/
	$(INSTALL) -D -m 755 $(@D)/fft-plot/fft_plot $(TARGET_DIR)/usr/bin/fft_plot
	mkdir -p $(TARGET_DIR)/usr/share/rfsom-box-gui/
	cp -rdpf $(@D)/share/rfsom-box-gui/* $(TARGET_DIR)/usr/share/rfsom-box-gui/
	$(INSTALL) -D -m 0755 $(@D)/tun_tap/modemd $(TARGET_DIR)/usr/sbin
	$(INSTALL) -D -m 0755 $(@D)/tun_tap/ip_reg $(TARGET_DIR)/usr/sbin
	$(INSTALL) -D -m 0755 $(@D)/tun_tap/ip_monitor $(TARGET_DIR)/usr/sbin
	$(INSTALL) -D -m 0777 $(@D)/tun_tap/restart_modem_gui.sh $(TARGET_DIR)/usr/sbin
	$(INSTALL) -D -m 0777 $(@D)/tun_tap/ip_reg_default.sh $(TARGET_DIR)/usr/sbin
	$(INSTALL) -D -m 0444 $(@D)/tun_tap/modem_filter.ftr $(TARGET_DIR)/usr/share/rfsom-box-gui
endef

$(eval $(generic-package))
