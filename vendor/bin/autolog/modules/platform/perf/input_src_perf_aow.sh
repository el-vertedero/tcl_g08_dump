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



Wait_finish()
{
    message="${COLOR_RED}After issue appears, press keyin any words to finishing recording!${COLOR_REST}"
    echo $message
    read
}


INIT_INPUT_SOURCE_PERF()
{
    #echo "IN INIT_INPUT_SOURCE_PERF"
    echo "Enable input source perf debug log"

    PERF_LOG_FP="$LOG_DIR/$LOG_DT-input_src_perf.log"
    #echo "PERF_LOG_FP: $PERF_LOG_FP"

    setprop vendor.mtk.broadcast.log.level D
    setprop vendor.mtk.tvexoplayer.log all
    setprop vendor.mtk.c2.enable.comp.log 2
    setprop vendor.mtk.c2.enable.vdec.log 2
    setprop vendor.mtktv.c2.enable.vdec.log 2
    setprop vendor.mtk.vcodecvideo.log 2
    setprop vendor.mtk.vcodecvdecimpl.log 3
    setprop vendor.debug.tuner.service.log 1
    #DISPLINK
    setprop vendor.mtk.displink.log 1
    setprop vendor.mtk.displink.render.log 1
    setprop vendor.mtk.mi.vdec.log 64
    #RENDER
    setprop vendor.mtk.mirender.debuginfo 417E0000 #MEMC unmute
    setprop vendor.mtk.mirender.debuglevel F0 ##MEMC unmute
    #PQ
    setprop vendor.mtk.pqlink.log 1
    setprop vendor.mtk.pqhal.debuglevel 5
    setprop vendor.mtk.pqlink.performance.profile 1

    setprop vendor.mtktv.c2.enable.tpcvideo.log 2
    setprop vendor.mtktv.c2.enable.bm.log 2
    setprop vendor.mtk.displink.bm.profile 1
    #TPC
    setprop vendor.mtk.tpchwc.log 1
    setprop vendor.mtk.sharemem.debug.log 2
    #AUDIO
    setprop vendor.hal.audio.log.level VERBOSE

    setprop vendor.mtk.vsyncbridge.log 1
    #BWM
    setprop vendor.mtk.c2bwm.log 3
    setprop vendor.mtk.dispservice.mediator.info.log 1
    #MI_INUPT
    if [ "$ANDROID_VERSION" -ge 14 ]; then
      dumpsys vendor.mediatek.hardware.ExternIn.IExternIn/default --dbglevel 4
    else
      lshal debug vendor.mediatek.hardware.ExternIn@1.0::IExternIn/ExternIn --dbglevel 4
    fi
    setprop vendor.mtk.vcodechdmi.log.level 3
    echo 0 > /proc/sys/kernel/printk
    echo 6 > /sys/devices/platform/mtk_srccap0/mtk_dbg/log_level
    #ATV
    setprop vendor.mtk.vcodecatv.log.level 3
    #AV
    setprop vendor.mtk.vcodeccomposite.log.level 3
    #HDMI
    echo 6 > /sys/devices/platform/mtk_srccap0/mtk_dbg/hdmirx/log_level

    logcat -G 256M
    logcat -c
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
  INIT_INPUT_SOURCE_PERF $SCENARIO_NUM $MODULE_ARG1

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
  CLOSE_PLATFORM_MM_MM

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
