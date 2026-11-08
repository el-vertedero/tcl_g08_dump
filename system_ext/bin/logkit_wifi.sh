#!/bin/bash
CURTIME=`date +%F_%H-%M-%S`
config="$1"
defaultLogcatSize=0
globalStatus="0"
tarpath=""
maxindex=0
minpath=""
globalCount=0


function StartDebugWifi() {
  Version=$(getprop ro.build.version.release)
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
    echo 4 > /proc/net/rtl8192fu/log_level
  fi
  if [ -f "/proc/net/rtl8192eu/log_level" ]; then
    echo 4 > /proc/net/rtl8192eu/log_level
  fi
  if [ -f "/proc/net/rtl88x2eu/log_level" ]; then
    echo 4 > /proc/net/rtl88x2eu/log_level
  fi
  if [ -c "/dev/LOG" ]; then
    rm /data/tcl_log/skw_log_disable.txt
    current_file=""
    while true; do
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

function StartWifiNormalLog() {
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
    echo 0xff:0x3f > /proc/net/wlan/dbgLevel
    echo 0x00:0x2f > /proc/net/wlan/dbgLevel
    echo 0x04:0x2f > /proc/net/wlan/dbgLevel
    echo 0x05:0x2f > /proc/net/wlan/dbgLevel
    echo 0x11:0x2f > /proc/net/wlan/dbgLevel
    echo 0x16:0x2f > /proc/net/wlan/dbgLevel
  fi
  if [ -f "/proc/net/rtl8192fu/log_level" ]; then
    echo 6 > /proc/net/rtl8192fu/log_level
  fi
  if [ -f "/proc/net/rtl8192eu/log_level" ]; then
    echo 6 > /proc/net/rtl8192eu/log_level
  fi
  if [ -f "/proc/net/rtl88x2eu/log_level" ]; then
    echo 4 > /proc/net/rtl88x2eu/log_level
  fi
}

function StartIwpriv() {
  if [ -f "/proc/net/wlan/dbg_level" ]; then
   iwpriv wlan0 driver "set_fwlog 0 2"
   iwpriv wlan0 driver ver
  fi
  if [ -f "/proc/net/wlan/dbgLevel" ]; then
   iwpriv wlan0 driver "set_fwlog 0 2"
   iwpriv wlan0 driver ver
  fi
}
function StopDebugWifi() {
    cd /data/tcl_log/tmp
    if [ ! -d NetworkLog ]; then
        mkdir NetworkLog
    fi
    cd NetworkLog
    START=$(date +%s)

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
    netstat -atnp >netstat.txt
    {
        echo "===debuggerd wpa_supplicant pid==="
        debuggerd $(pidof wpa_supplicant)
        echo "===cat wpa_supplicant stack==="
        cat /proc/$(pidof wpa_supplicant)/stack
        echo "===cat /proc/slabinfo==="
        cat /proc/slabinfo
        echo "===cat /proc/net/dev==="
        cat /proc/net/dev
        echo "===cat /proc/net/arp==="
        cat /proc/net/arp
        echo "===cat /proc/net/snmp==="
        cat /proc/net/snmp
        echo "===cat /proc/net/tcp==="
        cat /proc/net/tcp
        echo "===cat /proc/net/udp==="
        cat /proc/net/udp
        echo "===cat /proc/net/softnet_stat==="
        cat /proc/net/softnet_stat
        echo "===cat /proc/sys/net/netfilter/nf_conntrack_count==="
        cat /proc/sys/net/netfilter/nf_conntrack_count
        echo "===ss -imnp==="
        ss -imnp
    } >all_debug_networklog.txt
    {
        echo "===dumpsys netd==="
        dumpsys netd
        echo "===dumpsys scanner==="
        dumpsys scanner
        echo "===dumpsys ethernet==="
        dumpsys ethernet
        echo "===dumpsys connmetrics==="
        dumpsys connmetrics
        echo "===dumpsys dnsresolver==="
        dumpsys dnsresolver
        echo "===dumpsys network_time_update_service==="
        dumpsys network_time_update_service
    } >all_dump_networklog.txt

    END=$(date +%s)
    duration=$(expr ${END} - ${START} 2>/dev/null)
    echo "StopDebugWifi-exec-${duration} s"
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
    if [ -f "/proc/net/rtl88x2eu/log_level" ]; then
        echo 4 > /proc/net/rtl88x2eu/log_level
    fi
    Version=$(getprop ro.build.version.release)
    if [ "${Version}" == "9" ]; then
        svc wifi logoff
    fi
    if [ "${Version}" -ge 11 ]; then
        cmd wifi set-verbose-logging disabled
    fi
    isRunning=$(getprop init.svc.GeorgedebugTcpDumpLog)
    if [ "${isRunning}" = "running" ]; then
        setprop ctl.stop GeorgedebugTcpDumpLog
    fi
    if [ -c "/dev/LOG" ]; then
        echo disable > /data/tcl_log/skw_log_disable.txt
        echo STOP  > /dev/LOG
        mv /data/tcl_log/skwusb_LOG_*.txt .
        mv /data/tcl_log/*dump.bin .
        mv /data/tcl_log/BTLOG_* .
    fi
    netstat >netstat.txt
    touch /data/tcl_log/tmp/copy_wifi
    setprop sys.tranfer.finished "copyWifi"
}

function StopWifiNormalLog() {
    echo "stop wifi normal log" | tee -a /data/tcl_log/debug.txt
        cd /data/tcl_log/tmp
    if [ ! -d NetworkLog ]; then
        mkdir NetworkLog
    fi
    cd NetworkLog
    START=$(date +%s)

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
    netstat -atnp >netstat.txt
    {
        echo "===debuggerd wpa_supplicant pid==="
        debuggerd $(pidof wpa_supplicant)
        echo "===cat wpa_supplicant stack==="
        cat /proc/$(pidof wpa_supplicant)/stack
        echo "===cat /proc/slabinfo==="
        cat /proc/slabinfo
        echo "===cat /proc/net/dev==="
        cat /proc/net/dev
        echo "===cat /proc/net/arp==="
        cat /proc/net/arp
        echo "===cat /proc/net/snmp==="
        cat /proc/net/snmp
        echo "===cat /proc/net/tcp==="
        cat /proc/net/tcp
        echo "===cat /proc/net/udp==="
        cat /proc/net/udp
        echo "===cat /proc/net/softnet_stat==="
        cat /proc/net/softnet_stat
        echo "===cat /proc/sys/net/netfilter/nf_conntrack_count==="
        cat /proc/sys/net/netfilter/nf_conntrack_count
        echo "===ss -imnp==="
        ss -imnp
    } >all_debug_networklog.txt
    {
        echo "===dumpsys netd==="
        dumpsys netd
        echo "===dumpsys scanner==="
        dumpsys scanner
        echo "===dumpsys ethernet==="
        dumpsys ethernet
        echo "===dumpsys connmetrics==="
        dumpsys connmetrics
        echo "===dumpsys dnsresolver==="
        dumpsys dnsresolver
        echo "===dumpsys network_time_update_service==="
        dumpsys network_time_update_service
    } >all_dump_networklog.txt

    END=$(date +%s)
    duration=$(expr ${END} - ${START} 2>/dev/null)
    if [ -f "/proc/net/wlan/dbg_level" ]; then
        echo 0xff:0x0f >/proc/net/wlan/dbg_level
    fi
    if [ -f "/proc/net/wlan/dbgLevel" ]; then
        echo 0xff:0x0f >/proc/net/wlan/dbgLevel
    fi
    if [ -f "/proc/net/rtl8192fu/log_level" ]; then
        echo 2 >/proc/net/rtl8192fu/log_level
    fi
    if [ -f "/proc/net/rtl8192eu/log_level" ]; then
        echo 4 >/proc/net/rtl8192eu/log_level
    fi
    if [ -f "/proc/net/rtl88x2eu/log_level" ]; then
        echo 4 > /proc/net/rtl88x2eu/log_level
    fi
    Version=$(getprop ro.build.version.release)
    if [ "${Version}" == "9" ]; then
        svc wifi logoff
    fi
    if [ "${Version}" -ge 11 ]; then
        cmd wifi set-verbose-logging disabled
    fi

    netstat >netstat.txt
    touch /data/tcl_log/tmp/copy_wifi
    setprop sys.tranfer.finished "copyWifi"
}

function TcpDumpLog() {
    SENSITIVE_LOG_ENABLE=$(getprop persist.sys.sensitive_log_enabled)
    if [ "${SENSITIVE_LOG_ENABLE}" = "true" ]; then
        START=$(date +%s)
        if [ ! -d /data/tcl_log/TcpDump ]; then
            mkdir -p /data/tcl_log/TcpDump
        fi
        if [  -d /data/tcl_log/TcpDump ]; then
            tcpdump -i any -p -s 0 -e -W 10 -C 200 -w /data/tcl_log/TcpDump/tcpdump.pcap
        fi
        echo "tcpdump  error"
        END=$(date +%s)
        duration=$(expr ${END} - ${START} 2>/dev/null)
        echo "TcpDumpLog-exec-${duration} s"
    fi
}

case "$config" in
    "StartDebugWifi")
      StartDebugWifi
     ;;
    "StartWifiNormalLog")
      StartWifiNormalLog
     ;;
   "StartIwpriv")
      StartIwpriv
     ;;
    "StopDebugWifi")
      StopDebugWifi
     ;;
    "StopWifiNormalLog")
      StopWifiNormalLog
     ;;
    "TcpDumpLog")
      TcpDumpLog
     ;;
     *)
     ;;
esac

