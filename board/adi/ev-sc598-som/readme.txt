Analog Devices ADSP-SC598 evaluation kits
=========================================

The ADSP-SC598 evaluation kits consist of the EV-SC598-SOM and either the
EV-SOMCRR-EZKIT or EV-SOMCRR-EZLITE carrier board. Both configurations target
Rev. E of the EV-SC598-SOM.

The ADSP-SC598 processor includes one 1.2 GHz Cortex-A55 core and two 1 GHz
ADI SHARC DSP cores. ADI supports running baremetal or FreeRTOS applications on
the SHARC cores, which can be loaded from Linux using remoteproc.

Build EZ-KIT
============

  $ make adi_sc598_ezkit_defconfig
  $ make

Build EZ-LITE
=============

  $ make adi_sc598_ezlite_defconfig
  $ make

Output artifacts
----------------

output/images/
├── boot
│   ├── fitImage
│   ├── Image
│   ├── sc598-htol.dtb
│   ├── sc598-som-ezkit.dtb
│   └── sc598-som-ezlite.dtb
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
├── sc598-htol.dtb
├── sc598-som-ezkit.dtb
├── sc598-som-ezlite.dtb
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

- Connect the EV-SC598-SOM target to a host computer using the USB-C connector
  (P1) on the SoM
- Connect a ICE-1000 or ICE-2000 debugger to the JTAG debug header (P6) on the
  SoM or connect a host computer to the embedded debugger using the micro USB
  connector (P2) on the carrier board
- Set the rotary switch (S1) to 0 on the SoM

Build and install the ADI fork of OpenOCD:

  $ git clone https://github.com/analogdevicesinc/openocd
  $ cd openocd
  $ ./bootstrap
  $ ./configure
  $ make -j$(nproc)

Run openocd with either ice1000.cfg, ice2000.cfg or adi-dbgagent.cfg and
adspsc59x_a55.cfg:

  $ src/openocd -f adi-dbgagent.cfg \
      -f adspsc59x_a55.cfg \
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

Set the rotary switch (S1) to 1 and reset the board.

Hardware design and constraints
===============================

The SoM and carrier boards use GPIO expanders to configure peripheral enables,
resets, and shared signal routing.

SoM SoftConfig
--------------

- UART0 is routed to a FT232RQ and then USB-C connector (P1) on the SoM. Two
  enable lines to a 4-bit bus switch control the RTS/CTS lines and the
  TX/RX lines. It defaults to disabled on boot.
- The ADSP-SC598 SD controller is shared by the SoM eMMC and the SD card slot
  on the carrier board. Only one can be used at a time.
- SPI2 connects to the 128 MiB Quad SPI NOR on the SoM.

EZ-KIT SoftConfig
-----------------

- The ADIN-1200 10/100 Ethernet (J21) and USB PHY connector (P7) on the carrier
  board are multiplexed on the same ADSP-SC598 pins, which means that they can
  not be used at the same time, nor is it possible to switch during runtime
- An Octal SPI flash is connected to the OSPI controller and is disabled by
  the default device tree.

EZ-LITE SoftConfig
------------------

- An ADP5588 GPIO expander controls peripheral enable and reset signals.
- The default device tree enables the ADIN1300 Gigabit Ethernet PHY and the
  ADAU1372 audio codec, while keeping the USB SPI and QSPI interfaces disabled.
- The FT422 USB-QSPI interface (P2) is connected to SPI2 through bus switches.
  Its mode jumper selects USB-QSPI master or slave operation.

EV-SC598-SOM
------------

- Mainline support for the evaluation kit focuses on Rev. E.
- Rev. D uses a different GPIO expander and smaller SPI NOR flash.
- The GPIO expander controls UART routing, so booting an image on a SoM of the
  wrong revision may not produce console output.
