Analog Devices ADSP-SC598 evaluation kit
========================================

The ADSP-SC598 evaluation kit consists of the EV-SC598-SOM and the
EV-SOMCRR-EZKIT carrier board.

The ADSP-SC598 processor includes one 1.2 GHz Cortex-A55 core and two 1 GHz
ADI SHARC DSP cores. ADI supports running baremetal or FreeRTOS applications on
the SHARC cores, which can be loaded from Linux using remoteproc.

Build
=====

  $ make adi_sc598_ezkit_defconfig
  $ make

Output artifacts
----------------

output/images/
├── boot.vfat
├── emmc.img
├── flash.img
├── Image
├── rootfs.ext2
├── rootfs.ext4 -> rootfs.ext2
├── sc598-som-ezkit.dtb
├── u-boot
├── u-boot.ldr
├── u-boot-spl
└── u-boot-spl.ldr

Bootstrap SPI flash
===================

It is possible to bootstrap the evaluation kit with either JTAG or over UART,
but only JTAG is currently documented and tested. The boot ROM does not support
booting from SD cards. Additionally, the appropriate GPIO expanders needs to be
configured to enable the SD card even at later stages.

JTAG
----

Setup the board as follows:

- Connect the EV-SC598-SOM target to a host computer using the USB-C connector
  (P1)
- Connect a ICE-1000 or ICE-2000 debugger to the JTAG debug header (P6)
- Set the rotary switch (S1) to 0

Build and install the ADI fork of OpenOCD:

  $ git clone https://github.com/analogdevicesinc/openocd
  $ cd openocd
  $ ./bootstrap
  $ ./configure
  $ make -j$(nproc)

Run openocd with either ice1000.cfg or ice2000.cfg and adspsc59x_a55.cfg.

  $ src/openocd -f ice1000.cfg \
      -f adspsc59x_a55.cfg \
      --search tcl/ \
      --search tcl/interface/ \
      --search tcl/target/

In a second terminal start a serial program (e.g. minicom) configured for
115200 8N1 and flow control disabled.

In a third terminal cd into buildroot/output/images/ and then load and run the
two U-Boot stages using gdb-multiarch:

  $ gdb-multiarch
  (gdb) load u-boot-spl
  (gdb) c
  ^C
  (gdb) load u-boot
  (gdb) c

In a fourth and final terminal start a web server in buildroot/output/images/
(e.g. python -m http.server).

In the serial program there should be logging output from U-Boot and the U-Boot
prompt.

  => sf probe
  => dhcp
  => wget ${fdt_addr_r} <host-ip-addr>:/flash.img
  => sf update ${fdt_addr_r} 0x0 ${filesize}

Set the rotary switch (S1) to 1 and reset the board.

Hardware design and constraints
===============================

SoftConfig
----------

The SoM and carrier boards include a set of GPIO expanders that control bus
switches to enable and disable peripherals.

- The ADIN-1200 10/100 Ethernet (J21) and USB PHY connector (P7) on the carrier
  board are multiplexed on the same ADSP-SC598 pins, which means that they can
  not be used at the same time, nor is it possible to switch during runtime
- UART0 is routed to a FT232RQ and then USB-C connector (P1) on the SoM. Two
  enable lines to a 4-bit bus switch control the RTS/CTS lines and the
  TX/RX lines. It defaults to disabled on boot.
- The SD controller on the ADSP-SC598 is routed to an eMMC on the SoM and the
  SD card slot on the carrier board. Only one can be used at a time.
- A MCU was added to the carrier board to facilitate debugging, but it is not
  used
- SPI2 and a single chip select are routed to the MCU, 128 MByte Octal SPI
  flash, and a FT422 that is in turn routed to the USB QSPI connector (P2).
  A set of bus switches controls whether the chip select reaches each
  peripheral.

EV-SC598-SOM
------------

Mainline support for the evaluation kit will focus on Rev. E. Rev. D included a
different GPIO expander and smaller SPI NOR flash. The GPIO expander most
critically controls the UART, which means that booting an image on a SoM of the
wrong revision will not print anything.
