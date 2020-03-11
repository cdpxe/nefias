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
#######
#
# kappa_TCP_seqmod_message_ordering_pattern.sh: calculate compressibility score
# to detect network covert channels that utilize the MESSAGE ORDERING pattern
# by artificually maniupulating the order of TCP packets. To achieve this, this
# script performs string operations of succeeding packet's sequence numbers
# as described by Wendzel, S.: Protocol-independent Detection of “Messaging
# Ordering” Network Covert Channels, in Proc. ARES (CUING Workshop), ACM, 2019.
# This script utilizes different window sizes to ease the process of finding
# a high-quality threshold for K.
#
# This script receives the following parameters: ./script [chunk] [jobname]

source "`dirname $0`/nefias_lib.sh"
NEFIAS_INIT_PER_FLOW $1 $2 "tcp"

WINDOWSIZES="200" # 500 1000 2500 5000"

for windowsize in $WINDOWSIZES; do
	for flow in $FLOWS; do
		# always get the first $windowsize packets of that flow and calculate the kappa
		# value using relative increase of seq no. using string coding by Wendzel (2019)
		#
		# -this gets the sorted [packet-no (reconstructed)] [seq-no (increasing)]
		# -afterwards, cut removes second field, because we do not need it anymore after sorting
		# -then, use sed to remove the preamble of zeros that we instered by %.10d for sorting
		#  numbers of different amount of digits
		# -finally, let awk do the string creation
		cat ${TMPPKTSFILE} | grep $flow | head -n ${windowsize} | awk  -F\, ${FLOWFIELDS} '
		{ printf sprintf("%.10d,%.10d\n", NR, $tcp_seq) }' | sort -t ',' --key=2 | \
		cut -d ',' -f 1 | sed 's/^[0]*//' | awk -F\, -vtcp_seq=1 -vwinsize=${windowsize} \
		'function abs(x) { return x<0 ? -x : x }
		BEGIN{ previous=0; output=""; counter=0 }
		{
			# only consider TCP+UDP packets
			if ($tcp_seq != "" && counter < winsize) {
				if (previous == 0) {
					output = $tcp_seq "A"
					previous = $tcp_seq
				} else {
					# Wendzel (2019): best performance provided by
					# """str(|diff|) || ( |diff| % 2 ? ’A’ : ’B’ )"""
					diff = $tcp_seq - previous
					output = output abs(diff) (abs(diff) % 2 ? "A" : "B") 
					previous = $tcp_seq
				}
				counter++
			}
		}
		END {
			# make sure the window is filled with enough pkts (max defined by head -n)
			if (counter >= winsize) printf output;
		}' > ${TMPWORKFILE}

		gzip -9 --no-name --keep ${TMPWORKFILE}
		S_len=`/bin/ls -l ${TMPWORKFILE} | awk '{print $5}'`
		if [ "$S_len" = "0" ]; then
			# too few elements (less than window size)
			touch ${TMPRESULTSFILE} # just let NEFIAS know that we did our job here (create the file, if not present)
		else
			C_len=`/bin/ls -l ${TMPWORKFILE}.gz | awk '{print $5}'`
			K=`echo "scale=6;($S_len/$C_len)" | bc`
			echo "${flow},WinSize=${windowsize},K=${K}" >> ${TMPRESULTSFILE} # Temporary storage for results until all entries were calculated
		fi
		rm -f ${TMPWORKFILE} ${TMPWORKFILE}.gz
	done
done

NEFIAS_FINISH

