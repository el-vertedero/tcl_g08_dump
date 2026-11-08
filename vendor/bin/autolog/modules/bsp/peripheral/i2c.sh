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
# 100--01 for hardware i2c issue
# 900--01 common dump after issue occurred


BOARD_INI=/vendor/tvconfig/config/board.ini
#PROC_I2C=/proc/utopia_mdb/hwi2c
#PROC_RIU=/proc/utopia_mdb/riuinfo

DUMP_BSP_PERIPHERAL_I2C_BOARD_INI()
{
  if [ -e $BOARD_INI ] ; then
    echo ">>>> DUMP I2C settings from $BOARD_INI ..." >> $ACT_LOG_FP
    grep -i -e i2c -e iic $BOARD_INI >> $ACT_LOG_FP
    echo ">>>> DUMP I2C settings from $BOARD_INI DONE" >> $ACT_LOG_FP
  else
    echo ">>>> DUMP I2C settings from $BOARD_INI FAIL: not existed..." >> $ACT_LOG_FP
  fi
}

DUMP_BSP_PERIPHERAL_I2C()
{
  echo "DUMP_BSP_PERIPHERAL_I2C not support yet..."
  echo "need module owner to update control command...."
  echo "==============================================="
  #echo "Dump HWI2C info" >> /dev/kmsg
  #cat $PROC_I2C
  #echo "Dump HWI2C RIU BANK" >> /dev/kmsg
  #echo dump,0x1118 > $PROC_RIU
  #echo dump,0x1119 > $PROC_RIU
}


INIT_BSP_PERIPHERAL_I2C()
{
  echo "Initialize BSP.PERIPHERAL.I2C configs..."
#  set -e

  SCENARIO_NUM="$1"


  # Open log by scenario number
  ### You can setup kinds of scenario here
  case "$SCENARIO_NUM" in
    "10001")
      # 10001 => For Common Scenario Used
      echo "IN 10001"
      DUMP_BSP_PERIPHERAL_I2C_BOARD_INI
      DUMP_BSP_PERIPHERAL_I2C
    ;;
    "90001")
      # 90001 => For after issue used
      echo "IN 90001"
      DUMP_BSP_PERIPHERAL_I2C_BOARD_INI
      DUMP_BSP_PERIPHERAL_I2C
    ;;
    *)

      echo "SCENARIO_NUM='$SCENARIO_NUM' is not defined in i2c, please check or contact related RD"
      return 1
    ;;
  esac

  #common

#  set +e
  echo -e "I2C Init log Success!\n"
}


CLOSE_BSP_PERIPHERAL_I2C()
{
#  set -e
  #Log Off

#  set +e
  DUMP_BSP_PERIPHERAL_I2C
  echo -e "Close I2C log Success!\n"
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

  echo -e "Wait for i2c log initialization ...\n"

  if [ "$script_debug_mode" -gt 0 ]
  then
      echo "script debug mode: on"
    set -x
  fi

  # Open log
  INIT_BSP_PERIPHERAL_I2C $SCENARIO_NUM

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
  CLOSE_BSP_PERIPHERAL_I2C


  #### log settings
  ## re-cover log level
  #echo $org_printk > /proc/sys/kernel/printk || echo -e "${COLOR_RED}Change printk error! Permission Denied${COLOR_REST}"

  ## stop dmesg running in background jobs
  #sleep 2
  #kill -9 $child_pid
  #sync
  #sync
}


if [ "$*" = "--source-only" ]; then
  :
else
  MAIN $*
fi
