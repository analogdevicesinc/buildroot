#!/bin/sh

case "${ACTION}" in
add|"")
	ifup ${MDEV}
	echo $(ip -f inet -o addr show ${MDEV}|cut -d\  -f 7 | cut -d/ -f 1) > /opt/ipaddr-${MDEV}
	;;
remove)
	echo $(ip -f inet -o addr show ${MDEV}|cut -d\  -f 7 | cut -d/ -f 1) > /opt/ipaddr-${MDEV}
	ifdown ${MDEV}
	;;
esac
