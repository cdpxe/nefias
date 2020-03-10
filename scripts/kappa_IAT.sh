#!/bin/bash
# This file is part of NeFiAS.
# 
# NeFiAS is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# NeFiAS is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with Foobar.  If not, see <https://www.gnu.org/licenses/>.
#
# kappa_IAT.sh: calculate Kappa compressibility score based on inter-arrival times of flows
# This script receives the following parameters: ./script [chunk] [jobname]
# note: I recommend to use ~nefias/nefias as tmpfs to speed up the 'cat' command and to limit disk I/O!

source ~/nefias/scripts/nefias_lib.sh
NEFIAS_INIT_PER_FLOW $1 $2 "tcp"

for flow in $FLOWS; do
	# always get the first 1000 packets of that flow and calculate the kappa value based on frame.time_relative.
	cat ${TMPPKTSFILE} | grep $flow | head -1001 | awk -F\, ${FLOWFIELDS} \
	'BEGIN{ previous=0; output=""; counter=0 }
	{
		diff = $frame_time_relative - previous;
		output = output sprintf("%1.4f,", diff)
		previous = $frame_time_relative;
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
		#echo "${flow}, K=${K}"
	fi
	rm -f ${TMPWORKFILE} ${TMPWORKFILE}.gz
done

NEFIAS_FINISH

