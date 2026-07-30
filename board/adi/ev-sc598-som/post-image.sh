#!/bin/sh
set -e

dtb="$(sed -n 's/^BR2_LINUX_KERNEL_INTREE_DTS_NAME="adi\/\([^" ]*\).*/\1.dtb/p' \
  "$BR2_CONFIG")"

if [ -z "$dtb" ]; then
  echo "Could not read a single adi/ device tree name from $BR2_CONFIG" >&2
  exit 1
fi

if [ ! -f "$BINARIES_DIR/$dtb" ]; then
  echo "Device tree $dtb was not built in $BINARIES_DIR" >&2
  exit 1
fi

# TODO(OD): Until we transition to a FIT image we can only support one dtb
ln -fs "$dtb" "$BINARIES_DIR/flash.dtb"

# Locally calculated
hash='91cb667184599d1fc9fee6c3835b3f8d884cf980d4f0104547a9cbe4dca9065f'

tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT

curl -fsSL \
  https://raw.githubusercontent.com/analogdevicesinc/documentation/refs/heads/main/docs/products/adsp/u-boot.gdb \
  -o "$tmp"
echo "$hash  $tmp" | sha256sum -c -
install -m 0644 "$tmp" "$BINARIES_DIR/u-boot.gdb"
