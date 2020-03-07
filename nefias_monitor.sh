#!/bin/bash

source nefias_common.inc

# nefias progress monitor

while [ ! -e ${NEFIAS_STATUS_FILE} ]; do
	echo "waiting for ${NEFIAS_STATUS_FILE} to become available..."; sleep 2
done

(
	while [ 1 ]; do
		cat ${NEFIAS_STATUS_FILE} | tr '.' ' ' | awk '{print $1}'
		sleep 1
	done
) | dialog --title "NEFIAS Progress" --gauge "Please wait ..." 7 70 0


