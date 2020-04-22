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

WINDOWSIZES="100 200 250"

for windowsize in $WINDOWSIZES; do
	for flow in $FLOWS; do
		# always get the first $windowsize packets of that flow and calculate the kappa value based on frame.time_relative.
		cat ${TMPPKTSFILE} | grep $flow | awk -F\, ${FLOWFIELDS} -vwinsize=${windowsize} \
		'BEGIN{ last_client_id=99999; previous=0; output=""; client_id_changes=0; counter=0 }
		{
			#mqtt.msgtype	mqtt.clientid
			#print "msg_type="$mqtt_msgtype", clientid="$mqtt_clientid
			
			if ($mqtt_msgtype == "1" && counter < winsize) {
				i=0
				found=0
				client_number=0
				for (i in client_ids) {
					if (client_ids[i] == $mqtt_clientid) {
						found=1
						client_number=i
					}
				}
				if (found == 0) {
					# add the new client_id
					client_ids[length(client_ids)+1]=$mqtt_clientid
					client_number=length(client_ids)
				}
				# encode this in a way that clientid-CHANGES get some extra character "!" here
				if (client_number == last_client_id) {
					output = output client_number
				} else {
					output = output client_number "!"
					client_id_changes++
				}
				last_client_id = client_number
				counter++;
			}
			
		}
		END {
			# make sure the window is filled with enough pkts (max defined by head -n)
			if (counter >= winsize) {
				print output" "client_id_changes
			}
		}
		' > ${TMPWORKFILE}
		#echo -n ">>>";head -10 ${TMPWORKFILE}; echo -n "<<<"
		CLIENTID_CHANGES=`cat ${TMPWORKFILE} | awk '{print $2}'`
		gzip -9 --no-name --keep ${TMPWORKFILE}
		S_len=`/bin/ls -l ${TMPWORKFILE} | awk '{print $5}'`
		if [ "$S_len" = "0" ]; then
			# too few elements (less than window size)
			touch ${TMPRESULTSFILE} # just let NEFIAS know that we did our job here (create the file, if not present)
		else
			C_len=`/bin/ls -l ${TMPWORKFILE}.gz | awk '{print $5}'`
			K=`echo "scale=6;($S_len/$C_len)" | bc`
			echo "${flow},${windowsize},${K},${CLIENTID_CHANGES}" >> ${TMPRESULTSFILE} # Temporary storage for results until all entries were calculated
			#echo "${flow}, K=${K}"
		fi
		rm -f ${TMPWORKFILE} ${TMPWORKFILE}.gz
	done
done

NEFIAS_FINISH

