#!/usr/bin/env sh
#set -x
BROADCAST_LOG_VERSION="1.0.1"

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
Import bsp video video.sh

INIT_PLATFORM_BROADCAST_AUTO_LOG ()
{

  SCENARIO_NUM="$1"
  LOG_DIR="$2"

  echo "USE case :$LOG_DIR"

  LOGCAT_LOG="${LOG_DIR}/broadcast_logcat.log"

#   set -e

  case "$SCENARIO_NUM" in
    "10101")
      echo "IN 10101"
      echo "Set Broadcast properties first"
      ## start

      # broadcast and tuner prop
      setprop vendor.mtk.broadcast.log.level D
      setprop vendor.mtk.tvexoplayer.log all
      setprop vendor.debug.tuner.service.log 1

      # VDEC / DISP prop
      setprop vendor.mstar.vsync_bridge.log 1
      setprop vendor.mstar.vdec.log 2
      setprop vendor.mtk.displink.bm.profile 1
      setprop vendor.mtk.c2.enable.comp.log 2
      setprop vendor.mtk.c2.enable.vdec.log 2
      setprop vendor.mtktv.c2.enable.vdec.log 2
      setprop vendor.mtktv.c2.enable.bm.log 2
      setprop vendor.mtk.codec2.log 2
      setprop mtk.exoplayer.debug.level 11
      setprop vendor.mtk.vcodecvideo.log 2
      setprop vendor.mtk.vcodecvdecimpl.log 3
      setprop vendor.mtk.tpchwc.log 1
      setprop vendor.mtk.vsyncbridge.log 1
      setprop vendor.mtk.displink.log 1
      setprop vendor.mtk.subhalvideo.log 0x40
      setprop vendor.hal.c2.audio.log.level VERBOSE
      setprop vendor.hal.audio.log.level VERBOSE
      setprop vendor.mtk.mipq.debuglevel F0
      setprop vendor.mtk.tpc.debug.log 4
      setprop vendor.mtk.pqlink.log 1
      setprop vendor.mtk.pqlink.performance.profile 1
      setprop vendor.mtk.pqlink.setwin.info 1

      # tunerlink for dtv passthrough mode, mediator for new feature. request by Boodin Yao
      setprop vendor.mtk.tunerlink.log 2
      setprop vendor.mtk.c2bwm.log 3
      setprop vendor.mtk.dispservice.mediator.info.log 1

      #Render //20211104 request by Adam-tt
      setprop vendor.mtk.mirender.debuglevel F0
      setprop vendor.mtk.mirender.debuginfo 41680000

      #TS/PS container log //20211118 requested by Neil Hsieh
      setprop vendor.mtk.ts.verbose.log 1
      setprop vendor.mtk.ps.verbose.log 1

      # Runtime sync mode enable
      setprop vendor.mtk.tpc.runtime.syncmode.enable 1

      #################################################
      #TODO
      echo "Enable Kernel log"
      echo "Enable VDEC LOG"
      INIT_BSP_VIDEO_VIDEO 10101

      ## end
      echo "Already Enable Broadcast debug level, now begin caption log...."

      locat -c
      logcat -G 256M
      touch /data/tkui.print
      touch /data/mtk_dt_log
      logcat > $LOGCAT_LOG &
      sync
      echo "Please wait 10 seconds!!!"
      echo "Please wait 10 seconds!!!"
      sleep 12
      echo "Please start to reproduce this issue......"
      echo "Please start to reproduce this issue......"
    ;;
    "20101")
      echo "IN 20101"
      echo "Set Broadcast properties first"
      ## start

      # broadcast and tuner prop
      setprop vendor.mtk.broadcast.log.level D
      setprop vendor.mtk.tvexoplayer.log all
      setprop vendor.debug.tuner.service.log 1

      # VDEC / DISP prop
      setprop vendor.mstar.vsync_bridge.log 1
      setprop vendor.mstar.vdec.log 2
      setprop vendor.mtk.displink.bm.profile 1
      setprop vendor.mtk.c2.enable.comp.log 2
      setprop vendor.mtk.c2.enable.vdec.log 2
      setprop vendor.mtktv.c2.enable.vdec.log 2
      setprop vendor.mtktv.c2.enable.bm.log 2
      setprop vendor.mtk.codec2.log 2
      setprop mtk.exoplayer.debug.level 11
      setprop vendor.mtk.vcodecvideo.log 2
      setprop vendor.mtk.vcodecvdecimpl.log 3
      setprop vendor.mtk.tpchwc.log 1
      setprop vendor.mtk.vsyncbridge.log 1
      setprop vendor.mtk.displink.log 1
      setprop vendor.mtk.subhalvideo.log 0x40
      setprop vendor.hal.c2.audio.log.level VERBOSE
      setprop vendor.hal.audio.log.level VERBOSE
      setprop vendor.mtk.tpc.debug.log 4
      setprop vendor.mtk.pqlink.log 1
      setprop vendor.mtk.pqlink.performance.profile 1
      setprop vendor.mtk.pqlink.setwin.info 1

      # tunerlink for dtv passthrough mode, mediator for new feature. request by Boodin Yao
      setprop vendor.mtk.tunerlink.log 2
      setprop vendor.mtk.c2bwm.log 3
      setprop vendor.mtk.dispservice.mediator.info.log 1

      #Render //20211104 request by Adam-tt
      setprop vendor.mtk.mirender.debuglevel F0
      setprop vendor.mtk.mirender.debuginfo 41680000

      #TS/PS container log //20211118 requested by Neil Hsieh
      setprop vendor.mtk.ts.verbose.log 1
      setprop vendor.mtk.ps.verbose.log 1

      # Runtime sync mode enable
      setprop vendor.mtk.tpc.runtime.syncmode.enable 1

      #################################################
      #TODO
      echo "Enable Kernel log"
      echo "Enable VDEC LOG"
      INIT_BSP_VIDEO_VIDEO 10101

      ## end
      #echo "Already Enable Broadcast debug level, now begin caption log...."

      touch /data/tkui.print
      touch /data/mtk_dt_log
      sync
      echo "Please wait 10 seconds!!!"
      echo "Please wait 10 seconds!!!"
      sleep 10
      #echo "Please start to reproduce this issue......"
      #echo "Please start to reproduce this issue......"
    ;;
    "10102")
      echo "IN 10102"
      pkill -f logcat
      DUMP_INFO="${LOG_DIR}/apk_dump.log"
      ANR_LOG_PATH="/data/anr"
      SURFACE_DUMP_CMD="dumpsys SurfaceFlinger"
      TVINPUT_DUMP_CMD="dumpsys tv_input"
      INPUT_DUMP_CMD="dumpsys input"
      TV_DB_FILE="/data/data/com.android.providers.tv/databases/tv.db"
      PS_DUMP="ps -ef"
      PROP_DUMP="getprop"
      TV_MEM_DUMP="dumpsys meminfo com.mediatek.tv.oneworld.tvcenter"
      WIZARD_MEM_DUMP="dumpsys meminfo com.mediatek.tv.oneworld.tvcenter"
      echo "$PS_DUMP>>>>>>>>>>>>>>>>>>>>>>" > $DUMP_INFO
      $PS_DUMP >> $DUMP_INFO
      echo "$PROP_DUMP>>>>>>>>>>>>>>>>>>>" >> $DUMP_INFO
      $PROP_DUMP >> $DUMP_INFO
      echo "$SURFACE_DUMP_CMD>>>>>>>>>>>>>>>>>>>>>>" >> $DUMP_INFO
      $SURFACE_DUMP_CMD >> $DUMP_INFO
      echo "$TVINPUT_DUMP_CMD>>>>>>>>>>>>>>>>>>>>>>" >> $DUMP_INFO
      $TVINPUT_DUMP_CMD >> $DUMP_INFO
      echo "$INPUT_DUMP_CMD>>>>>>>>>>>>>>>>>>>>>>" >> $DUMP_INFO
      $INPUT_DUMP_CMD >> $DUMP_INFO
      echo "$TV_MEM_DUMP>>>>>>>>>>>>>>>>>>>>>>" >> $DUMP_INFO
      $TV_MEM_DUMP >> $DUMP_INFO
      echo "$WIZARD_MEM_DUMP>>>>>>>>>>>>>>>>>>>>>>" >> $DUMP_INFO
      $WIZARD_MEM_DUMP >> $DUMP_INFO
      cp -rf $ANR_LOG_PATH $LOG_DIR && cp $TV_DB_FILE $LOG_DIR
      rm /data/tkui.print
      rm /data/mtk_dt_log
      sync
      echo "Well done, Information collected! "
    ;;
    "10103")
      echo "check start... "
      sh $AUTOLOG_MODULES_DIR/platform/broadcast/check_broadcast_log.sh $LOGCAT_LOG $LOG_DIR
      echo "Well done, check ok! "
    ;;
    *)
      echo "SCENARIO_NUM='$SCENARIO_NUM' is not defined , please check or contact with Chiahsiu.Chuang"
      exit 1
      ;;
  esac
  echo "case done."
}


CLOSE_PLATFORM_BROADCAST_AUTO_LOG()
{
  echo -e "Close Platform APK APK AUTO LOG log Success!\n"
}


MAIN()
{
  echo "BROADCAST_LOG_VERSION: $BROADCAST_LOG_VERSION"

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

  INIT_PLATFORM_BROADCAST_AUTO_LOG $SCENARIO_NUM $LOG_DIR
  CLOSE_PLATFORM_BROADCAST_AUTO_LOG
}

if [  "$*" = "--source-only" ];then
  :
else
  MAIN $*
fi
