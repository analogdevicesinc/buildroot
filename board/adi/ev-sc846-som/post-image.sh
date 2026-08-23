#!/bin/sh
set -e

BOARD_DIR="$(dirname "$0")"

default_dtb="$(sed -n 's/^fdtfile="\?\([^"]*\)"\?/\1/p' \
  "$TARGET_DIR/etc/u-boot-initial-env")"

sed "s/@DEFAULT_DTB@/$default_dtb/" "$BOARD_DIR/kernel.its" \
  > "$BINARIES_DIR/kernel.its"
(cd "$BINARIES_DIR" && "$HOST_DIR/bin/mkimage" -f kernel.its kernel.itb)
ln -sf kernel.itb "$BINARIES_DIR/fitImage"

# Assemble boot partition contents
install -d "$BINARIES_DIR/boot"
for f in Image sc846-som-ezkit.dtb fitImage; do
  install -m 0644 "$BINARIES_DIR/$f" "$BINARIES_DIR/boot/"
done

# GDB script to load the two U-Boot stages over JTAG
install -m 0644 "$BOARD_DIR/../u-boot.gdb" "$BINARIES_DIR/u-boot.gdb"

# TODO(KT): Workaround for https://github.com/analogdevicesinc/linux/issues/3400
gzip -f -k "${BINARIES_DIR}/emmc.img"
