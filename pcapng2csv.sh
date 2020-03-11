#!/bin/bash
# Initial version with support for only very few header fields
# Author: Steffen Wendzel, wendzel@hs-worms.de
#
# This file is part of NeFiAS. It was originally part of the WoDiCoF
# project.
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

OCURRENCE=f # use first occurrence of a field if it occurs multiple times

# IMPORTANT: only add new -e parameters behind udp.dstport, never change
#            the order of the fields ip.proto till udp.srcport.
HEADER_FIELDS="	-e ip.proto \
		-e ipv6.nxt \
		-e frame.number \
		-e frame.time_relative \
		-e frame.len \
		-e frame.cap_len \
		-e eth.src \
		-e eth.dst \
		-e ip.src \
		-e ip.dst \
		-e ipv6.src \
		-e ipv6.dst \
		-e tcp.srcport \
		-e tcp.dstport \
		-e udp.srcport \
		-e udp.dstport \
		-e tcp.seq"  # -e tcp.ack
INFILE=$1
OUTFILE=$2
TSHARK_CMD="tshark -r ${INFILE} -T fields ${HEADER_FIELDS} -E header=y -E separator=, -E quote=d -E occurrence=${OCURRENCE}"
ERR_EXIT=2
OK_EXIT=0

if [ "$1" = "" -o "$1" = "-h" -o "$1" = "--help" ]; then
	echo "Usage: $0 input.file [output.file]" >&2
	echo "Note: If no output file is provided, CSV output will be written to STDOUT." >&2
	exit ${ERR_EXIT}
	#NOTREACHED
fi


if [ "${OUTFILE}" = "" ]; then # OUTFILE is already set to $2 if parameter was provided
	OUTFILE="/dev/stdout"
	LOGFILE="/dev/stderr"
else
	# OUTFILE remains as is, thus only adjust LOGFILE
	LOGFILE="${OUTFILE}.log"
	if [ -e ${LOGFILE} ]; then
		rm ${LOGFILE}
		if [ "$?" != "0" ]; then
			echo "Unable to delete ${LOGFILE}. Exiting."
			#Try to write to LOGFILE anyway (unlikely successful but an attempt to log this."
			echo "!!!!!!!!!!!!!!!!! Unable to delete ${LOGFILE}. Exiting." >>${LOGFILE}
			#Also leave a log message in syslog
			logger -t $0 "Unable to delete ${LOGFILE}. Exiting."
			exit ${ERR_EXIT}
		fi
	fi
fi

echo "# Processing file \"${INFILE}\" at `date +"%Y-%m-%d %T %Z%z"`..." >>${LOGFILE} 2>&1
echo "# Process initiated by user: `whoami`, host: `hostname -f`" >>${LOGFILE} 2>&1
echo "# Process running under: `uname -ap`." >>${LOGFILE} 2>&1
${TSHARK_CMD} > ${OUTFILE} 2>>${LOGFILE} || exit 9
TSHARK_RET=$?
echo "# tshark exited with code: ${TSHARK_RET} [interpretation: success==0, error!=0] at "`date +"%Y-%m-%d %T %Z%z"` >>${LOGFILE} 2>&1

# only provide checksum if output is not STDERR
if [ "${OUTFILE}" != "/dev/stdout" ]; then
	echo -n "# SHA-256 checksum of output: " >>${LOGFILE} 2>&1
	sha256sum ${OUTFILE} >>${LOGFILE} 2>&1
fi
# always provide checksum for PCAP file
echo -n "# SHA-256 checksum of input: " >>${LOGFILE} 2>&1
sha256sum ${INFILE} >>${LOGFILE} 2>&1

if [ "${TSHARK_RET}" != "2" ]; then
	echo "# Script finished without errors codes returned by binaries." >>${LOGFILE} 2>&1
else
	echo "# Script finished with an ERROR in tshark!" >>${LOGFILE} 2>&1
fi

exit ${OK_EXIT}

