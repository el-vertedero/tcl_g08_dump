#!/bin/bash

#当前时间
#CURTIME=`date +%F_%H:%M:%S`
pmode="$(getprop odm.tcl.factory.pmode)"

#日志单个文件大小15M = 15*1024K
FILE_LOG_SIZE_MAX=15360

#压缩文件最大数量5，再加上script_record.txt，数量为6
TAR_GZ_COUNT_MAX=6

#日志目录空间大小设计为 LOG_MAX_USED_SIZE.
#1.正在抓取日志大小:FILE_LOG_SIZE_MAX .
#2.单个日志文件大小:最大20M.开始下一次抓取的同时,将上一个日志文件压缩，压缩比1:10，压缩文件大小2M.
#3.压缩的文件总大小:2*5 = 10M,压缩文件大于5个时，把最早的压缩文件删除.
#4.当可用空间不足5M时,停止日志打印.(即日志相关文件占用空间大小35M的时候停止抓取日志40*1024-5*1024=35*1024 K).
LOG_MAX_USED_SIZE=35840

#data目录
FTY_DATA=/data
#data空间不足10M时，停止logcat
FTY_DATA_LIMIT_SPACE=10240

#工厂log目录
FTY_ROOT_DIR=/data/factory_log

#log 初始化的信息
FTY_INIT_LOG_DIR=${FTY_ROOT_DIR}/log_init

#log 日志拷贝的路径
FTY_SAVE_LOG_DIR=${FTY_ROOT_DIR}/save_log

#脚本运行日志
FTY_SCRIPT_RECORD=${FTY_ROOT_DIR}/save_log/script_record.txt

#日志脚本shell子进程logcat的进程PID
FTY_LOG_CHILD_PROCESS_PID=${FTY_INIT_LOG_DIR}/process_child_pid.txt

#日志启动状态存放：100/101/102
FTY_LOG_STATUS_SAVE=${FTY_SAVE_LOG_DIR}/log_status.txt

#日志脚本shell父进程logcat的进程PID
FTY_LOG_MAIN_PROCESS_PID=${FTY_INIT_LOG_DIR}/process_main_pid.txt

#日志保存的路径，比如：/data/factory_log/log_init/android_2023-07-31_21-05-43.txt
FTY_LOG_PATH=${FTY_INIT_LOG_DIR}/log_path.txt

#日志拷贝结果保存
FTY_LOG_CLONE_RESULT=${FTY_SAVE_LOG_DIR}/log_clone_result.txt

#system/bin/sh执行的shell命令
SYSTEM_BIN_LOGCAT=/system/bin/logcat
SYSTEM_BIN_TAR=/system/bin/tar
SYSTEM_BIN_KILL=/system/bin/kill
SYSTEM_BIN_DU=/system/bin/du


#每次start log 需要清空上次的抓取痕迹
#但是 restart 不需要删除(切忌)
function fty_init_logcat()
{
    #创建工厂存储日志目录
    if [ ! -d $FTY_INIT_LOG_DIR ]; then
        mkdir -p $FTY_INIT_LOG_DIR
    else
        rm -rf $FTY_INIT_LOG_DIR/*
    fi

    #创建工厂压缩日志目录
    if [ ! -d $FTY_SAVE_LOG_DIR ]; then
        mkdir -p $FTY_SAVE_LOG_DIR
    
    #避免每次触发日志都会删除上一次的日志，把以下注释
    #else
        #rm -rf $FTY_SAVE_LOG_DIR/*
    fi

    #清空debug info信息
    if [ -f ${FTY_SCRIPT_RECORD} ]; then
        echo "" > ${FTY_SCRIPT_RECORD}
    else
        touch ${FTY_SCRIPT_RECORD}
    fi

    #初始化log拷贝结果文件
    if [ -f ${FTY_LOG_CLONE_RESULT} ]; then
        echo "" > ${FTY_LOG_CLONE_RESULT}
    else
        touch ${FTY_LOG_CLONE_RESULT}
    fi

    #${SYSTEM_BIN_LOGCAT} -c
    ${SYSTEM_BIN_LOGCAT} -G 3M

    #保存父进程pid
    echo $$ > ${FTY_LOG_MAIN_PROCESS_PID}
}


#开启日志后，需要开启后台检测
#同fty_start_log使用
function fty_run_logcat(){
    while [ true ]; do
        fty_check_file_tar_count $FTY_SAVE_LOG_DIR $TAR_GZ_COUNT_MAX

        #LOG_MAX_USED_SIZE=35840
        fty_check_data_space ${LOG_MAX_USED_SIZE}
        resDataSpace=$?

        #echo "[`date +%F_%H:%M:%S`]<fty_run_logcat>resDataSpace=$resDataSpace" >> ${FTY_SCRIPT_RECORD}

        if [ $resDataSpace -eq 0 ]; then
            echo "[`date +%F_%H:%M:%S`]<fty_run_logcat> data space not enough ,stop logcat !!" >> ${FTY_SCRIPT_RECORD}
            fty_stop_logcat
        fi

        sleep 1

        fty_check_log_file_size ${FTY_LOG_PATH} ${FILE_LOG_SIZE_MAX}
        resFileSize=$?

        if [ $resFileSize -eq 0 ]; then
            echo "[`date +%F_%H:%M:%S`]<fty_run_logcat> single log file over size ,need to restart logcat!!" >> ${FTY_SCRIPT_RECORD}
            fty_restart_logcat
        fi

        sleep 1


        #退出logcat，shell的三目运算
        #fty_check_data_space ${LOG_MAX_USED_SIZE} && fty_stop_logcat || echo "data avail space enough...." >> ${FTY_SCRIPT_RECORD}
        #sleep 1
        #fty_check_log_file_size ${FTY_LOG_PATH} ${FILE_LOG_SIZE_MAX} && fty_restart_logcat || echo "log file size < 20M" >> ${FTY_SCRIPT_RECORD}
        #sleep 1
        #fty_check_file_tar_count $FTY_SAVE_LOG_DIR $TAR_GZ_COUNT_MAX
        #sleep 1

        #ps -ef > ${FTY_SAVE_LOG_DIR}/process_info.txt
    done
}

function fty_exec_logcat(){
    currenttime=$(date +%F_%H-%M-%S)
    log_file=${FTY_SAVE_LOG_DIR}/android_${currenttime}.txt
    echo "[`date +%F_%H:%M:%S`}]<fty_exec_logcat>name=$log_file" >> ${FTY_SCRIPT_RECORD}

    echo "[`date +%F_%H:%M:%S`]<fty_exec_logcat>start---log" >> ${FTY_SCRIPT_RECORD}
	
    #${SYSTEM_BIN_LOGCAT} -c		#先注释掉，-c会删除日志，压缩日志和重启日志之间可能会日志丢失
	
    ${SYSTEM_BIN_LOGCAT} -f ${log_file} -v threadtime&
    echo "100" > ${FTY_LOG_STATUS_SAVE}
    #1记录日志存储路径,2保存后台子进程pid
    echo ${log_file} > ${FTY_LOG_PATH}
    echo $! > ${FTY_LOG_CHILD_PROCESS_PID}
    echo "[`date +%F_%H:%M:%S`]<fty_exec_logcat>end---log" >> ${FTY_SCRIPT_RECORD}
}

#1 先获取上一次logcat的进程pid
#2 重新logcat
#3 kill掉之前的logcat进程
#4 触发重新抓日志
function fty_restart_logcat(){
    #获取子进程pid
    last_logcat_pid=`cat ${FTY_LOG_CHILD_PROCESS_PID}`
    last_logcat_file_path=`cat ${FTY_LOG_PATH}`
    echo "[`date +%F_%H:%M:%S`]<fty_restart_logcat>last_logcat_pid=${last_logcat_pid}" >> ${FTY_SCRIPT_RECORD}

    #停止上一次抓取日志行为,但不停止当前sh
    fty_stop_logcat ${last_logcat_pid} ${last_logcat_file_path} "true"

    if [ $# -eq 1 ];then
        echo "[`date +%F_%H:%M:%S`]<fty_restart_logcat>args 1=$1" >> ${FTY_SCRIPT_RECORD}
        if [ "$1" == "copy_log_only" ];then
            echo "[`date +%F_%H:%M:%S`]<fty_restart_logcat>only copy log, no need to restart logcat" >> ${FTY_SCRIPT_RECORD}
            return 1
        fi
    fi

    #重新抓日志
    fty_exec_logcat
}

#返回0表示命令执行成功;对文件进行压缩操作，成功后，删除对应文件
#参数1:传入log文件路径
#参数2:传入生成压缩包的路径
function fty_tar_log(){
    if [ $# -lt 2 ];then
        echo "[`date +%F_%H:%M:%S`]<fty_tar_log>param count error!!!" >> ${FTY_SCRIPT_RECORD}
        return 1
    fi

    if [ ! -f $1 -o ! -d $2 ];then
        echo "[`date +%F_%H:%M:%S`]<fty_tar_log>file or dir not exist!!" >> ${FTY_SCRIPT_RECORD}
        return 1
    fi
    file_name=$1
    dir_path=$2
    echo "[`date +%F_%H:%M:%S`]<fty_tar_log>file_name = $file_name" >> ${FTY_SCRIPT_RECORD}
    
    # -s判断文件长度是否为0，不为0返回真
    if [ -s $file_name ];then
        currenttime=$(date +%F_%H-%M-%S)
        echo "[`date +%F_%H:%M:%S`]<fty_tar_log>currenttime=${currenttime}" >> ${FTY_SCRIPT_RECORD}

        # &>/dev/null 会把指令执行结果定向丢进“黑洞”，使整个过程不会因为指令的返回而中断
        ${SYSTEM_BIN_TAR} -zcvf ${dir_path}/Android_${currenttime}.tar.gz ${file_name} &>/dev/null
        
        # $? 是指上一次命令执行的结果，0是成功，1是失败
        if [ $? -eq 0 ];then
            echo "rm -f $file_name" >> ${FTY_SCRIPT_RECORD}
            rm -f $file_name
            return 0
        else
            echo "tar $file_name failed" >> ${FTY_SCRIPT_RECORD}
            return 1
        fi
    fi
    return 1
}

#返回0表示命令执行成功;对文件进行压缩操作，成功后，删除对应文件
#每次执行log抓取时，强制压缩以往残留的logcat文件
function fty_force_tar_log(){
    echo "[`date +%F_%H:%M:%S`]<fty_force_tar_log>enter fty_force_tar_log" >> ${FTY_SCRIPT_RECORD}

    logcat_file=$(find "${FTY_SAVE_LOG_DIR}" -name 'android_*')
    currenttime=$(date +%F_%H-%M-%S)
    echo "[`date +%F_%H:%M:%S`]<fty_force_tar_log>currenttime=${currenttime} logcat_file=${logcat_file}" >> ${FTY_SCRIPT_RECORD}

    ${SYSTEM_BIN_TAR} -zcvf ${FTY_SAVE_LOG_DIR}/Android_${currenttime}.tar.gz ${logcat_file} &>/dev/null

    echo "rm -f $logcat_file" >> ${FTY_SCRIPT_RECORD}
    rm -f $logcat_file
    return 0
}

##返回0 说明单个日志文件已经超过了20M，需要打包tar，同时重新抓取
#参数1:传入文件名存储所在路径
#参数2:文件大小阈值
function fty_check_log_file_size(){
    if [ ! -f $1 -o $2 -le 1 ];then
        echo "[`date +%F_%H:%M:%S`]<fty_check_log_file_size>param error!!!" >> ${FTY_SCRIPT_RECORD}
        return 1
    fi

    file_path=$(cat $1)
    max_size=$2
    if [ -s ${file_path} ];then
        file_size=$(du -s ${file_path}|awk '{print $1}')
        #echo "[`date +%F_%H:%M:%S`]<fty_check_log_file_size>file_size = ${file_size}" >> ${FTY_SCRIPT_RECORD}
        if [ ${file_size} -gt ${max_size} ];then
            return 0
        fi
    fi
    return 1
}

#参数1:data分区log空间阈值
#data总可用空间不足10M,log文件使用达到35M，返回0，需要停止抓日志
function fty_check_data_space(){
    max_size=$1
    log_used_size=$(du -s ${FTY_ROOT_DIR} | tail -1 | awk '{print $1}')
    avail_space_of_data=$(df -k ${FTY_DATA} | tail -1 | awk '{print $4}')

    if [ ${max_size} -le ${log_used_size} ] ; then
        echo "[`date +%F_%H:%M:%S`]<fty_check_data_space>used=${log_used_size};max_size=$1" >> ${FTY_SCRIPT_RECORD}
        return 0
    fi

    if [ ${avail_space_of_data} -le ${FTY_DATA_LIMIT_SPACE} ] ; then
        echo "[`date +%F_%H:%M:%S`]<fty_check_data_space>avail space=${avail_space_of_data},less than 10240,stop logcat" >> ${FTY_SCRIPT_RECORD}
        return 0
    fi

    return 1
}

##扫描压缩包个数，超过5个需要删除旧的
#参数1:传入压缩包文件夹路径
#参数2:压缩包最大个数
function fty_check_file_tar_count(){
    if [ $# -lt 2 ];then
        echo "[`date +%F_%H:%M:%S`]<fty_check_file_tar_count>args count error!!!" >> ${FTY_SCRIPT_RECORD}
    fi

    if [ ! -d $1 -o $2 -le 1 ];then
        echo "[`date +%F_%H:%M:%S`]<fty_check_file_tar_count>args error!!!" >> ${FTY_SCRIPT_RECORD}
        return 1
    fi

    dir_path=$1
    max_size=$2

    #根据传入的路径，检查路径下的文件数。wc命令是用来统计文件的行数、字节数-l 统计行（line）数
    file_num=`find $dir_path -type f |wc -l`
    
    if [ $file_num -gt $max_size ];then
        echo "[`date +%F_%H:%M:%S`]<fty_check_file_tar_count>num = $file_num" >> ${FTY_SCRIPT_RECORD}
        delete_size=$(expr $file_num - $max_size)
        echo "[`date +%F_%H:%M:%S`]<fty_check_file_tar_count>delete_size = $delete_size" >> ${FTY_SCRIPT_RECORD}

    #显示多出来个数的压缩包明细：显示n行的第8列，即文件名。
    #因为按时间顺序排列，所以显示在顶部的时间越早，删除最早的几个文件
        file_list=`ls -l $dir_path/Android_* |head -$delete_size |awk '{print $8}'`

        for i in $file_list
        do
            echo "[`date +%F_%H:%M:%S`]<fty_check_file_tar_count>i = $i" >> ${FTY_SCRIPT_RECORD}
            rm -f $i
        done
    fi
}

#该接口为阻塞式，禁止重复调用。
#start---stop  成对调用
function fty_start_logcat(){
    #初始化日志相关目录
    fty_init_logcat

    #清除原来的log
    fty_force_tar_log

    #抓日志
    fty_exec_logcat

    #while循环check (日志文件打包压缩、压缩包个数、data空间剩余大小检测)
    fty_run_logcat
}

#功能描述: 先停掉logcat 进程;然后停掉 start log的 sh进程
#参数1:子进程pid
#参数2:log的路径
#参数3:是否需要退出主进程
function fty_stop_logcat(){
    echo "101" > ${FTY_LOG_STATUS_SAVE}
    # $#检查传参个数,为0停止抓日志
    echo "[`date +%F_%H:%M:%S`]<fty_stop_logcat>args=$#" >> ${FTY_SCRIPT_RECORD}
    
    #停掉logcat进程,-z检查传参长度是否为0，为0返回true
    if [ -z "$1" ];then
        process_pid=$(cat ${FTY_LOG_CHILD_PROCESS_PID})
    else
        process_pid=$1
    fi
    echo "[`date +%F_%H:%M:%S`]<fty_stop_logcat>pid=${process_pid}" >> ${FTY_SCRIPT_RECORD}

    # -n检查进程ID长度是否为0，不为0返回true
    if [ -n "${process_pid}" ];then
        ${SYSTEM_BIN_KILL} -9 ${process_pid}
        echo "[`date +%F_%H:%M:%S`]<fty_stop_logcat>success(2-1)!!!" >> ${FTY_SCRIPT_RECORD}
    fi

    #打包日志文件
    if [ -z "$2" ];then
        file_path=$(cat ${FTY_LOG_PATH})
    else
        file_path=$2
    fi
    fty_tar_log ${file_path} ${FTY_SAVE_LOG_DIR}

    #当参数3为空，表示退出主进程
    #当参数3非空，表示不退出主进程
    if [ -z "$3"  ];then
        if [ -f ${FTY_LOG_MAIN_PROCESS_PID} ];then
            main_pid=$(cat ${FTY_LOG_MAIN_PROCESS_PID})
            echo "[`date +%F_%H:%M:%S`]<fty_stop_logcat>main_pid=${main_pid}" >> ${FTY_SCRIPT_RECORD}
            if [ -n "${main_pid}" ];then
                echo "[`date +%F_%H:%M:%S`]<fty_stop_logcat>success(2-2)!!!" >> ${FTY_SCRIPT_RECORD}
                ${SYSTEM_BIN_KILL} -9 ${main_pid}
            fi
        fi
        ##exit退出sh
        exit 0
    fi
}

#参数1:待拷贝的文件
#参数2:拷贝指定目录
function fty_copy_file_to_targetdir() {
    if [ -z "$1" -o -z "$2" ];then
        echo "[`date +%F_%H:%M:%S`]<fty_copy_file_to_targetdir>param args is null!!!!" 
        #clone 失败
        echo "failed" > ${FTY_LOG_CLONE_RESULT}
        return 1
    fi
    echo "[`date +%F_%H:%M:%S`]<fty_copy_file_to_targetdir> parm_1=${1};parm2=${2}"

    if [ ! -f $1 -o ! -d $2 ]; then
        echo "[`date +%F_%H:%M:%S`]<fty_copy_file_to_targetdir>file or dir is not exist!!!!"
        #clone 失败
        echo "failed" > ${FTY_LOG_CLONE_RESULT}
        return 1
    fi
    if [ ! -d $2/factory_log ];then
        mkdir -p $2/factory_log
    fi
    #将文件cp到usb里面
    cp -rf $1 $2/factory_log/
    # $? 是指上一次命令执行的结果，0是成功，1是失败
    if [ $? -eq 0 ];then
        #clone 中
        echo "cloning" > ${FTY_LOG_CLONE_RESULT}
        echo "cp logs success" >> ${FTY_SCRIPT_RECORD}
    fi
    /system/bin/sync
}

function fty_copy_log_to_usb(){
    currenttime=$(date +%F_%H-%M-%S)
    if [ ! -d ${FTY_SAVE_LOG_DIR} ]; then
        echo "[`date +%F_%H:%M:%S`]<fty_copy_log_to_usb>${FTY_SAVE_LOG_DIR} is not exisit!!!!" >> ${FTY_SCRIPT_RECORD}
        #clone 失败
        echo "none" > ${FTY_LOG_CLONE_RESULT}
        return 1
    fi

    
    usbdir=`grep -e "/media_rw/" /proc/mounts | awk '{print $2}' | head -1`
    if [ ! -n "$usbdir" ]; then
        echo "[`date +%F_%H:%M:%S`]<fty_copy_log_to_usb>Usb dir null..." >> ${FTY_SCRIPT_RECORD}
        #clone 失败
        echo "none" > ${FTY_LOG_CLONE_RESULT}
        return 1
    else
        if [ -f ${FTY_LOG_STATUS_SAVE} ];then
            log_status=`cat ${FTY_LOG_STATUS_SAVE}`
            echo "<fty_copy_log_to_usb>log_status = ${log_status}" >> ${FTY_SCRIPT_RECORD}
            if [[ "${log_status}" == "100" ]];then
                echo "[`date +%F_%H:%M:%S`]<fty_copy_log_to_usb>because log is working,to clone log need to stop current process" >> ${FTY_SCRIPT_RECORD}
                fty_restart_logcat copy_log_only
                #fty_stop_logcat
            fi
        fi
    
        ALL_FILE=$(ls -tr ${FTY_SAVE_LOG_DIR})
        for path in $ALL_FILE; do
            fty_copy_file_to_targetdir  ${FTY_SAVE_LOG_DIR}/${path} ${usbdir}
            
            #检查U盘是否存在,避免中途拔出
            usbdir=$(grep -e "/media_rw/" /proc/mounts | awk '{print $2}' | head -1)
            
            if [ ! -n "$usbdir" ]; then
                echo "[`date +%F_%H:%M:%S`]<fty_copy_log_to_usb>Usb dir null--cp to usb failed!!!" >> ${FTY_SCRIPT_RECORD} 
                break
            fi
       done
       echo "success" > ${FTY_LOG_CLONE_RESULT}
       echo "[`date +%F_%H:%M:%S`]<fty_copy_log_to_usb>cp to usb end"  >> ${FTY_SCRIPT_RECORD}
       cp -rf ${FTY_LOG_CLONE_RESULT} ${usbdir}/factory_log
       /system/bin/sync
    fi
    sleep 1
}

echo "[`date +%F_%H:%M:%S`]<fty_log>enter factory log sh process ,in" >> ${FTY_SCRIPT_RECORD}

if [[ "$pmode" != "1" ]];then
    #rm -rf $FTY_ROOT_DIR
    exit 0
fi

if [ $# == 0 ];then
    echo "[`date +%F_%H:%M:%S`]<fty_log>args is 0,do nothing......" >> ${FTY_SCRIPT_RECORD}  
else
    echo "[`date +%F_%H:%M:%S`]<fty_log>args=$1" >> ${FTY_SCRIPT_RECORD}
    case "$1" in
        "fty_start_log")
            fty_start_logcat
        ;;
        "fty_stop_log")
            fty_stop_logcat
        ;;
        "fty_copy_log")
            fty_copy_log_to_usb
        ;;
        *)
            echo "<fty_locale>do nothing..." >> ${FTY_SCRIPT_RECORD}
        ;;
    esac
fi

if [ -f ${FTY_SCRIPT_RECORD} ]; then
    echo "[`date +%F_%H:%M:%S`]<fty_log>enter factory log sh process ,out" >> ${FTY_SCRIPT_RECORD}
fi

