#/bin/bash -e
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

NEFIAS_VERSION="0.7-alpha"
NEFIAS_LICENSE="GPLv3"
EXECUTABLE=$0
DEBUG="0"

# default configuration
SLAVE_HOSTCONFIG="slaves.cfg"
SLAVE_USERNAME="nefias"
SLAVE_SCRIPT="scripts/kappa_IAT.sh"
TRAFFIC_SOURCE="mypcap.csv"
CHUNK_SIZE_IN_LINES=10000
VALUES="frame.number,frame.time_relative,frame.len,ip.src,ip.dst,ipv6.src,ipv6.dst,tcp.srcport,tcp.dstport,udp.srcport,udp.dstport"
JOBNAME="nefias_${RANDOM}"
KEEP_CHUNKFILES="0"

ALLBUSY_WAITSEC=5

SLAVE_SCRIPTDIR="scripts"
SLAVE_INPUTDIR="input"

source "nefias_common.inc"


function help()
{
	echo 'usage: '`basename ${EXECUTABLE}`' [parameters]

supported parameters:
 --slave-hostconfig=slaves.cfg -- config of slaves
 --slave-username=nefias       -- username on slaves
 --slave-script=scripts/kap.sh -- script to upload to slaves
 --traffic-source=mypcap.csv   -- source script that we need to split
 --chunk-size-in-lines=10000   -- split into chunkes of 10k lines
 --values="frame.number,..."   -- list of PCAP parameters to consider [***]
 --jobname="MyJob-..."         -- if you want to specify an own job name
 --allbusy-waitsec=5           -- after how many seconds should NEFIAS
                                  try again to find idle slave nodes if
                                  all nodes were just found to be busy
 --keep-chunkfiles             -- use the existing chunk files instead of
                                  creating and compressing new ones

[***] CAUTION: Your traffic-source file MUST contain the following values
      and they MUST be in the given order: frame.number,frame.time_relative,
      frame.len,ip.src,ip.dst,ipv6.src,ipv6.dst,tcp.srcport,tcp.dstport,
      udp.srcport,udp.dstport
      It is fine you only have IPv4 OR only IPv6 OR both.
      If is also fine if you have no TCP and/or no UDP flows.
      However, feel free to add additional values to the list.
'
}

function version()
{
	echo "NEFIAS v.${NEFIAS_VERSION}, License: ${NEFIAS_LICENSE}"
	echo "(C) 2020 Steffen Wendzel, wendzel (at) hs-worms (dot) de"
	echo "Personal website: http://www.wendzel.de"
	echo "Project website: http://nefias.ztt.hs-worms.de"
}


##############################################
# 1. PARSE ARGUMENTS
##############################################

for i in "$@"; do
case $i in
    -h=*|--slave-hostconfig=*)
	    SLAVE_HOSTCONFIG="${i#*=}"
	    shift # past argument=value
	    ;;
    -u=*|--slave-username=*)
	    SLAVE_USERNAME="${i#*=}"
	    shift # past argument=value
	    ;;
    -s=*|--slave-script=*)
	    SLAVE_SCRIPT="${i#*=}"
	    shift # past argument=value
	    ;;
    -t=*|--traffic-source=*)
	    TRAFFIC_SOURCE="${i#*=}"
	    shift # past argument=value
	    ;;
    -l=*|--chunk-size-in-lines=*)
	    CHUNK_SIZE_IN_LINES="${i#*=}"
	    shift # past argument=value
	    ;;
    -v=*|--values=*)
	    VALUES="${i#*=}"
	    shift # past argument=value
	    ;;
    -j=*|--jobname=*)
	    JOBNAME="${i#*=}"
	    shift # past argument=value
	    ;;
    --allbusy-waitsec=*)
            ALLBUSY_WAITSEC="${i#*=}"
	    shift # past argument=value
        ;;
    -k|--keep-chunkfiles)
            KEEP_CHUNKFILES="1"
	    shift # past argument=value
        ;;
    -h|--help)
	    help
	    exit 1
	    shift # past argument=value
    ;;
    -v|--version)
	    version
	    exit 1
	    shift # past argument=value
    ;;
    *)
          # unknown option
          help
          echo; echo "Unknown option provided. Exiting."
          exit 99
          ;;
esac
done

version
echo
echo "SLAVE_HOSTCONFIG    = ${SLAVE_HOSTCONFIG}"
echo "SLAVE_USERNAME      = ${SLAVE_USERNAME}"
echo "SLAVE_SCRIPT        = ${SLAVE_SCRIPT}"
echo "TRAFFIC_SOURCE      = ${TRAFFIC_SOURCE}"
echo "CHUNK_SIZE_IN_LINES = ${CHUNK_SIZE_IN_LINES}"
echo "VALUES              = ${VALUES}"
echo "JOBNAME             = ${JOBNAME}"
echo "ALLBUSY_WAITSEC     = ${ALLBUSY_WAITSEC}sec"
echo "KEEP_CHUNKFILES     = ${KEEP_CHUNKFILES}"

if [ ! -e ${SLAVE_HOSTCONFIG} ]; then
	echo "${SLAVE_HOSTCONFIG} does not exist."
else
	source ${SLAVE_HOSTCONFIG}
fi

##############################################
# 2. PREPARE OPERATION
##############################################

# start time measurement
STARTTIME=`date +%s`
echo "0.000" > ${NEFIAS_STATUS_FILE}

# 2.1 generate random number for the session (hash input parameters+current time)
TIMESTAMP=`date +"%y%m%d-%H%M%S"`
SESSION="${JOBNAME}-${TIMESTAMP}"
echo "SESSION             = ${SESSION}"


# 2.2 CREATE CHUNKS FROM 'traffic-source' (FOR OUR RANDOM DATA)

# 2.2.1 extract only $VALUES from $TRAFFIC_SOURCE and store in some tmp file

echo "Extracting the fields ${VALUES} from ${TRAFFIC_SOURCE} ..."
NEEDED_FIELDS=""
for value in `echo ${VALUES} | tr ',' ' '`; do
	NEEDED_FIELDS=${NEEDED_FIELDS}`head -1 ${TRAFFIC_SOURCE} | awk -F\, -v awkval="${value}" '{	for(i = 1; i <= NF; i++) { if ($i == awkval) { printf(i","); } } }'`
done
# remove trailing ',' from NEEDED_FIELDS (otherwise 'cut' will complain!)
NEEDED_FIELDS=`echo ${NEEDED_FIELDS} | sed 's/,$//'`
cut --delimiter=, --fields=${NEEDED_FIELDS} ${TRAFFIC_SOURCE} > tmp

# 2.2.2 split the tmp file in chunks

# how many chunks of CHUNK_SIZE_IN_LINES do we need?
NUM_LINES_TMPFILE=`wc -l tmp | awk '{print $1}'` # number of lines in tmp file

if [ "$KEEP_CHUNKFILES" = "1" ]; then
	echo "Keeping original chunk files ..."
else
	echo -n "Creating chunks from extraction (overall: ${NUM_LINES_TMPFILE} lines split into >="
	# This includes ceiling by checking whether there is some .x, where x!=0.
	# This solution kills trailing values where x is >0 but <1, (e.g. 7.00481 or something)
	NUM_CHUNKS=`echo "scale=1;${NUM_LINES_TMPFILE}/${CHUNK_SIZE_IN_LINES}" | bc | tr '.' ' ' | awk '{ if ($2 == 0) { print $1 } else { print ($1 + 1) } }'`
	echo "${NUM_CHUNKS} chunks)"

	# cleanup all old chunk files
	rm -fv chunk_*
	# create the new chunks
	CSV_HEADER=`head -1 tmp`
	export CSV_HEADER
	echo "splitting into chunks ..."
	tail -n +2 tmp | split -l ${CHUNK_SIZE_IN_LINES} -d --filter='{ printf %s\\n "$CSV_HEADER"; cat; } >$FILE' - chunk_
	echo "compressing chunks ... "
	for chunkfilename in `/bin/ls chunk_*`; do
		echo -n "#"
		gzip -9 $chunkfilename
	done; echo
fi

##############################################
# 3. UPLOAD SCRIPT TO SLAVES
##############################################

echo "Attaching slaves ..."
for slave in "${slaves[@]}"; do
	echo -n "uploading slave script to ${slave} ..."
	scp -qC ${SLAVE_SCRIPT} scripts/nefias_lib.sh ${SLAVE_USERNAME}@${slave}/${SLAVE_SCRIPTDIR}/
	echo "done"
done

##############################################
# 4. MAIN LOOP
##############################################

# 4.1 upload first part of chunks

CHUNKS_NOT_UPLOADED=(`/bin/ls chunk_* | sed 's/\.gz//'`) # contains only chunkname, w/o .gz extension
CHUNKS_UPLOADED=() # contains chunkname+slave in the form chunk§slavehost
CHUNKS_COMPLETED=() # contains only chunkname
NUMBER_OF_ALL_CHUNKS=${#CHUNKS_NOT_UPLOADED[@]}

# 4.2 enter mainloop

completed="0"
#for chunk in $CHUNKSTACK; do
while [ "$completed" = "0" ]; do
	chunk="" # clean-up
	# If there are chunks left to be uploaded, get next one
	if [ "${#CHUNKS_NOT_UPLOADED[@]}" != "0" ]; then
		chunk=${CHUNKS_NOT_UPLOADED[${#CHUNKS_NOT_UPLOADED[@]}-1]}
		unset CHUNKS_NOT_UPLOADED[${#CHUNKS_NOT_UPLOADED[@]}-1] # remove the element
		#echo "chunk=\'$chunk\'"
	fi
	
	# create an empty list of idle slaves
	SLAVES_IDLE=()
	
	# add all currently idle slaves to the list of idle slaves
	if [ "$chunk" = "" ]; then
		if [ "$DEBUG" = "1" ]; then
			echo "no chunk selected for upload"
		fi
	else
		while [ "${#SLAVES_IDLE[@]}" = "0" ]; do
			for slave in "${slaves[@]}"; do
#				# only continue if there is currently no item marked as uploaded on the particular slave
#				# (otherwise, this will result in a race condition when we remove whole hosts (with all
#				# their chunks, i.e. they should only have ONE chunk assigned at a time)!)
				skip_slave="0"
#				for needle in ${CHUNKS_UPLOADED[@]}; do
#					if [ "`echo $needle | sed 's/.*§//'`" = "$slave" ]; then
#						echo -n "SLAVE "`echo $needle | sed 's/.*§//'`" STILL HAS UPLOADED CONTENT, SKIPPING"
#						skip_slave="1"
#					else
#						echo ">`echo $needle | sed 's/.*§//'`< != >$slave<"
#					fi
#				done
				
				# check whether tmp/ and input/ are both empty (previously only checked for tmp/); now might be better.
				if [ "$skip_slave" = "0" ]; then
					CMD=`echo "ssh nefias@${slave}" | sed 's/:.*//'`" ( /bin/ls /`echo "${slave}" | sed 's/.*://'`/tmp/; /bin/ls /`echo "${slave}" | sed 's/.*://'`/input/ ) | wc -l"
					if [ `$CMD` = "0" ]; then
						# no files in directory means: slave is idle => add to list
						SLAVES_IDLE+=( $slave )
					else
						# slave is busy; do nothing
						echo -n;
					fi
				fi
			done
			if [ "${#SLAVES_IDLE[@]}" = "0" ]; then
				echo "All nodes busy; pausing for ${ALLBUSY_WAITSEC}sec."
				sleep ${ALLBUSY_WAITSEC}
			fi
		done
	fi
	
	# Pick random idle slave node and assign chunk
	if [ "$chunk" = "" ]; then
		echo -n; # no chunk available, so we do not need to upload any chunk/run any
			 # script on any slave!
	else
		slave=${SLAVES_IDLE[$RANDOM % ${#SLAVES_IDLE[@]}]}
		echo "uploading chunk $chunk to ${slave} ..."
		scp -qC ${chunk}.gz ${SLAVE_USERNAME}@${slave}/${SLAVE_INPUTDIR}/
		CHUNKS_UPLOADED+=($chunk"§"$slave) # mark the chunk as uploaded
		
		echo "executing script $SLAVE_SCRIPT on ${slave} ..."
		CMD=`echo "ssh nefias@${slave}" | tr ':' ' '`"/${SLAVE_SCRIPTDIR}/`basename ${SLAVE_SCRIPT}` /`echo "${slave}" | sed 's/.*://'`/${SLAVE_INPUTDIR}/$chunk ${JOBNAME}"
		#echo ">>>$CMD<<<"
		( $CMD ) & # make this a background process
	fi
	unset chunk # free
	unset SLAVES_IDLE # new round, new game: we start with zero knowledge
	
	# Check the chunks that were already completed on the slaves
	#FIXME evtl. löscht das slave-script ja alle Dateien des Jobs oder so?????????
	for chunkslave in "${CHUNKS_UPLOADED[@]}"; do
		chunk=`echo $chunkslave | sed 's/§.*//'`
		slave=`echo $chunkslave | sed 's/.*§//'`
		if [ "$DEBUG" = "1" ]; then echo "checking chunk >$chunk< for completion (was uploaded to slave >$slave<)"; fi
		# check $DIRNAME/../results/${JOBNAME}.${chunk}.results on $slave
		CMD=`echo "ssh nefias@${slave}" | sed 's/:.*//'`" if [ -e /`echo "${slave}" | sed 's/.*://'`/results/${JOBNAME}.${chunk}.results ]; then echo \"done\"; else echo \"in-progress\"; fi"
		#echo ">>>$CMD<<<"
		if [ `$CMD` = "done" ]; then
			echo "chunk ${chunk} completed on ${slave} at `date` (transfering results)"
			CMD="scp -qC nefias@${slave}/results/${JOBNAME}.${chunk}.results ./results/"
			#echo ">>>$CMD<<<"
			$CMD
			# chunk completed; remove $chunkslave from $CHUNKS_UPLOADED
			haystack=()
			for needle in ${CHUNKS_UPLOADED[@]}; do
				if [ "$needle" = "$chunkslave" ]; then # ERROR FIXME this removes ALL chunks from the slave! solution: only mark slaves as IDLE when they have no element in chunks_uploaded!
					echo -n "" # skip this element
				else
					haystack+=( $needle )
				fi
			done
			unset needle
			unset CHUNKS_UPLOADED
			CHUNKS_UPLOADED=( ${haystack[@]} )
			unset haystack
			# add this chunk to the list of completed chunks
			CHUNKS_COMPLETED+=( $chunk )
		else
			if [ "$DEBUG" = "1" ]; then
				echo -n "chunk ${chunk} is NOT completed on ${slave} +++ currently uploaded chunks: ["
				for testchunk in "${CHUNKS_UPLOADED[@]}"; do
					echo -n "$testchunk,"
				done
				echo "]"
			fi
		fi
	done
	unset chunk # free
	
	echo "status: chunks to be uploaded=${#CHUNKS_NOT_UPLOADED[@]}, uploaded=${#CHUNKS_UPLOADED[@]}, completed=${#CHUNKS_COMPLETED[@]}"
	echo "${#CHUNKS_COMPLETED[@]}/${NUMBER_OF_ALL_CHUNKS}*100" | bc -l > ${NEFIAS_STATUS_FILE}
	
	if [ "$DEBUG" = "1" ]; then
		echo -n "===completed chunks: ["
		for chunk in "${CHUNKS_COMPLETED[@]}"; do
			echo -n "$chunk,"
		done
		echo "]==="
		echo -n "===currently uploaded chunks: ["
		for chunk in "${CHUNKS_UPLOADED[@]}"; do
			echo -n "$chunk,"
		done
		echo "]==="
		echo -n "===not uploaded chunks: ["
		for chunk in "${CHUNKS_NOT_UPLOADED[@]}"; do
			echo -n "$chunk,"
		done
		echo "]==="
	fi
	
	# check for completion
	if [ ${#CHUNKS_NOT_UPLOADED[@]} = "0" -a ${#CHUNKS_UPLOADED[@]} = "0" ]; then
		if [ ${#CHUNKS_COMPLETED[@]} != "${NUMBER_OF_ALL_CHUNKS}" ]; then
			echo "There are no chunks left to be uploaded. And there are no uploaded chunks left. This might be an internal error."
		else
			completed="1"
		fi
	fi
done


##############################################
# 5. PRINT REPORT
##############################################

echo "===NEFIAS JOB ${JOBNAME} COMPLETED in $((`date +%s`-${STARTTIME}))sec==="
echo "100.000" > ${NEFIAS_STATUS_FILE}
exit 0

