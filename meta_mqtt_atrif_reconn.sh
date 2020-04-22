#!/bin/bash -e

SLAVE_CONFIG=1slaves.cfg
WAIT_SEC=5
CHUNKSIZE=35000

FILES_WITHCC_QOS_NULL="`/bin/ls recordings/MQTT5_I5/Measurements/WithCC/QoS0/*.csv`"
FILES_WITHCC_QOS_ONE="`/bin/ls recordings/MQTT5_I5/Measurements/WithCC/QoS1/*.csv`"
FILES_WITHOUTCC_QOS_NULL="`/bin/ls recordings/MQTT5_I5/Measurements/WithoutCC/QoS0/*.csv`"
FILES_WITHOUTCC_QOS_ONE="`/bin/ls recordings/MQTT5_I5/Measurements/WithoutCC/QoS1/*.csv`"

for recording in $FILES_WITHCC_QOS_NULL $FILES_WITHCC_QOS_ONE $FILES_WITHOUTCC_QOS_NULL $FILES_WITHOUTCC_QOS_ONE; do
	./nefias_master.sh --add-values="mqtt.topic,mqtt.msgtype,mqtt.clientid" --slave-hostconfig=$SLAVE_CONFIG --slave-script=scripts/MQTT_ArtificialRecon_multiple_winsize.sh --traffic-source=${recording} --jobname="MQTT5_I5_`basename ${recording}`_$RANDOM" --allbusy-waitsec=$WAIT_SEC --chunk-size-in-lines=$CHUNKSIZE
done
exit 0

