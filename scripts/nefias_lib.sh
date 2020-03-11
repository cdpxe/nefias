# NeFiAS Script Library
#
# This file is part of NeFiAS.
#
# Do not use this file directly, just include it in your scripts.
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

function NEFIAS_INIT()
{
	export FILENAME=`basename $1`
	export DIRNAME=`dirname $1 | sed 's/\/\//\//'`
	export TMPWORKFILE=/tmp/nefias.${RANDOM} # store intermediate results in this file; MAKE SURE TO DELETE IF AFTERWARDS!
	export JOBNAME=$2
	export TMPPKTSFILE=/tmp/${JOBNAME}_nefias_allpkts_${RANDOM} # storage file for the ("-free) packet CSV (probably without header)
	export TMPRESULTSFILE=$DIRNAME/../tmp/${JOBNAME}.results # store your results here; will moved to final location by NEFIASH_FINISH
	
	# decompress the file so that we can use it
	gzip -d ${1}.gz
	
	# move the file to the tmp folder to *lock it*
	mv $1 $DIRNAME/../tmp/$FILENAME

	# First, get all the IPv4 flows
	export HEADER=`head -1 $DIRNAME/../tmp/$FILENAME`
}

# ip.src,ip.dst,ipv6.src,ipv6.dst
# [tcp.srcport,tcp.dstport,udp.srcport,udp.dstport]
function NEFIAS_INIT_PER_FLOW()
{
	UDP="0"
	TCP="0"
	UDP_FINDFIELD=""
	TCP_FINDFIELD=""
	if [ "$1" = "" -o "$2" = "" -o "$3" = "" ]; then
		echo "ERROR: Not enough parameters provided for NEFIAS_INIT_PER_FLOW" >&2
		exit
	fi
	NEFIAS_INIT $1 $2
	
	# check whether we need to focus on UDP/TCP flows
	case $3 in
	tcp+udp|udp+tcp)
		TCP="1"
		UDP="1"
		;;
	tcp)
		TCP="1"
		;;
	udp)
		UDP="1"
		;;
	ip|ip6|ipv4|ipv6|ipv4+ipv6|ip4+ip6)
		echo -n # default case (i.e., just IPv4+IPv6)
		;;
	*)
		echo "ERROR: Input parameter not supported by NEFIAS_INIT_PER_FLOW" >&2
		exit 9
		;; #NOTREACHED
	esac
	
	export FLOWFIELDS=`echo ${HEADER} | awk -F\, -vudp=${UDP} -vtcp=${TCP} '
	{
		ip_src=""
		ip_dst=""
		ip6_src=""
		ip6_dst=""
		tcp_srcport=""
		tcp_dstport=""
		tcp_ack=""
		tcp_dst=""
		udp_srcport=""
		udp_dstport=""
		frame_len=""
		frame_time_relative=""
		
		for(i = 1; i <= NF; i++) {
			if ($i == "ip.src") {
				ip_src=i
			} else if ($i == "ip.dst") {
				ip_dst=i
			} else if ($i == "ipv6.src") {
				ip6_src=i
			} else if ($i == "ipv6.dst") {
				ip6_dst=i
			} else if ($i == "frame.len") {
				frame_len=i
			} else if ($i == "frame.time_relative") {
				frame_time_relative=i
			}
			
			# if we need to process UDP/TCP flows ...
			if (udp == "1") {
				if ($i == "udp.srcport") {
					udp_srcport=i
				} else if ($i == "udp.dstport") {
					udp_dstport=i
				}
			} # do not use "else" here since "udp+tcp" is possible as a parameter
			if (tcp == "1") {
				if ($i == "tcp.srcport") {
					tcp_srcport=i
				} else if ($i == "tcp.dstport") {
					tcp_dstport=i
				} else if ($i == "tcp.ack") {
					tcp_ack=i
				} else if ($i == "tcp.seq") {
					tcp_seq=i
				}
			}
		}
	}
	END {
		error = 0
		if ((ip_src == ip_dst && ip_src == "" ) && (ip6_src == ip6_dst && ip6_src == "")) {
			printf("FATAL ERROR_code_nl131: did not find ip[v6].src and/or ip[v6].dst field!\n")
			error = 1
		}
		if (udp == "1" && (udp_srcport == "" || udp_dstport == "" ) && tcp == "0") {
			printf("FATAL ERROR_code_nl141: did not find and UDP flows!\n")
			error = 1
		}
		if (tcp == "1" && (tcp_srcport == "" || tcp_dstport == "" ) && udp == "0") {
			printf("FATAL ERROR_code_nl151: did not find and TCP flows!\n")
			error = 1
		}
		
		if (error == 0) {
			# provide the awk -v parameter to import the variables when we extract the flows in the next step
			# keep the white-spaces after potentially empty variables, just in case
			printf "-vip_src="ip_src"  -vip_dst="ip_dst"  -vip6_src="ip6_src"  -vip6_dst="ip6_dst"  -vframe_len="frame_len" -vframe_time_relative="frame_time_relative" "
			if (udp_srcport != "" && udp_dstport != "") {
				printf "-vudp_srcport="udp_srcport"  -vudp_dstport="udp_dstport" "
			} else {
				printf "-vudpfalse=1 "
			}
			
			if (tcp_srcport != "" && tcp_dstport != "") {
				printf "-vtcp_srcport="tcp_srcport"  -vtcp_dstport="tcp_dstport" -vtcp_ack="tcp_ack" -vtcp_seq="tcp_seq" "
			} else {
				printf "-vtcpfalse=1 "
			}
			printf("\n");
		}
	}'`

	# do not include line 1 (thus "+2") as this is the $HEADER
	tail -n +2 ${DIRNAME}/../tmp/${FILENAME} | sed 's/\"//g' > ${TMPPKTSFILE}
	
	#FIXME: test IPv6 support
	#FIXME: test UDP support
	export FLOWS=`cat ${TMPPKTSFILE} | awk -F\, ${FLOWFIELDS} -vudp=${UDP} -vtcp=${TCP} '{
	# 1) internet layer, we either have IPv4 or IPv6
		if (ip_src != "" && ip_dst != "") {
			#ipv4
			printf $ip_src","$ip_dst",,,"; # three (not two!) commas to incl. empty IPv6 values
		} else {
			#ipv6 (two prefix commas for IPv4 values)
			print ",,"$ip6_src","$ip6_dst;
		}
	# 2) transport layer; we support only UDP+TCP, otherwise print nothing
		if (udp == "1" || tcp == "1") {
			if (tcp_srcport != "" && tcp_srcport != "") {
				#tcp
				# add two commas at tail for UDP values
				# (not three, because nothing is necessarily behind the udp.dstport!)
				printf $tcp_srcport","$tcp_dstport",,";
			} else if(udp_srcport != "" && udp_srcport != "") {
				#udp
				printf ",,"$udp_srcport","$udp_dstport",,"; # two leading commas for TCP values
			} else {
				# neither TCP nor UDP, print only ",,,,"
				printf ",,,,"
			}
		}
		printf("\n");
	}' | sort | uniq`
}

function NEFIAS_FINISH()
{
	rm -f ${TMPPKTSFILE} # clean-up the tmp file
	mv $DIRNAME/../tmp/$FILENAME $DIRNAME/../finished/${FILENAME} # mark file as finished
	mv $TMPRESULTSFILE $DIRNAME/../results/${JOBNAME}.${FILENAME}.results # mark results as finalized
	exit 0
}

