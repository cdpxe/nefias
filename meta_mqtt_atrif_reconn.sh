#!/bin/bash -e

SLAVE_CONFIG=1slaves.cfg # both just sw-sun nefias1+2
WAIT_SEC=5
CHUNKSIZE=35000

FILES_WITHCC_QOS_NULL="`/bin/ls recordings/MQTT5_I5/Measurements/WithCC/QoS0/*.csv`"
FILES_WITHCC_QOS_ONE="`/bin/ls recordings/MQTT5_I5/Measurements/WithCC/QoS1/*.csv`"
FILES_WITHOUTCC_QOS_NULL="`/bin/ls recordings/MQTT5_I5/Measurements/WithoutCC/QoS0/*.csv`"
FILES_WITHOUTCC_QOS_ONE="`/bin/ls recordings/MQTT5_I5/Measurements/WithoutCC/QoS1/*.csv`"

for recording in $FILES_WITHCC_QOS_NULL; do
	# check file $num for WithCC AES 4T
	./nefias_master.sh --add-values="mqtt.topic,mqtt.msgtype,mqtt.clientid" --slave-hostconfig=$SLAVE_CONFIG --slave-script=scripts/MQTT_ArtificialRecon_multiple_winsize.sh --traffic-source=${recording} --jobname="MQTT5_I4_`basename ${recording}`_$RANDOM" --allbusy-waitsec=$WAIT_SEC --chunk-size-in-lines=$CHUNKSIZE
done

for recording in $FILES_WITHCC_QOS_ONE; do
	# check file $num for WithCC AES 4T
	./nefias_master.sh --add-values="mqtt.topic,mqtt.msgtype,mqtt.clientid" --slave-hostconfig=$SLAVE_CONFIG --slave-script=scripts/MQTT_ArtificialRecon_multiple_winsize.sh --traffic-source=${recording} --jobname="MQTT5_I4_`basename ${recording}`_$RANDOM" --allbusy-waitsec=$WAIT_SEC --chunk-size-in-lines=$CHUNKSIZE
done

for recording in $FILES_WITHOUTCC_QOS_NULL; do
	# check file $num for WithCC AES 4T
	./nefias_master.sh --add-values="mqtt.topic,mqtt.msgtype,mqtt.clientid" --slave-hostconfig=$SLAVE_CONFIG --slave-script=scripts/MQTT_ArtificialRecon_multiple_winsize.sh --traffic-source=${recording} --jobname="MQTT5_I4_`basename ${recording}`_$RANDOM" --allbusy-waitsec=$WAIT_SEC --chunk-size-in-lines=$CHUNKSIZE
done

for recording in $FILES_WITHOUTCC_QOS_ONE; do
	# check file $num for WithCC AES 4T
	./nefias_master.sh --add-values="mqtt.topic" --slave-hostconfig=$SLAVE_CONFIG --slave-script=scripts/MQTT_ArtificialRecon_multiple_winsize.sh --traffic-source=${recording} --jobname="MQTT5_I4_`basename ${recording}`_$RANDOM" --allbusy-waitsec=$WAIT_SEC --chunk-size-in-lines=$CHUNKSIZE
done


