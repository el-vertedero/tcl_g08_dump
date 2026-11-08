#!/sbin/sh

LOG_DIR=$1
LOG_DT=$2
#echo "LOG_DIR=$LOG_DIR"
#echo "LOG_DT=$LOG_DT"
#echo "AUTOLOG_LOG_DEFAULT_DIR=$AUTOLOG_LOG_DEFAULT_DIR"
#echo "AUTOLOG_LOG_DIR=$AUTOLOG_LOG_DIR"
STOP_STRESS_LOG=$AUTOLOG_LOG_DEFAULT_TEMP_DIR/stop_stress_log

make_sure_tar_all_files()
{
    target_dir=$1
    #echo "==============================================="
    #echo "$target_dir"
    for fileFullPath in "$target_dir"/*
    do
        #echo "@ $fileFullPath"

        fileFullName=$(basename "$fileFullPath")
        #echo "@@ $fileFullName"

        fileName=$(basename "$fileFullName")
        name="${fileName%.*}"
        #echo "@@@ $name"

        fileType="${fileName##*.}"
        #echo "@@@@ $fileType"
        if [ $fileType != gz ]; then
            #echo "Not a tar file: $fileFullName"
            cd $target_dir
            tar zcvf $name.tar.gz $fileFullName
            rm $fileFullName
        fi
    done
    #echo "==============================================="
}

wait_for_logging_stop_done()
{
    dmesg_log_pid=$(cat $AUTOLOG_LOG_DEFAULT_TEMP_DIR/running_pids.log | awk -F'dmesg_log_pid=' '{print $2}' |  cut -d ' ' -f 1)
    logcat_log_pid=$(cat $AUTOLOG_LOG_DEFAULT_TEMP_DIR/running_pids.log | awk -F'logcat_log_pid=' '{print $2}' |  cut -d ' ' -f 1)

    while [ true ]
    do
        kill -9 $dmesg_log_pid
        if [ $? -eq 0 ] ; then
            echo "..."
        else
            kill -9 $logcat_log_pid
            if [ $? -eq 0 ] ; then
                echo "..."
            else
                break
            fi
        fi
        sleep 1
    done
}

recheck_logging()
{
    make_sure_tar_all_files $1/kernel_log
    make_sure_tar_all_files $1/logcat_log
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

kill_str_related_log_pids()
{
    killed_pids=$(awk '{if (match($0,"^dumpsys_power_pid=")){print substr($0,RLENGTH+1)}}' $AUTOLOG_LOG_DEFAULT_TEMP_DIR/running_pids.log)
    killed_pids+=" "$(awk '{if (match($0,"^dumpsys_suspend_control_internal_pid=")){print substr($0,RLENGTH+1)}}' $AUTOLOG_LOG_DEFAULT_TEMP_DIR/running_pids.log)
    killed_pids+=" "$(awk '{if (match($0,"^getevent_pid=")){print substr($0,RLENGTH+1)}}' $AUTOLOG_LOG_DEFAULT_TEMP_DIR/running_pids.log)
    kill -9 $killed_pids
}

copy_with_log()
{
    source_file=$1
    target_file=$2

    echo "${COLOR_GREEN}[AUTOLOG] copy $source_file to $target_file [start]${COLOR_REST}"
    cp -fr $source_file $target_file
    echo "${COLOR_GREEN}[AUTOLOG] copy $source_file to $target_file [end]${COLOR_REST}"
}

move_with_log()
{
    source_file=$1
    target_file=$2

    echo "${COLOR_GREEN}[AUTOLOG] move $source_file to $target_file [start]${COLOR_REST}"
    mv $source_file $target_file
    echo "${COLOR_GREEN}[AUTOLOG] move $source_file to $target_file [end]${COLOR_REST}"
}

#echo "\033[1m \033[4m"
#echo "In bugreport_common_aow.sh\033[0m"

#echo "[AUTOLOG] LOG_DIR=$LOG_DIR"

if [ ! -d $AUTOLOG_LOG_DEFAULT_DIR ]; then
    mkdir $AUTOLOG_LOG_DEFAULT_DIR
    dmesg -T -c > $AUTOLOG_LOG_DEFAULT_DIR/kernel_log.log
    logcat -v threadtime -v printable -v uid -v year -d > $AUTOLOG_LOG_DEFAULT_DIR/logcat_log.log
else
    touch $STOP_STRESS_LOG
    sync
    wait_for_logging_stop_done
    kill_kmemleak_log_pid
    kill_slab_log_pid
    kill_memory_log_pid
    kill_str_related_log_pids
fi

if [ $CHANGE_OUTPUT_DIR == true ]; then
     TEMP_CURRENT_LOG_DIR=$AUTOLOG_LOG_DIR
else
    TEMP_CURRENT_LOG_DIR=$AUTOLOG_LOG_DEFAULT_DIR
fi

if [ ! -d $AUTOLOG_LOG_DEFAULT_DIR/kernel_log ] && [ ! -f $TEMP_CURRENT_LOG_DIR/kernel_log.log ] && [ ! -f $TEMP_CURRENT_LOG_DIR/logcat_log.log ]; then
   dmesg -T -c > $TEMP_CURRENT_LOG_DIR/kernel_log.log
   echo "fetch LOGCAT buffer to file, please wait a moment ........."
   logcat -v threadtime -v printable -v uid -v year -d > $TEMP_CURRENT_LOG_DIR/logcat_log.log
   tar zcvf $TEMP_CURRENT_LOG_DIR/logcat_log.tar.gz $TEMP_CURRENT_LOG_DIR/logcat_log.log
   rm $TEMP_CURRENT_LOG_DIR/logcat_log.log
fi

    OUTPUT_LOG_DIR=$LOG_DIR
    mkdir $OUTPUT_LOG_DIR
    echo "[AUTOLOG] Output directory of log is $OUTPUT_LOG_DIR"
if [ $CHANGE_OUTPUT_DIR == true ]; then
    echo "[AUTOLOG] Move log files under specify folder."
    #echo "AUTOLOG_LOG_DEFAULT_DIR=$AUTOLOG_LOG_DEFAULT_DIR"
    #echo "AUTOLOG_LOG_DIR=$AUTOLOG_LOG_DIR"
    if [ -d $AUTOLOG_LOG_DEFAULT_DIR/kernel_log ]; then
        recheck_logging $AUTOLOG_LOG_DEFAULT_DIR
        copy_with_log /sys/fs/pstore $DOMAIN_SYSTEM_DUMP_LOG_DIR
        move_with_log $AUTOLOG_LOG_DEFAULT_DIR $OUTPUT_LOG_DIR
    else
        recheck_logging $AUTOLOG_LOG_DIR
        copy_with_log /sys/fs/pstore $DOMAIN_SYSTEM_DUMP_LOG_DIR
        move_with_log $AUTOLOG_LOG_DIR $OUTPUT_LOG_DIR
    fi
else
    echo "[AUTOLOG] Keep log files under default folder."
    if [ -d $AUTOLOG_LOG_DEFAULT_DIR/kernel_log ]; then
        recheck_logging $AUTOLOG_LOG_DEFAULT_DIR
        copy_with_log /sys/fs/pstore $DOMAIN_SYSTEM_DUMP_LOG_DIR
        echo "[AUTOLOG] DO NOT Move Log by bugreport.sh"
    else
        recheck_logging $AUTOLOG_LOG_DIR
        copy_with_log /sys/fs/pstore $DOMAIN_SYSTEM_DUMP_LOG_DIR
    fi
fi

if [ -d $DOMAIN_SYSTEM_DUMP_LOG_DIR ]; then
    if [ -f "$AUTOLOG_LOG_DIR/memory_info.txt" ]; then
        move_with_log $AUTOLOG_LOG_DIR/memory_info.txt $DOMAIN_SYSTEM_DUMP_LOG_DIR/memory_info.txt
    fi
    if [ -f "$AUTOLOG_LOG_DIR/wakelocks_info.txt" ]; then
        move_with_log $AUTOLOG_LOG_DIR/wakelocks_info.txt $DOMAIN_SYSTEM_DUMP_LOG_DIR/wakelocks_info.txt
    fi
    if [ -f "$AUTOLOG_LOG_DIR/ps_info.txt" ]; then
        move_with_log $AUTOLOG_LOG_DIR/ps_info.txt $DOMAIN_SYSTEM_DUMP_LOG_DIR/ps_info.txt
    fi
    if [ -f "$AUTOLOG_LOG_DIR/interrupts_info.txt" ]; then
        move_with_log $AUTOLOG_LOG_DIR/interrupts_info.txt $DOMAIN_SYSTEM_DUMP_LOG_DIR/interrupts_info.txt
    fi
fi

echo "[AUTOLOG] Find wifi_dump log"
WiFi_FW_dump_log_DIR=/storage/emulated/0/Download
filename=$(ls $WiFi_FW_dump_log_DIR)
    if [ $filename != "" ];then
        echo "[AUTOLOG] WiFi_dump log is:$filename"
        copy_with_log $WiFi_FW_dump_log_DIR/$filename $AUTOLOG_LOG_DIR/$filename
    else
        echo "[AUTOLOG] WiFi_dump log isn't exist!"
    fi

echo "[AUTOLOG] stop and kill wifi_dump tool"
wifi_dump_pid=$(pgrep wifi_dump)
    if [ $wifi_dump_pid != "" ];then
        echo "[AUTOLOG] Kill wifi_dump process."
        kill -9 $wifi_dump_pid
    else
        echo "[AUTOLOG] There is no wifi_dump process in backgroup!"
    fi

echo "[AUTOLOG][Broadcast log dump] Starting ..."
DUMP_INFO="${LOG_DIR}/apk_dump.log"
SURFACE_DUMP_CMD="dumpsys SurfaceFlinger"
TVINPUT_DUMP_CMD="dumpsys tv_input"
INPUT_DUMP_CMD="dumpsys input"
TV_DB_FILE="/data/data/com.android.providers.tv/databases/tv.db"
AGENT_DB_FILE="/data/user_de/0/com.mediatek.tv.agent/"
PS_DUMP="ps -ef"
PROP_DUMP="getprop"
TV_MEM_DUMP="dumpsys meminfo com.mediatek.tv.oneworld.tvcenter"
WIZARD_MEM_DUMP="dumpsys meminfo com.mediatek.tv.oneworld.wizardkt"
echo "$PS_DUMP>>>>>>>>>>>>>>>>>>>>>>" > $DUMP_INFO
$PS_DUMP >> $DUMP_INFO
echo "$PROP_DUMP>>>>>>>>>>>>>>>>>>>" >> $DUMP_INFO
$PROP_DUMP >> $DUMP_INFO
echo "$SURFACE_DUMP_CMD>>>>>>>>>>>>>>>>>>>>>>" >> $DUMP_INFO
$SURFACE_DUMP_CMD >> $DUMP_INFO
echo "$TVINPUT_DUMP_CMD>>>>>>>>>>>>>>>>>>>>>>" >> $DUMP_INFO
$TVINPUT_DUMP_CMD >> $DUMP_INFO
echo "$INPUT_DUMP_CMD>>>>>>>>>>>>>>>>>>>>>>" >> $DUMP_INFO
$INPUT_DUMP_CMD >> $DUMP_INFO
echo "$TV_MEM_DUMP>>>>>>>>>>>>>>>>>>>>>>" >> $DUMP_INFO
$TV_MEM_DUMP >> $DUMP_INFO
echo "$WIZARD_MEM_DUMP>>>>>>>>>>>>>>>>>>>>>>" >> $DUMP_INFO
$WIZARD_MEM_DUMP >> $DUMP_INFO
cp $TV_DB_FILE $LOG_DIR && cp -rf $AGENT_DB_FILE $LOG_DIR
rm /data/tkui.print
rm /data/mtk_dt_log
sync
echo "[AUTOLOG][Broadcast log dump] Well done! Information collected!"

#echo "\033[1m \033[4m"
#echo "Out bugreport_common_aow.sh\033[0m"
