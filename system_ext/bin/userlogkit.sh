#!/bin/bash
CURTIME=`date +%F_%H-%M-%S`
config="$1"
LOG_PATH=/data/user_log/log

function UserLog() {
    # Create path: /data/user_log/log
    InitLogPath

    # Detect storage
    setprop ctl.start UserDetectStorageService

    # Capture different logs according to different log types
    # 1.Normal
    # 2.Performance
    # 3.Audio
    # 4.Bluetooth
    # 5.Wifi
    # 6.Display
    # 7.HDMI
    # 8.DTV
    # 9.Input Performance
    logtype=`getprop persist.sys.userlogtype`
    PrintLogToFile "Init and start user log, type: ${logtype}"
    if [ "${logtype}" = "normal" ]; then
        InitAndStartNormalLog
    elif [ "${logtype}" = "performance" ]; then
        InitAndStartPerformanceLog
        InitAndStartNormalLog
    elif [ "${logtype}" = "audio" ]; then
        InitAndStartAudioLog
        InitAndStartNormalLog
    elif [ "${logtype}" = "bluetooth" ]; then
        InitAndStartBluetoothLog
        InitAndStartNormalLog
    elif [ "${logtype}" = "wifi" ]; then
        InitAndStartWifiLog
        InitAndStartNormalLog
    elif [ "${logtype}" = "display" ]; then
        InitAndStartPerformanceLog
        InitAndStartDisplayLog
        InitAndStartNormalLog
    elif [ "${logtype}" = "hdmi" ]; then
        InitAndStartHDMILog
        InitAndStartNormalLog
    elif [ "${logtype}" = "dtv" ]; then
        InitAndStartDTVLog
        InitAndStartNormalLog
    elif [ "${logtype}" = "inputperformance" ]; then
        setprop persist.sys.userlog_inputperformance "true"
        setprop persist.sys.userlogstatus "running"
    else
        PrintLogToFile "Log type not exist, type: ${logtype}"
    fi
}

function StopAndTarLog() {
    logtype=`getprop persist.sys.userlogtype`
    PrintLogToFile "--------------STOP--------------"
    PrintLogToFile "Stop and tar user log, type: ${logtype}"

    setprop persist.sys.userlogstatus "prepackaging"
    setprop ctl.stop UserLogService
    setprop ctl.stop UserDetectStorageService
    if [ "${logtype}" = "normal" ]; then
        HandleStopNormalLog
    elif [ "${logtype}" = "performance" ]; then
        setprop ctl.stop StartUserPerformanceLogService
        setprop ctl.start StopUserPerformanceLogService
        sleep 8
        setprop ctl.start UserMvPerformanceLogService
        count=0
        while [ $count -le 60 ] && [ -f ${LOG_PATH}/trace/incomplete_mv_trace ];do
            PrintLogToFile "Trace log has not finished copying, retrying in 1 second"
            count=$((count + 1))
            sleep 1
        done
        PrintLogToFile "Trace log has finished copying"
        HandleStopNormalLog
    elif [ "${logtype}" = "audio" ]; then
        setprop ctl.start UserMvAudioLogService
        count=0
        while [ $count -le 60 ] && [ -f ${LOG_PATH}/audio/incomplete_mv_audio ];do
            PrintLogToFile "Audio log has not finished copying, retrying in 1 second"
            count=$((count + 1))
            sleep 1
        done
        PrintLogToFile "Audio log has finished copying"
        HandleStopNormalLog
    elif [ "${logtype}" = "bluetooth" ]; then
        setprop ctl.start UserMvBluetoothLogService
        count=0
        while [ $count -le 60 ] && [ -f ${LOG_PATH}/bluetooth/incomplete_mv_bluetooth ];do
            PrintLogToFile "Bluetooth log has not finished copying, retrying in 1 second"
            count=$((count + 1))
            sleep 1
        done
        PrintLogToFile "Bluetooth log has finished copying"
        HandleStopNormalLog
    elif [ "${logtype}" = "wifi" ]; then
        setprop ctl.stop UserWifiLogService
        setprop ctl.start UserStopIwprivWifiService
        setprop ctl.start UserStopDebugWifiService
        count=0
        while [ $count -le 60 ] && [ -f ${LOG_PATH}/tcpdump/incomplete_mv_wifi ];do
            PrintLogToFile "Wifi log has not finished copying, retrying in 1 second"
            count=$((count + 1))
            sleep 1
        done
        PrintLogToFile "Wifi log has finished copying"
        HandleStopNormalLog
    elif [ "${logtype}" = "display" ]; then
        # stop Trace log
        setprop ctl.stop StartUserPerformanceLogService
        setprop ctl.start StopUserPerformanceLogService
        # stop screencap
        setprop ctl.stop UserDisplayLogService
        sleep 8
        # start to copy trace and screencap
        setprop ctl.start UserMvPerformanceLogService
        setprop ctl.start UserMvDisplayLogService
        count=0
        while [ $count -le 90 ] && [[ -e ${LOG_PATH}/trace/incomplete_mv_trace || -e ${LOG_PATH}/screencap/incomplete_mv_screencap ]];do
            count=$((count + 1))
            PrintLogToFile "Trace and Screencap log has not finished copying, retrying in 1 second"
            sleep 1
        done
        PrintLogToFile "Trace and Screencap log has finished copying"
        HandleStopNormalLog
        setprop ctl.start UserDisplayLogService
    elif [ "${logtype}" = "hdmi" ]; then
        setprop ctl.start UserHDMIInfoOnFinishService
        sleep 8
        setprop ctl.start UserMvTcliInfoService
        count=0
        while [ $count -le 60 ] && [ -f ${LOG_PATH}/hdmi/incomplete_mv_hdmi ];do
            PrintLogToFile "HDMI log has not finished copying, retrying in 1 second"
            count=$((count + 1))
            sleep 1
        done
        PrintLogToFile "HDMI log has finished copying"
        HandleStopNormalLog
    elif [ "${logtype}" = "dtv" ]; then
        setprop ctl.start UserMvDTVLogService
        count=0
        while [ $count -le 60 ] && [ -f ${LOG_PATH}/dtv/incomplete_mv_dtv ];do
            PrintLogToFile "DTV log has not finished copying, retrying in 1 second"
            count=$((count + 1))
            sleep 1
        done
        PrintLogToFile "DTV log has finished copying"
        HandleStopNormalLog
    elif [ "${logtype}" = "inputperformance" ]; then
        setprop persist.sys.userlog_inputperformance "false"
        sleep 12
        LOG_NAME=$(date +%F_%H-%M-%S)

        # detect storage
        cd /data/
        dataAvailSize=$(df "user_log" | tail -1 | awk '{print $4}')
        logSize=$(du -s "user_log" | awk '{print $1}')
        cd ..
        PrintLogToFile "dataAvailSize:${dataAvailSize}KB, logSize:${logSize}KB"

        if [ ${dataAvailSize} -ge ${logSize}*3 ]; then
            # tar log
            PrintLogToFile "Tar log to /data/user_log/${LOG_NAME}.tar.gz"
            setprop persist.sys.userlogstatus "packaging"
            tar -zcvf  /data/user_log/${LOG_NAME}.tar.gz -C /data/user_log/log/ .
            chmod -R 777 /data/user_log/${LOG_NAME}.tar.gz
            rm -fr  /data/user_log/log
            setprop persist.sys.userlogstatus "stopped"
        else
            PrintLogToFile "System storage full, delete all logs"
            rm -fr  /data/user_log/log
            setprop persist.sys.userlogstatus "err_1"
        fi
    else
        PrintLogToFile "Log type not exist, type: ${logtype}"
    fi
}

function InitLogPath() {
    if [ ! -d  /data/user_log/log/ ]; then
        mkdir -p  ${LOG_PATH}
        chmod -R 777 /data/user_log/
        chmod -R 777 /data/user_log/log
        PrintLogToFile "--------------START--------------"
        PrintLogToFile "Make new dir log path: ${LOG_PATH}"
    else
        PrintLogToFile "--------------REBOOT--------------"
        PrintLogToFile "Path: ${LOG_PATH} exist"
    fi
}

function UserDetectStorage() {
    cd /data/
    while [ true ]; do
        dataAvailSize=$(df "user_log" | tail -1 | awk '{print $4}')
        logSize=$(du -s "user_log" | awk '{print $1}')
        if [ ${dataAvailSize} -ge ${logSize}*10 ]; then
            PrintLogToFile "dataAvailSize:${dataAvailSize}KB, logSize:${logSize}KB, and logging can continue"
        else
            PrintLogToFile "dataAvailSize:${dataAvailSize}KB, logSize:${logSize}KB, and logging can continue, and logging need stop!"
            setprop persist.sys.userlogstatus "err_2"
        fi
        sleep 30
    done
}

function UserDeleteAllLog() {
     if [ -d /data/user_log ];then
         rm -rf /data/user_log/*.tar.gz
         setprop persist.sys.userlog_delete_all "false"
     fi
}

#------------------1.NormalLog Start------------------
function InitAndStartNormalLog(){
    logenable=`getprop persist.sys.userlog`
    boot_completed=`getprop sys.boot_completed`
    if [ "${logenable}" = "true" ] ; then
        if [ x${boot_completed} == x"1" ] ; then
            PrintLogToFile "The system has started, so the log service was triggered by the user"
        else
            PrintLogToFile "The system has not started yet, maybe reboot occurred"
        fi
        setprop ctl.start UserNormalLogService
        setprop ctl.start UserKmsgLogService
    fi
}

# set persist.sys.userlogstatus "running"
function UserNormalLog(){
    logenable=`getprop persist.sys.userlog`
    if [ "${logenable}" = "true" ] ; then
        PrintLogToFile "Start collect normal log"
        setprop persist.sys.userlogstatus "running"
        mkdir -p  ${LOG_PATH}/normal
        /system/bin/logcat -b all -v threadtime -v printable -f ${LOG_PATH}/normal/logcat.log -r 204800 -n 3
    fi
}

function UserKmsgLog(){
    logenable=`getprop persist.sys.userlog`
    if [ "${logenable}" = "true" ] ; then
        PrintLogToFile "Start collect kmsg log"
        mkdir -p  ${LOG_PATH}/kmsg
        cd ${LOG_PATH}/kmsg/
        /system_ext/bin/userklogcat -a
    fi
}

function UserKillUserklogcat() {
    userklogcatpid=`ps -A | grep userklogcat | head -n 1| awk '{print $2}'`
    if [ x"${userklogcatpid}" != x"" ]; then
       kill -9 $userklogcatpid
    fi
}

function HandleStopNormalLog() {
    # start UserDumpSystemService service to dump system info
    setprop ctl.start UserDumpSystemService
    count=0
    while [ $count -le 60 ] && [ ! -f ${LOG_PATH}/dumpsys/finish_dumpsys ];do
        count=$((count + 1))
        sleep 1
    done
    rm -fr ${LOG_PATH}/dumpsys/finish_dumpsys

    setprop ctl.stop UserKmsgLogService
    setprop ctl.start UserKillUserklogcatService
    setprop ctl.stop UserNormalLogService
    sleep 3
    LOG_NAME=$(date +%F_%H-%M-%S)
    # detect storage
    cd /data/
    dataAvailSize=$(df "user_log" | tail -1 | awk '{print $4}')
    logSize=$(du -s "user_log" | awk '{print $1}')
    cd ..
    PrintLogToFile "dataAvailSize:${dataAvailSize}KB, logSize:${logSize}KB"

    if [ ${dataAvailSize} -ge ${logSize}*3 ]; then
        # tar log
        PrintLogToFile "Tar log to /data/user_log/${LOG_NAME}.tar.gz"
        setprop persist.sys.userlogstatus "packaging"
        tar -zcvf  /data/user_log/${LOG_NAME}.tar.gz -C /data/user_log/log/ .
        chmod -R 777 /data/user_log/${LOG_NAME}.tar.gz
        rm -fr  /data/user_log/log
        setprop persist.sys.userlogstatus "stopped"
    else
        PrintLogToFile "System storage full, delete all logs"
        rm -fr  /data/user_log/log
        setprop persist.sys.userlogstatus "err_1"
    fi
}

function UserDumpSystem() {
    mkdir -p  ${LOG_PATH}/dumpsys
    if [ -d ${LOG_PATH}/dumpsys ]; then
        PrintLogToFile "Start dump system info"
        DUMP_LOG_PATH=${LOG_PATH}/dumpsys
        dumpsys -t 20 meminfo > ${DUMP_LOG_PATH}/dumpsys_mem.txt &
        ps -T -A -f > ${DUMP_LOG_PATH}/ps.txt
        export COLUMNS=180
        top -n 2 -s 10 > ${DUMP_LOG_PATH}/top.txt
        export COLUMNS=80
        cat /proc/meminfo > ${DUMP_LOG_PATH}/proc_meminfo.txt
        getprop > ${DUMP_LOG_PATH}/prop.txt
        df > ${DUMP_LOG_PATH}/df.txt
        dumpsys dropbox --print > ${DUMP_LOG_PATH}/dumpsys_dropbox_all.txt
        if [ -f "/dev/binderfs/binder_logs/state" ]; then
            cat /dev/binderfs/binder_logs/state > ${DUMP_LOG_PATH}/binder_state.txt
        else
            cat /d/binder/state > ${DUMP_LOG_PATH}/binder_state.txt
        fi
        dumpsys activity -v all > ${DUMP_LOG_PATH}/activity_all.txt
        dumpsys activity activities > ${DUMP_LOG_PATH}/activities.txt
        dumpsys window -a > ${DUMP_LOG_PATH}/window.txt
        dumpsys SurfaceFlinger > ${DUMP_LOG_PATH}/SurfaceFlinger.txt
        dumpsys gfxinfo > ${DUMP_LOG_PATH}/gfxinfo.txt
        dumpsys activity --proto > ${DUMP_LOG_PATH}/am.pb
        dumpsys window --proto > ${DUMP_LOG_PATH}/wm.pb
        dumpsys SurfaceFlinger --proto > ${DUMP_LOG_PATH}/sf.pb
        dumpsys audio > ${DUMP_LOG_PATH}/audio.txt
        dumpsys media.audio_flinger > ${DUMP_LOG_PATH}/audio_flinger.txt
        dumpsys media.audio_policy > ${DUMP_LOG_PATH}/audio_policy.txt
        dumpsys package > ${DUMP_LOG_PATH}/package.txt
        wait
        PrintLogToFile "Finish dump system info"
        # touch finish_dumpsys when finish dump
        touch ${DUMP_LOG_PATH}/finish_dumpsys
    fi
}
#------------------1.NormalLog End------------------


#----------------2.Performance Start----------------
function InitAndStartPerformanceLog(){
    logenable=`getprop persist.sys.userlog`
    if [ "${logenable}" = "true" ] ; then
        mkdir -p  ${LOG_PATH}/trace
        chmod -R 777 ${LOG_PATH}/trace
        touch ${LOG_PATH}/trace/incomplete_mv_trace
        setprop ctl.start StartUserPerformanceLogService
    fi
}

function StartUserPerformanceLog(){
    logenable=`getprop persist.sys.userlog`
    if [ "${logenable}" = "true" ] ; then
        PrintLogToFile "Start collect performance log"

        echo '
        write_into_file: true

        file_write_period_ms: 1000000000

        buffers {
          size_kb: 102400
        }

        data_sources {
          config {
            name: "linux.ftrace"
            ftrace_config {
              ftrace_events: "sched/sched_switch"
              ftrace_events: "sched/sched_wakeup"
              ftrace_events: "sched/sched_wakeup_new"
              ftrace_events: "sched/sched_waking"
              ftrace_events: "power/cpu_frequency"
              ftrace_events: "power/cpu_idle"
              ftrace_events: "power/gpu_frequency"
              ftrace_events: "sched/sched_process_exit"
              ftrace_events: "sched/sched_process_free"
              ftrace_events: "task/task_newtask"
              ftrace_events: "task/task_rename"
              ftrace_events: "ftrace/print"
              atrace_categories: "gfx"
              atrace_categories: "input"
              atrace_categories: "view"
              atrace_categories: "wm"
              atrace_categories: "am"
              atrace_categories: "hal"
              atrace_categories: "res"
              atrace_categories: "dalvik"
              atrace_categories: "bionic"
              atrace_categories: "pm"
              atrace_categories: "ss"
              atrace_categories: "database"
              atrace_categories: "aidl"
              atrace_categories: "binder_driver"
              atrace_categories: "binder_lock"
              atrace_apps: "*"
            }
          }
        }
        ' | perfetto -c - --txt --detach=userlog_trace -o /data/misc/perfetto-traces/tracelog
    fi
}

function StopUserPerformanceLog() {
    perfetto --attach=userlog_trace --stop
}

function UserMvPerformanceLog() {
    chmod -R 777 /data/misc/perfetto-traces/tracelog
    cp /data/misc/perfetto-traces/tracelog ${LOG_PATH}/trace/

    chmod -R 777 ${LOG_PATH}/trace/*
    rm -rf ${LOG_PATH}/trace/incomplete_mv_trace
    rm -rf /data/misc/perfetto-traces/tracelog
}
#----------------2.Performance End----------------


#------------------3.Audio Start------------------
function InitAndStartAudioLog(){
    logenable=`getprop persist.sys.userlog`
    if [ "${logenable}" = "true" ] ; then
        mkdir -p  ${LOG_PATH}/audio
        chmod -R 777 ${LOG_PATH}/audio
        touch ${LOG_PATH}/audio/incomplete_mv_audio
    fi
}

function UserMvAudioLog() {
     if [ -d /data/audio_dump ];then
         chmod -R 777 /data/audio_dump/*
         cp /data/audio_dump/*.pcm ${LOG_PATH}/audio/
         cp /data/audio_dump/*.bin ${LOG_PATH}/audio/
         rm -rf /data/audio_dump/*.pcm
         rm -rf /data/audio_dump/*.bin
         chmod -R 777 ${LOG_PATH}/audio/*
         rm -rf ${LOG_PATH}/audio/incomplete_mv_audio
     fi
}
#------------------3.Audio End--------------------


#----------------4.Bluetooth Start------------------
function InitAndStartBluetoothLog(){
    logenable=`getprop persist.sys.userlog`
    if [ "${logenable}" = "true" ] ; then
        mkdir -p  ${LOG_PATH}/bluetooth
        chmod -R 777 ${LOG_PATH}/bluetooth
        touch ${LOG_PATH}/bluetooth/incomplete_mv_bluetooth
    fi
}

function UserMvBluetoothLog(){
    if [ -d ${LOG_PATH}/bluetooth ]; then
        cp -a /data/misc/bluedroid/*cfa* ${LOG_PATH}/bluetooth
        chmod -R 777 ${LOG_PATH}/bluetooth/*
        rm -rf ${LOG_PATH}/bluetooth/incomplete_mv_bluetooth
    fi
}
#----------------4.Bluetooth End--------------------


#------------------5.WifiLog Start------------------
function InitAndStartWifiLog(){
    logenable=`getprop persist.sys.userlog`
    if [ "${logenable}" = "true" ] ; then
        setprop ctl.start UserWifiLogService
        setprop ctl.start UserStartDebugWifiService
        setprop ctl.start UserStartIwprivWifiService
    fi
}

function UserWifiLog(){
    logenable=`getprop persist.sys.userlog`
    if [ "${logenable}" = "true" ] ; then
        PrintLogToFile "Start collect wifi log"
        mkdir -p  ${LOG_PATH}/tcpdump
        touch ${LOG_PATH}/tcpdump/incomplete_mv_wifi
        tcpdump -i any -p -n -s 96 ip -W 5 -C 100 -w ${LOG_PATH}/tcpdump/tcpdump.pcap
    fi
}

function UserStartDebugWifi() {
    Version=`getprop ro.build.version.release`
    if [ "${Version}" == "9" ]; then
        svc wifi logon
    fi
    if [ "${Version}" -ge 11 ]; then
        cmd wifi set-verbose-logging enabled
    fi
    if [ -f "/proc/net/wlan/dbg_level" ]; then
        echo 0xff:0x3f > /proc/net/wlan/dbg_level
    fi
    if [ -f "/proc/net/wlan/dbgLevel" ]; then
        rm /data/tcl_log/mtk_fw_log_disable.txt
        echo 0xff:0x3f > /proc/net/wlan/dbgLevel
        echo "set_cfg EvtDrvnLogCatLvl 0xffffff7f" > /proc/net/wlan/driver
        echo "set_cfg FwIdxLogSave 1" > /proc/net/wlan/driver
        echo "set_fwlog 0 2" > /proc/net/wlan/driver
        files=($(ls -1t /data/tcl_log/WIFI_FW*.clog 2>/dev/null))
        file_count=${#files[@]}
        if [ $file_count -gt 1 ]; then
            ls -t /data/tcl_log/WIFI_FW*.clog 2>/dev/null | tail -n +2 | xargs -r rm -f
        fi
        wifi_dump -m 2 -n 2 -s 102400 -p /data/tcl_log/ &
        cat_pid=$!

    while true; do
        if [ -f "/data/tcl_log/mtk_fw_log_disable.txt" ]; then
           kill $cat_pid 2>/dev/null
        break
    fi

        echo "get_cfg EvtDrvnLogCatLvl" > /proc/net/wlan/driver
        output=$(cat /proc/net/wlan/driver 2>&1)
        if [[ "$output" == "0xFFFFFF00" ]]; then
            echo "set_cfg EvtDrvnLogCatLvl 0xffffff7f" > /proc/net/wlan/driver
            echo "set_cfg FwIdxLogSave 1" > /proc/net/wlan/driver
            echo "set_fwlog 0 2" > /proc/net/wlan/driver
        fi
        sleep 1
    done
    fi
    if [ -f "/proc/net/rtl8192fu/log_level" ]; then
        echo 6 > /proc/net/rtl8192fu/log_level
    fi
    if [ -f "/proc/net/rtl8192eu/log_level" ]; then
        echo 6 > /proc/net/rtl8192eu/log_level
    fi
    if [ -f "/sys/kernel/debug/skwusb/CPLog" ]; then
      rm /data/tcl_log/skw_log_disable.txt
      current_file=""
      while true; do
        #save assert memory log. less than 3 files。20251105 BEGIN
        last_logfile=$(ls /data/tcl_log/ -hlt | grep skwusb_LOG | tail -n1 | awk '{print $8}')
        res=$(cat  /data/tcl_log/${last_logfile} | grep -E "VERSION:trunk_W")
        if [ "$res" != "" ];then
            count=$(ls /data/tcl_log -l | grep dump.bin|wc -l)
            if [ $count -lt 6 ]; then
                start_timestamp="$(date '+%Y%m%d%H%M%S')"
                mv  /data/tcl_log/${last_logfile} /data/tcl_log/${start_timestamp}_dump.bin
                if [ "$current_file" != "" ];then
                    mv "$current_file"  /data/tcl_log/${start_timestamp}_1_dump.bin
                fi
                cp -r /data/misc/bluedroid /data/tcl_log/BTLOG_$start_timestamp &
            fi
        fi
        ##save assert memory END
        files=($(ls -1t /data/tcl_log/skwusb_LOG_*.txt 2>/dev/null))
        file_count=${#files[@]}
        if [ $file_count -gt 1 ]; then
            ls -t /data/tcl_log/skwusb_LOG_*.txt 2>/dev/null | tail -n +2 | xargs -r rm -f
        fi
        timestamp=$(date +"%Y%m%d_%H%M%S")
        current_file="/data/tcl_log/skwusb_LOG_$timestamp.txt"
        start_time=$(date +%s)

        cat /dev/LOG >  "$current_file" &
        cat_pid=$!
        while kill -0 $cat_pid 2>/dev/null; do
            if [ -f "/data/tcl_log/skw_log_disable.txt" ]; then
                fsync "$current_file"
                kill $cat_pid 2>/dev/null
                break 2
            fi
            current_time=$(date +%s)
            if [ $((current_time - start_time)) -ge 30 ]; then
                fsync "$current_file"
                start_time=$current_time
            fi
            sleep 1
        done
        wait $cat_pid 2>/dev/null
        fsync "$current_file"
        if [ -f "/data/tcl_log/skw_log_disable.txt" ]; then
            break
        fi
      done
    fi
}

function UserStopDebugWifi() {
    cd ${LOG_PATH}
    if [ ! -d networkLog ]; then
        mkdir networkLog
    fi
    cd networkLog
    iptables -L -n -v >iptable_Lnv.txt
    iptables -t nat -nvL >iptables_nat.txt
    ip rule show >v4_ip_rule_show.txt
    ip route show table all >v4_ip_route_show_table_all.txt
    ip addr >ip_addr.txt
    ifconfig >ifconfig.txt
    dumpsys wifi >wifi_dump.txt
    dumpsys wifip2p >wifip2p_dump.txt
    dumpsys connectivity >connectivity.txt
    dumpsys network_stack >network_stack.txt
    dumpsys netpolicy >netpolicy.txt
    dumpsys network_management >network_management.txt

    if [ -f "/proc/net/wlan/dbg_level" ]; then
        echo 0xff:0x0f >/proc/net/wlan/dbg_level
    fi
    if [ -f "/proc/net/wlan/dbgLevel" ]; then
        echo 0xff:0x0f >/proc/net/wlan/dbgLevel
        echo disable > /data/tcl_log/mtk_fw_log_disable.txt
        echo "set_cfg EvtDrvnLogCatLvl 0xffffff00" > /proc/net/wlan/driver
        echo "set_fwlog 0 0" > /proc/net/wlan/driver
        echo "set_cfg FwIdxLogSave 0" > /proc/net/wlan/driver
        mv /data/tcl_log/WIFI_FW* .
    fi
    if [ -f "/proc/net/rtl8192fu/log_level" ]; then
        echo 2 >/proc/net/rtl8192fu/log_level
    fi
    if [ -f "/proc/net/rtl8192eu/log_level" ]; then
        echo 4 >/proc/net/rtl8192eu/log_level
    fi
    Version=$(getprop ro.build.version.release)
    if [ "${Version}" == "9" ]; then
        svc wifi logoff
    fi
    if [ "${Version}" -ge 11 ]; then
        cmd wifi set-verbose-logging disabled
    fi
    if [ -f "/sys/kernel/debug/skwusb/CPLog" ]; then
        echo disable > /data/tcl_log/skw_log_disable.txt
        echo STOP  > /dev/LOG
        mv /data/tcl_log/skwusb_LOG_*.txt .
        #move dump memory and BT log 20251105
        mv /data/tcl_log/*dump.bin .
        mv /data/tcl_log/BTLOG_* .
        ##move dump memory END
    fi
    rm -rf ${LOG_PATH}/tcpdump/incomplete_mv_wifi
}

function UserStartIwprivWifi() {
  if [ -f "/proc/net/wlan/dbg_level" ]; then
   iwpriv wlan0 driver "set_fwlog 0 2"
   iwpriv wlan0 driver ver
  fi
  if [ -f "/proc/net/wlan/dbgLevel" ]; then
   iwpriv wlan0 driver "set_fwlog 0 2"
   iwpriv wlan0 driver ver
  fi
}

function UserStopIwprivWifi() {
  if [ -f "/proc/net/wlan/dbg_level" ]; then
   iwpriv wlan0 driver "set_fwlog 0 0"
   iwpriv wlan0 driver ver
  fi
  if [ -f "/proc/net/wlan/dbgLevel" ]; then
   iwpriv wlan0 driver "set_fwlog 0 0"
   iwpriv wlan0 driver ver
  fi
}
#------------------5.WifiLog End------------------


#------------------6.Display Start------------------
function InitAndStartDisplayLog(){
    logenable=`getprop persist.sys.userlog`
    if [ "${logenable}" = "true" ] ; then
        mkdir -p  ${LOG_PATH}/screencap
        chmod -R 777 ${LOG_PATH}/screencap
        touch ${LOG_PATH}/screencap/incomplete_mv_screencap
        setprop ctl.start UserDisplayLogService
    fi
}

function UserDisplayLog(){
    logenable=`getprop persist.sys.userlog`
    if [ "${logenable}" = "true" ] ; then
        PrintLogToFile "Start collect display log"
        if [ ! -d /data/local/tmp/screencap ]; then
            mkdir -p /data/local/tmp/screencap
        fi
        count=1
        while [ true ];do
              if [ $count -gt 50 ] ; then
                  count=$((count - 50))
              fi
              PrintLogToFile "Screencap, count:${count}"
              screencap /data/local/tmp/screencap/${count}.png
              chmod -R 777 /data/local/tmp/screencap/${count}.png
              count=$((count + 1))
        done
    else
        rm -rf /data/local/tmp/screencap
    fi
}

function UserMvDisplayLog(){
    cp /data/local/tmp/screencap/*  ${LOG_PATH}/screencap/
    rm -rf ${LOG_PATH}/screencap/incomplete_mv_screencap
}
#------------------6.Display End--------------------


#------------------7.HDMI Start--------------------
function InitAndStartHDMILog(){
    logenable=`getprop persist.sys.userlog`
    if [ "${logenable}" = "true" ] ; then
        mkdir -p  ${LOG_PATH}/hdmi
        chmod -R 777 ${LOG_PATH}/hdmi
        touch ${LOG_PATH}/hdmi/incomplete_mv_hdmi
    fi
}

function UserHDMIInfoOnFinish(){
    if [ -d ${LOG_PATH}/hdmi ]; then
        PrintLogToFile "Start dump hdmi info"
        HDMI_INFO_PATH=${LOG_PATH}/hdmi
        dumpsys hdmi_control > ${HDMI_INFO_PATH}/hdmi_control.txt
        dumpsys audio > ${HDMI_INFO_PATH}/audio.txt
        dumpsys media.audio_flinger > ${HDMI_INFO_PATH}/audio_flinger.txt
        dumpsys media.audio_policy > ${HDMI_INFO_PATH}/audio_policy.txt
        settings get Global hdmi_control_enabled > ${HDMI_INFO_PATH}/hdmi_control_enabled.txt
        setprop ctl.start UserTcliInfoOnFinishService
    fi
}

function UserTcliInfoOnFinish(){
    if [ -f /vendor/tvos/bin/tcli ];then
        export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/vendor/lib:/system/lib:/system/apex/com.android.art.release/lib:/vendor/tvos/libBionic
        if [ ! -d /data/local/tmp/user_log_hdmi ]; then
            mkdir -p /data/local/tmp/user_log_hdmi
            chmod -R 777 /data/local/tmp/user_log_hdmi
        fi
        PrintLogToFile "Start dump tcli info"
        HDMI_INFO_PATH="/data/local/tmp/user_log_hdmi"
        /vendor/tvos/bin/tcli fpi.audio.info all > ${HDMI_INFO_PATH}/audio_info_all.txt
        /vendor/tvos/bin/tcli sita.cec.getSAD > ${HDMI_INFO_PATH}/cec_getSAD.txt
        /vendor/tvos/bin/tcli tos.source.get_input > ${HDMI_INFO_PATH}/source_get_input.txt
        /vendor/tvos/bin/tcli sita.cec.getEDID 0 > ${HDMI_INFO_PATH}/getEDID_0.txt
        /vendor/tvos/bin/tcli sita.cec.getEDID 1 > ${HDMI_INFO_PATH}/getEDID_1.txt
        /vendor/tvos/bin/tcli sita.cec.getEDID 2 > ${HDMI_INFO_PATH}/getEDID_2.txt
        /vendor/tvos/bin/tcli sita.cec.getEDID 3 > ${HDMI_INFO_PATH}/getEDID_3.txt
        /vendor/tvos/bin/tcli tos.signal.get_state > ${HDMI_INFO_PATH}/signal_get_state.txt
        /vendor/tvos/bin/tcli tos.signal.get_timing_info > ${HDMI_INFO_PATH}/signal_get_timing_info.txt
        /vendor/tvos/bin/tcli fpi.video.get_mute > ${HDMI_INFO_PATH}/video_get_mute.txt
    fi
}

function UserMvTcliInfo(){
    cp /data/local/tmp/user_log_hdmi/*  ${LOG_PATH}/hdmi/
    rm -rf /data/local/tmp/user_log_hdmi
    rm -rf ${LOG_PATH}/hdmi/incomplete_mv_hdmi
}
#------------------7.HDMI End--------------------


#------------------8.DTV Start--------------------
function InitAndStartDTVLog(){
    logenable=`getprop persist.sys.userlog`
    if [ "${logenable}" = "true" ] ; then
        mkdir -p  ${LOG_PATH}/dtv
        chmod -R 777 ${LOG_PATH}/dtv
        touch ${LOG_PATH}/dtv/incomplete_mv_dtv
    fi
}

function UserMvDTVLog(){
    cp /userdata/satellite.db  ${LOG_PATH}/dtv/
    cp /userdata/DtvData.db  ${LOG_PATH}/dtv/
    cp /userdata/AtvData.db  ${LOG_PATH}/dtv/
    chmod -R 777 ${LOG_PATH}/dtv/*
    rm -rf ${LOG_PATH}/dtv/incomplete_mv_dtv
}
#------------------8.DTV End--------------------


#------------9.Input Performance Start------------------
function UserInputPerformanceLog(){
    logenable=`getprop persist.sys.userlog_inputperformance`
    if [ "${logenable}" = "true" ] ; then
        PrintLogToFile "Start collect Input performance log"
        setprop ctl.start StartUserInputPerformanceLogService
        sleep 10
        setprop ctl.start UserMvInputPerformanceLogService
        PrintLogToFile "Finish collect Input performance log"
    fi
    setprop persist.sys.userlog_inputperformance_service "false"
}

function StartUserInputPerformanceLog(){
    logenable=`getprop persist.sys.userlog_inputperformance`
    if [ "${logenable}" = "true" ] ; then
        perfetto -o /data/misc/perfetto-traces/tracelog -t 5s sched/sched_switch sched/sched_wakeup sched/sched_wakeup_new sched/sched_waking sched/sched_process_exit sched/sched_process_free ftrace/print gfx input view webview wm am sm hal res dalvik rs bionic power pm ss network binder_driver binder_lock
    fi
}

function UserMvInputPerformanceLog() {
    chmod -R 777 /data/misc/perfetto-traces/tracelog
    TRACE_NAME=$(date +%F_%H-%M-%S)
    cp /data/misc/perfetto-traces/tracelog ${LOG_PATH}/${TRACE_NAME}
    chmod -R 777 ${LOG_PATH}/${TRACE_NAME}
}

#------------9.Input Performance End------------------

#------------------10.Pmode USB Log Start (ported from logkit.sh, pmode usb log to udisk)------------------

function PmodeGetMaxIndex() {
    INDEX_LIST=$(ls android_[0-9][0-9][0-9][0-9]_*.txt | cut -d "_" -f2)
    logindex=0
    for index in $INDEX_LIST; do
        index=$(echo ${index} | awk '{printf("%d",$1)}')
        if [ ${logindex} -lt ${index} ]; then
            logindex=$(expr ${index})
        fi
    done
    maxindex=$(expr ${logindex})
    setprop sys.log.maxindex ${maxindex}
    echo "PmodeGetMaxIndex maxindex= ${maxindex}"
}

function PmodeUsbLogcat() {
    local type=$1
    currenttime=$(date +%F_%H-%M-%S)
    usbdir=$(grep -e "/media_rw/" /proc/mounts | awk '{print $2}' | head -1)
    echo "usbdir=$usbdir"
    if [ ! -n "$usbdir" ]; then
        echo "Usb dir null"
    else
        if [ -f $usbdir/sitalog.txt ]; then
            if [ ! -d $usbdir/tcl_log/sitalog ]; then
                mkdir -p $usbdir/tcl_log/sitalog
            fi
            cd $usbdir/tcl_log/sitalog
            maxindex=$(getprop sys.log.maxindex)
            maxindex=$(expr ${maxindex} + 1)
            maxindex=$(echo ${maxindex} | awk '{printf("%04d\n",$0)}')
            echo "PmodeUsbLogcat ${type} ${maxindex}"
            if [ "${type}" == "main" ]; then
                /system/bin/logcat -f android_${maxindex}_${currenttime}.txt -v threadtime
            elif [ "${type}" == "event" ]; then
                /system/bin/logcat -b events -f events_${maxindex}_${currenttime}.txt -v threadtime
            elif [ "${type}" == "kernel" ]; then
                /system_ext/bin/klogkitlogcat -f kmsg_${maxindex}_${currenttime}.txt
            fi
        fi
    fi
}

function PmodeUsbLogcatMain() {
    PrintLogToFile "[userlogkit] PmodeUsbLogcatMain called from userlogkit.rc"
    logenable=$(getprop persist.sys.usblog)
    if [ "${logenable}" = "true" ]; then
        logdsize=$(getprop persist.logd.size)
        if [ "${logdsize}" = "" ]; then
            /system/bin/logcat -G 5M
        fi
        PmodeUsbLogcat "main"
    fi
}

function PmodeUsbLogcatEvent() {
    PrintLogToFile "[userlogkit] PmodeUsbLogcatEvent called from userlogkit.rc"
    logenable=$(getprop persist.sys.usblog)
    if [ "${logenable}" = "true" ]; then
        PmodeUsbLogcat "event"
    fi
}

function PmodeUsbLogcatKernel() {
    PrintLogToFile "[userlogkit] PmodeUsbLogcatKernel called from userlogkit.rc"
    logenable=$(getprop persist.sys.usblog)
    if [ "${logenable}" = "true" ]; then
        PmodeUsbLogcat "kernel"
    fi
}

function PmodeSetEnvironment() {
    PrintLogToFile "[userlogkit] PmodeSetEnvironment called from userlogkit.rc"
    dumpsys settings tlog set DEBUG 1
}

function PmodeStartNewLogcat() {
    local usbdir=$1
    cd $usbdir/tcl_log/sitalog/
    PmodeGetMaxIndex
    tempindex=$(echo ${maxindex} | awk '{printf("%04d\n",$0)}')
    count=$(ls android_${tempindex}_*.txt events_${tempindex}_*.txt kmsg_${tempindex}_*.txt | wc -l)
    echo "PmodeStartNewLogcat now ${tempindex} count=${count}"
    if [ $count -ge 1 ]; then
        sum=0
        ALL_FILE=$(ls -t android_${tempindex}_*.txt events_${tempindex}_*.txt kmsg_${tempindex}_*.txt)
        for path in $ALL_FILE; do
            fileSize=$(du -s $path | awk '{print $1}')
            sum=$(expr ${sum} + ${fileSize})
            echo "add ${path} ${fileSize} to sum=${sum}"
            MaxLogsize=$(echo | awk '{printf("%d",1*200*1024)}')
            if [ ${sum} -ge ${MaxLogsize} ]; then
                setprop ctl.stop PmodeUsbLogcatMain
                setprop ctl.stop PmodeUsbLogcatEvent
                setprop ctl.stop PmodeUsbLogcatKernel
                echo "PmodeStartNewLogcat ${maxindex}"
                setprop ctl.start PmodeUsbLogcatMain
                setprop ctl.start PmodeUsbLogcatEvent
                setprop ctl.start PmodeUsbLogcatKernel
                echo "PmodeWatchLogcat--start new usb Log"
            fi
        done
    fi
}

function PmodeDeleteLastUsbLog() {
    local usbdir=$1
    cd $usbdir/tcl_log/sitalog/
    usbAvailSize=$(df "$usbdir" | tail -1 | awk '{print $4}')
    echo "PmodeWatchLogcat--usbAvailSize=${usbAvailSize}--needToClearSize=${needToClearSize}"
    if [ ${usbAvailSize} -lt ${needToClearSize} ]; then
        cleansize=$(expr ${needToClearSize} - ${usbAvailSize})
        INDEX_LIST=$(ls android_[0-9][0-9][0-9][0-9]_*.txt | cut -d "_" -f2 | awk '{printf("%d ",$1)}' | sort)
        sum=0
        minpath=""
        for index in $INDEX_LIST; do
            tempindex=$(echo ${index} | awk '{printf("%04d\n",$0)}')
            ALL_FILE=$(ls -t android_${tempindex}_*.txt events_${tempindex}_*.txt kmsg_${tempindex}_*.txt)
            for path in $ALL_FILE; do
                fileSize=$(du -s $path | awk '{print $1}')
                sum=$(expr ${sum} + ${fileSize})
                if [ "${minpath}" == "" ]; then
                    minpath="${path}"
                    continue
                fi
                minpath="${minpath} ${path}"
            done
            if [ ${sum} -gt ${cleansize} ]; then
                echo "log size over ${cleansize}"
                break
            fi
        done
        for path in ${minpath}; do
            echo "" >${path}
            rm -rf ${path}
            echo "PmodeWatchLogcat--delete-${path}"
        done
    fi
}

function PmodeWatchLogcat() {
    PrintLogToFile "[userlogkit] PmodeWatchLogcat called from userlogkit.rc"
    needToClearSize=$(echo | awk '{printf("%d",1*600*1024)}')
    while [ true ]; do
        logkitenable=$(getprop persist.sys.normallog)
        if [ "${logkitenable}" == "true" ]; then
            echo "PmodeWatchLogcat--exit because logkit start"
            setprop persist.sys.usblog false
            return
        fi
        usbdir=$(grep -e "/media_rw/" /proc/mounts | awk '{print $2}' | head -1)
        echo "usbdir=$usbdir"
        if [ ! -n "$usbdir" ]; then
            echo "Usb dir null,return"
            break
        else
            if [ -d $usbdir/tcl_log ]; then
                PmodeDeleteLastUsbLog $usbdir
                PmodeStartNewLogcat $usbdir
            fi
            sleep 300
            logenable=$(getprop persist.sys.usblog)
            if [ "${logenable}" != "true" ]; then
                echo "PmodeWatchLogcat--exit"
                return
            fi
        fi
    done
}

function PmodeUsbInitLog() {
    PrintLogToFile "[userlogkit] PmodeUsbInitLog called from userlogkit.rc"
    logenable=$(getprop persist.sys.usblog)
    if [ "${logenable}" = "true" ]; then
        usbdir=$(grep -e "/media_rw/" /proc/mounts | awk '{print $2}' | head -1)
        count=0
        while [ ! -n "$usbdir" ] && [ $count -lt 60 ]; do
            count=$((count + 1))
            sleep 1
            usbdir=$(grep -e "/media_rw/" /proc/mounts | awk '{print $2}' | head -1)
            if [ ! -n "$usbdir" ]; then
                echo "Usb dir null,return count= ${count}"
            fi
        done
        if [ ! -n "$usbdir" ]; then
            echo "Usb dir null,return"
            return
        fi
        if [ ! -d $usbdir/tcl_log/sitalog ]; then
            mkdir -p $usbdir/tcl_log/sitalog
        fi
        cd $usbdir/tcl_log/sitalog/
        PmodeGetMaxIndex
        setprop ctl.start PmodeSetEnvironment
        setprop ctl.start PmodeUsbLogcatMain
        setprop ctl.start PmodeUsbLogcatEvent
        setprop ctl.start PmodeUsbLogcatKernel
        setprop ctl.start PmodeWatchLogcat
    fi
}

#------------------10.Pmode USB Log End------------------

function PrintLogToFile() {
    log_cur_time=$(date +%F_%H:%M:%S)
    echo "[${log_cur_time}] $*" | tee -a /data/user_log/log/logkit_keyevents.txt
}

case "$config" in
    "UserLog")
     UserLog
     ;;
    "UserDetectStorage")
     UserDetectStorage
     ;;
    "UserDeleteAllLog")
     UserDeleteAllLog
     ;;
    "UserNormalLog")
     UserNormalLog
     ;;
    "UserKmsgLog")
     UserKmsgLog
     ;;
    "UserKillUserklogcat")
     UserKillUserklogcat
     ;;
    "UserDumpSystem")
     UserDumpSystem
     ;;
    "UserWifiLog")
     UserWifiLog
     ;;
    "UserStartDebugWifi")
     UserStartDebugWifi
     ;;
    "UserStopDebugWifi")
     UserStopDebugWifi
     ;;
    "UserStartIwprivWifi")
     UserStartIwprivWifi
     ;;
    "UserStopIwprivWifi")
     UserStopIwprivWifi
     ;;
    "UserDisplayLog")
     UserDisplayLog
     ;;
    "UserMvDisplayLog")
     UserMvDisplayLog
     ;;
    "UserHDMIInfoOnFinish")
     UserHDMIInfoOnFinish
     ;;
    "UserTcliInfoOnFinish")
     UserTcliInfoOnFinish
     ;;
    "UserMvTcliInfo")
     UserMvTcliInfo
     ;;
    "StartUserPerformanceLog")
     StartUserPerformanceLog
     ;;
    "StopUserPerformanceLog")
     StopUserPerformanceLog
     ;;
    "UserMvPerformanceLog")
     UserMvPerformanceLog
     ;;
    "UserMvAudioLog")
     UserMvAudioLog
     ;;
    "UserMvBluetoothLog")
     UserMvBluetoothLog
     ;;
    "UserDumpAudio")
     UserDumpAudio
     ;;
    "UserMvDTVLog")
     UserMvDTVLog
     ;;
    "UserInputPerformanceLog")
     UserInputPerformanceLog
     ;;
    "StartUserInputPerformanceLog")
     StartUserInputPerformanceLog
     ;;
    "UserMvInputPerformanceLog")
     UserMvInputPerformanceLog
     ;;
    "StopAndTarLog")
     StopAndTarLog
     ;;
    "PmodeUsbInitLog")
     PmodeUsbInitLog
     ;;
    "PmodeUsbLogcatMain")
     PmodeUsbLogcatMain
     ;;
    "PmodeUsbLogcatEvent")
     PmodeUsbLogcatEvent
     ;;
    "PmodeUsbLogcatKernel")
     PmodeUsbLogcatKernel
     ;;
    "PmodeWatchLogcat")
     PmodeWatchLogcat
     ;;
    "PmodeSetEnvironment")
     PmodeSetEnvironment
     ;;
     *)
     ;;

esac
