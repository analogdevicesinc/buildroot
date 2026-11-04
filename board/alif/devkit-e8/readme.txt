Alif Ensemble DevKit-E8
=======================

This configuration builds a minimal Linux system for the Alif Ensemble
DevKit-E8 (DK-E8). The Ensemble E8 has two Cortex-A32 (AArch32) cores,
5.5 MiB of on-chip MRAM and about 8 MiB of on-chip SRAM available to
Linux. The system executes in place from MRAM: TF-A, the kernel
(xipImage) and the root filesystem (cramfs with XIP) all live in MRAM,
no external storage is used.

Boot chain
==========

The Secure Enclave (SE) ROM boots from the Application Table Of
Contents (ATOC) stored in MRAM. The ATOC starts TF-A on A32 core 0.
TF-A (BL32 / SP_MIN, built with ARM_LINUX_KERNEL_AS_BL33) jumps to the
XIP kernel directly and passes the device tree address in r2. Linux
mounts the cramfs image through the physmap MTD map configured in the
kernel defconfig.

MRAM layout (the kernel defconfig and the TF-A platform code fix the
addresses; bl32.bin is hardcoded in plat/alif/.../platform_def.h):

  Address      Size      Image                      Produced by
  0x80002000   0xE000    bl32.bin                   arm-trusted-firmware
  0x80010000   0x10000   devkit-e8.dtb              linux
  0x80020000   0x360000  xipImage                   linux
  0x80380000   0x200000  rootfs.cramfs              fs/cramfs

The 5.5 MiB of MRAM end at 0x80580000. SETOOLS stores the ATOC table and
the image certificates right below that address, i.e. at the top of the
rootfs window (6624 bytes for the four image entries and the DEVICE entry
in atoc.json). rootfs.cramfs therefore has to stay below
0x1FE000 bytes. board/alif/devkit-e8/post-image.sh
fails the build when an image exceeds its window.

Sources
=======

Linux:  https://github.com/alifsemi/linux_alif (tag APSS-v2.3.0,
        6.12 based, defconfig devkit_e8, DTS
        alif/ensemble/devkit/devkit-e8.dts)
TF-A:   https://github.com/alifsemi/trusted-firmware-a_alif
        (tag APSS-v2.3.0, platform devkit_e7, also used for the E8)

Both are vendor trees, there is no mainline Linux or U-Boot support for
Ensemble yet.

How to build
============

  make alif_devkit_e8_defconfig
  make

Output in output/images/:

  output/images/
  +-- bl32.bin               TF-A SP_MIN
  +-- devkit-e8.dtb          device tree
  +-- xipImage               XIP kernel
  +-- rootfs.cramfs          XIP root filesystem
  +-- atoc.json              ATOC description for SETOOLS
  `-- se-device-config.json  Secure Enclave device configuration for SETOOLS

The ATOC description places every image at the fixed address above
("mramAddress") and marks them unsigned.

The "DEVICE" entry applies se-device-config.json, the device configuration
that the Secure Enclave executes at boot, before the application cores
start. It can configure the firewall, pin mux and clocks, and the board
needs it to boot Linux. The file used here configures the firewall
in "open/flat" mode, see section "Open Firewall configuration" of the Alif
Security Toolkit User Guide (AUGD0005). A customized one can be generated
with the Alif Conductor tool, see chapter "Conductor Tool Flow" of the
same guide.

Flashing
========

Flashing uses the Alif Security Toolkit (SETOOLS), available from
https://alifsemi.com. The toolkit talks to the Secure Enclave over
the SE-UART USB port of the DevKit.

1. Set the boot switch (SW4) to SE mode and connect the SE-UART USB
   port.

2. In the SETOOLS directory, select the device once:

     ./tools-config -p "E8 (AE822FA0E5597LS0) - 5.5 MRAM / 9.75 SRAM" -r A1

3. Copy the images and the ATOC description:

     cp output/images/bl32.bin output/images/devkit-e8.dtb \
        output/images/xipImage output/images/rootfs.cramfs \
        <setools>/build/images/
     cp output/images/atoc.json \
        output/images/se-device-config.json <setools>/build/config/

4. Generate the ATOC package and write it to MRAM:

     ./app-gen-toc -f build/config/atoc.json
     ./app-write-mram -p

5. Set SW4 back to the normal boot position and reset the board.

Serial console
==============

The Linux console is UART2 of the Ensemble, 115200 8N1, available on the
DevKit's second USB-UART port. The kernel command line comes from the
device tree (console=ttyS0).
