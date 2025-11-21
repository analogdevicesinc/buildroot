#!/bin/sh

#set -x

TTY_CONSOLE="/dev/console"
IIO_EP="/sys/bus/iio/devices/iio:device0"
THRESHOLD_CONFIG_FILE="/run/threshold_mc"
THRESHOLD_DEFAULT_MC=100000  #100.000 degC

OVERTEMP_TRIGGERED=0

is_int() {
    case "$1" in
        ''|*[!0-9]*)
            return 1
            ;;
        *)
            return 0
            ;;
    esac
}

if ! [ -e "$IIO_EP/in_temp0_offset" ]; then
    echo "OVERTEMP_MONITOR: XADC temp node (offset) not found." >> $TTY_CONSOLE
    exit 1
fi

if ! [ -e "$IIO_EP/in_temp0_raw" ]; then
    echo "OVERTEMP_MONITOR: XADC temp node (raw) not found." >> $TTY_CONSOLE
    exit 1
fi

if ! [ -e "$IIO_EP/in_temp0_scale" ]; then
    echo "OVERTEMP_MONITOR: XADC temp node (scale) not found." >> $TTY_CONSOLE
    exit 1
fi

# write out with default threshold
echo "$THRESHOLD_DEFAULT_MC" > $THRESHOLD_CONFIG_FILE

while true; do

    # update threshold from runtime file
    if [ -r "$THRESHOLD_CONFIG_FILE" ]; then
        thr=$(cat "$THRESHOLD_CONFIG_FILE" 2>/dev/null)
        if is_int $thr; then
            THRESHOLD_MC="$thr"
        fi
    else
        THRESHOLD_MC="$THRESHOLD_DEFAULT_MC"
    fi

    raw=$(iio_attr -c xadc temp0 raw)
    scale=$(iio_attr -c xadc temp0 scale)
    offset=$(iio_attr -c xadc temp0 offset)

    temp_mc=$(echo "($raw + $offset) * $scale" | bc)

    if [ "$OVERTEMP_TRIGGERED" -eq 0 ] && [ $(echo "$THRESHOLD_MC < $temp_mc" | bc -l) -eq 1 ]; then
        OVERTEMP_TRIGGERED=1

        CUR_C=$(echo "$temp_mc / 1000" | bc)
        THR_C=$(echo "$THRESHOLD_MC / 1000" | bc)

        echo "============ CRITICAL TEMPERATURE ============" > $TTY_CONSOLE
        echo "OVERTEMP_MONITOR: ${CUR_C} degC >= ${THR_C} degC - Triggering SW shutdown" > $TTY_CONSOLE
        echo "==============================================" > $TTY_CONSOLE

        # initiate a sw poweroff (does not cut hw power)
        poweroff

        sync
        sleep 5
    fi

    sleep 1

done
