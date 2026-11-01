#!/bin/sh
#
# Check that the generated images fit in their MRAM windows and generate
# the SETOOLS ATOC description next to them.
#
# MRAM layout used by the Alif Linux reference flow:
#   0x80002000  bl32.bin       (TF-A SP_MIN, boots from here)   max 0x0000E000
#   0x80010000  devkit-e8.dtb                                   max 0x00010000
#   0x80020000  xipImage       (Linux executes in place)        max 0x00360000
#   0x80380000  rootfs.cramfs  (CRAMFS_MTD, XIP)                max 0x001FE000
#   0x80580000  start of the Alif (STOC) region
#
# SETOOLS places the ATOC table and the image certificates directly below
# 0x80580000, inside the 2 MiB rootfs window. The rootfs limit leaves
# 8 KiB for that package.

set -e

BOARD_DIR="$(dirname "$0")"

check_size() {
	file="${BINARIES_DIR}/$1"
	limit=$(($2))
	size=$(stat -c %s "${file}")
	if [ "${size}" -gt "${limit}" ]; then
		printf 'ERROR: %s is %d bytes, exceeds its MRAM window of %d bytes\n' \
			"$1" "${size}" "${limit}" >&2
		exit 1
	fi
	printf '%-24s %8d / %8d bytes\n' "$1" "${size}" "${limit}"
}

# The device tree name comes from the kernel configuration.
DTB="$(sed -n 's/^BR2_LINUX_KERNEL_INTREE_DTS_NAME="\(.*\)"$/\1/p' "${BR2_CONFIG}")"
DTB="$(basename "${DTB}").dtb"

check_size bl32.bin       0x0000E000
check_size "${DTB}"       0x00010000
check_size xipImage       0x00360000
check_size rootfs.cramfs  0x001FE000

cp "${BOARD_DIR}/se-device-config.json" \
	"${BINARIES_DIR}/se-device-config.json"
sed "s/@DTB@/${DTB}/" "${BOARD_DIR}/atoc.json.in" \
	> "${BINARIES_DIR}/atoc.json"
