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

INIT_PLATFORM_NETWORK_WIFI_ANDROID()
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
  echo "Initialize PLATFORM.NETWORK.WIFI_ANDROID log configs..."
  SCENARIO_NUM="$1"
#  set -e

  #========================================================
  #                   Common part  (CAUTION!!)
  #  Commands defined here will been executed while user
  #  call this function EVERY TIME.
  #========================================================
#  echo 7 > /proc/sys/kernel/printk

  ### Enable logs by scenario number
  ### You can setup kinds of scenario here
  ### Scenario Number is
  case "$SCENARIO_NUM" in
    "10101")
      ######################################################
      #              ( 10101 )  Scenario A - Catch logcat log
      #
      # <Please describe this Scenario in this block>
      # Catch logcat log for CI+1.4 test case fail after TV rebooting => DHCP server IP get 0.0.0.0
      ######################################################
      echo "IN 10101"
      echo "${COLOR_RED}<<<<Start catching logcat log...>>>>${COLOR_REST}"
      WIFI_LOGCAT_LOG_FP="$(GenLogPath "logcat.log")"
      echo "${COLOR_RED}WIFI_LOGCAT_LOG_FP = $WIFI_LOGCAT_LOG_FP${COLOR_REST}"
      cmd wifi set-verbose-logging enabled
      logcat -b main -b kernel -f $WIFI_LOGCAT_LOG_FP &
      echo "${COLOR_RED}<<<<now please reproduce your issues...>>>>${COLOR_REST}"
    ;;
    "10102")
      ######################################################
      #              ( 10102 )  Scenario A - Print debug command result
      #
      # <Please describe this Scenario in this block>
      # Catch debug command result for CI+1.4 test case fail => DHCP server IP get 0.0.0.0
      ######################################################
      echo "IN 10102"
	  echo "now kill logcat process"
	  killall logcat
	  echo "now start dumpsys log"
      echo "${COLOR_RED}<<<<Start printing debug command result...>>>>${COLOR_REST}"
      echo "${COLOR_RED}<<<<Please copy the debug command result and save to a file for RD debug...>>>>${COLOR_REST}"

      echo "-----------------------------------------------"
      echo "dumpsys connectivity =>"
      WIFI_CONNECTIVITY_LOG_FP="$(GenLogPath "dumpconnectivity.log")"
	  echo "${COLOR_RED}WIFI_CONNECTIVITY_LOG_FP = $WIFI_CONNECTIVITY_LOG_FP${COLOR_REST}"
      dumpsys connectivity > $WIFI_CONNECTIVITY_LOG_FP
      echo "-----------------------------------------------"
      echo "dumpsys wifi =>"
      WIFI_DUMP_LOG_FP="$(GenLogPath "dumpwifi.log")"
	  echo "${COLOR_RED}WIFI_DUMP_LOG_FP = $WIFI_DUMP_LOG_FP${COLOR_REST}"
      dumpsys wifi > $WIFI_DUMP_LOG_FP
      echo "-----------------------------------------------"
      echo "dumpsys alarm =>"
      WIFI_ALARM_LOG_FP="$(GenLogPath "dumpalarm.log")"
	  echo "${COLOR_RED}WIFI_ALARM_LOG_FP = $WIFI_ALARM_LOG_FP${COLOR_REST}"
      dumpsys alarm > $WIFI_ALARM_LOG_FP

      echo "${COLOR_RED}<<<<End printing debug command result...>>>>${COLOR_REST}"
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
  echo -e "Init Platform NETWORK WIFi_ANDROID log Success!\n"
}


CLOSE_PLATFORM_NETWORK_WIFI_ANDROID()
{
#  set -e
#  disable debug level for kernel log
#  echo 0 > /proc/sys/kernel/printk || echo -e "${COLOR_RED}Change printk error! Permission Denied${COLOR_REST}"
#  set +e
  echo -e "Close Platform NETWORK WIFI_ANDROID log Success!\n"
}


question1()
{
  local OUTPUT_FP="$1"
  message="${COLOR_RED} Please describe your question here [Y/N]? ${COLOR_REST}"
  ### This will call prompt function from utils/loggers.sh
  ### prompt(message, log_file_path)
  ###   => Use read command to ask user questions, and record it into log_file_path
  bug=$(prompt "$message" "$OUTPUT_FP")
  echo "$bug"  # Return answer
}


question2()
{
  local OUTPUT_FP="$1"
  message="${COLOR_RED} You can ask more when answer from question1 is 'y' [Y/N]? ${COLOR_REST}"
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
  INIT_PLATFORM_NETWORK_WIFI_ANDROID $SCENARIO_NUM
  CloseCommandDebuger
  PrintCommandDebuger $INIT_HISTORY_FP

  PrintCpuMemUsage "$ACT_LOG_FP"


  ################################
  ### Demo interactive flow
#  echo "-------- Interactive demo --------"
  ### Questions flow control
#  rst1=$(question1 $ACT_LOG_FP)
#  if [ "$rst1" = "Y" ] || [ "$rst1" = "y" ]; then
#    rst2=$(question2 $ACT_LOG_FP)
#  fi

  ################################
  ### CLOSE LOGs
  PrintCpuMemUsage "$ACT_LOG_FP"
  CLOSE_PLATFORM_NETWORK_WIFI_ANDROID

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
