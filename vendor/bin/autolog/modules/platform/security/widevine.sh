#!/usr/bin/env sh
#set -x
. "$AUTOLOG_HOME/utils/imports.sh"
ImportUtil "loggers.sh"
ImportUtil "colors.sh"
ImportUtil "sys.sh"

#========================================================
#          Import modules functions you need
# if you want to call modules/bsp/audio/audio.sh
#                  =>  Import bsp audio audio.sh
#========================================================
Import bsp optee optee.sh

INIT_PLATFORM_SECURITY_WIDEVINE()
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
  echo "Initialize PLATFORM.SECURITY.WIDEVINE log configs..."
  SCENARIO_NUM="$1"
#  set -e

  #========================================================
  #                   Common part  (CAUTION!!)
  #  Commands defined here will been executed while user
  #  call this function EVERY TIME.
  #========================================================

  ### Enable logs by scenario number
  ### You can setup kinds of scenario here
  ### Scenario Number is
  case "$SCENARIO_NUM" in
    "10101")
      #############################################################
      #              ( 10101 )  Scenario A - enable normal log
      #
      # Enable widevine normal log, should reboot
      #
      #############################################################
      echo "IN WIDEVINE 10101"

      # remount /config ?
      mkdir -p /config/drm
      cat > /config/drm/drmlog.ini << EOF
WIDEVINE_DRM_LOG_LEVEL=4
WIDEVINE_DRM_LOG_ENABLE_ALL_FEATURE=1
WIDEVINE_DRMCOMMON_DRM_PERFORMANCE_PROFILING=0
WIDEVINE_DRMCOMMON_DRM_TRACER=0
WIDEVINE_LICENSE_DURATION=0
EOF
      sync
      touch /config/widevine/drmlog_widevine.ini
    ;;
    "10102")
      #############################################################
      #              ( 10102 )  Scenario A - enable tracer log
      #
      # Enable tracer log for crash issue, should reboot
      #
      #############################################################
      echo "IN WIDEVINE 10102"

      # remount /config ?
      mkdir -p /config/drm
      cat > /config/drm/drmlog.ini << EOF
WIDEVINE_DRM_LOG_LEVEL=5
WIDEVINE_DRM_LOG_ENABLE_ALL_FEATURE=0
WIDEVINE_DRMCOMMON_DRM_TRACER=1
EOF
      sync
      touch /config/widevine/drmlog_widevine.ini
    ;;
    "10103")
      #############################################################
      #              ( 10103 )  Scenario A - disable all log
      #
      # disable all widevine log, should reboot
      #
      #############################################################
      echo "IN WIDEVINE 10103"

      # remount /config ?
      mkdir -p /config/drm
      cat > /config/drm/drmlog.ini << EOF
WIDEVINE_DRM_LOG_LEVEL=7
EOF
      sync
      touch /config/widevine/drmlog_widevine.ini
    ;;
    "10201")
      ###################################################################
      #              ( 10201 )  Scenario A - reset to default log level
      #
      # reset to default widevine log level, should reboot
      #
      ###################################################################
      echo "IN WIDEVINE 10201"
      cat > /config/drm/drmlog.ini << EOF
WIDEVINE_DRM_LOG_LEVEL=5
WIDEVINE_DRM_LOG_ENABLE_ALL_FEATURE=1
WIDEVINE_DRMCOMMON_DRM_PERFORMANCE_PROFILING=0
WIDEVINE_DRMCOMMON_DRM_TRACER=0
EOF
      sync
      touch /config/widevine/drmlog_widevine.ini

      rm -rf /config/drm/drmlog.ini
      sync

    ;;
    "10301")
      ######################################################
      #              ( 10301 )  Scenario A - general log
      #
      #
      #
      ######################################################
      echo "IN WIDEVINE 10301"
      INIT_BSP_OPTEE_OPTEE 10504
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

  echo -e "Init Platform Security widevine log Success!\n"
}

CLOSE_PLATFORM_SECURITY_WIDEVINE()
{
#  set -e
  CLOSE_BSP_OPTEE_OPTEE
#  set +e
  echo -e "Close Platform Security widevine log Success!\n"
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
  INIT_PLATFORM_SECURITY_WIDEVINE $SCENARIO_NUM
  CloseCommandDebuger
  PrintCommandDebuger $INIT_HISTORY_FP

  #PrintCpuMemUsage "$ACT_LOG_FP"

  #--------------------------------------
  #Reproduce issue and finishing record.
  echo -e "!!! After widevine issue appears, press [enter] to finishing recording !!!"
  read "abc"

  ################################
  ### CLOSE LOGs
  #PrintCpuMemUsage "$ACT_LOG_FP"
  CLOSE_PLATFORM_SECURITY_WIDEVINE

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
