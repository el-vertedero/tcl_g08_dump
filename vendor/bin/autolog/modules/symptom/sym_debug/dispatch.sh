#!/usr/bin/env sh
#set -x
source "$AUTOLOG_HOME/utils/imports.sh"
ImportUtil "loggers.sh"
ImportUtil "colors.sh"
ImportUtil "sys.sh"
Import platform mm mm_aow_an.sh
Import bsp audio audio_aow_soxy.sh
Import platform bluetooth bluetooth_android.sh
Import platform broadcast broadcast_auto_log.sh
Import platform apk apk_auto_log.sh

#========================================================
#          Import modules functions you need
# if you want to call modules/bsp/audio/audio.sh
#                  =>  Import bsp audio audio.sh
#========================================================

INIT_DISPATCH()
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
  #echo "Initialize SYMPTOM.SYM_DEBUG.DEBUG log configs..."
  MODULE_DOMAIN="$1"
  MODULE_ARG="$2"
  #echo "SCENARIO=$SCENARIO"
  #echo "SYMPTOM=$SYMPTOM"

  #========================================================
  #                   Common part  (CAUTION!!)
  #  Commands defined here will been executed while user
  #  call this function EVERY TIME.
  #========================================================

  ### Enable logs by symptom
  ### You can setup kinds of symptom here
  ### symptom is
  case "$MODULE_DOMAIN" in
    "audio")
      ######################################################
      #              DOMAIN - audio
      #
      # Switch to different scenario
      #
      ######################################################
      echo "IN audio dispatch helper"

    ;;

    "display")
      ######################################################
      #              DOMAIN - display
      #
      # Switch to different scenario
      #
      ######################################################
      echo "IN display dispatch helper"

    ;;

    *)
      ######################################################
      #              ( * )  module domain not defined
      #
      ######################################################
      echo "${COLOR_RED}[AUTOLOG] MODULE_DOMAIN='$MODULE_DOMAIN' is not defined in dispatch.sh!${COLOR_REST}"
      exit 1
    ;;
  esac

#  set +e
  echo -e "${COLOR_GREEN}[AUTOLOG] Init dispatch successfully!${COLOR_REST}\n"
}

MAIN()
{
  PID=$$
  version="v1.0"
  #========================================================
  #                 Pre-process functions
  #                  (Don't remove this)
  #========================================================
  #echo "=========== (PID=$PID) from $0 ============="
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
  MODULE_DOMAIN=$SCENARIO_NUM
  MODULE_ARG=$3

  #echo "LOG_FP=$LOG_FP"
  #echo "ACT_LOG_FP=$ACT_LOG_FP"
  #echo "LOG_DIR=$LOG_DIR"
  #echo "LOG_DT=$LOG_DT"
  echo "${COLOR_YELLOW}[AUTOLOG] MODULE_DOMAIN=$MODULE_DOMAIN${COLOR_REST}"
  echo "${COLOR_YELLOW}[AUTOLOG] MODULE_ARG=$MODULE_ARG${COLOR_REST}"
  #echo "MODULE_ARG2=$MODULE_ARG2"
  #echo "MODULE_ARG3=$MODULE_ARG3"

  #========================================================
  #                   Main codes here
  # You can modify codes under this section
  #========================================================

  ### Import functions from other modules/scripts
  ### DO SOMETHING
  OpenCommandDebuger $INIT_HISTORY_FP
  INIT_DISPATCH $MODULE_DOMAIN $MODULE_ARG
  CloseCommandDebuger
  PrintCommandDebuger $INIT_HISTORY_FP

  #echo
  #echo "================================"
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
