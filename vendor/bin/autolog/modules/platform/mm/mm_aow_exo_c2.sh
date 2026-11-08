#!/usr/bin/env sh
#set -x

. "$AUTOLOG_HOME/utils/imports.sh"
ImportUtil "loggers.sh"
ImportUtil "colors.sh"
#ImportUtil "helpers.sh"
ImportUtil "sys.sh"

#========================================================
#          Import modules functions you need
# if you want to call modules/bsp/audio/audio.sh
#                  =>  Import bsp audio audio.sh
#========================================================
#Import bsp video common.sh
#Import bsp audio audio_demo.sh

#TODO
#Import bsp audio audio.sh
Import bsp video video.sh
#Import bsp disp disp.sh
Import platform security widevine_an.sh

Wait_finish()
{
    message="${COLOR_RED}After issue appears, press keyin any words to finishing recording!${COLOR_REST}"
    bug=$(prompt "$message")
    echo "$bug"
    sleep 1s
}

INIT_PLATFORM_MM_EXO()
{
  SCENARIO_NUM="$1"
  echo "USE case SCENARIO_NUM=$SCENARIO_NUM"
  echo "USE case LOG_DIR=$LOG_DIR"
  case "$SCENARIO_NUM" in
    "10001")
      echo "IN1 10001"
      LOGCAT_LOG="$LOG_DIR/$LOG_DT-platform_mm_mm_aow_exo_c2.sh_10001-exo_c2_logcat.log"
      echo "LOGCAT_LOG: $LOGCAT_LOG"
      #su
      #setenforce 0
      svc bluetooth disable service
      service call bluetooth_manager 8
      svc wifi disable
      service call bluetooth_manager 8
      setprop vendor.mtktv.sideband.reportempty 0
      setprop vendor.mtktv.c2.enable.vdec.log 3
      setprop vendor.mtktv.c2.enable.tpcvideo.log 2
      setprop vendor.mtk.vcodecvdecimpl.log 3
      setprop vendor.mtk.pqlink.log 1
      setprop vendor.mtk.displink.log 1
      setprop vendor.mtk.tpchwc.log 1
      setprop vendor.hal.audio.log.level VERBOSE
      setprop mtk.exoplayer.debug.level 11

      setprop vendor.mtk.vcodecvideo.log 3
      setprop vendor.mtk.mirender.debuglevel F0
      setprop vendor.mtk.mirender.debuginfo 417E0000
      setprop vendor.mtk.displink.log 1
      echo 0xFF > /sys/module/drm/parameters/debug
      echo 0x400FFFF > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/log_level

      echo 0xdff > /sys/devices/platform/mtk-pq/mtk_dbg/log_level
      echo 0x003 > /sys/devices/platform/mtk-tvpqu/mtk_dbg/log_level
      setprop vendor.mtk.mipq.debuglevel F0
      mount -o rw,remount /data
      logcat -c
      logcat -G 64M
      logcat -v threadtime > $LOGCAT_LOG &
      ;;
    "10002")
      echo "IN1 10002"
    ;;
    *)
      echo "SCENARIO_NUM='$SCENARIO_NUM' is not defined "
      exit 1
    ;;
    esac
      echo "OUT 10001"
}

CLOSE_INIT_PLATFORM_MM_EXO()
{
  echo -e "Close Platform exo C2 log Success!\n"
}

MAIN()
{
  PID=$$
  version="v1.0"
  echo "=========== (PID=$PID) from $0 ============="
  . "$AUTOLOG_HOME/utils/preprocess.sh"

  #========================================================
  #                       Arguments
  # Defined in utils/preprocess.sh
  #   $LOG_FP     => output log file path
  #   $ACT_LOG_FP => interactive log output file path
  #   $LOG_DIR    => output directory of log
  #   $LOG_DT     => datetime from log file name
  #   $SCENARIO_NUM => scenario number
  #
  # The number of arguments for this script are not limited.
  # You can use $n to add & declare the argument you need
  #   $module_arg<n> = Arguments passed from main script
  #========================================================

  MODULE_ARG1=$1
  MODULE_ARG2=$2
  MODULE_ARG3=$3

  echo "LOG_FP=$LOG_FP"
  echo "ACT_LOG_FP=$ACT_LOG_FP"
  echo "LOG_DIR=$LOG_DIR"
  echo "LOG_DT=$LOG_DT"
  echo "SCENARIO_NUM=$SCENARIO_NUM"

  echo "MODULE_ARG1=$MODULE_ARG1"
  echo "MODULE_ARG2=$MODULE_ARG2"
  echo "MODULE_ARG3=$MODULE_ARG3"

  echo "open mm_aow_exo_c2.sh 10001"

  INIT_PLATFORM_MM_EXO $SCENARIO_NUM $LOG_DIR

  Wait_finish

  CLOSE_INIT_PLATFORM_MM_EXO
}

if [  "$*" = "--source-only" ];then
  :
else
  MAIN $*
fi