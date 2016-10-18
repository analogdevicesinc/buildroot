#!/bin/sh

file=/sys/kernel/config/usb_gadget/pluto_comp_gadget/functions/mass_storage.0/lun.0/file
firmware=/mnt/pluto.frm
mtd=/dev/mtdblock3
img=/opt/vfat.img 

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
		echo timer > /sys/class/leds/led0:green/trigger
		echo 50 > /sys/class/leds/led0:green/delay_off
		echo 500 > /sys/class/leds/led0:green/delay_on
		rm -f /mnt/SUCCESS /mnt/FAILED /mnt/FAILED_NO_PLUTO_FRM
		grep -q "ITB PlutoSDR (ADALM-PLUTO)" ${firmware} && dd if=$firmware of=$mtd bs=64k && touch /mnt/SUCCESS || touch /mnt/FAILED
		rm -f $firmware
		sync
	else
		touch /mnt/FAILED_NO_PLUTO_FRM
	fi	

	if [[ -r /mnt/RESET ]]
	then
		killall -9 watchdog
		watchdog -t 1 -T5 /dev/watchdog
		killall -9 watchdog
	fi

	if [[ -r /mnt/DFU ]]
	then
		reboot -f
	fi

	umount /mnt
	#losetup -d /dev/loop7
	echo $img > $file
	echo heartbeat > /sys/class/leds/led0:green/trigger
	sleep 1
    fi
fi

sleep 1

done

exit 1
