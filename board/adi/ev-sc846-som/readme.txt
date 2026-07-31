Analog Devices ADSP-SC846 evaluation kit
========================================

The ADSP-SC846 evaluation kit consists of the EV-SC846-SOM and the
EV-SOMCRR2-EZKIT carrier board.

The ADSP-SC846 processor includes two 1.2 GHz Cortex-A55 cores and one 1.2 GHz
ADI SHARC FX core. ADI supports running baremetal or FreeRTOS applications on
the SHARC cores, which can be loaded from Linux using remoteproc.

Build
=====

  $ make adi_sc846_ezkit_defconfig
  $ make

Output artifacts
----------------

output/images/
├── boot
│   ├── fitImage
│   ├── Image
│   └── sc846-som-ezkit.dtb
├── boot.ext4
├── emmc.img
├── fitImage -> kernel.itb
├── flash.img
├── Image
├── kernel.itb
├── kernel.its
├── rootfs.ext2
├── rootfs.ext4 -> rootfs.ext2
├── rootfs.ubi
├── rootfs.ubifs
├── sc846-som-ezkit.dtb
├── u-boot
├── u-boot.gdb
├── u-boot.ldr
├── u-boot-spl
└── u-boot-spl.ldr

Bootstrap SPI flash
===================

It is possible to bootstrap the evaluation kit with either JTAG or over UART,
but only JTAG is currently documented and tested. The boot ROM does not support
booting from SD cards. Additionally, the appropriate GPIO expanders need to be
configured to enable the SD card even at later stages.

JTAG
----

Setup the board as follows:

- Connect the EV-SC846-SOM target to a host computer using the USB-C connector
  (P2) on the SoM
- Connect a ICE-1000 or ICE-2000 debugger to the JTAG debug header (P4) on the
  SoM or connect a host computer to the embedded debugger using the USB-C
  connector (P9) on the carrier board
- Set the rotary switch (S2) to 0 on the SoM

Build and install the ADI fork of OpenOCD:

  $ git clone https://github.com/analogdevicesinc/openocd
  $ cd openocd
  $ ./bootstrap
  $ ./configure
  $ make -j$(nproc)

Run openocd with either ice1000.cfg, ice2000.cfg or adi-dbgagent.cfg and
adspsc84x.cfg:

  $ src/openocd -f adi-dbgagent.cfg \
      -f adspsc84x.cfg \
      --search tcl/ \
      --search tcl/interface/ \
      --search tcl/target/

In a second terminal start a serial program (e.g. minicom) configured for
115200 8N1 and flow control disabled.

In a third terminal cd into buildroot/output/images/ and then load and run the
two U-Boot stages using gdb-multiarch (Debian/Ubuntu) or gdb (RHEL/Fedora):

  $ gdb -x u-boot.gdb

In a fourth and final terminal start a web server in buildroot/output/images/
(e.g. python -m http.server).

In the serial program there should be logging output from U-Boot and the U-Boot
prompt.

  => sf probe
  => dhcp
  => wget ${fdt_addr_r} <host-ip-addr>:/flash.img
  => sf update ${fdt_addr_r} 0x0 ${filesize}

Set the rotary switch (S2) to 1 and reset the board.

Hardware design and constraints
===============================

SoftConfig
----------

The SoM and carrier boards include a set of GPIO expanders that control bus
switches to enable and disable peripherals. A single ADP5587 I2C GPIO expander
(U4) controls the following:

- UART0 is routed to a Silicon Labs CP2102N-GQFN28 USB bridge and then USB-C
  connector (P2) on the SoM. Two enable lines to a 4-bit bus switch control the
  RTS/CTS lines and the TX/RX lines.
- The eMSI controller on the ADSP-SC846 is routed to an eMMC and an SD card
  slot (P6) on the SoM. Only one can be used at a time
- Microchip USB 2.0 PHY reset
