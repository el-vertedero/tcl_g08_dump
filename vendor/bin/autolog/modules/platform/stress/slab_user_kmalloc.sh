#!/bin/sh
#echo "\033[1m \033[4m"
#echo "[AUTOLOG] In slab_user_kmalloc.sh: $1|$2\033[0m"

if [ -d /sys/kernel/debug/slab ]; then
    if [ ! -f /sys/kernel/debug/slab/kmalloc-256/alloc_traces ]; then
        echo "\033[1m \033[4m"
        echo "[AUTOLOG] ERROR: Please add \"addbootargs slub_debug FPUZ\" in MBOOT!\033[0m"
        return 1
    fi
fi

if [ "$1" == "" ]; then
    SLAB_LOG_DIR=/data/slab
else
    SLAB_LOG_DIR=$1/slab
fi

if [ "$2" == "" ]; then
    SLAB_LOG_INTERVAL=600
else
    SLAB_LOG_INTERVAL=$2
fi

if [ -d $SLAB_LOG_DIR ]; then
    rm -rf $SLAB_LOG_DIR
fi

mkdir $SLAB_LOG_DIR

while :
do
    tname=`date +%Y%m%d%H%M%S`
    log_file_kmalloc_128=$SLAB_LOG_DIR/${tname}_kmalloc_128.log
    cat /sys/kernel/debug/slab/kmalloc-128/alloc_traces > $log_file_kmalloc_128
    log_file_kmalloc_256=$SLAB_LOG_DIR/${tname}_kmalloc_256.log
    cat /sys/kernel/debug/slab/kmalloc-256/alloc_traces > $log_file_kmalloc_256
    log_file_kmalloc_512=$SLAB_LOG_DIR/${tname}_kmalloc_512.log
    cat /sys/kernel/debug/slab/kmalloc-512/alloc_traces > $log_file_kmalloc_512
    log_file_kmalloc_1k=$SLAB_LOG_DIR/${tname}_kmalloc_1k.log
    cat /sys/kernel/debug/slab/kmalloc-1k/alloc_traces > $log_file_kmalloc_1k
    log_file_kmalloc_2k=$SLAB_LOG_DIR/${tname}_kmalloc_2k.log
    cat /sys/kernel/debug/slab/kmalloc-2k/alloc_traces > $log_file_kmalloc_2k
    log_file_kmalloc_4k=$SLAB_LOG_DIR/${tname}_kmalloc_4k.log
    cat /sys/kernel/debug/slab/kmalloc-4k/alloc_traces > $log_file_kmalloc_4k
    log_file_kmalloc_8k=$SLAB_LOG_DIR/${tname}_kmalloc_8k.log
    cat /sys/kernel/debug/slab/kmalloc-8k/alloc_traces > $log_file_kmalloc_8k
    sleep $SLAB_LOG_INTERVAL
done
