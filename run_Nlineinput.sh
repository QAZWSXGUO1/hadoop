#!/bin/bash

set -x

source ./conf/common.conf || exit -3

#UNIQ_PATH="/user/img-build/guoweilin/test"
$local_hadoop_cmd fs -ls ${UNIQ_PATH} | awk 'NF > 3{print $NF}' > ./data/file.list.conf
${local_hadoop_cmd} fs -rm ${dbuild_dir}/conf/file.list.conf
${local_hadoop_cmd} fs -put ./data/file.list.conf ${dbuild_dir}/conf
${local_hadoop_cmd} fs -rmr $OUTPUT_TMP

${local_hadoop_cmd} fs -rmr $MCPACK_PATH
${local_hadoop_cmd} fs -mkdir $MCPACK_PATH
${local_hadoop_cmd} fs -rmr $MCKV_PATH
${local_hadoop_cmd} fs -mkdir $MCKV_PATH
${local_hadoop_cmd} fs -rmr $SIGN_PATH
${local_hadoop_cmd} fs -mkdir $SIGN_PATH
${local_hadoop_cmd} fs -rmr $CONTSIGN_PATH
${local_hadoop_cmd} fs -mkdir $CONTSIGN_PATH

${local_hadoop_cmd} streaming \
    -D mapred.job.priority="VERY_HIGH" \
    -D mapred.job.map.capacity=400 \
    -D mapred.job.map.tasks=10 \
    -D mapred.job.reduce.capacity=20 \
    -D mapred.reduce.tasks=20 \
    -D mapred.max.reduce.failures.percent=2 \
    -D mapred.line.input.format.linespermap="1" \
    -D stream.memory.limit=4000 \
    -D mapred.job.name=guoweilin_tuji_ndi \
    -D mapred.map.tasks.speculative.execution=false \
    -input ${dbuild_dir}/conf/file.list.conf \
    -output $OUTPUT_TMP \
    -mapper "sh -x ndi.sh" \
    -reducer NONE \
    -inputformat "org.apache.hadoop.mapred.lib.NLineInputFormat" \
    -file "conf/common.conf" \
    -file "conf/hadoop-site.xml" \
    -file "shell/ndi.sh" \
    -file "shell/run_write_mcpack.py" \
    -file "shell/mcpack.py" \
    -file "shell/_mcpack.so" \
    -file "shell/imgset_pb2.pyc" \
    -file "shell/imgset_pb2.py" \
    -file "shell/run_write_pb.py" \
    -file "shell/run_crop_midpic.py" \
    -file "shell/run_obj.py" \
    -file "bin/compress_kv" \
    -file "bin/get_sign" \
    -file "conf/compress.conf" \
    -file "conf/ndbstore_cm.conf" \
    -file "bin/ndbstore" \
    -cacheArchive ${PYTHON_PATH}#python \
    -cacheArchive ${SEQ_PATH}#sequence_file \


if [ $? -ne 0 ];then
    echo "mysql hadoop error"
#    date=`date +"%Y-%m-%d %H:%M:%S"`
#    echo "$data mysql tuji failed" | mail -s "mysql tuji" ${mail_list}
    exit 1
fi


exit 0
