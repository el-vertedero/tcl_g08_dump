#!/bin/sh
#echo "\033[1m \033[4m"
#echo "[AUTOLOG] In get-kmemleak.sh: $1|$2\033[0m"

if [ "$1" == "" ]; then
    KMEMLEAK_LOG=/data/kmemleak.log
else
    KMEMLEAK_LOG=$1/kmemleak.log
fi

if [ "$2" == "" ]; then
    KMEMLEAK_LOG_INTERVAL=600
else
    KMEMLEAK_LOG_INTERVAL=$2
fi

if [ -f $KMEMLEAK_LOG ]; then
    rm -f $KMEMLEAK_LOG
fi

if [ -f $STOP_STRESS_LOG ]; then
    rm -rf $STOP_STRESS_LOG
fi

while :
do
    echo scan > /sys/kernel/debug/kmemleak
    uptime >> $KMEMLEAK_LOG
    echo "--- kmemleakinfo begin ---" >> $KMEMLEAK_LOG
    cat /sys/kernel/debug/kmemleak >> $KMEMLEAK_LOG
    echo "--- kmemleakinfo end ---" >> $KMEMLEAK_LOG

    sleep $KMEMLEAK_LOG_INTERVAL
done
