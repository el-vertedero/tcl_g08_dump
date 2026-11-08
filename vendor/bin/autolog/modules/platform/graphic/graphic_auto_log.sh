#!/usr/bin/env sh
#set -x
GRAPHIC_LOG_VERSION="1.0.0"

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
#Import bsp video video.sh

INIT_PLATFORM_GRAPHIC_AUTO_LOG ()
{

  SCENARIO_NUM="$1"
  LOG_DIR="$2"

  echo "USE case :$LOG_DIR"

  LOGCAT_LOG="${LOG_DIR}/graphic_logcat.log"

#   set -e

  case "$SCENARIO_NUM" in
    "10001")
      echo "IN 10001"
      echo "Set Graphic properties first"
      ## start

      # HWC prop
      setprop vendor.mtk.debugEx.hwcomposer20 421D6

      # MI_Render prop
      setprop vendor.mtk.mirender.debuglevel F0
      setprop vendor.mtk.mirender.debuginfo 407E0000

      #################################################
      #TODO
      echo "Enable DRM LOG"
      echo 0xFF > /sys/module/drm/parameters/debug
      echo 0x3FFFFF > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/log_level

      ## end
      echo "Please wait 1 seconds!!!"
      sleep 1
      echo "Please start to reproduce this issue......"
    ;;
  esac
  echo "case done."
}


CLOSE_PLATFORM_GRAPHIC_AUTO_LOG()
{
  echo -e "Close Platform GRAPHIC AUTO LOG log Success!\n"
}


MAIN()
{
  echo "GRAPHIC_LOG_VERSION: $GRAPHIC_LOG_VERSION"

  PID=$$
  echo "=========== (PID=$PID) from $0 ============="
  source "$AUTOLOG_HOME/utils/preprocess.sh"

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
  #MODULE_ARG1=$1
  #MODULE_ARG2=$2
  #MODULE_ARG3=$3
  echo "LOG_FP=$LOG_FP"
  echo "ACT_LOG_FP=$ACT_LOG_FP"
  echo "LOG_DIR=$LOG_DIR"
  echo "LOG_DT=$LOG_DT"
  echo "SCENARIO_NUM=$SCENARIO_NUM"

  INIT_PLATFORM_GRAPHIC_AUTO_LOG $SCENARIO_NUM $LOG_DIR
  CLOSE_PLATFORM_GRAPHIC_AUTO_LOG
}

if [  "$*" = "--source-only" ];then
  :
else
  MAIN $*
fi
