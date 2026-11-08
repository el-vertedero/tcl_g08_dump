#!/usr/bin/env sh
. "$AUTOLOG_HOME/utils/imports.sh"

ImportUtil "loggers.sh"
ImportUtil "colors.sh"

Import bsp peripheral ir.sh
Import bsp peripheral i2c.sh
Import bsp peripheral pwm.sh
Import bsp peripheral emac.sh
Import bsp peripheral bdma.sh
Import bsp peripheral hwsem.sh

Leaving_question()
{
  local LOG_FP="$1"
  message="${COLOR_RED} After issue appears, press enter Y/y to finishing recording! ${COLOR_REST}"
  bug=$(prompt "$message" "$LOG_FP")
  echo "$bug"
}
#
# 200--01 IR hardware decoder issue
#     \02 IR software decoder issue
# 300--01 HW I2C issue
# 400--01 PWM issue
# 500--01 EMAC issue
# 600--01 BDMA issue
# 650--01 HWSEM issue
#
# 900--01 common dump after issue occurred

INIT_BSP_PERIPHERAL_PERIPHERAL()
{
  echo "Initialize BSP.PERIPHERAL.PERIPHERAL configs..."
#  set -e

  SCENARIO_NUM="$1"


  # Open log by scenario number
  ### You can setup kinds of scenario here
  case "$SCENARIO_NUM" in
    "20001")
      # 20001 => For IR HW decoder
      echo "IN 20001"
      INIT_BSP_PERIPHERAL_IR 10001
    ;;
    "20002")
      # 20002 => For IR SW decoder
      echo "IN 20002"
      INIT_BSP_PERIPHERAL_IR 10002
    ;;
    "30001")
      # 30001 => For HW I2C issue
      echo "IN 30001"
      INIT_BSP_PERIPHERAL_I2C 10001
    ;;
    "40001")
      # 40002 => For PWM issue
      echo "IN 40001"
      INIT_BSP_PERIPHERAL_PWM 10001
    ;;
    "50001")
      # 50002 => For EMAC status check
      echo "IN 50001"
      INIT_BSP_PERIPHERAL_EMAC 10001
    ;;
    "60001")
      # 60002 => For BDMA debug
      echo "IN 60001"
      INIT_BSP_PERIPHERAL_BDMA 10001
    ;;
    "62001")
      # 62002 => For HWSEM debuf info
      echo "IN 62001"
      INIT_BSP_PERIPHERAL_HWSEM 10001
    ;;
    "90001")
      # 90001 => For after issue used
      echo "IN 90001"
      INIT_BSP_PERIPHERAL_IR 90001
      INIT_BSP_PERIPHERAL_I2C 90001
      INIT_BSP_PERIPHERAL_PWM 90001
      INIT_BSP_PERIPHERAL_EMAC 90001
      INIT_BSP_PERIPHERAL_BDMA 90001
      INIT_BSP_PERIPHERAL_HWSEM 90001
    ;;
    *)

      echo "SCENARIO_NUM='$SCENARIO_NUM' is not defined in peripheral, please check or contact related RD"
      return 1
    ;;
  esac

  #common

#  set +e
  echo -e "PERIPHERAL Init log Success!\n"
}


CLOSE_BSP_PERIPHERAL_PERIPHERAL()
{
#  set -e
  #Log Off
  CLOSE_BSP_PERIPHERAL_IR
  CLOSE_BSP_PERIPHERAL_I2C
  CLOSE_BSP_PERIPHERAL_PWM
  CLOSE_BSP_PERIPHERAL_EMAC
  CLOSE_BSP_PERIPHERAL_BDMA
  CLOSE_BSP_PERIPHERAL_HWSEM

#  set +e
  echo -e "Close PERIPHERAL log Success!\n"
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

  echo -e "Wait for peripheral log initialization ...\n"

  if [ "$script_debug_mode" -gt 0 ]
  then
      echo "script debug mode: on"
    set -x
  fi

  # Open log
  INIT_BSP_PERIPHERAL_PERIPHERAL $SCENARIO_NUM

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
  CLOSE_BSP_PERIPHERAL_PERIPHERAL


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
