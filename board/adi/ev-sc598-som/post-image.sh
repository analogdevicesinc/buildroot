#!/bin/sh
set -e

# Locally calculated
hash='91cb667184599d1fc9fee6c3835b3f8d884cf980d4f0104547a9cbe4dca9065f'

tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT

curl -fsSL \
  https://raw.githubusercontent.com/analogdevicesinc/documentation/refs/heads/main/docs/products/adsp/u-boot.gdb \
  -o "$tmp"
echo "$hash  $tmp" | sha256sum -c -
install -m 0644 "$tmp" "$BINARIES_DIR/u-boot.gdb"
