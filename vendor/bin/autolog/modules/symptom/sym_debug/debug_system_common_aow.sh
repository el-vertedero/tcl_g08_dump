#!/usr/bin/env sh

KERNEL_LOG_DIR=$AUTOLOG_LOG_DIR/kernel_log
START_STRESS_LOG=$AUTOLOG_LOG_DEFAULT_TEMP_DIR/start_stress_log
STOP_STRESS_LOG=$AUTOLOG_LOG_DEFAULT_TEMP_DIR/stop_stress_log
LOGCAT_LOG_DIR=$AUTOLOG_LOG_DIR/logcat_log
MEMORY_DEBUG_LOG=$AUTOLOG_LOG_DIR/memory_info.txt
WAKELOCKS_DEBUG_LOG=$AUTOLOG_LOG_DIR/wakelocks_info.txt
PS_DEBUG_LOG=$AUTOLOG_LOG_DIR/ps_info.txt
INTERRUPTS_DEBUG_LOG=$AUTOLOG_LOG_DIR/interrupts_info.txt

DO_SYMPTOM_DEBUG_SYSTEM_COMMON()
{
    #echo "IN DO_SYMPTOM_DEBUG_SYSTEM_COMMON"
    #kernel space log
    dmesg_log &
    DMESG_LOG_PID=$!
    #echo "dmesg_log_pid=$DMESG_LOG_PID"
    echo "dmesg_log_pid=$DMESG_LOG_PID" >> $AUTOLOG_LOG_DEFAULT_TEMP_DIR/running_pids.log

    #user space log
    logcat_log &
    LOGCAT_LOG_PID=$!
    #echo "logcat_log_pid=$LOGCAT_LOG_PID"
    echo "logcat_log_pid=$LOGCAT_LOG_PID" >> $AUTOLOG_LOG_DEFAULT_TEMP_DIR/running_pids.log

    while [ ! -f $START_STRESS_LOG ]
    do
       #echo "waiting for dmesg..."
       sleep 3
    done
}

move_kernel_tar_file_2_USB()
{
    kernel_tar_file=$1
    if [ "$LOG_DIR" == "/data" ];then
        echo "\033[1m \033[4m NO USB devices !!!!! \033[0m"
        return
    fi

    if [ ! -d $KERNEL_LOG_DIR ]; then
        mkdir $KERNEL_LOG_DIR
    fi

    mv $kernel_tar_file $KERNEL_LOG_DIR

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

dmesg_log()
{
    kernel_count=0
    kernel_tar_count=0

    if [ ! -d $KERNEL_LOG_DIR ]; then
        mkdir $KERNEL_LOG_DIR
    else
        rm -fr $KERNEL_LOG_DIR
        mkdir $KERNEL_LOG_DIR
    fi

    while [ -d $KERNEL_LOG_DIR ]
    do
        if [ "$kernel_tar_count" = "0" ]; then
            capture_meminfo
            capture_wakelocks
            capture_ps
            capture_interrupts
        fi

        #echo "start save $kernel_tar_count kmsg_$kernel_count.log!"
        dmesg -T -c >> $KERNEL_LOG_DIR/kmsg_$kernel_count.log
        sync
        if [ ! -f $START_STRESS_LOG ]; then
            touch $START_STRESS_LOG
            sync
        fi
        sleep 10

        kernel_tar_count=$(($kernel_tar_count+1))

        if [ "$kernel_tar_count" = "60" ]; then
            #echo "start tar kmsg_$kernel_count.log!"
            tar_kernel_file_and_copy_to_usb $KERNEL_LOG_DIR kmsg_$kernel_count.tar.gz kmsg_$kernel_count.log
            kernel_count=$(($kernel_count+1))
            kernel_tar_count=0
            # Print __log_buf address
            echo 0 > /proc/sys/kernel/kptr_restrict
            cat /proc/kallsyms | grep -i __log_buf
        fi

        if [ -f $STOP_STRESS_LOG ]; then
            #echo "\033[1m \033[4m"
            #echo "[AUTOLOG] dmesg_log Exit\033[0m"
            return 0
        fi
    done
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
        #echo "kill logcat thread:$line"
        kill $line
    done
}

logcat_log()
{
    logcat -G 256M
    if [ ! -d LOGCAT_LOG_DIR ]; then
      mkdir $LOGCAT_LOG_DIR
    fi

    while [ -d $LOGCAT_LOG_DIR ]
    do
        if [ -f $STOP_STRESS_LOG ]; then
            #echo "\033[1m \033[4m"
            #echo "[AUTOLOG] logcat_log Exit\033[0m"
            return 0
        fi
        tname=`date +%Y%m%d%H%M%S`
#   start logcat and save log.
        logcat_file=$LOGCAT_LOG_DIR/${tname}.log
        #echo "\033[1m \033[4m"
        #echo "[AUTOLOG] logcat_file = $logcat_file\033[0m"
        #echo "START store logcat file->${tname}.log"
        logcat -v threadtime -v printable -v uid -v year > $logcat_file &
        sleep 30
        logcat -c
        kill_logcat
        sync

        # tar logcat .log -> .tar.gz
        #echo "tar ${tname}.log to ${tname}.tar.gz"
        cd $LOGCAT_LOG_DIR
        for logcat_name in $(ls *.log)
        do
            #echo $(basename $logcat_name .log)
            tar zcvf $(basename $logcat_name .log).tar.gz ${logcat_name}
            rm -fr $LOGCAT_LOG_DIR/$logcat_name
        done
        #echo "End store logcat file->${tname}.log"
    done
}

#capture meminfo for memory leakage.
capture_meminfo()
{
    echo "@@@@@@@ memory dump start @@@@@@@" >> $MEMORY_DEBUG_LOG
    echo "@@@@@@@ script ver 2020.10.14 @@@@@@@" >> $MEMORY_DEBUG_LOG
    date +%Y/%m/%d-%H:%M:%S >> $MEMORY_DEBUG_LOG
    uptime >> $MEMORY_DEBUG_LOG
    echo "@@ meminfo @@" >> $MEMORY_DEBUG_LOG
    cat /proc/meminfo >> $MEMORY_DEBUG_LOG
    echo "@@ slabinfo @@" >> $MEMORY_DEBUG_LOG
    cat /proc/slabinfo >> $MEMORY_DEBUG_LOG
    echo "@@ zoneinfo @@" >> $MEMORY_DEBUG_LOG
    cat /proc/zoneinfo >> $MEMORY_DEBUG_LOG
    echo "@@ procrank @@" >> $MEMORY_DEBUG_LOG
    procrank >> $MEMORY_DEBUG_LOG
    echo "@@ top @@" >> $MEMORY_DEBUG_LOG
    top -b -H -m 20 -n 1 >> $MEMORY_DEBUG_LOG
    echo "@@ vmallocinfo @@" >> $MEMORY_DEBUG_LOG
    cat /proc/vmallocinfo | grep -ve "unpurged vm_area" >> $MEMORY_DEBUG_LOG
    echo "@@ cat iommu memory info @@" >> $MEMORY_DEBUG_LOG
    cat /sys/class/iommu/mtk-dtv-iommu/mtk_dbg/meminfo >> $MEMORY_DEBUG_LOG
    echo "@@@@@@@ ===================== @@@@@@@" >> $MEMORY_DEBUG_LOG
}

#capture wakelocks for STR issues.
capture_wakelocks()
{
    uptime >> $WAKELOCKS_DEBUG_LOG
    echo "--- wakelocks begin ---" >> $WAKELOCKS_DEBUG_LOG
    echo "*******************" >> $WAKELOCKS_DEBUG_LOG
    echo "cat /sys/power/wake_lock:" >> $WAKELOCKS_DEBUG_LOG
    cat /sys/power/wake_lock >> $WAKELOCKS_DEBUG_LOG
    echo "dumpsys power:" >> $WAKELOCKS_DEBUG_LOG
    dumpsys power | grep -A 10 "Wake Locks" >> $WAKELOCKS_DEBUG_LOG
    dumpsys power | grep -E "mWakefulness=|mHalAutoSuspendModeEnabled|mHalInteractiveModeEnabled" >> $WAKELOCKS_DEBUG_LOG
    echo "*******************" >> $WAKELOCKS_DEBUG_LOG
    dumpsys suspend_control_internal >> $WAKELOCKS_DEBUG_LOG
    echo "--- wakelocks end ---" >> $WAKELOCKS_DEBUG_LOG
}

#capture ps info.
capture_ps()
{
    uptime >> $PS_DEBUG_LOG
    echo "--- ps begin ---" >> $PS_DEBUG_LOG
    ps -A >> $PS_DEBUG_LOG
    echo "--- ps end ---" >> $PS_DEBUG_LOG
}

#capture interrupts info.
capture_interrupts()
{
    uptime >> $PS_DEBUG_LOG
    echo "--- interrupts begin ---" >> $INTERRUPTS_DEBUG_LOG
    cat /proc/interrupts >> $INTERRUPTS_DEBUG_LOG
    echo "--- interrupts end ---" >> $INTERRUPTS_DEBUG_LOG
}

MAIN()
{
  ### Import functions from other modules/scripts
  ### DO SOMETHING
  #echo "\033[1m \033[4m"
  #echo "In debug_system_common_aow.sh\033[0m"

  DO_SYMPTOM_DEBUG_SYSTEM_COMMON

  #echo "\033[1m \033[4m"
  #echo "Out debug_system_common_aow.sh\033[0m"
}

#========================================================
#                 Script entrance control
#                  (Don't remove this)
#  If call this script through 'sh' command:
#      => Execute script, e.g MAIN function
#  If call this script through 'source <script_path> --source-only'
#      => import functions inside this script and this will
#         not execute MAIN()
#========================================================
if [ "$*" = "--source-only" ]; then
  :
else
  MAIN $*
fi