#!/usr/bin/env sh
source "$AUTOLOG_HOME/utils/imports.sh"
ImportUtil "loggers.sh"
ImportUtil "colors.sh"
ImportUtil "sys.sh"

INIT_BSP_EARC_INFO()
{
  SCENARIO_NUM="$1"
  echo "INIT_BSP_EARC_INFO"

  case "$SCENARIO_NUM" in
    "90001")
      echo "Mode Select:ALL"
	  SYSFS_printk=$(echo 1 > /sys/devices/platform/mtk_earc/RD/Info)
	  SYSFS_printk=$(cat /sys/devices/platform/mtk_earc/RD/Info)
      echo "$SYSFS_printk" | tee -a "$LOG_FP"
	  SYSFS_printk=$(cat /sys/devices/platform/mtk_earc/RD/DeviceNodeNum)
      echo "$SYSFS_printk" | tee -a "$LOG_FP"
    ;;
    *)
      echo "SCENARIO_NUM='$SCENARIO_NUM' is not defined in hwsem, please check or contact related RD"
      return 1
    ;;
  esac

  echo -e "eARC Init log Success!\n"
}

CLOSE_BSP_HDMIRX_EARCINFO()
{
  echo "CLOSE_BSP_HDMIRX_EARCINFO"
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

  echo -e "Wait for eARC log initialization ...\n"

  if [ "$script_debug_mode" -gt 0 ]
  then
      echo "script debug mode: on"
    set -x
  fi

  # Open log
  INIT_BSP_EARC_INFO $SCENARIO_NUM

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
  CLOSE_BSP_HDMIRX_EARCINFO

}

if [ "$*" = "--source-only" ]; then
  :
else
  MAIN $*
fi
