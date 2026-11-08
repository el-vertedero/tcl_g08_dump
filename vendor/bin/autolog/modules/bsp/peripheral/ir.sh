#!/usr/bin/env sh
. "$AUTOLOG_HOME/utils/imports.sh"

ImportUtil "loggers.sh"
ImportUtil "colors.sh"

Leaving_question()
{
  local LOG_FP="$1"
  message="${COLOR_RED} After issue appears, press enter Y/y to finishing recording! ${COLOR_REST}"
  bug=$(prompt "$message" "$LOG_FP")
  echo "$bug"
}
#
# 100--01 IR hardware decoder issue
# 100--02 IR software decoder issue
#
# 900--01 common dump after issue occurred


IR_CONFIG_INI=/vendor/tvconfig/config/ir_config.ini
#SYSFS_IR=/sys/devices/ir/IRDebug

DUMP_BSP_PERIPHERAL_IR_CONFIG()
{
  if [ -e $IR_CONFIG_INI ] ; then
    echo ">>>> DUMP IR settings from $IR_CONFIG_INI ..." >> $ACT_LOG_FP
    cat $IR_CONFIG_INI >> $ACT_LOG_FP
    echo ">>>> DUMP IR settings DONE." >> $ACT_LOG_FP
  else
    echo ">>>> DUMP IR settings from $IR_CONFIG_INI FAIL: not existed..." >> $ACT_LOG_FP
  fi
}

DUMP_BSP_PERIPHERAL_IR()
{ 
   echo "DUMP_BSP_PERIPHERAL_IR not support yet..."
   echo "need ir module to update control command...."
   echo "============================================"
#  echo $1 > $SYSFS_IR
}


INIT_BSP_PERIPHERAL_IR()
{
  echo "Initialize BSP.PERIPHERAL.IR configs..."
#  set -e

  SCENARIO_NUM="$1"


  # Open log by scenario number
  ### You can setup kinds of scenario here
  case "$SCENARIO_NUM" in
    "10001")
      # 10001 => IR HW decoder
      echo "IN 10001"
      DUMP_BSP_PERIPHERAL_IR_CONFIG
      DUMP_BSP_PERIPHERAL_IR 4 
    ;;
    "10002")
      # 10002 => For IR SW decoder
      echo "IN 10002"
      DUMP_BSP_PERIPHERAL_IR_CONFIG
      DUMP_BSP_PERIPHERAL_IR 3
    ;;
    "90001")
      # 90001 => For after issue used
      echo "IN 90001"
      DUMP_BSP_PERIPHERAL_IR_CONFIG
      DUMP_BSP_PERIPHERAL_IR 4
    ;;
    *)

      echo "SCENARIO_NUM='$SCENARIO_NUM' is not defined in ir, please check or contact related RD"
      return 1
    ;;
  esac

  #common

#  set +e
  echo -e "IR Init log Success!\n"
}


CLOSE_BSP_PERIPHERAL_IR()
{
#  set -e
  #Log Off
  DUMP_BSP_PERIPHERAL_IR 0

#  set +e
  echo -e "Close IR log Success!\n"
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

  #### log settings
  ## back-up log level
  #org_printk=$(cat /proc/sys/kernel/printk)
  ## start kernel log
  #echo 0 > /proc/sys/kernel/printk || echo -e "${COLOR_RED}Change printk error! Permission Denied${COLOR_REST}"
  #dmesg --follow -r >> $LOG_FP &
  #child_pid=$!

  #--------------------------------------
  #Need to open/key log before issue appears
  script_debug_mode=0

  echo -e "Wait for ir log initialization ...\n"

  if [ "$script_debug_mode" -gt 0 ]
  then
      echo "script debug mode: on"
    set -x
  fi

  # Open log
  INIT_BSP_PERIPHERAL_IR $SCENARIO_NUM

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
  CLOSE_BSP_PERIPHERAL_IR


  #### log settings
  ## re-cover log level
  #echo $org_printk > /proc/sys/kernel/printk || echo -e "${COLOR_RED}Change printk error! Permission Denied${COLOR_REST}"

  ## stop dmesg running in background jobs
  #kill -9 $child_pid
  #sync
  #sync
}


if [ "$*" = "--source-only" ]; then
  :
else
  MAIN $*
fi
