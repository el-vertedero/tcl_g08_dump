#!/usr/bin/env sh
#set -x
APK_LOG_VERSION="1.0.0"
APK_VERSION="v1.0.0"


INIT_PLATFORM_APK_APK_AUTO_LOG ()
{

  SCENARIO_NUM="$1"
  LOG_DIR="$2"

  echo "USE case :$LOG_DIR"

  LOGCAT_LOG="${LOG_DIR}/apk_logcat.log"
  DUMP_INFO="${LOG_DIR}/apk_dump.log"
  ANR_LOG_PATH="/data/anr"
  SURFACE_DUMP_CMD="dumpsys SurfaceFlinger"
  TVINPUT_DUMP_CMD="dumpsys tv_input"
  INPUT_DUMP_CMD="dumpsys input"
  TV_DB_FILE="/data/data/com.android.providers.tv/databases/tv.db"
  AGENT_DB_FILE="/data/user_de/0/com.mediatek.tv.agent/"
  PS_DUMP="ps -ef"
  PROP_DUMP="getprop"
  TV_MEM_DUMP="dumpsys meminfo com.mediatek.tv.oneworld.tvcenter"
  WIZARD_MEM_DUMP="dumpsys meminfo com.mediatek.tv.oneworld.wizardkt"

#   set -e

  case "$SCENARIO_NUM" in
    "10101")
      echo "IN 10101"
      echo "Prepare Enable APK debug level, Platform will be reboot. please waiting..."
      #su

      # TIS layer
      setprop persist.vendor.mtk.broadcast.log.level D
      setprop vendor.mtk.tvexoplayer.log all

      # input source c2 hal
      setprop vendor.mtk.c2.enable.comp.log 2
      setprop vendor.mtk.c2.enable.vdec.log 2
      setprop vendor.mtktv.c2.enable.vdec.log 2
      setprop vendor.mtktv.c2.enable.bm.log 2

      # input source vdec sub-hal
      setprop vendor.mtk.vcodechdmi.log.level 3
      setprop vendor.mtk.vcodecatv.log.level 3
      setprop vendor.mtk.vcodeccomposite.log.level 3
      setprop vendor.mtk.vcodeccomponent.log.level 3

      # tunerlink for dtv passthrough mode, mediator for new feature. request by Boodin Yao
      setprop vendor.mtk.tunerlink.log 2
      setprop vendor.mtk.c2bwm.log 3
      setprop vendor.mtk.dispservice.mediator.info.log 1

      # pqhal
      setprop vendor.mtk.pqhal.debuglevel 5
      setprop vendor.mtk.mipq.debuglevel 40

      logcat -c
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
    "10102")
      echo "IN 10102"
      echo "Already Enable APK debug level, now begin caption log...."
      #su;
      setprop vendor.mtk.tvexoplayer.log all
      logcat -G 60M
      logcat > $LOGCAT_LOG &
      echo "please begin reproduce this issue."
    ;;
    "10103")
      echo "IN 10103"

      pkill -f logcat
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
      cp -rf $ANR_LOG_PATH $LOG_DIR && cp $TV_DB_FILE $LOG_DIR && cp -rf $AGENT_DB_FILE $LOG_DIR
      rm /data/tkui.print
      rm /data/mtk_dt_log
      sync
      echo "Well done, Information collected! "
    ;;
    *)
      echo "SCENARIO_NUM='$SCENARIO_NUM' is not defined , please check or contact with Tan.Wang"
      exit 1
      ;;
  esac
  echo "case done."
}


CLOSE_PLATFORM_APK_APK_AUTO_LOG()
{
  echo -e "Close Platform APK APK AUTO LOG log Success!\n"
}


MAIN()
{
  echo "APK_LOG_VERSION: $APK_LOG_VERSION"
  echo "APK_VERSION: $APK_VERSION"

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

  INIT_PLATFORM_APK_APK_AUTO_LOG $SCENARIO_NUM $LOG_DIR
  CLOSE_PLATFORM_APK_APK_AUTO_LOG
}

if [  "$*" = "--source-only" ];then
  :
else
  MAIN $*
fi
