#!/bin/sh
freq=95000000
state=0
gain=10

if [ -s /tmp/fm_radio ];
then
freq=$(cat /tmp/fm_radio)
fi

if [ -s /tmp/fm_radio_gain ];
then
gain=$(cat /tmp/fm_radio_gain)
fi

if [ -s /tmp/fm_radio_state ];
then
state=$(cat /tmp/fm_radio_state)
fi

if [ $state -eq 1 ];
then
killall softfm;
echo 0 > /tmp/fm_radio_state
else
echo 1 > /tmp/fm_radio_state
/usr/bin/softfm -f $freq -s 520888 -g $gain > /tmp/fm_radio_log 2>&1
fi
