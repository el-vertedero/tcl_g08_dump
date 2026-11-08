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

INIT_PLATFORM_SECURITY_PLAYREADY()
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
  echo "Initialize PLATFORM.SECURITY.PLAYREADY log configs..."
  SCENARIO_NUM="$1"
#  set -e

  #========================================================
  #                   Common part  (CAUTION!!)
  #  Commands defined here will been executed while user
  #  call this function EVERY TIME.
  #========================================================
  PLAYREADY_LOG_FP="$LOG_DIR/$LOG_DT-platform_security_playready.sh_${SCENARIO_NUM}.log"
  echo "PLAYREADY_LOG_FP: $PLAYREADY_LOG_FP"

  case "$AUTOLOG_PLATFORM" in
    "linux")
        #############################################################
        #              ( linux )  Linux platfrom
        #############################################################
        echo "[PLAYREADY] Linux"
        PLAYREADY_LOG_INI_PATH="/tmp"
    ;;
    "android")
        #############################################################
        #              ( android )  Android platfrom
        #############################################################
        echo "[PLAYREADY] Android"
        PLAYREADY_LOG_INI_PATH="/mnt/vendor/tmp"
    ;;
    *)
        ######################################################
        #              ( * )  platfrom not defined
        #
        ######################################################
        echo "[PLAYREADY] AUTOLOG_PLATFORM='$AUTOLOG_PLATFORM' is not defined in autolog.sh"
        exit 1
    ;;
  esac


  ### Enable logs by scenario number
  ### You can setup kinds of scenario here
  ### Scenario Number is
  case "$SCENARIO_NUM" in
    "10101")
      #############################################################
      #              ( 10101 )  Scenario A - enable normal log
      #
      # Enable playready normal log, should kill playready hidl service
      #
      #############################################################
      echo "IN PLAYREADY 10101"

      mkdir -p $PLAYREADY_LOG_INI_PATH
      echo touch $PLAYREADY_LOG_INI_PATH/playready.ini
      touch $PLAYREADY_LOG_INI_PATH/playready.ini
      chmod o+rx $PLAYREADY_LOG_INI_PATH/playready.ini
      cat > $PLAYREADY_LOG_INI_PATH/playready.ini << EOF

ca_log_level=4
ta_log_level=4
parse_ca_command=0
parse_ta_command=0
ca_back_trace=0
aes_sw_mode=0
time_from_linux=0
EOF
      sync
      if [ "$AUTOLOG_PLATFORM" = "android" ]; then
        chcon -R u:object_r:vendor_media_data_file:s0 $PLAYREADY_LOG_INI_PATH/playready.ini
        logcat -c
        kill `ps -A | grep playready | grep service | awk '{print $2}'`

        logcat -v threadtime > $PLAYREADY_LOG_FP&
      fi

      INIT_BSP_OPTEE_OPTEE 10002
    ;;
    "10102")
      #############################################################
      #              ( 10102 )  Scenario A - enable more tee log
      #
      # Enable more log for tee issue, should kill playready hidl service
      #
      #############################################################
      echo "IN PLAYREADY 10102"

      mkdir -p $PLAYREADY_LOG_INI_PATH
      echo touch $PLAYREADY_LOG_INI_PATH/playready.ini
      touch $PLAYREADY_LOG_INI_PATH/playready.ini
      chmod o+rx $PLAYREADY_LOG_INI_PATH/playready.ini
      cat > $PLAYREADY_LOG_INI_PATH/playready.ini << EOF

ca_log_level=7
ta_log_level=7
parse_ca_command=0
parse_ta_command=0
ca_back_trace=0
aes_sw_mode=0
time_from_linux=0
EOF
      sync
      if [ "$AUTOLOG_PLATFORM" = "android" ]; then
        chcon -R u:object_r:vendor_media_data_file:s0 $PLAYREADY_LOG_INI_PATH/playready.ini
        logcat -c
        kill `ps -A | grep playready | grep service | awk '{print $2}'`

        logcat -v threadtime > $PLAYREADY_LOG_FP&
      fi

      INIT_BSP_OPTEE_OPTEE 10504
    ;;
    "10201")
      ###################################################################
      #              ( 10201 )  Scenario A - reset to default log level
      #
      # reset to default playready log level, should kill playready hidl service
      #
      ###################################################################
      echo "IN PLAYREADY 10201"

      rm -f $PLAYREADY_LOG_INI_PATH/playready.ini
      sync
      if [ "$AUTOLOG_PLATFORM" = "android" ]; then
        logcat -c
        kill `ps -A | grep playready | grep service | awk '{print $2}'`

        logcat -v threadtime > $PLAYREADY_LOG_FP&
      fi
    ;;
    *)
      ######################################################
      #              ( * )  Scenario not defined
      #
      ######################################################
      echo "SCENARIO_NUM='$SCENARIO_NUM' is not defined in playready.sh, please check or contact related RD"
      exit 1
    ;;
  esac

  echo -e "Init Platform Security playready log Success!\n"
}

CLOSE_PLATFORM_SECURITY_PLAYREADY()
{
  if [ "$AUTOLOG_PLATFORM" = "android" ]; then
    kill `pidof logcat`
  fi

#  set -e
  CLOSE_BSP_OPTEE_OPTEE
#  set +e
  echo -e "Close Platform Security playready log Success!\n"
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
  INIT_PLATFORM_SECURITY_PLAYREADY $SCENARIO_NUM
  CloseCommandDebuger
  PrintCommandDebuger $INIT_HISTORY_FP

  #PrintCpuMemUsage "$ACT_LOG_FP"

  #--------------------------------------
  #Reproduce issue and finishing record.
  echo -e "!!! After playready issue appears, press [enter] to finishing recording !!!"
  read "abc"

  ################################
  ### CLOSE LOGs
  #PrintCpuMemUsage "$ACT_LOG_FP"
  CLOSE_PLATFORM_SECURITY_PLAYREADY

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
