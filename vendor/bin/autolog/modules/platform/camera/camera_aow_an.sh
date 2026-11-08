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

ARGV=0

Wait_finish()
{
    message="${COLOR_RED}After issue appears, press any key to finish recording!${COLOR_REST}"
    bug=$(prompt "$message")
    echo "$bug"
    sleep 1s
}

INIT_PLATFORM_CAMERA()
{

  #========================================================
  #                   Define Scenarios
  # In this section, you have to design log switches for
  #   each kinds of scenarios.
  # For example:
  #    Scenario A (10101) is related to log_a, log_b, log_c
  #        => Enable log_a, log_b, log_c
  #    Scenario A' (10102) is a light version of scenario A.
  #      only enable log_a, log_b
  #        => Enable log_a, log_b
  #    Scenario B (10201) is only related to log_b
  #        => Just have to enable log_b
  #========================================================
  echo "Initialize PLATFORM.CAMERA.CAMERA log configs..."
  SCENARIO_NUM="$1"
  ARGV="$2"
#  set -e

  #========================================================
  #                   Common part  (CAUTION!!)
  #  Commands defined here will been executed while user
  #  call this function EVERY TIME.
  #========================================================
  #echo debug_level=4 > /proc/utopia_mdb/audio

  ### Enable logs by scenario number
  ### You can setup kinds of scenario here
  ### Scenario Number is
  case "$SCENARIO_NUM" in
    "10001")
      ######################################################
      #              ( 10001 )  Scenario A - Normal
      #
      # <camera logcat+kernel>
      #
      ######################################################
      echo "IN 10001"

      CAMERA_LOG_FP="$LOG_DIR/$LOG_DT-camera_log.log"
      CAMERA_START_STATUS_FP="$LOG_DIR/$LOG_DT-camera_start_status.log"
      echo "CAMERA_LOG_FP: $CAMERA_LOG_FP"
      echo "CAMERA_START_STATUS_FP: $CAMERA_START_STATUS_FP"
      echo "Enable CAMERA log"
      logcat -c
      logcat -G 256M
      setenforce permissive

      # camera status
      ls /dev/video* -l  | tee -a $CAMERA_START_STATUS_FP
      ps -A | grep camera  | tee -a $CAMERA_START_STATUS_FP
      ls /vendor/lib/vendor.mediatek.camera.*  | tee -a $CAMERA_START_STATUS_FP
      ls /vendor/bin/hw/vendor.mediatek.hardware.camera.provider@2.4-external-service  | tee -a $CAMERA_START_STATUS_FP
      dumpsys media.camera -v2 | tee -a $CAMERA_START_STATUS_FP

      #camera log
      mkdir /data/camera
      chmod 777 /data/camera
      mkdir -p /data/camera/
      chmod 777 /data/camera/
      setprop vendor.camera.dumpdata 1
      echo 2 > /sys/module/uvcvideo/parameters/trace
      echo 8 > /proc/sys/kernel/printk

      # mi_pq log
      setprop vendor.mtk.mipq.debuglevel 40
      setprop vendor.mtk.pqhal.debuglevel 5

      #PQDD log
      echo 0 > /proc/sys/kernel/printk
      echo 0 > /sys/devices/platform/mtk-pq/mtk_dbg/log_interval
      echo 0xdff > /sys/devices/platform/mtk-pq/mtk_dbg/log_level

      # c2 log
      setprop vendor.mtktv.c2.enable.venc.log 1
      setprop vendor.mtk.c2.enable.vdec.log 2
      setprop vendor.mtktv.c2.enable.vdec.log 2

      # capture hal log
      setprop vendor.mtk.capture_hal.loglevel A
      echo dbg MI_CAP 0xF0 > /sys/kernel/mik/MI_UTIL

      # aivision manager log
      mkdir /data/dump
      chmod 777 /data/dump
      setprop vendor.mtk.aivision.manager.log 1
      setprop vendor.mtk.alpha.log 1
      setprop vendor.mtk.alpha.dump 1
      setprop vendor.mtk.dptz.debug 1
      setprop vendor.mtk.aivision.manager.log 1
      setprop vendor.mtk.aivision.manager.timer 1
      setprop vendor.mtk.c2.enable.comp.log 2
      setprop vendor.mtk.c2.enable.vdec.log 2
      setprop vendor.mtktv.c2.enable.vdec.log 2
      setprop vendor.mtktv.c2.enable.bm.log 2
      setprop vendor.mtk.vcodecvideo.log 2
      setprop vendor.mtk.vcodecvdecimpl.log 3

      echo "Start recording log"
      logcat -v threadtime > $CAMERA_LOG_FP &

    ;;
    *)
      ######################################################
      #              ( * )  Scenario not defined
      #
      ######################################################
      echo "SCENARIO_NUM='$SCENARIO_NUM' is not defined in camera_aow_an.sh, please check or contact related RD"
      exit 1
    ;;
  esac

#  set +e
  echo -e "Init Platform CAMERA CAMERA log Success!\n"
}


CLOSE_PLATFORM_CAMERA()
{

  cp /data/anr/* $LOG_DIR/
  sync
  sync
  kill `pidof logcat`
  kill `pidof cat`
  echo "Disable CAMERA log "
  sync
  sync

#  set -e
  #TODO
  CLOSE_BSP_VIDEO_VIDEO
  #CLOSE_BSP_DISP_DISP
  echo 0x0 > /sys/devices/platform/mtk-pq/mtk_dbg/log_level
  echo 0x0 > /sys/module/drm/parameters/debug
  echo 0x0 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/log_level
#  set +e

  #Close DRM WV Log
  if [ "$ARGV" = "wv" ]; then
  CLOSE_PLATFORM_SECURITY_WIDEVINE
  fi

  echo -e "Close Platform CAMERA log Success!\n"
}


MAIN()
{
  PID=$$
  version="v1.0"
  #========================================================
  #                 Pre-process functions
  #                  (Don't remove this)
  #========================================================
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
  ES_FRAME_DUMP_DIR="/data/vendor/tmp/dump"

  echo "LOG_FP=$LOG_FP"
  echo "ACT_LOG_FP=$ACT_LOG_FP"
  #LOG_DIR=$2
  echo "LOG_DIR=$LOG_DIR"
  echo "LOG_DT=$LOG_DT"

  echo "SCENARIO_NUM=$SCENARIO_NUM"
  echo "MODULE_ARG1=$MODULE_ARG1"
  echo "MODULE_ARG2=$MODULE_ARG2"
  echo "MODULE_ARG3=$MODULE_ARG3"

  #========================================================
  #                   Main codes here
  # You can modify codes under this section
  #========================================================

  ### Import functions from other modules/scripts
  ### DO SOMETHING
  OpenCommandDebuger $INIT_HISTORY_FP
  INIT_PLATFORM_CAMERA $SCENARIO_NUM $MODULE_ARG1

  Wait_finish

  CloseCommandDebuger
  PrintCommandDebuger $INIT_HISTORY_FP

  PrintCpuMemUsage "$ACT_LOG_FP"


  ################################
  ### Demo interactive flow
  #echo "-------- Interactive demo --------"
  ### Questions flow control
  #rst1=$(question1 $ACT_LOG_FP)
  #if [ "$rst1" = "Y" ] || [ "$rst1" = "y" ]; then
  #  rst2=$(question2 $ACT_LOG_FP)
  #fi

  ################################
  ### CLOSE LOGs
  PrintCpuMemUsage "$ACT_LOG_FP"
  CLOSE_PLATFORM_CAMERA

  echo
  echo "================================"
  ################## ENDs HERE ##################
}

#========================================================
#                 Script entrance control
#                  (Don't remove this)
#  If call this script through 'sh' command:
#      => Execute script, e.g MAIN function
#  If call this script through 'source <script_path> --source-only'
#      => import functions inside this script and this will
#         not execute MAIN()
#========================================================
if [ "$*" = "--source-only" ]; then
  :
else
  MAIN $*
fi
