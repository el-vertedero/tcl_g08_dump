#!/system/bin/sh
#!/bin/bash
CURTIME=`date +%F_%H-%M-%S`
config="$1"
# ===========================
# Sandman Log Helper Script
# ===========================
# 功能: 启动 Perfetto 跟踪并记录日志
# 支持动态传入参数:
#   1. 函数名称 (决定调用哪个功能)
#   2. 输出路径
#   3. 缓冲区大小 (单位: KB)
#   4. 跟踪时长 (单位: 毫秒)
# ===========================
function BootAnimStatusChange(){
    #sleep 1
    usleep 500000
    bootanim_exit_status=`getprop service.bootanim.exit`
    #setprop persist.sys.bootexit.tmphu "$bootanim_exit_status"
    if [ "${bootanim_exit_status}" = "0" ] ; then
        #setprop persist.sys.bootexit.tmphu "hu"
        return
    fi
    setprop sys.tcl.bootexit.statuschange "true"
}

function CopyDataAnr(){
    targetDir="/data/system/nvrhung/sandman/crash4timebeforeboot/"
    fileNamePattern="anr"
    startTime=$(getprop sys.copydataanr.startTime)
    find /data/anr -type f -name "*${fileNamePattern}*" -newermt "${startTime}" -exec cp -a {} "${targetDir}" \;
    cd /data/system/nvrhung/sandman/crash4timebeforeboot/
    chmod 755 *
}

case "$config" in
    "BootAnimStatusChange")
     BootAnimStatusChange
     ;;
    "CopyDataAnr")
     CopyDataAnr
     ;;
     *)
     ;;
esac