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
# eSim_IAT_frametimerelative.sh: calculate epsilon similarity scores based on inter-arrival times of flows
# This script receives the following parameters: ./script [chunk] [jobname]
# note: I recommend to use ~nefias/nefias as tmpfs to speed up the 'cat' command and to limit disk I/O!

source "`dirname $0`/nefias_lib.sh"
NEFIAS_INIT_PER_FLOW $1 $2 "ip"

for flow in $FLOWS; do
	# always get the first 2001 packets of that flow and calculate epsilon similarity scores based on frame.time_relative.
	cat ${TMPPKTSFILE} | grep $flow | head -n 2001 | \
	# use gawk for built-in functions asort() und length().
	gawk -F\, ${FLOWFIELDS} \
	'BEGIN {counter=0
		epsilon_1=0.005; epsilon_1_counter=0
		epsilon_2=0.008; epsilon_2_counter=0
		epsilon_3=0.01; epsilon_3_counter=0
		epsilon_4=0.02; epsilon_4_counter=0
		epsilon_5=0.03; epsilon_5_counter=0
		epsilon_6=0.1; epsilon_6_counter=0
		# epsilon_7 means lambda_i >= 0.1. See Cabuk et al. 2004 (and 2009).
		epsilon_7=0.1; epsilon_7_counter=0
	}
	{
		counter++
		
		# starting from the second packet (counter >= 2), calculate the inter-arrival times.
		if (counter >= 2) {
			arr_T[counter] = $frame_time_relative - previous_time
		}
				
		previous_time = $frame_time_relative
	}
	END {
		# make sure the window is filled with enough pkts (max defined by head -n).
		# there must be at least 3, otherwise an error would occur because of dividing by 0.
		if (counter == 2001 && counter >= 3) {

			# sort the inter-packet times.
			asort(arr_T)
			
			# calculate the pairwise relative differences lambda.
			for (i = 1; i < length(arr_T); i++) {
				# error handling for divding by 0: If inter-packet time equals 0, lambda is set to 0.
				if (arr_T[i] != 0)
						arr_lambda[i] = (arr_T[i+1]-arr_T[i])/arr_T[i]
					else
						arr_lambda[i] = 0
			}
			
			# count the number of lambdas which are below the respective epsilon thresholds.
			for (i = 1; i <= length(arr_lambda); i++) {
				if (arr_lambda[i] < epsilon_1) epsilon_1_counter++
				if (arr_lambda[i] < epsilon_2) epsilon_2_counter++
				if (arr_lambda[i] < epsilon_3) epsilon_3_counter++
				if (arr_lambda[i] < epsilon_4) epsilon_4_counter++
				if (arr_lambda[i] < epsilon_5) epsilon_5_counter++
				if (arr_lambda[i] < epsilon_6) epsilon_6_counter++
				if (arr_lambda[i] >= epsilon_7) epsilon_7_counter++
			}
			
			# calculate the epsilon similarity scores.
			eSim_1 = epsilon_1_counter / length(arr_lambda)
			eSim_2 = epsilon_2_counter / length(arr_lambda)
			eSim_3 = epsilon_3_counter / length(arr_lambda)
			eSim_4 = epsilon_4_counter / length(arr_lambda)
			eSim_5 = epsilon_5_counter / length(arr_lambda)
			eSim_6 = epsilon_6_counter / length(arr_lambda)
			eSim_7 = epsilon_7_counter / length(arr_lambda)
			
			# concatenate the epsilon similarity scores to a single string.
			eSim_Werte = "eSim(" epsilon_1 ")=" sprintf("%.2f", 100*eSim_1) "%, "\
				"eSim(" epsilon_2 ")=" sprintf("%.2f", 100*eSim_2) "%, "\
				"eSim(" epsilon_3 ")=" sprintf("%.2f", 100*eSim_3) "%, "\
				"eSim(" epsilon_4 ")=" sprintf("%.2f", 100*eSim_4) "%, "\
				"eSim(" epsilon_5 ")=" sprintf("%.2f", 100*eSim_5) "%, "\
				"eSim(" epsilon_6 ")=" sprintf("%.2f", 100*eSim_6) "%, "\
				"eSim(>=" epsilon_7 ")=" sprintf("%.2f", 100*eSim_7) "%"		
		
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
