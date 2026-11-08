#!/bin/bash
CURTIME=`date +%F_%H-%M-%S`
config="$1"
defaultLogcatSize=0
globalStatus="0"
tarpath=""
maxindex=0
minpath=""
globalCount=0

function InitBootLog(){
    logenable=`getprop persist.sys.normallog`
    boot_completed=`getprop sys.boot_completed`
    echo "${CURTIME}--InitBootLog start collect log" >> /data/tcl_log/debug.txt
    if [ x"${logenable}" = x"true" ] && [ x"${boot_completed}" != x"1" ]; then
        setprop sys.collectbootlog.start true
    fi
}

function CollectBootMainLog(){
    logenable=`getprop persist.sys.normallog`
    argtrue='true'
    if [ "${logenable}" = "${argtrue}" ]; then
       setLogcatBuffer
       /system/bin/logcat -f /data/tcl_log/tmp/android_boot.txt -r10240 -v threadtime
    fi
}
function CollectBootEventLog(){
    logenable=`getprop persist.sys.normallog`
    argtrue='true'
    if [ "${logenable}" = "${argtrue}" ] ; then
    /system/bin/logcat -b events -f /data/tcl_log/tmp/events_boot.txt -r4096 -v threadtime
    fi
}

function CollectBootKernelLog(){
  logenable=`getprop persist.sys.normallog`
  argtrue='true'
  if [ "${logenable}" = "${argtrue}" ] ; then
    dmesg > /data/tcl_log/tmp/dmesg_boot.txt
    /system_ext/bin/klogkitlogcat -f  /data/tcl_log/tmp/kmsg_boot.txt
  fi
}

function InitLog(){
    logenable=`getprop persist.sys.normallog`
    if [ "${logenable}" = "true" ] ; then
        boot_completed=`getprop sys.boot_completed`
        decrypt_delay=0
        while [ x${boot_completed} != x"1" ];do
            sleep 1
            decrypt_delay=`expr $decrypt_delay + 1`
            boot_completed=`getprop sys.boot_completed`
            if [ $decrypt_delay -gt 600 ];then
                 echo "${CURTIME}--system start  timeout 600s" | tee -a /data/tcl_log/debug.txt
                 setprop persist.sys.normallog -1
                 setprop ctl.stop GeorgedebugStartCollectBootMainLog
                 setprop ctl.stop GeorgedebugStartCollectBootEventLog
                 setprop ctl.stop GeorgedebugStartCollectBootKernelLog
                 setprop ctl.start GeorgedebugMvLogtoSDcard
                 return
             fi
        done
        NORMAL_LOG_PATH=/data/tcl_log/tmp/${CURTIME}/log
        mkdir -p  ${NORMAL_LOG_PATH}
        echo "make new dir ${NORMAL_LOG_PATH}" | tee -a /data/tcl_log/debug.txt
        mkdir -p /data/tcl_log/compresslog
        chmod -R 770 /data/tcl_log/
        chmod -R 770 /data/tcl_log/tmp/${CURTIME}
        setprop sys.logkit.normallog ${NORMAL_LOG_PATH}
        decrypt='false'
        if [ x"${decrypt}" != x"true" ]; then
            setprop ctl.stop GeorgedebugStartCollectBootMainLog
            setprop ctl.stop GeorgedebugStartCollectBootEventLog
            setprop ctl.stop GeorgedebugStartCollectBootKernelLog
            mv /data/tcl_log/tmp/*_boot.txt* ${NORMAL_LOG_PATH}/
            echo "mv cache to normal"
        fi
        startCollectLog
    fi
}

function startCollectLog(){
    startCollectCommonLog
}

function startCollectCommonLog(){
  setprop ctl.start   GeorgedebugSetEnvironment
  setprop ctl.start   GeorgedebugLogcatMain
  setprop ctl.start   GeorgedebugLogcatEvent
  setprop ctl.start   GeorgedebugLogcatKernel
  setprop ctl.start   GeorgedebugDetectStorage
  enable_wifilog=$(getprop persist.sys.wifi.log_enable)
  log_type=$(getprop persist.sys.logtype)
  if [ x${log_type} = x"wifi" ]; then
        setprop ctl.start GeorgedebugStartDebugWifi
        setprop ctl.start GeorgedebugStartIwpriv
        enable_TcpDump=$(getprop persist.sys.enableTcpDump)
        if [ x${enable_TcpDump} = x"true" ]; then
            setprop ctl.start GeorgedebugTcpDumpLog
        fi
  elif [ x${enable_wifilog} = x"1" ]; then
        setprop ctl.start GeorgedebugStartWifiNormalLog
  fi
  # #ifdef VENDOR_EDIT
  #peng65.chen@tcl.com, 2025/12/03, [LINTHY-88529] logkit add bluetooth chip log
  if [ x${log_type} = x"bluetooth" ]; then
        setprop ctl.start GeorgedebugStartDebugBluetooth
  fi
  #endif /* VENDOR_EDIT */
  if [ x${log_type} = x"screenrecord" ]; then
        setprop ctl.start GeorgedebugScreenRecordAndEnableWmStart
  fi
}
function waitToCopyBootLog() {
    START=`date +%s`
    local NORMAL_LOG_PATH=$1
    count=0
    while [ $count -lt 10 ] ;do
        count=$((count + 1))
        sleep 1
        usbdir=$(grep -e "/media_rw/" /proc/mounts | awk '{print $2}' | head -1)
        echo "usbdir=$usbdir"
        if [ ! -n "$usbdir" ]; then
          echo "Usb dir null,cannot mv tar to udisk" >> /data/tcl_log/debug.txt
        else
          if [ ! -d $usbdir/tcl_log ]; then
             mkdir -p $usbdir/tcl_log
          fi
          moveTarToUdisk
          cp ${NORMAL_LOG_PATH}/*_boot.txt* $usbdir/tcl_log/
          sync
          echo " copy boot log  to udisk" >> /data/tcl_log/debug.txt
          break
        fi
    done
    END=`date +%s`
    duration=`expr ${END} - ${START} 2>/dev/null`
    echo "waitToCopyBootLog-exec-${duration} s" >> /data/tcl_log/debug.txt
}
function DetectStorage() {

  dataSize=$(df "/data" | tail -1 | awk '{print $2}')
  dataAvailSize=$(df "/data" | tail -1 | awk '{print $4}')
  RemainSize=$(expr ${dataSize} / 5)
  GSize=$(echo | awk '{printf("%d",1*1024*1024)}')
  if [ ${RemainSize} -lt ${GSize} ] ; then
    RemainSize=$(expr 1 \* 1024 \* 1024)
  fi
  MaxCacheSize=$(echo | awk '{printf("%d",5*1000*1024)}')
  echo "DetectStorage dataSize ${dataSize} RemainSize ${RemainSize}  dataAvailSize ${dataAvailSize}"   | tee -a /data/tcl_log/debug.txt
  MaxLogsize=$(echo | awk '{printf("%d",1*100*1024)}')

  NORMAL_LOG_PATH=$(getprop sys.logkit.normallog)
  needCopyLog=`getprop sys.collectbootlog.start`
  if [ "${needCopyLog}" = "true" ]; then
    setprop sys.collectbootlog.start false
    waitToCopyBootLog ${NORMAL_LOG_PATH} &
  fi
  while [ true ]; do
    globalStatus="1"
    dataSize=$(df "/data" | tail -1 | awk '{print $4}')
    echo "DetectStorage--dataSize=${dataSize}--RemainSize=${RemainSize}" | tee -a /data/tcl_log/debug.txt
    logenable=$(getprop persist.sys.normallog)
    if [ "${logenable}" != "true" ]; then
      echo "DetectStorage--Georgedebug-exit" | tee -a /data/tcl_log/debug.txt
      globalStatus="0"
      return
    fi
    DeleteCompressLog
    # if data storage less than 1GB
    # move tar file to udisk
    #
    if [ ${dataSize} -le ${RemainSize} ] ; then
        setprop ctl.stop   GeorgedebugLogcatMain
        setprop ctl.stop   GeorgedebugLogcatEvent
        setprop ctl.stop   GeorgedebugLogcatKernel
        setprop persist.sys.normallog 2
        echo "DetectStorage-data size below 20%-Georgedebug-exit" | tee -a /data/tcl_log/debug.txt
        du -sh /data/tcl_log/* | tee -a /data/tcl_log/debug.txt
        du -sh /data/tcl_log/tmp/* | tee -a /data/tcl_log/debug.txt
        setprop ctl.start   GeorgedebugWriteSettings
        globalStatus="0"
        return
    fi

    threeGSize=$(echo | awk '{printf("%d",3*1024*1024)}')
    LogSize=$(du -s "/data/tcl_log/tmp" | awk '{print $1}')
    echo "DetectStorage---LogSize=${LogSize}--threeGSize=${threeGSize}"  | tee -a /data/tcl_log/debug.txt
    if [ ${LogSize} -ge ${threeGSize} ]; then
        setprop ctl.stop GeorgedebugLogcatMain
        setprop ctl.stop GeorgedebugLogcatEvent
        setprop ctl.stop GeorgedebugLogcatKernel
        setprop persist.sys.normallog 3
        echo "DetectStorage-data size over 2000m-Georgedebug-exit" | tee -a /data/tcl_log/debug.txt
        du -sh /data/tcl_log/* | tee -a /data/tcl_log/debug.txt
        du -sh /data/tcl_log/tmp/* | tee -a /data/tcl_log/debug.txt
        setprop ctl.start GeorgedebugWriteSettings
        globalStatus="0"
        return
    fi

    LogSize=$(du -s "/data/tcl_log/tmp" | awk '{print $1}')
    echo "DetectStorage--LogSize=${LogSize}--MaxLogsize=${MaxLogsize} globalCount=${globalCount}" | tee -a /data/tcl_log/debug.txt
     globalCount=$(expr ${globalCount})
     # log size great than max log size we set
    if [ ${LogSize} -ge ${MaxLogsize} ] ||  [ x"${globalCount}" = x"4" ]  ; then
         globalCount=0
         NORMAL_LOG_PATH=$(getprop sys.logkit.normallog)
         # tar dir01 dir02 dir03 to Andorid_timestamp.tar.gz
         moveAndTarMultiLog ${NORMAL_LOG_PATH}

         # tar android.txt.01 ... android.txt.n to Android_timestamp.tar.gz
         moveAndTarAndroidList ${NORMAL_LOG_PATH}
     fi
     moveTarToUdisk
     logenable=$(getprop persist.sys.normallog)
     if [ "${logenable}" != "true" ]; then
      echo "DetectStorage-mv--exit" | tee -a /data/tcl_log/debug.txt
      return
     fi
    echo "DetectStorage--sleep 300 s--${globalStatus}" | tee -a /data/tcl_log/debug.txt
    globalStatus="0"
    sleep 300
    globalCount=$(expr ${globalCount} + 1)
  done
}

function DeleteCompressLog() {
     START=`date +%s`
     compressLogSize=$(du -s "/data/tcl_log/compresslog" | awk '{print $1}')
     count=`ls -t /data/tcl_log/compresslog/Android_*.tar.gz | wc -l`
     echo  "/data/tcl_log/compresslog has ${count} files"| tee -a /data/tcl_log/debug.txt
     while [ $count -gt 0 ] && [ ${compressLogSize} -gt ${MaxCacheSize} ];do
          lastUsbFile=`ls -tr /data/tcl_log/compresslog/Android_*.tar.gz | head -1`
          rm -rf ${lastUsbFile}
          count=$((count - 1))
          echo "delete--${lastUsbFile}" | tee -a /data/tcl_log/debug.txt
          compressLogSize=$(du -s "/data/tcl_log/compresslog" | awk '{print $1}')
          echo "compressLogSize=${compressLogSize}" | tee -a /data/tcl_log/debug.txt
          if [ ${compressLogSize} -lt ${MaxCacheSize} ]; then
            echo "compresslog enough-move-- return" | tee -a /data/tcl_log/debug.txt
            break
          fi
     done
     END=`date +%s`
     duration=`expr ${END} - ${START} 2>/dev/null`
     echo "DeleteCompressLog-exec-${duration} s" | tee -a /data/tcl_log/debug.txt
}

function moveTarToUdisk() {
    usbdir=$(grep -e "/media_rw/" /proc/mounts | awk '{print $2}' | head -1)
    if [ ! -n "$usbdir" ]; then
        echo "moveTarToUdisk Usb dir null,cannot mv tar to udisk" | tee -a /data/tcl_log/debug.txt
    else
      if [ ! -d $usbdir/tcl_log ]; then
          mkdir -p $usbdir/tcl_log
      fi
      sum=0
      ALL_FILE=$(ls -tr /data/tcl_log/compresslog/Android_*.tar.gz)
      for path in $ALL_FILE; do
         fileSize=$(du -s $path | awk '{print $1}')
         sum=$(expr ${sum} + ${fileSize})
         echo "add  ${path} ${fileSize} to sum=${sum}" | tee -a /data/tcl_log/debug.txt
         copysize=$(echo | awk '{printf("%d",1*50*1024)}')
         if [ ${sum} -gt ${copysize} ]; then
              echo "log size moveTarToUdisk over 50m path  ${path}" | tee -a /data/tcl_log/debug.txt
              break
         fi
         checkUdiskAndCopy  ${path} ${usbdir}
         usbdir=$(grep -e "/media_rw/" /proc/mounts | awk '{print $2}' | head -1)
         if [ ! -n "$usbdir" ]; then
            echo "Usb dir null--moveTarToUdisk return ${sourceFile}" | tee -a /data/tcl_log/debug.txt
            return
         fi
      done
    fi
}
function checkUdiskAndCopy() {
    local sourceFile=$1
    local usbdir=$2
    START=`date +%s`
    usbAvailSize=$(df "$usbdir" | tail -1 | awk '{print $4}')
    sourceSize=$(du -s ${sourceFile} | awk '{print $1}')
    echo "sourceSize=${sourceSize}-usbAvailSize=$usbAvailSize" | tee -a /data/tcl_log/debug.txt
    PRODUCT_TYPE=$(getprop ro.tcl.product_type)
    if [ ${usbAvailSize} -ge ${sourceSize} ]; then
       mv ${sourceFile}  $usbdir/tcl_log/
       if [ "${PRODUCT_TYPE}" = "FTV" ]; then
           fsync $usbdir/tcl_log/${sourceFile}
       else
           sync
       fi
       echo "-move ${sourceFile} to ${usbdir}/tcl_log/" | tee -a /data/tcl_log/debug.txt
    else
        count=`ls -t $usbdir/tcl_log/Android_*.tar.gz | wc -l`
        echo  "${usbdir} has ${count} files" | tee -a /data/tcl_log/debug.txt
        while [ $count -gt 0 ] && [ ${usbAvailSize} -lt ${sourceSize} ];do
              lastUsbFile=`ls -tr $usbdir/tcl_log/Android_*.tar.gz | head -1`
              echo ""> ${lastUsbFile}
              rm -rf ${lastUsbFile}
              sync
              count=$((count - 1))
              echo "delete--${lastUsbFile}" | tee -a /data/tcl_log/debug.txt
              usbdir=$(grep -e "/media_rw/" /proc/mounts | awk '{print $2}' | head -1)
              if [ ! -n "$usbdir" ]; then
                echo "Usb dir null--return ${sourceFile}" | tee -a /data/tcl_log/debug.txt
                return
              fi
              usbAvailSize=$(df "$usbdir" | tail -1 | awk '{print $4}')
              echo "usbAvailSize=${usbAvailSize} sourceSize=${sourceSize}" | tee -a /data/tcl_log/debug.txt
              if [ ${usbAvailSize} -ge ${sourceSize} ]; then
                mv ${sourceFile}  $usbdir/tcl_log/
                sync
                echo "storage enough-move ${sourceFile} to ${usbdir}/tcl_log/ return" | tee -a /data/tcl_log/debug.txt
                return
              fi
              continue
        done
        echo "Usb dir-full move  ${sourceFile}  to /data/tcl_log/compresslog/" | tee -a /data/tcl_log/debug.txt
      fi
    END=`date +%s`
    duration=`expr ${END} - ${START} 2>/dev/null`
    echo "checkUdiskAndCopy-exec-${duration} s" | tee -a /data/tcl_log/debug.txt
}

function moveAndTarMultiLog() {
  local NORMAL_LOG_PATH=$1
  START=`date +%s`
  logPath=$(echo -e "${NORMAL_LOG_PATH}" | cut -d "\/" -f5)
  tarpath=""
  count=$(ls -t /data/tcl_log/tmp/ | wc -l)
  echo "moveAndTarMultiLog--/data/tcl_log/tmp/ has ${count} dirs logPath=${logPath}" | tee -a /data/tcl_log/debug.txt
  if [ $count -gt 1 ]; then
     sum=0
     cd /data/tcl_log/tmp/
     ALL_FILE=$(ls -tr /data/tcl_log/tmp/)
     for path in $ALL_FILE; do

        if [ "${path}" == "${logPath}" ];then
           echo "current log write path  ${path}" | tee -a /data/tcl_log/debug.txt
           continue
        fi
        if [ ! -d ${path} ];then
           echo "is not dir  path  ${path}" | tee -a /data/tcl_log/debug.txt
        fi

        fileSize=$(du -s $path | awk '{print $1}')
        sum=$(expr ${sum} + ${fileSize})
        echo "add  ${path} ${fileSize} to sum=${sum}" | tee -a /data/tcl_log/debug.txt
        if [ "${tarpath}" == "" ];then
           tarpath="${path}"
        else
          MaxLogsize=$(echo | awk '{printf("%d",1*100*1024)}')
          if [ ${sum} -gt ${MaxLogsize} ]; then
              echo "log size over 100m path  ${path}" | tee -a /data/tcl_log/debug.txt
              break
          fi
           tarpath="${tarpath} ${path}"
        fi
     done
  fi
   END=`date +%s`
   duration=`expr ${END} - ${START} 2>/dev/null`

   echo "moveAndTarMultiLog-exec-${duration} s" | tee -a /data/tcl_log/debug.txt
}
function moveAndTarAndroidList() {
   local NORMAL_LOG_PATH=$1
   count=$(ls -t ${NORMAL_LOG_PATH}/*.txt* | wc -l)
   echo "moveAndTarAndroidList ${NORMAL_LOG_PATH} has ${count}  *.txt" | tee -a /data/tcl_log/debug.txt
   logPath=$(echo -e "${NORMAL_LOG_PATH}" | cut -d "\/" -f5)
   START=$(date +%s)
   if [ $count -ge 1 ]; then
      currenttime=$(date +%F_%H-%M-%S)
      echo "beofore-mv-to sdcard--${currenttime}" | tee -a /data/tcl_log/debug.txt
      cd ${NORMAL_LOG_PATH}
      ALL_FILE=$(ls -t *.txt*)
      echo "ALL_FILE ${ALL_FILE}" | tee -a /data/tcl_log/debug.txt
      setprop ctl.stop  GeorgedebugLogcatKernel
      setprop ctl.stop  GeorgedebugLogcatMain
      setprop ctl.stop  GeorgedebugLogcatEvent
      sleep 1
      setprop ctl.start  GeorgedebugLogcatMain
      setprop ctl.start  GeorgedebugLogcatEvent
      setprop ctl.start  GeorgedebugLogcatKernel
      for path in $ALL_FILE; do
         tarpath="${tarpath} ${logPath}/log/${path}"
      done
   fi

   cd /data/tcl_log/tmp/
   tarCount=$(find -name *.tar.gz 2>/dev/null| wc -l)
   if [ $tarCount -ge 1 ]; then
     echo "beofore-has tarCount tar.gz ${tarCount}" | tee -a /data/tcl_log/debug.txt
     find -name *.tar.gz 2>/dev/null|xargs rm -fr
   fi

   if [ ! -d /data/tcl_log/compresslog ]; then
        mkdir -p /data/tcl_log/compresslog
   fi

   PRODUCT_TYPE=$(getprop ro.tcl.product_type)
   if [ -d /data/tcl_log/compresslog ]; then
        currenttime=$(date +%F_%H-%M-%S)
        # pisong.huang@tcl: for FTV opt
        if [ "${PRODUCT_TYPE}" = "FTV" ]; then
            tar -cvf - ${tarpath} | gzip -1 > ${NORMAL_LOG_PATH}/Android_${currenttime}.tar.gz
        else
            tar -zcvf ${NORMAL_LOG_PATH}/Android_${currenttime}.tar.gz ${tarpath}
        fi
        # tar -zcvf ${NORMAL_LOG_PATH}/Android_${currenttime}.tar.gz ${tarpath}
        mv ${NORMAL_LOG_PATH}/Android_${currenttime}.tar.gz /data/tcl_log/compresslog/
        rm -fr ${tarpath}
        echo "delete tarpath ${tarpath}" | tee -a /data/tcl_log/debug.txt
        echo "make a new tar file to  /data/tcl_log/compresslog/Android_${currenttime}.tar.gz" | tee -a /data/tcl_log/debug.txt
   fi

   END=`date +%s`
   duration=`expr ${END} - ${START} 2>/dev/null`
   echo "moveAndTarAndroidList-exec-${duration} s" | tee -a /data/tcl_log/debug.txt
}

function LogcatMain(){
    logenable=`getprop persist.sys.normallog`
    NORMAL_LOG_PATH=`getprop  sys.logkit.normallog`
    if [ "${logenable}" = "true" ] ; then
        setLogcatBuffer
        currenttime=$(date +%F_%H-%M-%S)
        /system/bin/logcat -f ${NORMAL_LOG_PATH}/android_${currenttime}.txt -v threadtime
    else
        setprop ctl.stop GeorgedebugLogcatMain
    fi
}
function setLogcatBuffer() {
    logdsize=$(getprop persist.logd.size)
    if [ "${logdsize}" = "" ]; then
        /system/bin/logcat -b main -b system -b kernel  -G 5M
        /system/bin/logcat -b crash -G 3M
    else
         /system/bin/logcat -G ${logdsize}
    fi
}

function LogcatEvent(){
    logenable=`getprop persist.sys.normallog`
    NORMAL_LOG_PATH=`getprop  sys.logkit.normallog`
    if [ "${logenable}" = "true" ] ; then
        currenttime=$(date +%F_%H-%M-%S)
        /system/bin/logcat -b events -f ${NORMAL_LOG_PATH}/events_${currenttime}.txt  -v threadtime
    else
        setprop ctl.stop GeorgedebugLogcatEvent
    fi
}

function LogcatKernel(){
    logenable=`getprop persist.sys.normallog`
    NORMAL_LOG_PATH=`getprop sys.logkit.normallog`
    if [ "${logenable}" = "true" ]; then
       currenttime=$(date +%F_%H-%M-%S)
       /system_ext/bin/klogkitlogcat -f  ${NORMAL_LOG_PATH}/kmsg_${currenttime}.txt
    fi
}
function setEnvironment() {
   dumpsys settings tlog set DEBUG 1
}

function MvLogtoSDcard(){
    copyLog
    setprop ctl.start GeorgedebugResetEnvironment
}
function resetEnvironment() {
    bufferSize=`logcat -g|grep "main"| awk '{print $5$6}'`
    if [ "${bufferSize}" == "5MiB" ]; then
       logcat -b main -b system -b kernel -b crash -G 1M
    fi
    dumpsys settings tlog set DEBUG 0
}
function copyNormalLog(){
    if [ -d /data/tcl_log/tmp ]; then
        local stop_log_path=$(date +%F_%H-%M-%S)
        mkdir -p /data/tcl_log/tmp/${stop_log_path}
        chmod -R 777 /data/tcl_log/tmp/${stop_log_path}
        mv /data/tcl_log/tmp/* /data/tcl_log/tmp/${stop_log_path}
        setprop sys.tranfer.finished "copyNormalLog"
    fi
}

function copyAee() {
    if [ -d /data/tcl_log/tmp ]; then
       mkdir -p  /data/tcl_log/tmp/aee_exp
       mkdir -p  /data/tcl_log/tmp/aee_exp/vendor
       chmod -R 770 /data/tcl_log/tmp/aee_exp
       cp -ar /data/aee_exp/*  /data/tcl_log/tmp/aee_exp/
       cp -ar /data/vendor/aee_exp/*  /data/tcl_log/tmp/aee_exp/vendor/
       chmod -R 770 /data/tcl_log/tmp/aee_exp
       touch /data/tcl_log/tmp/copy_aee
       setprop sys.tranfer.finished "copyAee"
    fi
}
function copyAnr(){
    if [ -d /data/tcl_log/tmp ]; then
       mkdir -p  /data/tcl_log/tmp/anr
       chmod -R 770 /data/tcl_log/tmp/anr
       cp  /data/anr/*  /data/tcl_log/tmp/anr
       touch /data/tcl_log/tmp/copy_anr
       setprop sys.tranfer.finished "copyAnr"
    fi
}
function copyTombstone(){
    if [ -d /data/tcl_log/tmp ]; then
       mkdir -p /data/tcl_log/tmp/tombstones
       chmod -R 770 /data/tcl_log/tmp/tombstones
       mv /data/tombstones/tombstone* /data/tcl_log/tmp/tombstones
       setprop sys.tranfer.finished "copyTombstone"
    fi
}
function copyPstore(){
  if [ -d /data/tcl_log/tmp ]; then
    cp -a /sys/fs/pstore/* /data/tcl_log/tmp/
    chmod 770 /data/tcl_log/tmp/*
    touch /data/tcl_log/tmp/copy_pstore
    setprop sys.tranfer.finished "copyPstore"
  fi
}
function copyKfault(){
  if [ -d /data/tcl_log/tmp ]; then
    ALL_FILE=`ls -t /sys/fs/kfault/`
    for path in $ALL_FILE;
    do
        if [ $path != "latest" ] ; then
           cp -afr /sys/fs/kfault/$path /data/tcl_log/tmp/
        fi
    done
    chmod 770 /data/tcl_log/tmp/*
    touch /data/tcl_log/tmp/copyKfault
    setprop sys.tranfer.finished "copyKfault"
  fi
}
function copyCoredump(){
   setprop sys.tranfer.finished "copyCoredump"
}

function waitToCopyAee() {
    rm -fr /data/tcl_log/tmp/copy_aee
    setprop ctl.start GeorgedebugCopyAee
    count=0
    while [ $count -le 20 ] && [ ! -f /data/tcl_log/tmp/copy_aee ];do
          count=$((count + 1))
          sleep 1
    done
    rm -fr /data/tcl_log/tmp/copy_aee
}

function waitToCopyAnr() {
    rm -fr /data/tcl_log/tmp/copy_anr
    setprop ctl.start GeorgedebugCopyAnr
    count=0
    while [ $count -le 20 ] && [ ! -f /data/tcl_log/tmp/copy_anr ];do
          count=$((count + 1))
          sleep 1
    done
    rm -fr /data/tcl_log/tmp/copy_anr
}
function waitToDumpSystem() {
    setprop ctl.start dumpSystem
    count=0
    while [ $count -le 60 ] && [ ! -f /data/tcl_log/tmp/finish_system ];do
        count=$((count + 1))
        sleep 1
    done
    rm -fr data/tcl_log/tmp/finish_system
}
function waitToCopyPstone() {
    rm -fr /data/tcl_log/tmp/copy_pstore
    setprop ctl.start   GeorgedebugCopyPstore
    count=0
    while [ $count -le 5 ] && [ ! -f /data/tcl_log/tmp/copy_pstore ];do
        count=$((count + 1))
        sleep 1
    done
    rm -fr /data/tcl_log/tmp/copy_pstore
}
function waitToCopyKfault() {
    rm -fr /data/tcl_log/tmp/copyKfault
    setprop ctl.start   GeorgedebugCopyKfault
    count=0
    while [ $count -le 5 ] && [ ! -f /data/tcl_log/tmp/copyKfault ];do
        count=$((count + 1))
        sleep 1
    done
    rm -fr /data/tcl_log/tmp/copyKfault
}

function CopyBlueToothLog(){
    if [ -d /data/tcl_log/tmp ]; then
        mkdir -p /data/tcl_log/tmp/bluetooth
        chmod -R 770 /data/tcl_log/tmp/bluetooth
        SENSITIVE_LOG_ENABLE=$(getprop persist.sys.sensitive_log_enabled)
        if [ "${SENSITIVE_LOG_ENABLE}" = "true" ]; then
            cp -a /data/misc/bluedroid/* /data/tcl_log/tmp/bluetooth
        fi
        chmod -R 777 /data/tcl_log/tmp/*
        touch /data/tcl_log/tmp/copy_bluetooth
        setprop sys.tranfer.finished "CopyBlueToothLog"
    fi
}

function WaitToCopyBlueToothLog() {

    rm -fr /data/tcl_log/tmp/copy_bluetooth
    setprop ctl.start   GeorgedebugCopyBluetoothLog
    count=0
    while [ $count -le 20 ] && [ ! -f /data/tcl_log/tmp/copy_bluetooth ];do
        count=$((count + 1))
        sleep 1
    done
    rm -fr /data/tcl_log/tmp/copy_bluetooth
    #setprop ctl.start   GeorgedebugKillBluetooth
    # #ifdef VENDOR_EDIT
    #peng65.chen@tcl.com, 2025/12/03, [LINTHY-88529] logkit add bluetooth chip log
    ls -Rl /data/tcl_log/tmp/bluetooth/skwtest/ >> /data/tcl_log/debug.txt
    setprop ctl.start   GeorgedebugStopDebugBluetooth
    #endif /* VENDOR_EDIT */
}
function WaitToDetectStorage() {

  count=0
  setprop sys.tranfer.finished "WaitToDetectStorage"
  while [ $count -le 200 ] ; do
    count=$((count + 1))
    if [ "${globalStatus}" = "0" ]; then
       echo "stop GeorgedebugDetectStorage"
       setprop ctl.stop GeorgedebugDetectStorage
       break
    fi
    sleep 1
  done
}
function KillBluetooth() {
    bluetoothpid=`ps -A | grep com.android.bluetooth|grep -v remote | head -n 1| awk '{print $2}'`
    if [ x"${bluetoothpid}" != x"" ]; then
       kill -9 $bluetoothpid
    fi
}
function copyLog(){
    setprop sys.tranfer.finished ""
    waitToDumpSystem
    waitToCopyAee
    waitToCopyAnr
    waitToCopyPstone
    waitToCatKfence
    waitToCopyKfault
    WaitToCopyBlueToothLog
    waitToDumpWifiLog
    waitToCopyPcm
    waitToCopyAudio
    CopyMiniLog
    copyTombstone
    copyCoredump
    copyNormalLog
    chown root:system -R /data/tcl_log/*
    chmod -R 770 /data/tcl_log/*
    setprop persist.sys.logtype ""
    waitToDumpScreenRecord
    MvtoUdisk
    MvNetLogtoUdisk
    WaitToDetectStorage
    MvDebugLogtoUdisk
    setprop sys.tranfer.finished "1"
}
function MvtoUdisk(){
    currenttime=$(date +%F_%H-%M-%S)
    PRODUCT_TYPE=$(getprop ro.tcl.product_type)
    if [ ! -d /data/tcl_log/compresslog ]; then
        mkdir -p /data/tcl_log/compresslog
    fi
    cd /data/tcl_log/tmp/
    # pisong.huang@tcl.com: for FTV opt
    if [ "${PRODUCT_TYPE}" = "FTV" ]; then
        tar -cvf - [0-9]* | gzip -1 > /data/tcl_log/tmp/Android_${currenttime}.tar.gz
    else
        tar -zcvf /data/tcl_log/tmp/Android_${currenttime}.tar.gz [0-9]*
    fi
    # tar -zcvf /data/tcl_log/tmp/Android_${currenttime}.tar.gz [0-9]*
    mv /data/tcl_log/tmp/Android_${currenttime}.tar.gz /data/tcl_log/compresslog/
    rm -fr /data/tcl_log/tmp/[0-9]*
    usbdir=`grep -e "/media_rw/" /proc/mounts | awk '{print $2}' | head -1`
    if [ ! -n "$usbdir" ]; then
       echo "Usb dir null, Move log to /data/tcl_log/compresslog/Android_${currenttime}.tar.gz" | tee -a /data/tcl_log/debug.txt
       setprop sys.tranfer.finished "Usb dir null, Move to data"
    else
        ALL_FILE=$(ls -tr /data/tcl_log/compresslog/Android_*.tar.gz)
        for path in $ALL_FILE; do
           checkUdiskAndCopy  ${path} ${usbdir}
           usbdir=$(grep -e "/media_rw/" /proc/mounts | awk '{print $2}' | head -1)
           if [ ! -n "$usbdir" ]; then
             echo "Usb dir null--moveTarToUdisk return ${sourceFile}" | tee -a /data/tcl_log/debug.txt
             break
           fi
       done
       echo "MvtoUdisk udisk end" | tee -a /data/tcl_log/debug.txt
       setprop sys.tranfer.finished "Move log to udisk"
    fi
    sleep 1
}

function PerfettoStart(){
    perfetto --out /data/misc/perfetto-traces/trace.txt sched/sched_switch sched/sched_wakeup sched/sched_wakeup_new sched/sched_waking sched/sched_process_exit sched/sched_process_free ftrace/print gfx input view webview wm am sm hal res dalvik rs bionic power pm ss network binder_driver binder_lock
    #atrace -z -b 32769 -t 10 gfx input view webview wm am sm hal res dalvik rs bionic power pm ss network >/data/tcl_log/tmp/trace1.txt
}
function mvPerfetto(){
    if [ ! -d /data/local/tmp/tcl_log/performance/ ]; then
         mkdir -p /data/local/tmp/tcl_log/performance/
    fi
    if [ -d /data/local/tmp/tcl_log/performance/ ]; then
        cd /data/misc/perfetto-traces/
        /system/bin/cp trace.txt /data/local/tmp/tcl_log/performance/
        /system/bin/chmod 777 -R /data/local/tmp/tcl_log
        usbdir=$(grep -e "/media_rw/" /proc/mounts | awk '{print $2}' | head -1)
        if [ ! -n "$usbdir" ]; then
            return
        else
            if [ ! -d $usbdir/tcl_log ]; then
               mkdir -p $usbdir/tcl_log
            fi
            if [ -d $usbdir/tcl_log ]; then
                 cd /data/local/tmp/tcl_log/performance/
                 currenttime=$(date +%F_%H-%M-%S)
                 mv trace.txt $usbdir/tcl_log/trace_${currenttime}.txt
                 sync
            fi

        fi
    fi
}
function getSystemStatus() {
    boot_completed=`getprop sys.boot_completed`
    if [ -d /data/tcl_log/tmp ]; then
    outputPath=/data/tcl_log/tmp
    rm -fr /data/tcl_log/tmp/finish_system
    dumpsys -t 20 meminfo > ${outputPath}/dumpsys_mem.txt &
    setprop sys.tranfer.finished dumpsysmeminfo
    ps -T -A > ${outputPath}/ps.txt
    setprop sys.tranfer.finished ps
    export COLUMNS=180
    top -n 2 -s 10 > ${outputPath}/top.txt
    export COLUMNS=80
    setprop sys.tranfer.finished top
    cat /proc/meminfo > ${outputPath}/proc_meminfo.txt
    setprop sys.tranfer.finished procmeminfo
    getprop > ${outputPath}/prop.txt
    setprop sys.tranfer.finished getprop
    df > ${outputPath}/df.txt
    setprop sys.tranfer.finished df
    mkdir -p  ${outputPath}/dropbox
    chmod -R 770 ${outputPath}/dropbox
    #mv /data/system/dropbox/*  ${outputPath}/dropbox/
    dumpsys dropbox --print > ${outputPath}/dropbox/dumpsys_dropbox_all.txt
    setprop sys.tranfer.finished dropbox
    if [ -f "/dev/binderfs/binder_logs/state" ]; then
        cat /dev/binderfs/binder_logs/state > ${outputPath}/binder_state.txt
    else
        cat /d/binder/state > ${outputPath}/binder_state.txt
    fi
    setprop sys.tranfer.finished binder
    wait
    touch /data/tcl_log/tmp/finish_system
    fi
}

function ClearAllLog() {
  setprop sys.clear.finish "clear data log"
  chmod -R 777 /data/tcl_log/*
  chown root:system -R /data/tcl_log/*
  if [ -d /data/tcl_log/ ]; then
    ALL_FILE=$(ls -t /data/tcl_log/)
    for path in $ALL_FILE; do
      if [ "${path}" = "tmp" ]; then
         cd /data/tcl_log/tmp/
         rm -fr *
      elif [ "${path}" = "compresslog" ]; then
         cd /data/tcl_log/compresslog/
         rm -fr *
      else
          rm -fr /data/tcl_log/$path
      fi
    done
  fi
  sleep 1
  setprop sys.clear.finish "clear tmp log"

  if [ -d /data/local/tmp/tcl_log ]; then
    rm -fr /data/local/tmp/tcl_log/*
  fi
  sleep 1
  setprop sys.clear.finish "clear sdcard log"
  if [ -d /sdcard/tcl_log ]; then
    rm -fr /sdcard/tcl_log/*
  fi
  sleep 1
  setprop sys.clear.finish "clear usb log"
  usbdir=$(grep -e "/media_rw/" /proc/mounts | awk '{print $2}' | head -1)
  echo "usbdir=$usbdir"
  if [ ! -n "$usbdir" ]; then
    echo "Usb dir null, Move to sdcard"
  else
    if [ -d $usbdir/tcl_log ]; then
       cd $usbdir/tcl_log
       rm -fr  $usbdir/tcl_log/*
    fi
  fi
  sleep 1
  setprop sys.clear.finish "1"
}
function DumpHprof() {
  PACKAGE_NAME=`getprop sys.logkit.package`
  if [ "${PACKAGE_NAME}" != "" ]; then
    am dumpheap ${PACKAGE_NAME} /data/local/tmp/heapdump_${PACKAGE_NAME}.hprof
    /system/bin/chmod 770 /data/local/tmp/heapdump*
  fi
}
function StartKfence() {
  if [ -f "/proc/kfence_dyn_alloc" ]; then
   echo 1 > /proc/kfence_dyn_alloc
  fi
}
function waitToCatKfence() {
  if [ -f "/proc/kfence_dyn_alloc" ]; then
     if [ -d /data/tcl_log/tmp ]; then
       cat /proc/kfence/objects > /data/tcl_log/tmp/kfence_objects.txt
       cat /proc/kfence/stats > /data/tcl_log/tmp/kfence_stats.txt
     fi
  fi
}
function CatKfence() {
  if [ -f "/proc/kfence_dyn_alloc" ]; then
     if [ ! -d  /sdcard/tcl_log/ ];then
        mkdir  -p /sdcard/tcl_log
     fi
     if [ -d /sdcard/tcl_log ]; then
       cat /proc/kfence/objects > /sdcard/tcl_log/kfence_objects.txt
       cat /proc/kfence/stats > /sdcard/tcl_log/kfence_stats.txt
     fi
  fi
}
function EnablePrintk() {
  PRINTK_TYPE=`getprop sys.logkit.printk`
  if [ "${PRINTK_TYPE}" != "" ]; then
    echo ${PRINTK_TYPE} > /proc/sys/kernel/printk
  fi
}

function mvPerformance() {

     if [ ! -d /data/local/tmp/tcl_log/performance/ ]; then
         mkdir -p /data/local/tmp/tcl_log/performance/
     fi

     if [ -d /sdcard/Android/data/com.tcl.logkit/files/ ];then
        cd /sdcard/Android/data/com.tcl.logkit/files/
        if [ -f memLeak.txt ];then
           mv memLeak.txt /data/local/tmp/tcl_log/performance/
        fi
        if [ -f meminfo.txt ];then
           mv meminfo.txt /data/local/tmp/tcl_log/performance/
        fi
        if [ -f performance.csv ];then
           mv performance.csv /data/local/tmp/tcl_log/performance/
        fi
        if [ -f CpuInfo.txt ];then
           mv CpuInfo.txt /data/local/tmp/tcl_log/performance/
        fi
     fi
     if [ -d /sdcard/Android/data/com.tcl.hedebugcenter/files/ ];then
        cd /sdcard/Android/data/com.tcl.hedebugcenter/files/
        if [ -f memLeak.txt ];then
           mv memLeak.txt /data/local/tmp/tcl_log/performance/
        fi
        if [ -f meminfo.txt ];then
           mv meminfo.txt /data/local/tmp/tcl_log/performance/
        fi
        if [ -f performance.csv ];then
           mv performance.csv /data/local/tmp/tcl_log/performance/
        fi
        if [ -f CpuInfo.txt ];then
           mv CpuInfo.txt /data/local/tmp/tcl_log/performance/
        fi
     fi

     mv /data/local/tmp/heapdump* /data/local/tmp/tcl_log/performance/
     /system/bin/chmod 777 -R /data/local/tmp/tcl_log
     usbdir=$(grep -e "/media_rw/" /proc/mounts | awk '{print $2}' | head -1)
      if [ ! -n "$usbdir" ]; then
          return
      else
          if [ ! -d $usbdir/tcl_log ]; then
             mkdir -p $usbdir/tcl_log
          fi
          if [ -d $usbdir/tcl_log ]; then
               cd /data/local/tmp/tcl_log/performance/
               mv * $usbdir/tcl_log/
               sync
          fi

      fi
}
function DumpMiddleWare() {
    if [ -f /vendor/tvos/bin/tcli ];then
       export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/vendor/lib:/system/lib:/system/apex/com.android.art.release/lib:/vendor/tvos/libBionic
       MIDDLEWARE_TYPE=`getprop sys.logkit.middlewaredebugtype`
       if [ "${MIDDLEWARE_TYPE}" != "" ]; then
          /vendor/tvos/bin/tcli ${MIDDLEWARE_TYPE}
       fi
    fi
}
function WriteSettings() {
    dataSize=$(df "/data" | tail -1 | awk '{print $4}')
    settings put global logkit_observer_size "${dataSize}"
}
function MvPcmToUdisk() {
    echo "MvPcmToUdisk-- start"
    setprop sys.AudioDump.finish "MvPcmToUdiskStart"
    if [ -d /data/audio_dump ];then
        cd /data/audio_dump/
        ls -al | tee -a /data/tcl_log/debug.txt
        chmod 770 /data/audio_dump/*
        usbdir=$(grep -e "/media_rw/" /proc/mounts | awk '{print $2}' | head -1)
        echo "usbdir=$usbdir"
        if [ ! -n "$usbdir" ]; then
            echo "Usb dir null,cannot mv tar to udisk"
        else
            SENSITIVE_LOG_ENABLE=$(getprop persist.sys.sensitive_log_enabled)
            if [ "${SENSITIVE_LOG_ENABLE}" = "true" ]; then
                if [ ! -d $usbdir/tcl_log/AudioDump ]; then
                    mkdir -p $usbdir/tcl_log/AudioDump
                fi
                if [ -d $usbdir/tcl_log/AudioDump ]; then
                    cd /data/audio_dump/
                    mv *.pcm $usbdir/tcl_log/AudioDump/
                    mv *.bin $usbdir/tcl_log/AudioDump/
                    sync
                fi
                echo " Move pcm  to udisk"
            fi
        fi
    fi
    setprop sys.AudioDump.finish "MvPcmToUdiskEnd"
    echo "MvPcmToUdisk--end"
}

function DumpAudio() {
     echo "DumpAudio start"
     export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/vendor/tvos/libBionic:/vendor/tvos/libBionic/ffmpeg
     temppath=""
     if [ -d /tvos/bin/ ];then
         usbdir=$(grep -e "/media_rw/" /proc/mounts | awk '{print $2}' | head -1)
         if [ ! -n "$usbdir" ]; then
            if [ ! -d /data/local/tmp/tcl_log/AudioDump ]; then
                mkdir -p /data/local/tmp/tcl_log/AudioDump
            fi
            temppath="/data/local/tmp/tcl_log/AudioDump"
         else
           if [ ! -d $usbdir/tcl_log/AudioDump ]; then
             mkdir -p $usbdir/tcl_log/AudioDump
           fi
            temppath="$usbdir/tcl_log/AudioDump"
        fi
        if [ -d ${temppath} ]; then
                currenttime=$(date +%F_%H-%M-%S)
                echo "/tvos/bin/tcli fpi.audio.info all  start" >  ${temppath}/Audio_${currenttime}.txt
                mute_tcli=`/tvos/bin/tcli fpi.audio.info all`
                echo "${mute_tcli}" >>${temppath}/Audio_${currenttime}.txt
                echo "dumpsys audio ------------" >> ${temppath}/Audio_${currenttime}.txt
                dumpsys audio >> ${temppath}/Audio_${currenttime}.txt
                echo "dumpsys media.audio_flinger --------------" >> ${temppath}/Audio_${currenttime}.txt
                dumpsys media.audio_flinger >> ${temppath}/Audio_${currenttime}.txt
                echo "dumpsys media.audio_policy---------------" >> ${temppath}/Audio_${currenttime}.txt
                dumpsys media.audio_policy >> ${temppath}/Audio_${currenttime}.txt
                if [ ! -n "$usbdir" ]; then
                    /system/bin/chmod 777 -R /data/local/tmp/tcl_log
                fi
        fi
     fi
     echo "DumpAudio  end, Audio log save to  ${temppath}"
}

function WatchLogkitInputEvent() {
    /system_ext/bin/LogkitInputEvent
}
function FastMvLogtoUdisk() {
    boot_completed=$(getprop sys.boot_completed)
    if [ x"${boot_completed}" == x"1" ]; then
        #ifndef VENDOR_EDIT
        # pisong.huang@tcl.com, 2025/01/07, add for jira issue id: LINTHYOSU-34626
        /system/bin/am  start-activity -n com.tcl.hedebugcenter/.MainActivity
        /system/bin/am  start-activity -n com.tcl.logkit/.MainActivity
        #endif /* VENDOR_EDIT */
    fi
}
function getMaxIndex(){
  INDEX_LIST=$(ls  android_[0-9][0-9][0-9][0-9]_*.txt | cut -d "_" -f2)
  logindex=0
  for index in $INDEX_LIST; do
        index=$(echo ${index} | awk '{printf("%d",$1)}')
        if [ ${logindex} -lt ${index} ]; then
            logindex=$(expr ${index})
        fi
  done
  maxindex=$(expr ${logindex})
  setprop sys.log.maxindex ${maxindex}
  echo "getMaxIndex maxindex= ${maxindex}"
}
function startNewLogcat() {
    local usbdir=$1
    cd $usbdir/tcl_log/sitalog/
    getMaxIndex
    tempindex=$(echo ${maxindex} | awk '{printf("%04d\n",$0)}')
    count=$(ls android_${tempindex}_*.txt events_${tempindex}_*.txt kmsg_${tempindex}_*.txt|wc -l)
    echo "startNewLogcat now ${tempindex} count=${count}"
    if [ $count -ge 1 ]; then
        sum=0
        ALL_FILE=$(ls -t android_${tempindex}_*.txt events_${tempindex}_*.txt kmsg_${tempindex}_*.txt)
        for path in $ALL_FILE; do
            fileSize=$(du -s $path | awk '{print $1}')
            sum=$(expr ${sum} + ${fileSize})
            echo "add  ${path} ${fileSize} to sum=${sum}"
            MaxLogsize=$(echo | awk '{printf("%d",1*200*1024)}')
            if [ ${sum} -ge ${MaxLogsize} ]; then
                setprop ctl.stop GeorgedebugUsbLogcatMain
                setprop ctl.stop GeorgedebugUsbLogcatEvent
                setprop ctl.stop GeorgedebugUsbLogcatKernel
                echo "startNewLogcat ${maxindex}"

                setprop ctl.start GeorgedebugUsbLogcatMain
                setprop ctl.start GeorgedebugUsbLogcatEvent
                setprop ctl.start GeorgedebugUsbLogcatKernel
                echo "WatchUsbLogcat--start new usb Log-"
            fi
        done
    fi
}

function getMinIndexList(){
  local tempsize=$1
  INDEX_LIST=$(ls  android_[0-9][0-9][0-9][0-9]_*.txt | cut -d "_" -f2| awk '{printf("%d ",$1)}'|sort )
  sum=0
  minpath=""
  cleansize=$(expr ${tempsize})
  echo "getMinIndexList cleansize  ${cleansize}"
  for index in $INDEX_LIST; do
        tempindex=$(echo ${index} | awk '{printf("%04d\n",$0)}')
        ALL_FILE=$(ls -t android_${tempindex}_*.txt events_${tempindex}_*.txt kmsg_${tempindex}_*.txt)
        for path in $ALL_FILE; do
            fileSize=$(du -s $path | awk '{print $1}')
            sum=$(expr ${sum} + ${fileSize})
            echo "add  ${path} ${fileSize} to sum=${sum}"
             if [ "${minpath}" == "" ];then
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
   echo "getMinIndexList  path ${minpath}"
}

function deleteLastUsbLog() {
    local usbdir=$1
    cd $usbdir/tcl_log/sitalog/
    usbAvailSize=$(df "$usbdir" | tail -1 | awk '{print $4}')
    echo "WatchUsbLogcat--usbAvailSize=${usbAvailSize}--needToClearSize=${needToClearSize}"
    if [ ${usbAvailSize} -lt ${needToClearSize} ]; then
        cleansize=$(expr ${needToClearSize} - ${usbAvailSize})
        getMinIndexList ${cleansize}
        echo "minpath ${minpath}"
        for path in ${minpath}; do
            echo "" >${path}
            rm -rf ${path}
            echo "WatchUsbLogcat--delete-${path}"
        done
    fi
}
function WatchLogcat() {
    needToClearSize=$(echo | awk '{printf("%d",1*600*1024)}')
    while [ true ]; do
        logkitenable=$(getprop persist.sys.normallog)
        if [ "${logkitenable}" == "true" ]; then
            echo "WatchUsbLogcat--Georgedebug-exit-because logkit start"
            setprop persist.sys.usblog false
            return
        fi
        usbdir=$(grep -e "/media_rw/" /proc/mounts | awk '{print $2}' | head -1)
        echo "usbdir=$usbdir"
        if [ ! -n "$usbdir" ]; then
            echo "Usb dir null,return  "
            break
        else
            if [ -d $usbdir/tcl_log ]; then
                deleteLastUsbLog $usbdir
                startNewLogcat $usbdir
            fi
            sleep 300
            logenable=$(getprop persist.sys.usblog)
            if [ "${logenable}" != "true" ]; then
                echo "WatchUsbLogcat--Georgedebug-exit"
                return
            fi
        fi
    done
}
function UsbLogcat() {
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
             echo "UsbLogcat "${type}"  ${maxindex}"
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
function UsbLogcatMain() {
    logenable=$(getprop persist.sys.usblog)
    if [ "${logenable}" = "true" ]; then
        logdsize=$(getprop persist.logd.size)
        if [ "${logdsize}" = "" ]; then
            /system/bin/logcat -G 5M
        fi
        UsbLogcat "main"
    fi
}

function UsbLogcatEvent() {
    logenable=$(getprop persist.sys.usblog)
    if [ "${logenable}" = "true" ]; then
        UsbLogcat "event"
    fi
}

function UsbLogcatKernel() {
    logenable=$(getprop persist.sys.usblog)
    if [ "${logenable}" = "true" ]; then
        UsbLogcat "kernel"
    fi
}

function UsbInitLog() {
    logenable=$(getprop persist.sys.usblog)
    if [ "${logenable}" = "true" ]; then
        usbdir=$(grep -e "/media_rw/" /proc/mounts | awk '{print $2}' | head -1)
        count=0
        while [ ! -n "$usbdir" ]  && [ $count -lt 60 ]; do
            count=$((count + 1))
            sleep 1
            usbdir=$(grep -e "/media_rw/" /proc/mounts | awk '{print $2}' | head -1)
            if [ ! -n "$usbdir" ]; then
                echo "Usb dir null,return count= ${count} "
            fi
        done
        if [ ! -n "$usbdir" ]; then
             echo "Usb dir null,return  "
             return
        fi
        if [ ! -d $usbdir/tcl_log/sitalog ]; then
            mkdir -p $usbdir/tcl_log/sitalog
        fi
        cd  $usbdir/tcl_log/sitalog/
        getMaxIndex
        setprop ctl.start GeorgedebugSetEnvironment
        start GeorgedebugUsbLogcatMain
        start GeorgedebugUsbLogcatEvent
        start GeorgedebugUsbLogcatKernel
        start GeorgedebugUsbWatchLogcat
    fi
}
function GetTcliInfo() {
    if [ -f /vendor/tvos/bin/tcli ];then
       export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/vendor/lib:/system/lib:/system/apex/com.android.art.release/lib:/vendor/tvos/libBionic

        usbdir=$(grep -e "/media_rw/" /proc/mounts | awk '{print $2}' | head -1)
         echo "GetTcliInfo-usbdir=$usbdir"
         temppath=""
         if [ ! -n "$usbdir" ]; then
            echo "Usb dir null,cannot mv tar to udisk"
            if [ ! -d /data/local/tmp/tcl_log/middle_ware ]; then
                mkdir -p /data/local/tmp/tcl_log/middle_ware
            fi
            temppath="/data/local/tmp/tcl_log/middle_ware"
         else
           if [ ! -d $usbdir/tcl_log/middle_ware ]; then
             mkdir -p $usbdir/tcl_log/middle_ware
           fi
           temppath="$usbdir/tcl_log/middle_ware"
        fi
        if [ -d ${temppath} ]; then
            echo " copy GetTcliInfo to ${temppath}"
            cd ${temppath}
            /vendor/tvos/bin/tcli tvh.oad.print.info > tvh_oad_print_info.txt
            /vendor/tvos/bin/tcli fpi.cc.info all > fpi_cc_info_all.txt
            /vendor/tvos/bin/tcli tos.function_setting.get_time 0 > tos_function_setting_get_time_0.txt
            /vendor/tvos/bin/tcli fpi.dtv.booking_trace > fpi_dtv_booking_trace.txt
            /vendor/tvos/bin/tcli fpi.audio.info mute > fpi_audio_info_mute.txt
            /vendor/tvos/bin/tcli fpi.scan.gettime 1 > fpi_scan_gettime_1.txt
            /vendor/tvos/bin/tcli fpi.play.gettime 1 > fpi_play_gettime_1.txt
            /vendor/tvos/bin/tcli tos.signal.get_current_info > tos.signal.get_current_info.txt
            /vendor/tvos/bin/tcli tvhsipsi.base.get_debug_info > tvhsipsi_base_get_debug_info.txt
            /vendor/tvos/bin/tcli tos.source.get_input > vendor_tos_source_get_input.txt
            /vendor/tvos/bin/tcli fpi.video.get_mute > vendor_fpi_video_get_mute.txt
            /vendor/tvos/bin/tcli fpi.dtv.print_filter_info > fpi_dtv_print_filter_info.txt
            /vendor/tvos/bin/tcli fpi.base.get_debug_play_info > fpi_base_get_debug_play_info.txt
            /vendor/tvos/bin/tcli tos.zoom.get_current_window > tos_zoom_get_current_window.txt
            /tvos/bin/tcli fpi.video.get_mute > fpi_video_get_mute.txt
            /tvos/bin/tcli tos.source.get_input > tos_source_get_input.txt
            if [ ! -n "$usbdir" ]; then
                /system/bin/chmod 777 -R /data/local/tmp/tcl_log
            fi
        fi
    fi
}
function waitToDumpScreenRecord() {
    setprop sys.tranfer.finished "copyScreenRecord"
    setprop debug.tranfer.finished ""
    setprop ctl.start GeorgedebugScreenRecordAndDisableWmStop
    count=0
    while [ $count -le 60 ]; do
        count=$((count + 1))
        finished=$(getprop debug.tranfer.finished)
        if [ "${finished}" = "CopyScreenRecord" ]; then
            echo "stop waitToDumpScreenRecord"
            break
        fi
        echo "waitToDumpScreenRecord sleep ${finished} ${count}"
        sleep 1
    done
}
function waitToDumpWifiLog() {
    enable_wifilog=$(getprop persist.sys.wifi.log_enable)
    log_type=$(getprop persist.sys.logtype)
    rm -fr /data/tcl_log/tmp/copy_wifi
    if [ x${log_type} = x"wifi" ]; then
            setprop ctl.start GeorgedebugStopDebugWifi
    elif [ x${enable_wifilog} = x"1" ]; then
            setprop ctl.start GeorgedebugStopWifiNormalLog
    fi
    count=0
    while [ $count -le 30 ] && [ ! -f /data/tcl_log/tmp/copy_wifi ]; do
        count=$((count + 1))
        sleep 1
    done
    rm -fr /data/tcl_log/tmp/copy_wifi
}
function ScreenRecordAndDump() {
    echo "DumpScreenRecord start "
    temppath=""
    if [ ! -d /data/local/tmp/tcl_log/ScreenRecord ]; then
         mkdir -p /data/local/tmp/tcl_log/ScreenRecord
    fi
    if [ -d /data/local/tmp/tcl_log/ScreenRecord ]; then
        cd /data/local/tmp/tcl_log/ScreenRecord/
        screencap -p screenshot_start.png
        dumpsys SurfaceFlinger >sf_start.txt
        dumpsys window -a >wm_start.txt
        dumpsys activity activities >am_start.txt
        timelimit=15
        templimit=$(getprop sys.logkit.timelimit)
        if [ x"${templimit}" != x"" ]; then
            timelimit=$(expr ${templimit})
        fi
        longscreenrecord --time-limit ${timelimit} --size 864x480 ScreenRecord.mp4
        screencap -p screenshot_end.png
        dumpsys SurfaceFlinger >sf_end.txt
        dumpsys window -a >wm_end.txt
        dumpsys activity activities >am_end.txt
        chmod 777 -R /data/local/tmp/tcl_log
        usbdir=$(grep -e "/media_rw/" /proc/mounts | awk '{print $2}' | head -1)
        echo "usbdir=$usbdir"
        if [ ! -n "$usbdir" ]; then
            temppath="/data/local/tmp/tcl_log/ScreenRecord"
        else
            if [ ! -d $usbdir/tcl_log ]; then
                mkdir -p $usbdir/tcl_log
            fi

            if [ -d $usbdir/tcl_log ]; then
                cd  /data/local/tmp/tcl_log/
                mv ScreenRecord $usbdir/tcl_log/
                sync
                temppath="$usbdir/tcl_log/ScreenRecord"
            fi
        fi
    fi
    echo "DumpScreenRecord end ,Screenrecord save to  ${temppath}"
}

function ScreenRecordAndEnableWmStart() {
    setprop debug.dumpscreenrecord.start true
    temppath=""
    if [ ! -d /data/local/tmp/tcl_log/ScreenRecord ]; then
         mkdir -p /data/local/tmp/tcl_log/ScreenRecord
    fi
    if [ -d /data/local/tmp/tcl_log/ScreenRecord ]; then
        cd /data/local/tmp/tcl_log/ScreenRecord/
        wm logging enable-text WM_DEBUG_ADD_REMOVE
        wm logging enable-text WM_DEBUG_APP_TRANSITIONS_ANIM
        wm logging enable-text WM_DEBUG_APP_TRANSITIONS
        wm logging enable-text WM_DEBUG_DRAW
        wm logging enable-text WM_DEBUG_ORIENTATION
        wm logging enable-text WM_SHOW_TRANSACTIONS
        wm logging enable-text WM_SHOW_SURFACE_ALLOC
        dumpsys window tlog set DEBUG_ANIM 1
        dumpsys window tlog set DEBUG_LAYERS 1
        dumpsys window tlog set DEBUG_VISIBILITY 1
        dumpsys window tlog set DEBUG_CONFIGURATION 1
        dumpsys window policy tlog set DEBUG_INPUT 1
        dumpsys activity_task tlog set DEBUG_STATES 1
        dumpsys activity_task tlog set DEBUG_PAUSE 1
        dumpsys activity_task tlog set DEBUG_STACK 1
        timelimit=30
        templimit=$(getprop sys.logkit.timelimit)
        if [ x"${templimit}" != x"" ]; then
            timelimit=$(expr ${templimit})
        fi
        longscreenrecord --time-limit ${timelimit} --size 864x480 ScreenRecord.mp4
        dumpsys SurfaceFlinger >sf.txt
        dumpsys window -a >wm.txt
        dumpsys activity activities >am.txt
        screencap -p screenshot.png
        cd /data/local/tmp/
        chmod 777 -R /data/local/tmp/tcl_log
        setprop debug.dumpscreenrecord.start false
    fi
}
function ScreenRecordAndDisableWmStop() {

    if [ ! -d /data/local/tmp/tcl_log/ScreenRecord ]; then
        echo " ScreenRecordAndDisableWmStop no dir end"
        setprop debug.tranfer.finished "CopyScreenRecord"
        return
    fi
    temppath=""
    chmod 777 -R /data/local/tmp/tcl_log
    dumpscreenend=$(getprop debug.dumpscreenrecord.start)
    if [ x"${dumpscreenend}" = x"true" ]; then
        cd /data/local/tmp/tcl_log/ScreenRecord/
        dumpsys SurfaceFlinger >sf.txt
        dumpsys window -a >wm.txt
        dumpsys activity activities >am.txt
        screencap -p screenshot.png
    fi
    if [ x"${dumpscreenend}" != x"" ]; then
        wm logging disable-text WM_DEBUG_ADD_REMOVE
        wm logging disable-text WM_DEBUG_APP_TRANSITIONS_ANIM
        wm logging disable-text WM_DEBUG_APP_TRANSITIONS
        wm logging disable-text WM_DEBUG_DRAW
        wm logging disable-text WM_DEBUG_ORIENTATION
        wm logging disable-text WM_SHOW_TRANSACTIONS
        wm logging disable-text WM_SHOW_SURFACE_ALLOC

        dumpsys window tlog set DEBUG_ANIM 0
        dumpsys window tlog set DEBUG_LAYERS 0
        dumpsys window tlog set DEBUG_VISIBILITY 0
        dumpsys window tlog set DEBUG_CONFIGURATION 0
        dumpsys window policy tlog set DEBUG_INPUT 0
        dumpsys activity_task tlog set DEBUG_STATES 0
        dumpsys activity_task tlog set DEBUG_PAUSE 0
        dumpsys activity_task tlog set DEBUG_STACK 0
    fi

    chmod 777 -R /data/local/tmp/tcl_log
    usbdir=$(grep -e "/media_rw/" /proc/mounts | awk '{print $2}' | head -1)
    echo "usbdir=$usbdir"
    if [ ! -n "$usbdir" ]; then
        temppath="/data/local/tmp/tcl_log/ScreenRecord"
    else
        if [ ! -d $usbdir/tcl_log ]; then
            mkdir -p $usbdir/tcl_log
        fi
        if [ -d $usbdir/tcl_log ]; then
            cd  /data/local/tmp/tcl_log/
            mv ScreenRecord $usbdir/tcl_log/
            sync
            temppath="$usbdir/tcl_log/ScreenRecord"
        fi
    fi
    echo "ScreenRecordAndDisableWmStop end,Screenrecord save to  ${temppath}"
    setprop debug.tranfer.finished "CopyScreenRecord"
}
function checkUdiskAndCopyCustom() {
    local sourceFile=$1
    local usbdir=$2
    local customPath=$3
    START=$(date +%s)
    usbAvailSize=$(df "$usbdir" | tail -1 | awk '{print $4}')
    sourceSize=$(du -s ${sourceFile} | awk '{print $1}')
    echo "sourceSize=${sourceSize}-usbAvailSize=$usbAvailSize" | tee -a /data/tcl_log/debug.txt
    if [ ${usbAvailSize} -ge ${sourceSize} ]; then
        mv ${sourceFile} ${customPath}/
        sync
        echo "-move--${sourceFile}--${customPath}" | tee -a /data/tcl_log/debug.txt
    else
        count=$(ls -t ${customPath}/* | wc -l)
        echo "${customPath} has ${count} file" | tee -a /data/tcl_log/debug.txt
        while [ $count -gt 0 ] && [ ${usbAvailSize} -lt ${sourceSize} ]; do
            lastUsbFile=$(ls -tr ${customPath}/* | head -1)
            echo "" >${lastUsbFile}
            rm -rf ${lastUsbFile}
            sync
            count=$((count - 1))
            echo "delete--${lastUsbFile}" | tee -a /data/tcl_log/debug.txt
            usbdir=$(grep -e "/media_rw/" /proc/mounts | awk '{print $2}' | head -1)
            if [ ! -n "$usbdir" ]; then
                echo "Usb dir null--return ${sourceFile}" | tee -a /data/tcl_log/debug.txt
                return
            fi
            usbAvailSize=$(df "$usbdir" | tail -1 | awk '{print $4}')
            echo "usbAvailSize=${usbAvailSize} sourceSize=&{sourceSize}" | tee -a /data/tcl_log/debug.txt
            if [ ${usbAvailSize} -ge ${sourceSize} ]; then
                mv ${sourceFile} ${customPath}/
                sync
                echo "storage enough-move--${sourceFile}--${customPath} return" | tee -a /data/tcl_log/debug.txt
                return
            fi
            continue
        done
        echo "Usb dir-full" | tee -a /data/tcl_log/debug.txt
      fi
    END=`date +%s`
    duration=`expr ${END} - ${START} 2>/dev/null`
    echo "checkUdiskAndCopyCustom-exec-${duration} s" | tee -a /data/tcl_log/debug.txt
}
function MvNetLogtoUdisk() {
    usbdir=`grep -e "/media_rw/" /proc/mounts | awk '{print $2}' | head -1`
    if [ ! -n "$usbdir" ]; then
       echo "Usb dir null, Move tcpdump to data"  | tee -a /data/tcl_log/debug.txt
       setprop sys.tranfer.finished "Usb dir null, tcpdump log save to data"
    else
        if [ -d /data/tcl_log/TcpDump ]; then
            if [ ! -d $usbdir/tcl_log/TcpDump ]; then
                mkdir -p $usbdir/tcl_log/TcpDump
            fi
            if [ -d  $usbdir/tcl_log/TcpDump ]; then
                ALL_FILE=$(ls -tr /data/tcl_log/TcpDump/*)
                for path in $ALL_FILE; do
                    checkUdiskAndCopyCustom  ${path} ${usbdir} ${usbdir}/tcl_log/TcpDump
                    usbdir=$(grep -e "/media_rw/" /proc/mounts | awk '{print $2}' | head -1)
                    if [ ! -n "$usbdir" ]; then
                        echo "Usb dir null--MvNetLogtoUdisk return ${sourceFile}" | tee -a /data/tcl_log/debug.txt
                        break
                    fi
                done
            fi
        fi
        echo "Move tcpdump to udisk" | tee -a /data/tcl_log/debug.txt
        setprop sys.tranfer.finished "mv tcpdump to udisk  end"
    fi
}
function MvDebugLogtoUdisk() {
    usbdir=$(grep -e "/media_rw/" /proc/mounts | awk '{print $2}' | head -1)
    if [ ! -n "$usbdir" ]; then
        echo "move debug.txt to /data/tcl_log" | tee -a /data/tcl_log/debug.txt
        return
    else
         currenttime=$(date +%F_%H-%M-%S)
         echo "move debug.txt to $usbdir/tcl_log/debug_${currenttime}.txt" | tee -a /data/tcl_log/debug.txt
         mv /data/tcl_log/debug.txt $usbdir/tcl_log/debug_${currenttime}.txt
         sync
    fi
}
function waitToCopyPcm() {
    log_type=$(getprop persist.sys.logtype)
    if [ x${log_type} = x"audio" ] ||  [ x"${log_type}" = x"bluetooth" ] ; then
         setprop sys.tranfer.finished "copyPcm"
         setprop sys.AudioDump.finish ""
         setprop ctl.start GeorgedebugMvPcmToData
         count=0
         while [ $count -le 60 ]; do
                count=$((count + 1))
                finished=$(getprop sys.AudioDump.finish)
               if [ "${finished}" = "MvPcmToUdiskEnd" ]; then
                 echo "stop waitToCopyPcm"
                 break
               fi
         echo "waitToCopyPcm sleep ${finished} ${count}"
         sleep 1
         done
    fi


}
function waitToCopyAudio() {
     log_type=$(getprop persist.sys.logtype)
    if [ x${log_type} = x"audio" ] ||  [ x"${log_type}" = x"bluetooth" ]; then
        setprop sys.tranfer.finished "copyPcm"
        setprop ctl.start GeorgedebugDumpAudio
        count=0
        while [ $count -le 15 ]; do
            count=$((count + 1))
            finished=$(getprop init.svc.GeorgedebugDumpAudio)
            if [ "${finished}" = "stopped" ]; then
                echo "stop waitToCopyAudio"
                break
            fi
            echo "waitToCopyAudio sleep ${finished} ${count}"
            sleep 1
        done
    fi
}

function CopyMiniLog() {
     cd /data/misc/
     if [  -d backup ]; then
         chmod -R 770 backup
         cp -ar backup /data/tcl_log/tmp/
         chmod -R 770 /data/tcl_log/tmp/backup
     fi
}
function PerfettoAsyncStart(){
   BUFFER_SIZE=$(getprop persist.sys.perfettobuffersize)
    if [ "${BUFFER_SIZE}" = "" ]; then
       BUFFER_SIZE=65536
    else
       BUFFER_SIZE=${BUFFER_SIZE}
    fi

    echo '
        write_into_file: true
        file_write_period_ms: 1000000000
        buffers {
          size_kb: '${BUFFER_SIZE}'
          fill_policy: RING_BUFFER
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
        ' | perfetto -c - --txt --detach=logkit_trace -o /data/misc/perfetto-traces/trace.txt
}
function PerfettoAsyncStop(){
    perfetto --attach=logkit_trace --stop
    sleep 2
    if [ ! -d /data/local/tmp/tcl_log/performance/ ]; then
         mkdir -p /data/local/tmp/tcl_log/performance/
    fi
    if [ -d /data/local/tmp/tcl_log/performance/ ]; then
        cd /data/misc/perfetto-traces/
        /system/bin/cp trace.txt /data/local/tmp/tcl_log/performance/
        /system/bin/chmod 777 -R /data/local/tmp/tcl_log
        usbdir=$(grep -e "/media_rw/" /proc/mounts | awk '{print $2}' | head -1)
        if [ ! -n "$usbdir" ]; then
            return
        else
            if [ ! -d $usbdir/tcl_log ]; then
               mkdir -p $usbdir/tcl_log
            fi
            if [ -d $usbdir/tcl_log ]; then
                 cd /data/local/tmp/tcl_log/performance/
                 currenttime=$(date +%F_%H-%M-%S)
                 echo "move trace.txt to $usbdir/tcl_log/trace_${currenttime}.txt"
                 mv trace.txt $usbdir/tcl_log/trace_${currenttime}.txt
                 sync
            fi

        fi
    fi
}
function InitPerfettoAsyncLog(){
  setprop ctl.start GeorgedebugPerfettoAsyncStart
}

function InitAnrPerfettoAsyncLog(){
   ANRTRACE_ENABLE=$(getprop persist.sys.anrtrace.enable)
    if [ "${ANRTRACE_ENABLE}" = "true" ]; then
       setprop ctl.start AnrPerfettoAsyncStartService
    else
       setprop persist.sys.anrtrace "false"
    fi
}
function StopAnrPerfettoLog() {
   setprop ctl.stop AnrPerfettoAsyncStartService
   setprop ctl.start AnrPerfettoAsyncStopService
}

function AnrPerfettoAsyncStart(){
    LOCAL_CONFIG=$(getprop persist.sys.anrtrace.localconfig)
    if [ "${LOCAL_CONFIG}" = "true" ]; then
       CONFIG_FILE_PATH="/data/misc/perfetto-traces/anr_perfetto_config.pbtx"
       perfetto -c "$CONFIG_FILE_PATH" --txt --detach=anr_trace -o /data/misc/perfetto-traces/anrtrace.txt
    else
       BUFFER_SIZE=$(getprop persist.sys.anrtrace.buffersize)
       if [ "${BUFFER_SIZE}" = "" ]; then
          BUFFER_SIZE=40960
       else
          BUFFER_SIZE=${BUFFER_SIZE}
       fi

       echo '
           write_into_file: true
           file_write_period_ms: 1000000000
           buffers {
             size_kb: '${BUFFER_SIZE}'
             fill_policy: RING_BUFFER
           }
           data_sources {
             config {
               name: "linux.ftrace"
               ftrace_config {
                 ftrace_events: "sched/sched_switch"
                 ftrace_events: "sched/sched_wakeup"
                 ftrace_events: "sched/sched_waking"
                 ftrace_events: "power/cpu_idle"
                 atrace_categories: "gfx"
                 atrace_categories: "input"
                 atrace_categories: "view"
                 atrace_categories: "wm"
                 atrace_categories: "am"
                 atrace_categories: "dalvik"
                 atrace_categories: "binder_driver"
                 atrace_apps: "*"
               }
             }
           }
           ' | perfetto -c - --txt --detach=anr_trace -o /data/misc/perfetto-traces/anrtrace.txt
    fi
    setprop persist.sys.anrtrace.state "started"
}

function AnrPerfettoAsyncStop(){
    perfetto --attach=anr_trace --stop
    setprop persist.sys.anrtrace.state "stopped"
}

function MvAnrPerfettoLog() {
    PKGNAME=$(getprop debug.anr.perfetto_dirname)
    chmod -R 777 /data/misc/perfetto-traces/anrtrace.txt
    cp /data/misc/perfetto-traces/anrtrace.txt /data/system/nvrhung/anr/${PKGNAME}/
    chmod -R 777 /data/system/nvrhung/anr/${PKGNAME}/*
    setprop persist.sys.anrtrace.state "copied"
}

function StopLog(){
  setprop persist.sys.normallog -1
  setprop ctl.stop  GeorgedebugStartCollectBootMainLog
  setprop ctl.stop  GeorgedebugStartCollectBootEventLog
  setprop ctl.stop  GeorgedebugStartCollectBootKernelLog
  setprop ctl.stop  GeorgedebugLogcatMain
  setprop ctl.stop  GeorgedebugLogcatEvent
  setprop ctl.stop  GeorgedebugLogcatKernel
  setprop ctl.start GeorgedebugMvLogtoSDcard
}
function LogcatBugreport() {
     /system/bin/bugreportz -p
     setprop ctl.start GeorgedebugMvBugreportToSDcard
}
function MvBugreportToSDcard() {
     echo "${CURTIME}--MvBugreportToSDcard start"  >> /data/tcl_log/debug.txt
     usbdir=$(grep -e "/media_rw/" /proc/mounts | awk '{print $2}' | head -1)
     bugreport_dir="/data/user_de/0/com.android.shell/files/bugreports/"
     if [ ! -d "$bugreport_dir" ]; then
        echo "Error: Bugreport directory does not exist." >> /data/tcl_log/debug.txt
        settings put global logkit_observer_size "bugreport_null"
        return
    fi
    cd "$bugreport_dir" || {
      echo "Error: Failed to change directory to $bugreport_dir" >> /data/tcl_log/debug.txt
      settings put global logkit_observer_size "bugreport_null"
      return
      }

    bugreport_file_name=$(ls -tr *.zip 2>/dev/null | tail -1)
    if [ -z "$bugreport_file_name" ]; then
        echo "No bugreport files found."  >> /data/tcl_log/debug.txt
        settings put global logkit_observer_size "bugreport-null"
        cd "$bugreport_dir"
        rm -f *
        return
    fi
     echo "bugreport file is ${bugreport_file_name}"  >> /data/tcl_log/debug.txt
     if [ ! -n "$usbdir" ]; then
        settings put global logkit_observer_size "bugreport_usbDir_null"
     else
        if [ ! -d "$usbdir/tcl_log" ]; then
            mkdir -p "$usbdir/tcl_log"
        fi
        if [ ! -d "$usbdir/tcl_log/bugreports" ]; then
            mkdir -p "$usbdir/tcl_log/bugreports"
        fi
      mv $bugreport_dir/*.zip $usbdir/tcl_log/bugreports/
      sync
      settings put global logkit_observer_size "${bugreport_file_name}"
     fi
     cd "$bugreport_dir"
     rm -f *
     echo "${CURTIME}--MvBugreportToSDcard end"  >> /data/tcl_log/debug.txt
}
function LogcatBugreportForNvr() {
     /system/bin/bugreportz -p
     setprop ctl.start GeorgedebugMvBugreportToData
}
function LogcatBugreportToData() {
     cd /data/system/nvrhung/bugreports/
     rm -f *
     cd /data/user_de/0/com.android.shell/files/bugreports/
     bugreport_file_name=$(ls -tr *.zip | tail -1 )
     echo "bugreport file is ${bugreport_file_name}"
     if [ ! -d "/data/local/tmp/bugreports" ]; then
         mkdir -p "/data/local/tmp/bugreports"
     fi
     mv /data/user_de/0/com.android.shell/files/bugreports/*.zip /data/local/tmp/bugreports/
     sleep 1
     setprop ctl.start GeorgedebugMvBugreportToNvr
     cd /data/user_de/0/com.android.shell/files/bugreports/
     rm -f *
}
function LogcatBugreportToNvr() {
     if [ ! -d "/data/system/nvrhung/bugreports" ]; then
         mkdir -p "/data/system/nvrhung/bugreports"
         chmod -R 777 /data/system/nvrhung/bugreports/
     fi
     chmod -R 777 /data/local/tmp/bugreports/*.zip
     cp -a /data/local/tmp/bugreports/*.zip /data/system/nvrhung/bugreports/
     sleep 1
     cd /data/local/tmp/bugreports/
     bugreport_file_name=$(ls -t *.zip | tail -1)
     rm -f bugreport_file_name
}
case "$config" in
    "InitBootLog")
     InitBootLog
     ;;
     "InitLog")
      InitLog
     ;;
    "CollectBootMainLog")
     CollectBootMainLog
     ;;
     "CollectBootEventLog")
     CollectBootEventLog
     ;;
     "CollectBootKernelLog")
     CollectBootKernelLog
     ;;
     "LogcatMain")
     LogcatMain
     ;;
     "LogcatEvent")
     LogcatEvent
     ;;
     "LogcatKernel")
     LogcatKernel
     ;;
     "MvLogtoSDcard")
     MvLogtoSDcard
     ;;
     "PerfettoStart")
     PerfettoStart
     ;;
     "mvPerfetto")
     mvPerfetto
     ;;
     "dumpSystem")
      getSystemStatus
     ;;
     "SetEnvironment")
      setEnvironment
     ;;
     "resetEnvironment")
      resetEnvironment
     ;;
     "CopyAee")
     copyAee
     ;;
     "CopyAnr")
      copyAnr
     ;;
     "copyPstore")
      copyPstore
     ;;
     "copyKfault")
      copyKfault
     ;;
     "mvPerformance")
      mvPerformance
     ;;
     "CopyBlueToothLog")
      CopyBlueToothLog
     ;;
     "KillBluetooth")
      KillBluetooth
     ;;
     "DumpHprof")
      DumpHprof
     ;;
   "StartKfence")
      StartKfence
     ;;
   "EnablePrintk")
      EnablePrintk
     ;;
   "MvtoUdisk")
      MvtoUdisk
     ;;
   "CatKfence")
      CatKfence
     ;;
   "DumpMiddleWare")
      DumpMiddleWare
     ;;
   "DetectStorage")
    DetectStorage
    ;;
    "ClearAllLog")
     ClearAllLog
    ;;
  "WriteSettings")
     WriteSettings
    ;;
  "MvPcmToUdisk")
     MvPcmToUdisk
    ;;
  "DumpAudio")
     DumpAudio
     ;;
"WatchLogkitInputEvent")
    WatchLogkitInputEvent
    ;;
"FastMvLogtoUdisk")
    FastMvLogtoUdisk
    ;;
"UsbLogcatMain")
    UsbLogcatMain
    ;;
"UsbLogcatEvent")
    UsbLogcatEvent
    ;;
"UsbLogcatKernel")
    UsbLogcatKernel
    ;;
"WatchLogcat")
    WatchLogcat
    ;;
"UsbInitLog")
    UsbInitLog
    ;;
"GetTcliInfo")
     GetTcliInfo
    ;;
"ScreenRecordAndDump")
    ScreenRecordAndDump
    ;;
"ScreenRecordAndDisableWmStop")
    ScreenRecordAndDisableWmStop
    ;;
"ScreenRecordAndEnableWmStart")
    ScreenRecordAndEnableWmStart
    ;;
  "StopLog")
    StopLog
    ;;
  "InitPerfettoAsyncLog")
    InitPerfettoAsyncLog
    ;;
  "PerfettoAsyncStart")
    PerfettoAsyncStart
    ;;
  "PerfettoAsyncStop")
    PerfettoAsyncStop
    ;;
  "InitAnrPerfettoAsyncLog")
    InitAnrPerfettoAsyncLog
    ;;
  "AnrPerfettoAsyncStart")
    AnrPerfettoAsyncStart
    ;;
  "AnrPerfettoAsyncStop")
    AnrPerfettoAsyncStop
    ;;
  "MvAnrPerfettoLog")
    MvAnrPerfettoLog
    ;;
  "StopAnrPerfettoLog")
    StopAnrPerfettoLog
    ;;
  "LogcatBugreport")
     LogcatBugreport
     ;;
  "MvBugreportToSDcard")
     MvBugreportToSDcard
     ;;
  "LogcatBugreportForNvr")
     LogcatBugreportForNvr
     ;;
  "LogcatBugreportToData")
     LogcatBugreportToData
     ;;
  "LogcatBugreportToNvr")
     LogcatBugreportToNvr
     ;;
     *)
     ;;
esac
