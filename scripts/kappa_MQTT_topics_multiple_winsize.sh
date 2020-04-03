#!/bin/bash
# (C) 2020 Steffen Wendzel, wendzel (at) hs-worms (dot) de
#     http://www.wendzel.de
#
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
# kappa_MQTT_topics_multiple_winsize.sh: calculate Kappa compressibility
# score based on MQTT topics of flows for different window sizes.
#
# This script receives the following parameters: ./script [chunk] [jobname]
#
# Output format:
# <flow (CSV)>, window-size, kappa, number-of-topic-changes-within-winsize-pkts

source "`dirname $0`/nefias_lib.sh"
NEFIAS_INIT_PER_FLOW $1 $2 "ip"

WINDOWSIZES="100 500 750 1000 1500 1750 2000 2500 3000"

for windowsize in $WINDOWSIZES; do
	for flow in $FLOWS; do
		# always get the first $windowsize packets of that flow and calculate the kappa value based on frame.time_relative.
		cat ${TMPPKTSFILE} | grep $flow | awk -F\, ${FLOWFIELDS} -vwinsize=${windowsize} \
		'BEGIN{ last_topic=99999; previous=0; output=""; topic_changes=0; counter=0 }
		{
			if ($mqtt_topic != "" && counter < winsize) {
				i=0
				found=0
				topic_number=0
				for (i in topics) {
					if (topics[i] == $mqtt_topic) {
						found=1
						topic_number=i
					}
				}
				if (found == 0) {
					# add the new topic
					topics[length(topics)+1]=$mqtt_topic
					topic_number=length(topics)
				}
				# encode this in a way that topic-CHANGES get some extra character "!" here
				if (topic_number == last_topic) {
					output = output topic_number
				} else {
					output = output topic_number "!"
					topic_changes++
				}
				last_topic = topic_number
				counter++;
			}			
		}
		END {
			# make sure the window is filled with enough pkts (max defined by head -n)
			if (counter >= winsize) {
				print output" "topic_changes
			}
		}' > ${TMPWORKFILE}
		TOPIC_CHANGES=`cat ${TMPWORKFILE} | awk '{print $2}'`
		#echo -n ">>>"; cat ${TMPWORKFILE}; echo "<<<"
		gzip -9 --no-name --keep ${TMPWORKFILE}
		S_len=`/bin/ls -l ${TMPWORKFILE} | awk '{print $5}'`
		if [ "$S_len" = "0" ]; then
			# too few elements (less than window size)
			touch ${TMPRESULTSFILE} # just let NEFIAS know that we did our job here (create the file, if not present)
		else
			C_len=`/bin/ls -l ${TMPWORKFILE}.gz | awk '{print $5}'`
			K=`echo "scale=6;($S_len/$C_len)" | bc`
			echo "${flow},${windowsize},${K},${TOPIC_CHANGES}" >> ${TMPRESULTSFILE} # Temporary storage for results until all entries were calculated
			#echo "${flow}, K=${K}"
		fi
		rm -f ${TMPWORKFILE} ${TMPWORKFILE}.gz
	done
done

NEFIAS_FINISH

