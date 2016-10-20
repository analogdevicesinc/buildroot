#!/bin/sh

file=/sys/kernel/config/usb_gadget/pluto_comp_gadget/functions/mass_storage.0/lun.0/file
firmware=/mnt/pluto.frm
conf=/mnt/config.txt
mtd=/dev/mtdblock3
img=/opt/vfat.img


ini_parser() {
 FILE=$1
 SECTION=$2
 eval `sed -e 's/[[:space:]]*\=[[:space:]]*/=/g' \
    -e 's/[#;\`].*$//' \
    -e 's/[[:space:]]*$//' \
    -e 's/^[[:space:]]*//' \
    -e "s/^\(.*\)=\([^\"']*\)$/\1=\"\2\"/" \
   < $FILE \
    | sed -n -e "/^\[$SECTION\]/,/^\s*\[/{/^[^;].*\=.*/p;}"`
}

reset() {
	killall -9 watchdog
	watchdog -t 1 -T5 /dev/watchdog
	killall -9 watchdog
}

dfu() {
	reboot -f
}

flash_indication_on() {
	echo timer > /sys/class/leds/led0:green/trigger
	echo 40 > /sys/class/leds/led0:green/delay_off
	echo 40 > /sys/class/leds/led0:green/delay_on
}

flash_indication_off() {
	echo heartbeat > /sys/class/leds/led0:green/trigger
}

process_ini() {
	FILE=$1
	md5sum $FILE > /opt/config.md5
	ini_parser $FILE "NETWORK"

	rm -f /mnt/SUCCESS_ENV_UPDATE /mnt/FAILED_INVALID_UBOOT_ENV

	if [ -n "$ipaddr" ] && [ -n "$ipaddr_host" ] && [ -n $netmask ]
	then

		IPADDR=`fw_printenv -n ipaddr`
		IPADDR_HOST=`fw_printenv -n ipaddr_host`
		NETMASK=`fw_printenv -n netmask`

		if [ "$IPADDR" != $ipaddr ] || [ "$IPADDR_HOST" != $ipaddr_host ] || [ "$NETMASK" != $netmask ]
		then
			fw_printenv qspiboot
			if [ $? -eq 0 ]; then
				flash_indication_on
				echo "ipaddr $ipaddr" > /opt/fw_set.tmp
				echo "ipaddr_host  $ipaddr_host" >> /opt/fw_set.tmp
				echo "netmask  $netmask" >> /opt/fw_set.tmp
				fw_setenv -s /opt/fw_set.tmp
				rm /opt/fw_set.tmp
				flash_indication_off
				touch /mnt/SUCCESS_ENV_UPDATE
			else
				touch /mnt/FAILED_INVALID_UBOOT_ENV
			fi
		fi
	fi

	ini_parser $FILE "ACTIONS"

	if [ "$reset" == "1" ]
	then
		reset
	fi

	if [ "$dfu" == "1" ]
	then
		dfu
	fi

}


while [ 1 ]
do
 if [[ -r ${file} ]]
  then
    lun=`cat $file`
    if [ ${#lun} -eq 0 ]
    then
	losetup /dev/loop7 $img -o 512
	mount /dev/loop7 /mnt
	if [[ -s ${firmware} ]]
	then 
		flash_indication_on
		rm -f /mnt/SUCCESS /mnt/FAILED /mnt/FAILED_NO_PLUTO_FRM /mnt/FAILED_FIRMWARE_CHSUM_ERROR
		tail -c 33 ${firmware} > /opt/pluto.md5
		head -c -33 ${firmware} > /opt/pluto.frm
		frm=`md5sum /opt/pluto.frm | cut -d ' ' -f 1`
		md5=`cat /opt/pluto.md5`
		if [ "$frm" = "$md5" ]
		then
			grep -q "ITB PlutoSDR (ADALM-PLUTO)" /opt/pluto.frm && dd if=/opt/pluto.frm of=$mtd bs=64k && touch /mnt/SUCCESS || touch /mnt/FAILED
		else
			touch /mnt/FAILED_FIRMWARE_CHSUM_ERROR
		fi

		rm -f $firmware /opt/pluto.frm /opt/pluto.md5
		sync
	fi	

	md5sum /opt/config.md5 && process_ini $conf

	if [[ -r /mnt/RESET ]]
	then
		reset
	fi

	if [[ -r /mnt/DFU ]]
	then
		dfu
	fi

	umount /mnt
	#losetup -d /dev/loop7
	echo $img > $file
	flash_indication_off
	sleep 1
    fi
fi

sleep 1

done

exit 1
