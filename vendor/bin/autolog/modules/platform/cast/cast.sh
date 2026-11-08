#!/usr/bin/env sh
#set -x
. "$AUTOLOG_HOME/utils/imports.sh"
ImportUtil "loggers.sh"
ImportUtil "colors.sh"
ImportUtil "helpers.sh"
ImportUtil "sys.sh"

Import platform mm mm_fusion10_an.sh 
#========================================================
#          Import modules functions you need
# if you want to call modules/bsp/audio/audio.sh
#                  =>  Import bsp audio audio.sh
#========================================================
#Import bsp video common.sh
#Import bsp audio audio_demo.sh


INIT_PLATFORM_CAST_CAST()
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
  echo "Initialize PLATFORM.CAST.CAST log configs"
  SCENARIO_NUM="$1"
#  set -e

  #========================================================
  #                   Common part  (CAUTION!!)
  #  Commands defined here will been executed while user
  #  call this function EVERY TIME.
  #========================================================
#  echo debug_level=4 > /proc/utopia_mdb/audio

  ### Enable logs by scenario number
  ### You can setup kinds of scenario here
  ### Scenario Number is
  case "$SCENARIO_NUM" in
    "10101")
      ######################################################
      #              ( 10101 )  Scenario A - Cast fail
      #
      # include 
      # 1.cast fail
      # 2.cast success then auto disconnected
      # 3.others issue not include in Scenario B
      ######################################################
      echo "IN 10101, start catch logcat log"
      logcat -c; logcat -v time > /data/mycast.log &

    ;;
  #  "10102")
      ######################################################
      #              ( 10102 )  Scenario A -
      #
      # <Please describe this Scenario in this block>
      #
      ######################################################
   #   echo "IN 10102"

   #  INIT_BSP_AUDIO_AUDIO 10102
   # ;;
    "10201")
      ######################################################
      #              ( 10201 )  Scenario B
      #
      # Cast Success- "but 
      # 1.the video or audio not smoothly or
      # 2.black screen
      # 3.stuck on loading
      #...etc video or audio issue"
      ######################################################
      echo "IN 10201, need MM related logcat log for RD debug"
      INIT_PLATFORM_MM_MM 10001
      OPEN_MM_LOG
      logcat -c; logcat -v time > /data/mycast.log &
      #OPEN_MM_LOG
      #INIT_XXX_XXXXXX_XXXX 50301

    ;;
    *)
      ######################################################
      #              ( * )  Scenario not defined
      #
      ######################################################
      echo "SCENARIO_NUM='$SCENARIO_NUM' is not defined in cast.sh, please check or contact related RD"
      exit 1
    ;;
  esac

#  set +e
#dump mediashell info for checking process status and apk version
  echo -e "Init Platform CAST CAST log Success!\n"
}

OPEN_MM_LOG()
{
  setprop media.acodec.verbose.log 1
  setprop media.mediacodec.verbose.log 1
  setprop vendor.mstar.audioparser.log.level VERBOSE
}

CLOSE_MM_LOG()
{
  setprop media.acodec.verbose.log 0
  setprop media.mediacodec.verbose.log 0
  setprop vendor.mstar.audioparser.log.level DEBUG
}

CLOSE_PLATFORM_CAST_CAST()
{
  DUMP_CAST_INFO
  pkill logcat
  CLOSE_MM_LOG
#  set -e
  #CLOSE_BSP_AUDIO_AUDIO
  #CLOSE_BSP_VIDEO_COMMON
#  set +e
  echo -e "Close Platform CAST CAST log Success!\n"
}

Wait_finish()
{
    message="${COLOR_RED}After issue appears, press keyin any words to finishing recording!${COLOR_REST}"
    bug=$(prompt "$message")
    echo "$bug"
    sleep 1s
}

DUMP_CAST_INFO()
{
#check mediashell is killed by system or not
echo -e "DUMP_CAST_INFO start"
ps -AZ | grep "mediashell"
dumpsys package com.google.android.apps.mediashell | grep -e 'version'
echo -e "DUMP_CAST_INFO end"
#setprop media.mediacodec.dbg 1
#setprop media.framework.verbose.log 1
#setprop vendor.mstar.mstplayer.omx 1
#setprop vendor.mstar.avp.debug.demuxer 1
#setprop vendor.mstar.dip.log 1
#setprop vendor.media.acodec.verbose.log 1
}


question1()
{
  local OUTPUT_FP="$1"
  msg1="https://wiki.mediatek.inc/pages/viewpage.action?spaceKey=DTVMainPage&title=Fusion+OEM+Landing+Material+Alignment#FusionOEMLandingMaterialAlignment-ChromeCast"
  message="${COLOR_RED} $msg1 \n Please check wiki and not the common issues [Y/N]? ${COLOR_REST}"
  ### This will call prompt function from utils/helpers.sh
  ### prompt(message, log_file_path)
  ###   => Use read command to ask user questions, and record it into log_file_path
  bug=$(prompt "$message" "$OUTPUT_FP")
  echo "$bug"  # Return answer
}


question2()
{
  local OUTPUT_FP="$1"
  message="${COLOR_RED} Could you reproduce issue by another mobile(PC) [Y/N]? ${COLOR_REST}"
  bug=$(prompt "$message" "$OUTPUT_FP")
  echo "$bug" # Return answer
}

question3()
{
  local OUTPUT_FP="$1"
  message="${COLOR_RED} Could you reproduce issue by another wifi AP [Y/N]? ${COLOR_REST}"
  bug=$(prompt "$message" "$OUTPUT_FP")
  echo "$bug" # Return answer
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
  INIT_PLATFORM_CAST_CAST $SCENARIO_NUM
  Wait_finish

  CloseCommandDebuger
  PrintCommandDebuger $INIT_HISTORY_FP

  PrintCpuMemUsage "$ACT_LOG_FP"


  ################################
  ### Demo interactive flow
  echo "-------- Interactive demo --------"
  ### Questions flow control
  rst1=$(question1 $ACT_LOG_FP)
  rst2=$(question2 $ACT_LOG_FP)
  rst3=$(question3 $ACT_LOG_FP)

  ################################
  ### CLOSE LOGs
  PrintCpuMemUsage "$ACT_LOG_FP"
  CLOSE_PLATFORM_CAST_CAST

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

