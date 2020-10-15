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
# eSim_Retransmission_tcpseq.sh: calculate epsilon similarity scores based on sequence numbers of tcp retransmissions of flows
# This script receives the following parameters: ./script [chunk] [jobname]
# note: I recommend to use ~nefias/nefias as tmpfs to speed up the 'cat' command and to limit disk I/O!


source "`dirname $0`/nefias_lib.sh"
NEFIAS_INIT_PER_FLOW $1 $2 "tcp"

for flow in $FLOWS; do
	# always get the first 20010 packets of that flow and calculate epsilon similarity scores based on tcp.seq.
	cat ${TMPPKTSFILE} | grep $flow | head -n 2000 | \
	# use gawk for built-in functions asort() und length().
	gawk -F\, ${FLOWFIELDS} \
	'BEGIN {counter=0
		# define epsilon values.
		epsilon_1=0.01; epsilon_1_counter=0
		epsilon_2=0.2; epsilon_2_counter=0
		epsilon_3=2.5; epsilon_3_counter=0
		# epsilon_4 means lambda_i >= 2.5. (This epsilon value was not part of Zillien und Wendzel 2018)
		epsilon_4=2.5; epsilon_4_counter=0
	}
	{
		counter++
		
		# save all tcp sequence numbers.
		arr_Seq[counter] = $tcp_seq
	}
	END {
		# make sure the window is filled with enough pkts (max defined by head -n).
		if (counter == 2000) {
		
			# extract only sequence numbers of retransmissions from all sequence numbers.
			counter_Retrans = 0
			for (i = 1; i <= length(arr_Seq); i++) {
				# boolean variable is used. Set to 1, if retransmission is found, 0 otherwise.
				# This takes into account the case of multiple retransmissions of a single tcp segment.
				bool_retrans_found = 0
				for (j = i+1; bool_retrans_found == 0 && j <= length(arr_Seq); j++) {
					if (arr_Seq[i] == arr_Seq[j]) bool_retrans_found = 1
				}
				
				# extract the sequence numbers of retransmissions
				if (bool_retrans_found == 1) {
					counter_Retrans++
					arr_Retrans[counter_Retrans] = arr_Seq[i]	
				}
			}
			
			# There must be at least 3 retransmissions to calculate the epsilon similarity scores. Otherwise, an error because of division by 0 occurs.
			if (counter_Retrans <= 2) {
				eSim_Werte = "no or not enough (<=2) retransmissions existent"
			}
			else {
				# calculate distance delta between each retransmission and the previous retransmission (except for the last one).
				for (i = 1; i < length(arr_Retrans); i++) {
					arr_Delta[i] = arr_Retrans[i+1] - arr_Retrans[i]
				}
				
				# sort the deltas
				asort(arr_Delta)
				
				# calculate the pairwise relative differences lambda.
				for (i = 1; i < length(arr_Delta); i++) {
					# error handling for division by 0: If delta equals 0, lambda is set to 0.
					if (arr_Delta[i] != 0)
						arr_lambda[i] = (arr_Delta[i+1]-arr_Delta[i])/arr_Delta[i]
					else
						arr_lambda[i] = 0
				}
				
				# count the number of lambdas which are below the respective epsilon values.
				for (i = 1; i <= length(arr_lambda); i++) {
					if (arr_lambda[i] < epsilon_1) epsilon_1_counter++
					if (arr_lambda[i] < epsilon_2) epsilon_2_counter++
					if (arr_lambda[i] < epsilon_3) epsilon_3_counter++
					if (arr_lambda[i] >= epsilon_4) epsilon_4_counter++
				}
				
				# calculate the epsilon similarity scores.
				eSim_1 = epsilon_1_counter / length(arr_lambda)
				eSim_2 = epsilon_2_counter / length(arr_lambda)
				eSim_3 = epsilon_3_counter / length(arr_lambda)
				eSim_4 = epsilon_4_counter / length(arr_lambda)
				
				# concatenate the epsilon similarity scores to a single string.
				eSim_Werte = "eSim(" epsilon_1 ")=" sprintf("%.2f", 100*eSim_1) "%, "\
					"eSim(" epsilon_2 ")=" sprintf("%.2f", 100*eSim_2) "%, "\
					"eSim(" epsilon_3 ")=" sprintf("%.2f", 100*eSim_3) "%, "\
					"eSim(>=" epsilon_4 ")=" sprintf("%.2f", 100*eSim_4) "%"
			}
		
			# print out the string of the epsilon similarity scores.
			print eSim_Werte
		}
	
	# print out the string to the temporary working file.
	}' > ${TMPWORKFILE}
	
	# Paste the string of epsilon similarity scores into the temporary results file.
	if [ `/bin/ls -l ${TMPWORKFILE} | gawk '{print $5}'` = "0" ]; then
		# too few elements (less than window size)
		touch ${TMPRESULTSFILE} # just let NEFIAS know that we did our job here (create the file, if not present)
	else
		# temporary working file contains one line of epsilon similrity scores.
		# save the line to string variable
		eSim=`gawk '{print}' ${TMPWORKFILE}`
		# append flow information and epsilon similarity scores to the temporary results file as single line.
		echo "${flow}, ${eSim}" >> ${TMPRESULTSFILE} # Temporary storage for results until all entries were calculated
	fi
	
	# delete the temporary working file.
	rm -f ${TMPWORKFILE}
	
done

NEFIAS_FINISH
