#!/sbin/sh
# AUTHOR: Chunhui.kang & Xiaolu & Pinter

echo "\033[1m \033[4m"
echo "NOTES: \033[0m"
echo "parm: start/end"
echo "VERSION: 2019.5.8,Fix bug,loop 180s"
echo "VERSION: 2019.5.11,New auto_untar_merge_logcat.py for python"
echo "VERSION: 2020.8.10,Change logcat -f $file to logcat > $file"
echo "VERSION: 2020.8.20,Save kmsg to /data, add more pre-settings"
echo "VERSION: 2020.10.14,cat vmallocinfo to mMemDebug_stress.log"
echo "VERSION: 2021.01.11,change usb path from /storage to /mnt and add dump data info of du and df"
echo "VERSION: 2021.02.17, remove \"unpurged vm_area\" from vmallocinfo"
echo "VERSION: 2021/05/18 For M6"
echo "VERSION: 2021/05/18 Add screencap"
echo "VERSION: 2021/05/31 modify USB path detect"
echo "VERSION: 2021/07/22 remove dtv_svc debug info and add dumpsys package and backup function of ANR, tombstones and dropbox"
echo "VERSION: 2021/07/28 modify path of auto gen generate_merge_logcat_script"
echo "VERSION: 2021/08/05 remove stay awak"
echo "VERSION: 2021/09/29 tar AN_error to save copy time "
echo "VERSION: 2021/11/03 enable mm & display log"
echo "VERSION: 2021/11/04 add getevent"
echo "VERSION: 2021/11/08 add dump iommu memory info"
echo "VERSION: 2021/11/16 add zygote pid info"
echo "VERSION: 2022/01/12 set loglevel 4 for kernel"
echo "VERSION: 2022/04/18 add tool to check memory leak"

echo "for example: "
echo "       stress_test.sh start"
echo "       optional parameters: memory/thread/wakelock/kernel/SQA"
echo "       stress_test.sh end"

if [ ! -n "$1" ]; then
    echo "plz reference\033[1m \033[4m NOTES \033[0m"
    exit
fi

STOP_STRESS_LOG=$AUTOLOG_LOG_DEFAULT_DIR/stop_stress_log
LOG_DIR=$3
thread_leak_over200_pid_path=/data/thread_leak/process_200.txt
thread_leak_over500_pid_path=/data/thread_leak/process_500.txt
thread_leak_over1000_pid_path=/data/thread_leak/process_1000.txt
PS_date_path=/data/PS_data.log

#capture meminfo for memory leakage.
capture_top()
{
    echo "@@@@@@@ memory dump start @@@@@@@"
    echo "@@@@@@@ script ver 2020.10.14 @@@@@@@" >> /data/top.log
    date +%Y/%m/%d-%H:%M:%S >> /data/top.log
    uptime >> /data/top.log
    echo "@@ top @@" >> /data/top.log
    top -n 1 >> /data/top.log
    echo "@@@@@@@ ===================== @@@@@@@" >> /data/top.log
}

#dump mediatek app threads.
capture_com_mediatek_app_threads()
{
    tinfo=`date +%Y%m%d%H%M%S`
    ps -A | grep com.mediatek > /data/ps_mediatek.txt;sync
    cat /data/ps_mediatek.txt | while read LINE
    do
        #echo $LINE
        PNAME=`echo $LINE | awk '{ print $9 }'`
        #echo $PNAME
        PID=`echo $LINE | awk '{ print $2 }'`
        #echo $PID
        THREADS=`cat /proc/$PID/status | grep Threads`
        #echo $THREADS
        echo "${tinfo} ${PNAME}:${PID} --- ${THREADS}" >> /data/ps_mediatek_info.txt

        if [ `echo $THREADS | awk {'print$2'}` -gt 200 ]; then
            echo "${PID} thread leak --- ${THREADS}"
            cat $thread_leak_over200_pid_path | while read LINE2
            do
                if [ $PID -eq $LINE2 ]; then
                break
            fi
            done
            echo $PID >> $thread_leak_over200_pid_path
            touch /data/thread_leak/thread_info_over_200_$PID.log
            ps -T -p $PID > /data/thread_leak/thread_info_over_200_$PID.log
        fi

        if [ `echo $THREADS | awk {'print$2'}` -gt 500 ]; then
            echo "${PID} thread leak --- ${THREADS}"
            cat $thread_leak_over500_pid_path | while read LINE2
            do
                if [ $PID -eq $LINE2 ]; then
                break
            fi
            done
            echo $PID >> $thread_leak_over500_pid_path
            touch /data/thread_leak/thread_info_over_500_$PID.log
            ps -T -p $PID > /data/thread_leak/thread_info_over_500_$PID.log
        fi

        if [ `echo $THREADS | awk {'print$2'}` -gt 1000 ]; then
            echo "${PID} thread leak --- ${THREADS}"
            cat thread_leak_over1000_pid_path | while read LINE3
            do
                if [ $PID -eq $LINE3 ]; then
                break
            fi
            done
            echo $PID >> $thread_leak_over1000_pid_path
            touch /data/thread_leak/thread_info_over_1000_$PID.log
            ps -T -p $PID > /data/thread_leak/thread_info_over_1000_$PID.log
        fi

    done
}

print_kernel_log_level()
{
    kernel_log_level=$(cat /proc/sys/kernel/printk | awk {'print$1'} )
    echo "kernel log level is $kernel_log_level"
}

setup_stress_setting()
{
    echo "setup_stress_setting"
    #screen saver setting
    echo "Screen saver->When to start->After 2 hours of inactivity"
    settings put system screen_off_timeout 2147483647
    echo "Screen saver->Put device to Sleep->Never"
    settings put secure sleep_timeout -1

    #Power Setting：
    echo "Power->Sleep Timer->off"
    settings put global REMIND_TIME 0
    echo "Power->Switch off timer ->off"
    settings put global power_switch_off_timer 0
    echo "No Signal Auto Power off->off"
    settings put global no_signal_auto_power_off 0

    #close HDMI CEC：
    echo "Inputs->HDMI control->off"
    settings put global hdmi_control_enabled 0
    echo "Inputs->Device auto power off->off"
    settings put global hdmi_control_auto_device_off_enabled 0
    echo "Inputs->TV auto power on->off"
    settings put global hdmi_control_auto_wakeup_enabled 0


    #Auto Sleep:Never
    echo "enter input source(eg:DTV)"
    echo "Menu->Power->Auto Sleep->Never"
    settings put secure attentive_timeout  -1

    #Enbale ADB:
    echo "Enable Developer Option->ON"
    settings put global development_settings_enabled 1

}

teardown_stress_setting()
{
    echo "teardown_stress_setting"
    #screen saver setting
    settings put system screen_off_timeout 600000
    settings put secure sleep_timeout 1800000


    #Power Setting：
    #settings put global REMIND_TIME 0
    settings delete global power_switch_off_timer
    settings put global no_signal_auto_power_off 2

    #close HDMI CEC：
    settings delete global hdmi_control_enabled
    settings put global hdmi_control_auto_device_off_enabled 1
    settings delete global hdmi_control_auto_wakeup_enabled

    settings put secure attentive_timeout -1

    #Enbale ADB:
    settings put global development_settings_enabled 0
    settings put global adb_enabled 1
}


enable_getevent()
{
    echo "enable getevent"
    getevent -tl &
}

#clear logcat thread.
kill_logcat()
{
    if [ -f /data/ps_tmp.txt ]; then
        rm /data/ps_tmp.txt
    fi
    ps -A | grep ' logcat' | grep -v grep

    k2logcat=$(pgrep k2logcat)

    pgrep logcat > /data/ps_tmp.txt
    for line in $(cat /data/ps_tmp.txt)
    do
        if [ $line == $k2logcat ]; then
            continue
        fi
        echo "kill logcat thread:$line"
        kill $line
    done
}

# enable kmemleak monitoring
enable_kmemleak_monitoring()
{
    if [ -f /sys/kernel/debug/kmemleak ]; then
        rm -rf /data/kmemleak.log
        sh $AUTOLOG_MODULES_DIR/platform/stress/get-kmemleak.sh /data 600 &
        KMEMLEAK_LOG_PID=$!
        #echo "kmemleak_log_pid=$KMEMLEAK_LOG_PID"
        echo "kmemleak_log_pid=$KMEMLEAK_LOG_PID" >> $AUTOLOG_LOG_DEFAULT_TEMP_DIR/running_pids.log
    fi
}

# enable slab_kmalloc monitoring
enable_slab_kmalloc_monitoring()
{
    if [ -d /sys/kernel/debug/slab ]; then
        rm -rf /data/slab
        sh $AUTOLOG_MODULES_DIR/platform/stress/slab_user_kmalloc.sh /data 600 &
        SLAB_LOG_PID=$!
        #echo "slab_log_pid=$SLAB_LOG_PID"
        echo "slab_log_pid=$SLAB_LOG_PID" >> $AUTOLOG_LOG_DEFAULT_TEMP_DIR/running_pids.log
    fi
}

# enable memory_log monitoring
enable_memory_log_monitoring()
{
    rm -rf /data/meminfo_log
    rm -rf /data/memory_log_consolelog.txt
    sh $AUTOLOG_MODULES_DIR/platform/stress/memory_log.sh merak /data 600 > /data/memory_log_consolelog.txt &
    MEMORY_LOG_PID=$!
    #echo "memory_log_pid=$MEMORY_LOG_PID"
    echo "memory_log_pid=$MEMORY_LOG_PID" >> $AUTOLOG_LOG_DEFAULT_TEMP_DIR/running_pids.log
}

# reset logs data
reset_logs_data()
{
    if [ ! -d /data/stress_logcat ]; then
        mkdir /data/stress_logcat
    else
        rm -fr /data/stress_logcat
        sync
        mkdir /data/stress_logcat
    fi

    if [ -d $AUTOLOG_LOG_DEFAULT_DIR ]; then
        rm -rf $AUTOLOG_LOG_DEFAULT_DIR
    fi
    mkdir $AUTOLOG_LOG_DEFAULT_DIR

    if [ $AUTOLOG_LOG_DIR != $AUTOLOG_LOG_DEFAULT_DIR ]; then
        if [ -d $AUTOLOG_LOG_DIR ]; then
            rm -rf $AUTOLOG_LOG_DIR
        fi
        mkdir $AUTOLOG_LOG_DIR
    fi

    if [ -d $AUTOLOG_LOG_DEFAULT_TEMP_DIR ]; then
        rm -rf $AUTOLOG_LOG_DEFAULT_TEMP_DIR
    fi
    mkdir $AUTOLOG_LOG_DEFAULT_TEMP_DIR

    rm -fr /data/anr/*
    rm -fr /data/tombstones/*
    rm -fr /data/*_stress.log
    rm -fr /data/ps_mediatek.txt
    rm -fr /data/bugreport_*.log
    rm -rf /data/user_de/0/com.android.shell/files/bugreports/*
    rm -rf /data/ps_mediatek_info.txt
    logcat -c

    rm -fr /data/HDMI_start_info.txt
    rm -fr /data/HDMI_end_info.txt

    rm -fr $LOG_DIR/logcat_log
    rm -fr $LOG_DIR/kernel_log
    rm -fr $LOG_DIR/mMemDebug_stress.log
    rm -fr $LOG_DIR/*.log

    if [ ! -d /data/thread_leak ]; then
        mkdir /data/thread_leak/
        touch $thread_leak_over500_pid_path
        touch $thread_leak_over1000_pid_path
    else
        rm -fr /data/thread_leak
        sync
        mkdir /data/thread_leak/
        touch $thread_leak_over500_pid_path
        touch $thread_leak_over1000_pid_path
    fi

}

# generate merge logcat script
generate_merge_logcat_script()
{
    STRESS_TEST_FILE=/data/stress_test_M6.sh

    FIND_MERGE_LOGCAT_SCRIPT_HEAD="NO"
    MERGE_LOGCAT_SCRIPT_HEAD_KEYWORD="generate"

#    echo $1
#    echo $FIND_MERGE_LOGCAT_SCRIPT_HEAD
    if [ $1 == "shell" ];then
        MERGE_LOGCAT_SCRIPT_SCRIPT="auto_untar_merge_logcat.sh"
        rm -fr /data/auto_untar_merge_logcat.sh
    else
        MERGE_LOGCAT_SCRIPT_SCRIPT="auto_untar_merge_logcat.py"
        rm -fr /data/auto_untar_merge_logcat.py
    fi
    MERGE_LOGCAT_SCRIPT_HEAD="$MERGE_LOGCAT_SCRIPT_HEAD_KEYWORD $MERGE_LOGCAT_SCRIPT_SCRIPT"
    MERGE_LOGCAT_SCRIPT_TAIL="DONE"

    cat $STRESS_TEST_FILE | while read read_line
    do
        if [ $FIND_MERGE_LOGCAT_SCRIPT_HEAD == "YES" ];then
            echo "${read_line:1}" >> /data/$MERGE_LOGCAT_SCRIPT_SCRIPT
        fi

        #echo "$read_line"
        if [[ $FIND_MERGE_LOGCAT_SCRIPT_HEAD == "NO" ]] && [[ $read_line == *$MERGE_LOGCAT_SCRIPT_HEAD ]] ;then
            FIND_MERGE_LOGCAT_SCRIPT_HEAD="YES"
#            echo "FIND_MERGE_LOGCAT_SCRIPT_HEAD=$FIND_MERGE_LOGCAT_SCRIPT_HEAD"
        fi
        if [[ $FIND_MERGE_LOGCAT_SCRIPT_HEAD == "YES" ]] && [[ $read_line == *$MERGE_LOGCAT_SCRIPT_TAIL* ]] ;then
            FIND_MERGE_LOGCAT_SCRIPT_HEAD="NO"
#            echo "FIND_MERGE_LOGCAT_SCRIPT_HEAD=$FIND_MERGE_LOGCAT_SCRIPT_HEAD"
        fi
    done
}

capture_bugreport()
{
    /system/bin/bugreportz
}

# generate merge logcat script
move_logcat_2_USB()
{
    echo "LOG_DIR = $LOG_DIR"
    if [ "$LOG_DIR" == "/data" ];then
        echo "\033[1m \033[4m NO USB devices !!!!! \033[0m"
        return
    fi

    if [ ! -d $LOG_DIR/logcat_log ]; then
        mkdir $LOG_DIR/logcat_log
    fi

    mv /data/logcat_log/*.tar.gz $LOG_DIR/logcat_log
}

create_android_Errlog_temp()
{
    if [ ! -d /data/AN_error ]; then
        mkdir /data/AN_error
        mkdir /data/AN_error/ANR
        mkdir /data/AN_error/tombstones
        mkdir /data/AN_error/dropbox
    else
        rm -fr /data/AN_error
        sync
        mkdir /data/AN_error
        mkdir /data/AN_error/ANR
        mkdir /data/AN_error/tombstones
        mkdir /data/AN_error/dropbox
    fi

    OldFileSizeANR=`du -s /data/AN_error/ANR`
    OldFileSizeANR=`echo $OldFileSizeANR | awk '{ print $1 }'`

    OldFileSizetombstones=`du -s /data/AN_error/tombstones`
    OldFileSizetombstones=`echo $OldFileSizetombstones | awk '{ print $1 }'`

    OldFileSizedropbox=`du -s /data/AN_error/dropbox`
    OldFileSizedropbox=`echo $OldFileSizedropbox | awk '{ print $1 }'`

}

capture_dump_package_info()
{
    if [ -f /data/dump_package.log ]; then
        rm /data/dump_package.log
    fi

    dumpsys package > /data/dumpsys_package.log
}

move_kernel_tar_file_2_USB()
{
    kernel_tar_file=$1
    if [ "$LOG_DIR" == "/data" ];then
        echo "\033[1m \033[4m NO USB devices !!!!! \033[0m"
        return
    fi

    if [ ! -d $LOG_DIR/kernel_log ]; then
        mkdir $LOG_DIR/kernel_log
    fi

    mv $kernel_tar_file $LOG_DIR/kernel_log/

    echo "save kernel log to USB"
}

tar_kernel_file_and_copy_to_usb()
{
    directory=$1
    target_file=$2
    source_file=$3

    echo "start tar $directory/$source_file into $directory/$target_file!"
    tar zcvf $directory/$target_file $source_file -C $directory
    rm -fr $directory/$source_file

    move_kernel_tar_file_2_USB $directory/$target_file
}

kill_kmemleak_log_pid()
{
    killed_pid=$(cat $AUTOLOG_LOG_DEFAULT_TEMP_DIR/running_pids.log | awk -F'kmemleak_log_pid=' '{print $2}' |  cut -d ' ' -f 1)
    if [ $killed_pid != "" ]; then
        #echo "Kill kmemleak_log_pid=$killed_pid"
        kill -9 $killed_pid
    fi
}

kill_slab_log_pid()
{
    killed_pid=$(cat $AUTOLOG_LOG_DEFAULT_TEMP_DIR/running_pids.log | awk -F'slab_log_pid=' '{print $2}' |  cut -d ' ' -f 1)
    if [ $killed_pid != "" ]; then
        #echo "Kill slab_log_pid=$killed_pid"
        kill -9 $killed_pid
    fi
}

kill_memory_log_pid()
{
    killed_pid=$(cat $AUTOLOG_LOG_DEFAULT_TEMP_DIR/running_pids.log | awk -F'memory_log_pid=' '{print $2}' |  cut -d ' ' -f 1)
    if [ $killed_pid != "" ]; then
        #echo "Kill memory_log_pid=$killed_pid"
        kill -9 $killed_pid
    fi
}

dmesg_log()
{
    kernel_count=0
    kernel_tar_count=0
    if [ ! -d /data/kernel_log ]; then
        mkdir /data/kernel_log
    else
        rm -fr /data/kernel_log
        sync
        mkdir /data/kernel_log
    fi

    while true
    do
        echo "start save $kernel_tar_count kmsg_$kernel_count.log!"
        dmesg -T -c >> /data/kernel_log/kmsg_$kernel_count.log
        sync
        sleep 10
        kernel_tar_count=$(($kernel_tar_count+1))

        if [ "$kernel_tar_count" = "20" ]
            then
                echo "start tar kmsg_$kernel_count.log!"

                tar_kernel_file_and_copy_to_usb /data/kernel_log kmsg_$kernel_count.tar.gz kmsg_$kernel_count.log
                kernel_count=$(($kernel_count+1))
                kernel_tar_count=0
                # Print __log_buf address
                echo 0 > /proc/sys/kernel/kptr_restrict
                cat /proc/kallsyms | grep -i __log_buf
        fi

        if [ -f $STOP_STRESS_LOG ]; then
            #echo "\033[1m \033[4m dmesg_log Exit\033[0m"
            return 0
        fi
    done

}


log_system_date()
{
    if [ "$LOG_DIR" == "/data" ];then
        echo "\033[1m \033[4m NO USB devices !!!!! \033[0m"
    fi

    date +"%a %b %d %T %Y" > /data/start_date
}

log_zygote_pid()
{
    file=$1

    ps -A | grep -w zygote | awk {'print$2'} >  /data/$file

}

copy_with_log()
{
    source_file=$1
    target_file=$2

    echo "copy $source_file to $target_file [start]"
    cp -fr $source_file $target_file
    echo "copy $source_file to $target_file [end]"
}

move_with_log()
{
    source_file=$1
    target_file=$2

    echo "move $source_file to $target_file [start]"
    mv $source_file $target_file
    echo "move $source_file to $target_file [end]"
}

if [ $1 == "start" ] ; then

    if [ $# == 3 ] ; then
        LOG_DIR=$3
    else
        #using first usb device
        UUID=`/vendor/bin/mount | /vendor/bin/awk '{if($1~/media_rw/) print $1}'`
        UUID=${UUID##*media_rw/}
        if [ ! "$UUID" ];then
            echo "\033[1m \033[4m NO USB devices !!!!! \033[0m"
            return
        else
            LOG_DIR=/mnt/media_rw/$UUID
        fi
    fi
    echo "output directory of log is $LOG_DIR"
# clear residue data
    reset_logs_data

    generate_merge_logcat_script "shell"
    generate_merge_logcat_script "python"

#print kernel log level
    print_kernel_log_level
    setup_stress_setting

#dump process id
    echo "start test ps data ...." >> $PS_date_path
    ps -A >> $PS_date_path
#dumpsys package
    capture_dump_package_info

# prepare an error log temp folder
    create_android_Errlog_temp

    if [ ! -f /data/debug_stress.txt ]; then
        touch /data/debug_stress.txt
        echo 1 > /data/debug_stress.txt
        chmod 777 /data/debug_stress.txt
    fi

    echo "Disable GAM reboot when dtv_svc exit"
    echo ":am,am,:disable_reboot" >/data/vendor/fifo/fifo_am_write

# get system date
    log_system_date

# run detect_process_crash.sh
    sh $AUTOLOG_MODULES_DIR/platform/stress/detect_process_crash.sh &

# save kernel space log
    for i in $*
    do
        tmp=$(echo $i | tr [a-z] [A-Z])
        echo $tmp
        if [ $tmp == "KERNEL" ] ; then
            uptime >> /data/kernel_space_stress.log
            cat /proc/kmsg > /data/kernel_space_stress.log &
        fi
    done

# enable getevent
    enable_getevent

#cat HDMI info
    cat /sys/devices/platform/mtk_srccap0/mtk_dbg/hdmirx/ALL_INFO >> /data/HDMI_start_info.txt
    cat /sys/devices/platform/mtk_srccap0/mtk_dbg/hdmirx/HDMI_INFO >> /data/HDMI_start_info.txt
    cat /sys/devices/platform/mtk_srccap0/mtk_dbg/hdmirx/TIMING_DETECT >> /data/HDMI_start_info.txt

# enable kmemleak monitoring
    enable_kmemleak_monitoring

# enable slab_kmalloc monitoring
    enable_slab_kmalloc_monitoring

# enable memory_log monitoring
    enable_memory_log_monitoring

#capture interrupts info
    cat /proc/interrupts > /data/interrupts.txt

#run dmesg_log.sh"
    dmesg_log &

    while [ -d /data/logcat_log ]
    do
        kill_logcat
        date

        if [ -f $STOP_STRESS_LOG ]; then
            #echo "\033[1m \033[4m logcat_log Exit\033[0m"
            return 0
        fi


        tname=`date +%Y%m%d%H%M%S`
        # parse parameters
        #echo "parameters: $#"
        for i in $*
        do
            tmp=$(echo $i | tr [a-z] [A-Z])
            echo $tmp
            if [ $tmp == "SQA" ] ; then
                capture_com_mediatek_app_threads
            fi
        done

#   start logcat and save log.
        logcat_file=/data/logcat_log/${tname}.log

        echo "START store logcat file->${tname}.log"
        logcat -v threadtime -v printable -v uid -v year > $logcat_file &
        sleep 60
        logcat -c
        kill_logcat
        sync

        # tar logcat .log -> .tar.gz
        echo "tar ${tname}.log to ${tname}.tar.gz"
        cd /data/logcat_log/
        for logcat_name in $(ls *.log)
        do
            echo $(basename $logcat_name .log)
            tar zcvf $(basename $logcat_name .log).tar.gz ${logcat_name}
            rm -fr /data/logcat_log/$logcat_name
        done
        cd -
        move_logcat_2_USB
        echo "End store logcat file->${tname}.log"

        capture_top

#save AN error log

        NewFileSizeANR=`du -s /data/anr`
        NewFileSizeANR=`echo $NewFileSizeANR | awk '{ print $1 }'`
        NewFileSizetombstones=`du -s /data/tombstones`
        NewFileSizetombstones=`echo $NewFileSizetombstones | awk '{ print $1 }'`
        NewFileSizedropbox=`du -s /data/system/dropbox`
        NewFileSizedropbox=`echo $NewFileSizedropbox | awk '{ print $1 }'`

        if [ $OldFileSizeANR != $NewFileSizeANR ]; then
            echo "start capy anr file *******************"
            cp -rf /data/anr/. /data/AN_error/ANR/.
            OldFileSizeANR=$NewFileSizeANR
            echo "end copy anr file *********************"
        fi

        if [ $OldFileSizetombstones != $NewFileSizetombstones ]; then
            echo "start copy tombstones file *******************"
            cp -rf /data/tombstones/. /data/AN_error/tombstones/.
            OldFileSizetombstones=$NewFileSizetombstones
            echo "end copy tombstones file *********************"
        fi

        if [ $OldFileSizedropbox != $NewFileSizedropbox ]; then
            echo "start copy dropbox file *******************"
            cp -rf /data/system/dropbox/. /data/AN_error/dropbox/.
            OldFileSizedropbox=$NewFileSizedropbox
            echo "end copy dropbox file *********************"
        fi

    done
fi

if [ $1 == "end" ] ; then

    if [ $# == 2 ] ; then
        LOG_DIR=$2
    else
        UUID=`/vendor/bin/mount | /vendor/bin/awk '{if($1~/media_rw/) print $1}'`
        UUID=${UUID##*media_rw/}
        if [ ! "$UUID" ];then
            echo "\033[1m \033[4m NO USB devices !!!!! \033[0m"
            return
        else
            LOG_DIR=/mnt/media_rw/$UUID
        fi

    fi

    echo "output directory of log is $LOG_DIR"
    echo "Copy Data Start... "

    touch $STOP_STRESS_LOG
    kill_logcat
    kill_kmemleak_log_pid
    kill_slab_log_pid
    kill_memory_log_pid


#cat HDMI info
    cat /sys/devices/platform/mtk_srccap0/mtk_dbg/hdmirx/ALL_INFO >> /data/HDMI_end_info.txt
    cat /sys/devices/platform/mtk_srccap0/mtk_dbg/hdmirx/HDMI_INFO >> /data/HDMI_end_info.txt
    cat /sys/devices/platform/mtk_srccap0/mtk_dbg/hdmirx/TIMING_DETECT >> /data/HDMI_end_info.txt

    teardown_stress_setting
    tname=`date +%Y-%m%d-%H%M%S`

    echo "star touch log path"

    STRESS_LOG_DIR=$LOG_DIR/dump/stress/${tname}
    SYSTEM_LOG_DIR=$LOG_DIR/dump/system/${tname}
    ANDROID_LOG_DIR=$LOG_DIR/dump/android/${tname}
    echo "STRESS_LOG_DIR = $STRESS_LOG_DIR"
    echo "SYSTEM_LOG_DIR = $SYSTEM_LOG_DIR"
    echo "ANDROID_LOG_DIR = $ANDROID_LOG_DIR"

    if [ ! -d $LOG_DIR/dump ]; then
        mkdir $LOG_DIR/dump/
        mkdir $LOG_DIR/dump/stress
        mkdir $LOG_DIR/dump/system
        mkdir $LOG_DIR/dump/android
    fi

    mkdir $STRESS_LOG_DIR
    mkdir $SYSTEM_LOG_DIR
    mkdir $ANDROID_LOG_DIR

    echo "end touch log path"

    echo "end test ps data ...." >> $PS_date_path
    ps -A >> $PS_date_path
    copy_with_log "/data/PS_data.log"  $STRESS_LOG_DIR

    capture_bugreport

    file_name=$SYSTEM_LOG_DIR/data_du_df.log

    echo $LOG_DIR

    if [ ! -d $LOG_DIR/logcat_log ]; then
        mkdir $LOG_DIR/logcat_log
    fi
    if [ ! -d $LOG_DIR/kernel_log ]; then
        mkdir $LOG_DIR/kernel_log
    fi
    if [ "$LOG_DIR" != "/data/" ];then
        move_with_log $LOG_DIR/logcat_log $LOG_DIR/${tname}/logcat_log
        move_with_log $LOG_DIR/kernel_log $LOG_DIR/${tname}/kernel_log
    fi

    echo "generate data_du_df.log ... [start]"
    echo "start df –h...." >> $file_name
    df -h >> $file_name
    echo "du -h -a -d 2 /data | sort -r ...." >> $file_name
    du -h -a -d 2 /data | sort -r >> $file_name
    echo "du -a -h /data | sort -r ...." >> $file_name
    du -h -a /data | sort -r >> $file_name
    echo "generate data_du_df.log ...[end]"

    copy_with_log "/data/user_de/0/com.android.shell/files/bugreports/bugreport-*.zip"  $ANDROID_LOG_DIR

    if [ ! -d /data/logcat_log ]; then
        copy_with_log /data/logcat_log/* $LOG_DIR/logcat_log/
    fi

    mkdir -p /data/tombstones/old
    copy_with_log /data/AN_error/tombstones/* /data/tombstones/old/
    mkdir -p /data/anr/old
    copy_with_log /data/AN_error/anr/* /data/anr/old/
    echo "tar AN_error.tar.gz [start]"
    tar zcvf $ANDROID_LOG_DIR/AN_error.tar.gz /data/AN_error
    echo "tar AN_error.tar.gz [end]"

    copy_with_log /data/dumpsys_package.log $ANDROID_LOG_DIR
    copy_with_log /data/anr $ANDROID_LOG_DIR
    copy_with_log /data/tombstones $ANDROID_LOG_DIR
    copy_with_log /sys/fs/pstore $SYSTEM_LOG_DIR
    copy_with_log /data/kernel_log/* $LOG_DIR/kernel_log/
    copy_with_log /data/stress_logcat/* $LOG_DIR/stress_logcat/
    copy_with_log "/data/auto_untar_merge_logcat.*" $LOG_DIR/stress_logcat/
    copy_with_log "/data/HDMI_start_info.txt"  $STRESS_LOG_DIR
    copy_with_log "/data/HDMI_end_info.txt"  $STRESS_LOG_DIR
    copy_with_log "/data/ps_mediatek_info.txt"  $STRESS_LOG_DIR
    copy_with_log "/data/ps_report.txt"  $STRESS_LOG_DIR
    copy_with_log "/data/interrupts.txt"  $STRESS_LOG_DIR
    copy_with_log "/data/top.log" $STRESS_LOG_DIR
    copy_with_log "/data/start_date"  $STRESS_LOG_DIR
    copy_with_log "/data/thread_leak"  $STRESS_LOG_DIR

    if [ -f /data/kmemleak.log ];then
        copy_with_log /data/kmemleak.log $STRESS_LOG_DIR
    fi
    if [ -d /data/slab ];then
        #echo "\033[1m\033[4mCopy /data/slab!!!  \033[0m"
        copy_with_log /data/slab $SYSTEM_LOG_DIR
    fi
    if [ -d /data/meminfo_log ];then
        #echo "\033[1m\033[4mCopy /data/meminfo_log!!!  \033[0m"
        copy_with_log /data/meminfo_log $STRESS_LOG_DIR
        copy_with_log /data/memory_log_consolelog.txt $STRESS_LOG_DIR
    fi
    echo "screencap -p $LOG_DIR/${tname}/ScreenCap.png [start]"
    screencap -p $ANDROID_LOG_DIR/ScreenCap.png
    echo "screencap -p $LOG_DIR/${tname}/ScreenCap.png [end]"
    if [ -f /data/kernel_space_stress.log ];then
        copy_with_log /data/kernel_space_stress.log $STRESS_LOG_DIR
    fi

    if [ -f /data/mMemDebug_stress.log ];then
        cat /data/mMemDebug_stress.log >> $STRESS_LOG_DIR/mMemDebug_stress.log
    fi

    rm -fr /data/*_dtv_svc_maps.log
    rm -fr /data/auto_untar_merge_logcat.*
    sync

    if [ -d $LOG_DIR/stress_logcat ]; then
        echo "\033[1m\033[4mCopy Data Successfully!!!  \033[0m"
    else
        echo "\033[1m\033[4mPlease Confirm the reason for failure of copying the Log!!! \033[0m"
    fi
    if [ -d $LOG_DIR/kernel_log ]; then
        echo "\033[1m\033[4mCopy kernel_log Data Successfully!!!  \033[0m"
    else
        echo "\033[1m\033[4mPlease Confirm the reason for failure of copying the kernel_log!!! \033[0m"
    fi
fi


# the below is auto_untar_merge_logcat scripts(.sh/.py),DON'T MODIFY

##generate auto_untar_merge_logcat.sh
##/bin/sh
## AUTHER: Chunhui.kang
#
#if [ -d ./tmp ]; then
#   rm -fr ./tmp
#fi
#mkdir tmp
#
#for filename in $(ls *.tar.gz)
#do
#   echo $filename
#   tar zxvf $filename -C ./tmp
#   echo $(basename $filename .tar.gz) >> ./tmp/filename.txt
#done
#
#for filename in $(ls *.log)
#do
#   echo $filename
#   cp $filename ./tmp
#   echo $(basename $filename .log) >> ./tmp/filename.txt
#done
#
#cat ./tmp/filename.txt | sort -n > ./tmp/filename_sorted.txt
#
#cat ./tmp/filename_sorted.txt
#
#if [ -f logcat_merged.log ]; then
#   rm -fr logcat_merged.log
#fi
#
#touch logcat_merged.log
#
#for filename in $(cat ./tmp/filename_sorted.txt)
#do
#   echo $filename
#   cat ./tmp/$filename.log >> ./logcat_merged.log
#   rm ./tmp/$filename.log
#done
#
#rm -fr ./tmp
#
#echo "*******DONE!!!*******"
#

##generate auto_untar_merge_logcat.py
##!/usr/bin/python
## AUTHER: Chunhui.kang
#
#import os,sys,shutil
#import tarfile
#
#def  del_file(path):
#  for i in os.listdir(path):
#     path_file = os.path.join(path,i)
#     if os.path.isfile(path_file):
#       os.remove(path_file)
#     else:
#         del_file(path_file)
#
#def un_tar(file_name, target_folder):
#    tar = tarfile.open(file_name)
#    names = tar.getnames()
#    if not os.path.isdir(target_folder):
#        os.mkdir(target_folder)
#    for name in names:
#        tar.extract(name, target_folder)
#    tar.close()
#
#if os.path.isdir('./tmp'):
#    del_file('./tmp')
#    os.removedirs('./tmp')
#os.makedirs('./tmp')
#
#files_list=[]
#
#if os.path.exists('./logcat_merged.log'):
#    os.remove('./logcat_merged.log')
#
#for filename in os.listdir('./'):
#    if '.tar.gz' in filename:
#        print 'untar file:'+filename
#        un_tar(filename, './tmp')
#        files_list.append(filename.split('.')[0])
#        #print files_list
#    if '.log' in filename:
#        print 'copy file:'+filename
#        shutil.copyfile(filename,'./tmp/'+filename)
#        files_list.append(filename.split('.')[0])
#
##print files_list
#int_files_list=map(int, files_list)
#int_files_list.sort()
##print int_files_list
#
#target_merged=open("./logcat_merged.log",'a')
#
#for filename in int_files_list:
#    source_file_path='./tmp/'+str(filename)+'.log'
#    if not os.path.exists(source_file_path):
#        continue
#    print source_file_path
#    source_file=open(source_file_path,'r')
#    target_merged.write(source_file.read())
#    source_file.close()
#    os.remove(source_file_path)
#
#target_merged.close()
#os.removedirs('./tmp')
#print "*******DONE!!!*******"
