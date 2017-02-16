#!/bin/sh

case "${ACTION}" in
add|"")
	ifup ${MDEV}
	;;
remove)
	ifdown ${MDEV}
	;;
esac
