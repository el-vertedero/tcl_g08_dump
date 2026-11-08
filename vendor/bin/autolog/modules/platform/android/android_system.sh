#!/usr/bin/env sh
#set -x
#-------------------------------------------------------------------------------------------
. "$AUTOLOG_HOME/utils/imports.sh"
ImportUtil "loggers.sh"
ImportUtil "colors.sh"
ImportUtil "sys.sh"

#========================================================
#          Import modules functions you need
# if you want to call modules/bsp/audio/audio.sh
#                  =>  Import bsp audio audio.sh
#========================================================

#========================================================
#                   Default values
#========================================================

#========================================================
#          Autolog Framework Implementation
#========================================================
#-------------------------------------------------------------------------------------------
INIT_PLATFORM_ANDROID_SYSTEM()
{
  #========================================================
  #                   Common part  (CAUTION!!)
  #  Commands defined here will been executed while user
  #  call this function EVERY TIME.
  #========================================================

  #========================================================
  #                  Scenario Definition
  # 000XX : GTVS General
  #========================================================
  case $GTVS_SCENARIO_NUM in
    00001)
      ####################################################################
      # Scenario ( 00001 )
      # we have nothing to enable here
      #################################################################### 
    ;;
    10401)	
      ####################################################################
      # Scenario ( 10401 )
      # Trigger logcat
      #################################################################### 
      echo "IN 10101"
        logcat -c
        logcat -v threadtime
    ;;
  esac
  echo -e "${COLOR_YELLOW}Init GTVS Auto Log Success!${COLOR_REST}"
}

#-------------------------------------------------------------------------------------------
CLOSE_PLATFORM_ANDROID_SYSTEM()
{
  #========================================================
  #                  Scenario Definition
  # 000XX : GTVS General
  #========================================================
  case $GTVS_SCENARIO_NUM in
    00001)
      ####################################################################
      # Scenario ( 00001 )
      # General GTVS logs mainly bugreport
      ####################################################################
      echo "IN 00001"
      echo "Generating bugreport please wait patiently.."
      rm -rf /data/user_de/0/com.android.shell/files/bugreports/
      bugreportz -p
      cp -r /data/user_de/0/com.android.shell/files/bugreports $LOG_DIR/$LOG_DT-bugreports

  esac
  echo -e "${COLOR_YELLOW}Init GTVS Auto Log Success!${COLOR_REST}"
}

#-------------------------------------------------------------------------------------------
MAIN()
{
  PID=$$
  BASE_ON_AUTO_LOG_VERSION="1.0"
  version="v${BASE_ON_AUTO_LOG_VERSION}_20210618"

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
  #========================================================
  GTVS_SCENARIO_NUM=$SCENARIO_NUM
  MODULE_ARG1=$1
  MODULE_ARG2=$2
  MODULE_ARG3=$3

  echo -e "${COLOR_YELLOW}===========================================================${COLOR_REST}"
  echo -e "${COLOR_YELLOW}GTVS Auto Log START${COLOR_REST}"
  echo -e "${COLOR_YELLOW}Version: ${version}${COLOR_REST}"
  echo -e "${COLOR_YELLOW}Date: ${LOG_DT}${COLOR_REST}"
  echo -e "${COLOR_YELLOW}Path: ${LOG_DIR}${COLOR_REST}"
  echo -e "${COLOR_YELLOW}Reproducing Scenario: ${GTVS_SCENARIO_NUM}${COLOR_REST}"
  echo -e "${COLOR_YELLOW}===========================================================${COLOR_REST}"

  #========================================================
  #                   Main codes here
  #       You can modify codes under this section
  #========================================================

  ### Log On
  INIT_PLATFORM_ANDROID_SYSTEM
  ### Reproduce issue and finishing record
  ### Log Off
  CLOSE_PLATFORM_ANDROID_SYSTEM
  sleep 1s
  echo -e "${COLOR_YELLOW}===========================================================${COLOR_REST}"
  echo -e "${COLOR_YELLOW}GTVS Auto Log END${COLOR_REST}"
  echo -e "${COLOR_YELLOW}===========================================================${COLOR_REST}"
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

