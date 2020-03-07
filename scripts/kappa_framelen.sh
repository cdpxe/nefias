#!/bin/bash
# kappa_framelen.sh: calculate Kappa compressibility score based on frame length of flows
# This script receives the following parameters: ./script [chunk] [jobname]
# note: I recommend to use ~nefias/nefias as tmpfs to speed up the 'cat' command and to limit disk I/O!

source ~/nefias/scripts/nefias_lib.sh
NEFIAS_INIT_PER_FLOW $1 $2 "ip" # || tcp || udp

for flow in $FLOWS; do
	# always get the first 1000 packets of that flow and calculate the kappa value based on the frame length.
	cat ${TMPPKTSFILE} | grep $flow | head -1001 | awk -F\, ${FLOWFIELDS} \
	'function abs(x) { return x<0 ? -x : x }
	BEGIN{ previous=0; output=""; counter=0 }
	{
		output = output sprintf(abs(previous-$frame_len)",") 
		previous=$frame_len;
		counter++;
	}
	END {
		# make sure the window is filled with enough pkts (max defined by head -n)
		if (counter >= 1000) print output;	
	}' > ${TMPWORKFILE}
	gzip -9 --no-name --keep ${TMPWORKFILE}
	S_len=`/bin/ls -l ${TMPWORKFILE} | awk '{print $5}'`
	if [ "$S_len" = "0" ]; then
		# too few elements (less than window size)
		touch ${TMPRESULTSFILE} # just let NEFIAS know that we did our job here (create the file, if not present)
	else
		C_len=`/bin/ls -l ${TMPWORKFILE}.gz | awk '{print $5}'`
		K=`echo "scale=6;($S_len/$C_len)" | bc`
		echo "${flow}, K=${K}" >> ${TMPRESULTSFILE} # Temporary storage for results until all entries were calculated
	fi
	rm -f ${TMPWORKFILE} ${TMPWORKFILE}.gz
done

NEFIAS_FINISH

