#!/bin/sh
set -e

BOARD_DIR="$(dirname "$0")"

# The first adi/ device tree listed becomes the default FIT configuration
default_dtb="$(sed -n 's/^BR2_LINUX_KERNEL_INTREE_DTS_NAME="adi\/\([^" ]*\).*/\1.dtb/p' \
  "$BR2_CONFIG")"

if [ -z "$default_dtb" ]; then
  echo "Could not read a single adi/ device tree name from $BR2_CONFIG" >&2
  exit 1
fi

sed "s/@DEFAULT_DTB@/$default_dtb/" "$BOARD_DIR/kernel.its" \
  > "$BINARIES_DIR/kernel.its"
(cd "$BINARIES_DIR" && "$HOST_DIR/bin/mkimage" -f kernel.its kernel.itb)

# Assemble boot partition contents
install -d "$BINARIES_DIR/boot"
for f in Image sc598-htol.dtb sc598-som-ezkit.dtb sc598-som-ezlite.dtb; do
  install -m 0644 "$BINARIES_DIR/$f" "$BINARIES_DIR/boot/"
done

# GDB script to load the two U-Boot stages over JTAG
install -m 0644 "$BOARD_DIR/../u-boot.gdb" "$BINARIES_DIR/u-boot.gdb"
