#!/bin/bash

set -x

source ./conf/common.conf || exit -3

${local_hadoop_cmd} fs -rmr $OUTPUT_PATH
${local_hadoop_cmd} fs -rmr $RESULT_PATH
${local_hadoop_cmd} fs -mkdir $RESULT_PATH


${local_hadoop_cmd} bistreaming \
    -D mapred.job.priority="VERY_HIGH" \
    -D mapred.job.map.capacity=100 \
    -D mapred.job.map.tasks=100 \
    -D mapred.job.reduce.capacity=1000 \
    -D mapred.reduce.tasks=100 \
    -D mapred.max.reduce.failures.percent=2 \
    -input $INPUT_PATH \
    -output $OUTPUT_PATH \
    -mapper "cat -" \
    -reducer "sh map.sh" \
    -jobconf mapred.job.name=guoweilin_shixiao_gif \
    -inputformat "org.apache.hadoop.mapred.SequenceFileAsBinaryInputFormat" \
    -outputformat "org.apache.hadoop.mapred.SequenceFileAsBinaryOutputFormat" \
    -file "conf/common.conf" \
    -file "conf/ndbstore.conf" \
    -file "shell/map.sh" \
    -file "shell/pack" \
    -file "shell/convert" \
    -file "shell/dump_v" \
    -file "shell/list2kv" \
    -file "shell/dbstore_with_timestamp.32" \
    -file "conf/hadoop-site.xml" \
    -cacheArchive ${FFMPEG_PATH}#ffmpeg


if [ $? -ne 0 ];then
    echo "mysql hadoop error"
#    date=`date +"%Y-%m-%d %H:%M:%S"`
#    echo "$data mysql tuji failed" | mail -s "mysql tuji" ${mail_list}
    exit 1
fi


exit 0
