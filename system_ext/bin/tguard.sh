#!/bin/bash
config="$1"

function LogcatKernel(){
    log_path=`getprop sys.tms.kernel_path`
    if [ "$log_path" =  "" ];then
        log_path = "/data/tmp/tguard_tms"
    fi
    if [ ! -d $log_path  ]; then
        mkdir -p $log_path
    fi
    touch $log_path/kmsg.log
    chmod -R 776 $log_path
    chown -R system:system $log_path
    /system_ext/bin/klogkitlogcat -f $log_path/kmsg.log
}

case "$config" in
    "LogcatKernel")
     LogcatKernel
     ;;
     *)
     ;;
esac