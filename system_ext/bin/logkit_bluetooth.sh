#!/bin/bash
CURTIME=`date +%F_%H-%M-%S`
config="$1"
defaultLogcatSize=0
globalStatus="0"
tarpath=""
maxindex=0
minpath=""
globalCount=0

function StartDebugBluetooth() {
    echo "StartDebugBluetooth" >> /data/tcl_log/debug.txt
    skwtest_bt="/data/tcl_log/tmp/bluetooth/skwtest"
    if [[ "$(getprop sys.tcl.bt.driver)" != "swt"* ]]; then
        echo "Bluetooth driver is not swt, return" >> /data/tcl_log/debug.txt
        return 1
    fi
    #------------------------------------------------------------------------------
    #setprop persist.vendor.swtfwlog.enable true
    #setenforce 0
    #echo enable > /sys/kernel/debug/skwusb/CPLog
    #echo disable > /sys/kernel/debug/skwusb/recovery
    #echo START > /dev/LOG
    # setprop SKWBT.DRVLOG 1

    #svc bluetooth disable
    #sleep 10
    dmesg -c
    logcat -c	
    chmod 770 /data/misc/bluedroid/skw_bt_log_*
    rm -f /data/misc/bluedroid/skw*

    setprop persist.sys.swtfwlog.enable 1

    log_file="${skwtest_bt}/skwlog_bt.txt"

    if [ ! -d ${skwtest_bt} ];then
        mkdir -p ${skwtest_bt}
    else
        > ${log_file}
    fi

    if [ $(ls ${skwtest_bt} -l | grep '^d' | wc -l) -gt 0 ];then
        rm -rf ${skwtest_bt}/LOG_*
    fi

    #svc bluetooth enable

    logcat -v time| grep -E "BSPASSERT|btm_sec_disconnected|040603[1-9a-fA-F][0-9a-fA-F]8[0-9a-fA-F]00|0406030[1-9a-fA-F]8[0-9a-fA-F]00" > ${log_file} &

    sleep 1

    if [ $(pgrep -f 'logkit_wifi.sh') ];then
        # sh /system_ext/bin/logkit_wifi.sh StopDebugWifi>/dev/null 2>&1 &
        setprop ctl.start   GeorgedebugStopDebugWifi
    fi
    sleep 2
    # sh /system_ext/bin/logkit_wifi.sh StartDebugWifi >/dev/null 2>&1 &
    setprop ctl.start    GeorgedebugStartDebugWifi

    log_thread=$(pgrep -f 'logcat -v time')
    pre_skwbt_log_thread=$(pgrep -f 'SKWBT_LOG')
    if [ ! -z "$pre_skwbt_log_thread" ];then
        kill -9 $pre_skwbt_log_thread
    fi
    START_TS="$(date '+%Y%m%d%H%M%S')"

    while [ `cat /data/tcl_log/debug.txt | grep "DebugBluetooth" | tail -n1 | grep "Start"` ]
    do
        # if SKWBT_LOG not exist, exit log thread
        if [ ! -e '/dev/SKWBT_LOG' ];then
            echo "LOG thread exit, becuase /dev/SKWBT_LOG is not exist." > ${log_file}
            echo "StopDebugBluetooth" >> /data/tcl_log/debug.txt
            break
        fi

        if [ -z "`pgrep -f 'SKWBT_LOG'`" ];then
            START_TS="$(date '+%Y%m%d%H%M%S')"
            cat /dev/SKWBT_LOG > /data/misc/bluedroid/skw_bt_log_$(date '+%Y%m%d%H%M%S').log &
            sleep 1
            chmod 770 /data/misc/bluedroid/skw_bt_log_*
        fi

        if [ -d ${skwtest_bt} ] && [ $(du -m ${skwtest_bt} | tail -n1 | awk '{print $1}') -gt 2000 ];then
            kill -9 $(pgrep -f 'logcat -v time')
            kill -9 $(pgrep -f 'SKWBT_LOG')
            setprop ctl.start   GeorgedebugStopDebugWifi
            setprop ctl.start   GeorgedebugStopDebugBluetooth
            break
        fi

        if [ -f ${log_file} ] && [ -s ${log_file} ];then

            C_TS=$(date '+%Y%m%d%H%M%S')
            echo "Test started at: ${START_TS}" >> ${log_file}
            echo "$(cat ${log_file})" >> ${log_file}
            echo "Test end at: ${C_TS}" >> ${log_file}

            TARGET_LOG_PATH="${skwtest_bt}/LOG_${C_TS}"
            if [ ! -z "$(cat $log_file | grep BSPASSERT)" ];then
                sleep 10
                kill -9 $(pgrep -f 'logcat -v time')
                kill -9 $(pgrep -f 'SKWBT_LOG')
                cp -r /data/misc/bluedroid ${TARGET_LOG_PATH}
                cp /data/tcl_log/skwusb_LOG_* ${TARGET_LOG_PATH}
                cp /data/log* ${TARGET_LOG_PATH}
                chmod 770 -R ${TARGET_LOG_PATH}
                setprop ctl.start   GeorgedebugStopDebugWifi
                break
            else
                kill -9 $(pgrep -f 'SKWBT_LOG')
                cp -r /data/misc/bluedroid ${TARGET_LOG_PATH}
                cp /data/tcl_log/skwusb_LOG_* ${TARGET_LOG_PATH}
                cp /data/log* ${TARGET_LOG_PATH}
                cp -f ${log_file} ${TARGET_LOG_PATH}
                chmod 770 -R ${TARGET_LOG_PATH}
                > ${log_file}
                rm -f /data/misc/bluedroid/skw_bt_log_*.log
                logcat -c
                dmesg -c
                cat /dev/SKWBT_LOG > /data/misc/bluedroid/skw_bt_log_$(date '+%Y%m%d%H%M%S').log &
                sleep 1
                chmod 770 /data/misc/bluedroid/skw_bt_log_*
            fi
        fi
        sleep 3
    done
}

function StopDebugBluetooth() {
    echo "StopDebugBluetooth" >> /data/tcl_log/debug.txt
    if [[ "$(getprop sys.tcl.bt.driver)" != "swt"* ]]; then
        echo "Bluetooth driver is not swt, return" >> /data/tcl_log/debug.txt
        return 1
    fi
    setprop persist.sys.swtfwlog.enable 0
    kill -9 $(pgrep -f 'logcat -v time')
    kill -9 $(pgrep -f 'SKWBT_LOG')
    C_TS=$(date '+%Y%m%d%H%M%S')
    TARGET_LOG_PATH="${skwtest_bt}/LOG_${C_TS}"
    cp -r /data/misc/bluedroid ${TARGET_LOG_PATH}
    cp /data/tcl_log/skwusb_LOG_* ${TARGET_LOG_PATH}
    cp /data/log* ${TARGET_LOG_PATH}
    chmod 770 -R ${TARGET_LOG_PATH}
    cp -f ${skwtest_bt}/skwlog_bt.txt ${TARGET_LOG_PATH}
    rm -f /data/misc/bluedroid/skw_bt_log_*.log
}



case "$config" in
    "StartDebugBluetooth")
      StartDebugBluetooth
     ;;
    "StopDebugBluetooth")
      StopDebugBluetooth
     ;;
     *)
     ;;
esac
