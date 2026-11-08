#!/usr/bin/env sh
source "$AUTOLOG_HOME/utils/imports.sh"
ImportUtil "loggers.sh"
ImportUtil "colors.sh"
ImportUtil "sys.sh"
SCENARIO_DIR='scenario_aow'
INIT_BSP_HDMIRX_HDMIINFO()
{
  SCENARIO_NUM="$1"
  echo "INIT_BSP_HDMIRX_HDMIINFO"
  #echo "LOG_FP = $LOG_FP"
  #echo "ACT_LOG_FP = $ACT_LOG_FP"
  #echo "SCENARIO_NUM = $SCENARIO_NUM"

  case "$SCENARIO_NUM" in
    "90001")
      echo "Mode Select:ALL"
	  SYSFS_printk=$(cat /sys/devices/platform/mtk_srccap0/mtk_dbg/hdmirx/HDMI_INFO)
      echo "$SYSFS_printk" | tee -a "$LOG_FP"
	  SYSFS_printk=$(cat /sys/devices/platform/mtk_srccap0/mtk_dbg/hdmirx/TIMING_DETECT)
      echo "$SYSFS_printk" | tee -a "$LOG_FP"
	  SYSFS_printk=$(cat /sys/devices/platform/mtk_srccap0/mtk_dbg/hdmirx/ALL_INFO)
      echo "$SYSFS_printk" | tee -a "$LOG_FP"
    ;;
    "90002")
      echo "HDMI Auto relative Modules"
      Import bsp hdmirx $SCENARIO_DIR hdmirx_$SCENARIO_NUM.sh
      hdmirx_log_open
    ;;
    "10000")
      echo "Mode Select:HDMI INFO(10000)"
	  SYSFS_printk=$(cat /sys/devices/platform/mtk_srccap0/mtk_dbg/hdmirx/HDMI_INFO)
      echo "$SYSFS_printk" | tee -a "$LOG_FP"
    ;;
    "10001")
      echo "Mode Select:TIMING DETECT(10001)"
	  SYSFS_printk=$(cat /sys/devices/platform/mtk_srccap0/mtk_dbg/hdmirx/TIMING_DETECT)
      echo "$SYSFS_printk" | tee -a "$LOG_FP"
    ;;
	"10002")
      echo "Mode Select:ALL INFO(10002)"
	  SYSFS_printk=$(cat /sys/devices/platform/mtk_srccap0/mtk_dbg/hdmirx/ALL_INFO)
      echo "$SYSFS_printk" | tee -a "$LOG_FP"
    ;;
    *)
      echo "SCENARIO_NUM='$SCENARIO_NUM' is not defined in hwsem, please check or contact related RD"
      return 1
    ;;
  esac
  
  #cat /sys/devices/platform/mtk_srccap0/mtk_dbg/hdmirx/ALL_INFO
  #SYSFS_printk=$(cat /sys/devices/platform/mtk_srccap0/mtk_dbg/hdmirx/ALL_INFO)
  #echo "$SYSFS_printk" | tee -a "$LOG_FP"
  #result = 'cat /sys/devices/platform/mtk_srccap0/mtk_dbg/hdmirx/ALL_INFO'
  #printf "%s\n" $result
  
  echo -e "HDMIRX Init log Success!\n"
}

CLOSE_BSP_HDMIRX_HDMIINFO()
{
  SCENARIO_NUM="$1"
  case "$SCENARIO_NUM" in
    "90002")
      echo "close hdmirx scenario id: $SCENARIO_NUM"
      Import bsp hdmirx $SCENARIO_DIR hdmirx_$SCENARIO_NUM.sh
      hdmirx_log_close

      echo "Close hdmirx log Success!"
      sync
      sync
    ;;
    *)
      echo "CLOSE_BSP_HDMIRX_HDMIINFO"
    ;;
  esac
}

Leaving_question()
{
  local LOG_FP="$1"
  message="${COLOR_RED} After issue appears, press enter Y/y to finishing recording! ${COLOR_REST}"
  bug=$(prompt "$message" "$LOG_FP")
  echo "$bug"
}

MAIN()
{
  version="v1.0"
  . "$AUTOLOG_HOME/utils/preprocess.sh"
  
  ### Arguments
  # $log_fp => output log file path
  # $act_log_fp => interactive log output file path
  module_arg1=$1
  module_arg2=$2
  module_arg3=$3
  
  #echo "module_arg1 = $module_arg1"
  #echo "module_arg2 = $module_arg2"
  #echo "module_arg3 = $module_arg3"
  #echo "SCENARIO_NUM = $SCENARIO_NUM"
  
  ### log settings
  # back-up log level
  #org_printk=$(cat /proc/sys/kernel/printk)
  # start kernel log
  #echo 0 > /proc/sys/kernel/printk || echo -e "${COLOR_RED}Change printk error! Permission Denied${COLOR_REST}"
  #dmesg --follow -r >> $LOG_FP &
  #child_pid=$!
  #--------------------------------------

  #--------------------------------------
  #Need to open/key log before issue appears
  script_debug_mode=0

  echo -e "Wait for HDMIRX log initialization ...\n"

  if [ "$script_debug_mode" -gt 0 ]
  then
      echo "script debug mode: on"
    set -x
  fi
  
  # Open log
  INIT_BSP_HDMIRX_HDMIINFO $SCENARIO_NUM
  
  #--------------------------------------
  #Reproduce issue and finishing record.
  if [ "$script_debug_mode" -gt 0 ]
  then
    set +x && read "abc" && set -x
  else
    while :
    do
      rst1=$(Leaving_question $ACT_LOG_FP)
      if [ "${rst1}" == "Y" ] || [ "${rst1}" == "y" ]; then
         break
      fi
    done
  fi
  sleep 1s
  
   # Close log
  CLOSE_BSP_HDMIRX_HDMIINFO $SCENARIO_NUM
  
}

if [ "$*" = "--source-only" ]; then
  :
else
  MAIN $*
fi
