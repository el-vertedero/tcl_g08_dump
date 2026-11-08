#!/usr/bin/env sh
#set -x
source "$AUTOLOG_HOME/utils/imports.sh"
ImportUtil "loggers.sh"
ImportUtil "colors.sh"
ImportUtil "sys.sh"

#========================================================
#          Import modules functions you need
# if you want to call modules/bsp/audio/audio.sh
#                  =>  Import bsp audio audio.sh
#========================================================
#Import bsp video common.sh
Import bsp audio audio.sh
Import bsp disp disp.sh
Import bsp video video.sh
Import bsp peripheral peripheral.sh
Import bsp hdmirx hdmirx.sh

COMMON_VERSION=1.0

INIT_BSP_COMMON_COMMON()
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
  echo "Initialize Common common.sh log configs..."
  SCENARIO_NUM="$1"
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
    "90001")
      ######################################################
      #              ( 10201 )  Scenario B
      #
      # <Please describe this Scenario in this block>
      #
      ######################################################
      echo "IN common 90001"
      INIT_BSP_AUDIO_COMMON 90001
      INIT_BSP_VIDEO_VIDEO 90001
      INIT_BSP_DISP_DISP 90001
      INIT_BSP_PERIPHERAL_PERIPHERAL 90001
      INIT_BSP_HDMIRX_HDMIINFO 90001
    ;;
    *)
      ######################################################
      #              ( * )  Scenario not defined
      #
      ######################################################
      echo "SCENARIO_NUM='$SCENARIO_NUM' is not defined in mm.sh, please check or contact related RD"
      exit 1
    ;;
  esac

#  set +e
  echo -e "Init Bsp common common.sh log Success!\n"
}


CLOSE_BSP_COMMON_COMMON()
{
#  set -e
  CLOSE_BSP_PERIPHERAL_PERIPHERAL
  CLOSE_BSP_AUDIO_COMMON 90001
  CLOSE_BSP_VIDEO_VIDEO
  CLOSE_BSP_DISP_DISP
  CLOSE_BSP_HDMIRX_HDMIINFO
#  set +e
  echo -e "Close Bsp Common Common.sh log Success!\n"
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
  INIT_BSP_COMMON_COMMON $SCENARIO_NUM
  CloseCommandDebuger
  PrintCommandDebuger $INIT_HISTORY_FP

  ################################
  ### CLOSE LOGs
  ################################
  CLOSE_BSP_COMMON_COMMON

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


