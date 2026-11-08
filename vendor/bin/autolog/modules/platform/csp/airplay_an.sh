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
function dumpSystemStatus()
{
  echo -e "\nSystem status: ($1) ---------------------------------------------" >> $ACT_LOG_FP
  free >> $ACT_LOG_FP
  echo -e "" >> $ACT_LOG_FP

  if [ -f "/sys/kernel/debug/mali/gpu_memory" ]; then
    cat /sys/kernel/debug/mali/gpu_memory >> $ACT_LOG_FP
    echo -e "" >> $ACT_LOG_FP
  fi

  ps -A >> $ACT_LOG_FP
  echo -e "" >> $ACT_LOG_FP
}
#-------------------------------------------------------------------------------------------
INIT_PLATFORM_ANDROID_AIRPLAY()
{
  dumpSystemStatus "OPEN"
  #========================================================
  #                   Common part  (CAUTION!!)
  #  Commands defined here will been executed while user
  #  call this function EVERY TIME.
  #========================================================
  #========================================================
  #                  Scenario Definition
  # 00000XX : AIRPLAY General, Toggle log by each digit
  #========================================================

  echo "[AIRPLAY] ${AIRPLAY_SCENARIO_NUM}"
  case $AIRPLAY_SCENARIO_NUM in
    00001)
      ####################################################################
      # Scenario ( 00001 )
      # Get all log
      ####################################################################
      touch /data/tkui.print;
      echo 0 > /data/data/com.mediatek.airplaydaemon/cache/airplay/debug_level
      chmod 777 /data/data/com.mediatek.airplaydaemon/cache/airplay/debug_level 
      echo 3 > /data/data/com.mediatek.airplaydaemon/cache/airplay/hap_debug_level
      chmod 777 /data/data/com.mediatek.airplaydaemon/cache/airplay/hap_debug_level
      touch /data/data/com.mediatek.airplaydaemon/cache/airplay/hk_flow
      chmod 777 /data/data/com.mediatek.airplaydaemon/cache/airplay/hk_flow
      touch /data/data/com.mediatek.airplaydaemon/cache/airplay/hk_dbg
      chmod 777 /data/data/com.mediatek.airplaydaemon/cache/airplay/hk_dbg
      echo 0 > /data/data/com.mediatek.AirplayAPK/cache/dump_mediasample
      chmod 777 /data/data/com.mediatek.AirplayAPK/cache/dump_mediasample
      echo 0 > /data/data/com.mediatek.AirplayAPK/cache/dump_audio_sample
      chmod 777 /data/data/com.mediatek.AirplayAPK/cache/dump_audio_sample
      echo 0 > /data/data/com.mediatek.AirplayAPK/cache/dump_mediatime
      chmod 777 /data/data/com.mediatek.AirplayAPK/cache/dump_mediatime
      touch /data/data/com.mediatek.partner.airplay_sys/cache/debuglog
      ;;
    10001)
      ####################################################################
      # Scenario ( 10001 )
      # Get all log and dump video
      ####################################################################
      echo 0 > /data/data/com.mediatek.airplaydaemon/cache/airplay/debug_level
      chmod 777 /data/data/com.mediatek.airplaydaemon/cache/airplay/debug_level 
      echo 3 > /data/data/com.mediatek.airplaydaemon/cache/airplay/hap_debug_level
      chmod 777 /data/data/com.mediatek.airplaydaemon/cache/airplay/hap_debug_level
      touch /data/data/com.mediatek.airplaydaemon/cache/airplay/hk_flow
      chmod 777 /data/data/com.mediatek.airplaydaemon/cache/airplay/hk_flow
      touch /data/data/com.mediatek.airplaydaemon/cache/airplay/hk_dbg
      chmod 777 /data/data/com.mediatek.airplaydaemon/cache/airplay/hk_dbg
      echo 0 > /data/data/com.mediatek.AirplayAPK/cache/dump_mediasample
      chmod 777 /data/data/com.mediatek.AirplayAPK/cache/dump_mediasample
      echo 0 > /data/data/com.mediatek.AirplayAPK/cache/dump_audio_sample
      chmod 777 /data/data/com.mediatek.AirplayAPK/cache/dump_audio_sample
      echo 0 > /data/data/com.mediatek.AirplayAPK/cache/dump_mediatime
      chmod 777 /data/data/com.mediatek.AirplayAPK/cache/dump_mediatime
      echo 0 > /data/data/com.mediatek.AirplayAPK/cache/dump_video
      chmod 777 /data/data/com.mediatek.AirplayAPK/cache/dump_video
      ;;
    10002)
      ####################################################################
      # Scenario ( 10002 )
      # Get all log, dump video and disable low latency mode
      ####################################################################
      echo 0 > /data/data/com.mediatek.airplaydaemon/cache/airplay/debug_level
      chmod 777 /data/data/com.mediatek.airplaydaemon/cache/airplay/debug_level 
      echo 3 > /data/data/com.mediatek.airplaydaemon/cache/airplay/hap_debug_level
      chmod 777 /data/data/com.mediatek.airplaydaemon/cache/airplay/hap_debug_level
      touch /data/data/com.mediatek.airplaydaemon/cache/airplay/hk_flow
      chmod 777 /data/data/com.mediatek.airplaydaemon/cache/airplay/hk_flow
      touch /data/data/com.mediatek.airplaydaemon/cache/airplay/hk_dbg
      chmod 777 /data/data/com.mediatek.airplaydaemon/cache/airplay/hk_dbg
      echo 0 > /data/data/com.mediatek.AirplayAPK/cache/dump_mediasample
      chmod 777 /data/data/com.mediatek.AirplayAPK/cache/dump_mediasample
      echo 0 > /data/data/com.mediatek.AirplayAPK/cache/dump_audio_sample
      chmod 777 /data/data/com.mediatek.AirplayAPK/cache/dump_audio_sample
      echo 0 > /data/data/com.mediatek.AirplayAPK/cache/dump_mediatime
      chmod 777 /data/data/com.mediatek.AirplayAPK/cache/dump_mediatime
      echo 0 > /data/data/com.mediatek.AirplayAPK/cache/dump_video
      chmod 777 /data/data/com.mediatek.AirplayAPK/cache/dump_video
      echo 0 > /data/data/com.mediatek.AirplayAPK/cache/disable_low_latency
      chmod 777 /data/data/com.mediatek.AirplayAPK/cache/disable_low_latency
      ;;
    20001)
      ####################################################################
      # Scenario ( 20001 )
      # Get all log and dump audio
      ####################################################################
      echo 0 > /data/data/com.mediatek.airplaydaemon/cache/airplay/debug_level
      chmod 777 /data/data/com.mediatek.airplaydaemon/cache/airplay/debug_level 
      echo 4 > /data/data/com.mediatek.airplaydaemon/cache/airplay/hap_debug_level
      chmod 777 /data/data/com.mediatek.airplaydaemon/cache/airplay/hap_debug_level
      touch /data/data/com.mediatek.airplaydaemon/cache/airplay/hk_flow
      chmod 777 /data/data/com.mediatek.airplaydaemon/cache/airplay/hk_flow
      touch /data/data/com.mediatek.airplaydaemon/cache/airplay/hk_dbg
      chmod 777 /data/data/com.mediatek.airplaydaemon/cache/airplay/hk_dbg
      echo 0 > /data/data/com.mediatek.AirplayAPK/cache/dump_mediasample
      chmod 777 /data/data/com.mediatek.AirplayAPK/cache/dump_mediasample
      echo 0 > /data/data/com.mediatek.AirplayAPK/cache/dump_audio_sample
      chmod 777 /data/data/com.mediatek.AirplayAPK/cache/dump_audio_sample
      echo 0 > /data/data/com.mediatek.AirplayAPK/cache/dump_mediatime
      chmod 777 /data/data/com.mediatek.AirplayAPK/cache/dump_mediatime
      echo 0 > /data/data/com.mediatek.AirplayAPK/cache/dump_audio
      chmod 777 /data/data/com.mediatek.AirplayAPK/cache/dump_audio
      ;;
    *)
      ####################################################################
      # Scenario ( Unknown )
      ####################################################################
      echo -e "${COLOR_RED}[AIRPLAY] Unknown scenario type, please check it.${COLOR_REST}"
      exit 1
      ;;
  esac

  logcat -c
  logcat -v threadtime > $AIRPLAY_LOG_FP &
  airplay_logcat_pid=$!

  echo -e "${COLOR_YELLOW}Init AIRPLAY AutoLog Success!${COLOR_REST}"
}
#-------------------------------------------------------------------------------------------
CLOSE_PLATFORM_ANDROID_AIRPLAY()
{
  dumpSystemStatus "CLOSE"

  echo "[AIRPLAY] ${AIRPLAY_SCENARIO_NUM}"
  case $AIRPLAY_SCENARIO_NUM in
    00001)
      ####################################################################
      # Scenario ( 00001 )
      # Get all log
      ####################################################################
      rm /data/tkui.print;
      rm /data/data/com.mediatek.airplaydaemon/cache/airplay/debug_level
      rm /data/data/com.mediatek.airplaydaemon/cache/airplay/hap_debug_level
      rm /data/data/com.mediatek.airplaydaemon/cache/airplay/hk_flow
      rm /data/data/com.mediatek.airplaydaemon/cache/airplay/hk_dbg
      rm /data/data/com.mediatek.AirplayAPK/cache/dump_mediasample
      rm /data/data/com.mediatek.AirplayAPK/cache/dump_audio_sample
      rm /data/data/com.mediatek.AirplayAPK/cache/dump_mediatime
      rm /data/data/com.mediatek.partner.airplay_sys/cache/debuglog
      ;;
    10001)
      ####################################################################
      # Scenario ( 10001 )
      # Get all log and dump video
      ####################################################################
      rm /data/data/com.mediatek.airplaydaemon/cache/airplay/debug_level
      rm /data/data/com.mediatek.airplaydaemon/cache/airplay/hap_debug_level
      rm /data/data/com.mediatek.airplaydaemon/cache/airplay/hk_flow
      rm /data/data/com.mediatek.airplaydaemon/cache/airplay/hk_dbg
      rm /data/data/com.mediatek.AirplayAPK/cache/dump_mediasample
      rm /data/data/com.mediatek.AirplayAPK/cache/dump_audio_sample
      rm /data/data/com.mediatek.AirplayAPK/cache/dump_mediatime
      rm /data/data/com.mediatek.AirplayAPK/cache/dump_video
      ;;
    10002)
      ####################################################################
      # Scenario ( 10002 )
      # Get all log, dump video and disable low latency mode
      ####################################################################
      rm /data/data/com.mediatek.airplaydaemon/cache/airplay/debug_level
      rm > /data/data/com.mediatek.airplaydaemon/cache/airplay/hap_debug_level
      rm /data/data/com.mediatek.airplaydaemon/cache/airplay/hk_flow
      rm /data/data/com.mediatek.airplaydaemon/cache/airplay/hk_dbg
      rm /data/data/com.mediatek.AirplayAPK/cache/dump_mediasample
      rm /data/data/com.mediatek.AirplayAPK/cache/dump_audio_sample
      rm /data/data/com.mediatek.AirplayAPK/cache/dump_mediatime
      rm /data/data/com.mediatek.AirplayAPK/cache/dump_video
      rm /data/data/com.mediatek.AirplayAPK/cache/disable_low_latency
      ;;
    20001)
      ####################################################################
      # Scenario ( 20001 )
      # Get all log and dump audio
      ####################################################################
      rm /data/data/com.mediatek.airplaydaemon/cache/airplay/debug_level
      rm /data/data/com.mediatek.airplaydaemon/cache/airplay/hap_debug_level
      rm /data/data/com.mediatek.airplaydaemon/cache/airplay/hk_flow
      rm /data/data/com.mediatek.airplaydaemon/cache/airplay/hk_dbg
      rm /data/data/com.mediatek.AirplayAPK/cache/dump_mediasample
      rm /data/data/com.mediatek.AirplayAPK/cache/dump_audio_sample
      rm /data/data/com.mediatek.AirplayAPK/cache/dump_mediatime
      rm /data/data/com.mediatek.AirplayAPK/cache/dump_audio
      ;;
    *)
      ####################################################################
      # Scenario ( Unknown )
      ####################################################################
      echo -e "${COLOR_RED}[AIRPLAY] Unknown scenario type, please check it.${COLOR_REST}"
      exit 1
      ;;
  esac

  kill -9 $airplay_logcat_pid

  sync
  echo -e "${COLOR_YELLOW}Close AIRPLAY AutoLog Success!${COLOR_REST}"
}
#-------------------------------------------------------------------------------------------
MAIN()
{
  PID=$$
  version="v2.06.08"
  #========================================================
  #                 Pre-process functions
  #                  (Don't remove this)
  #========================================================
  echo -e "${COLOR_YELLOW}=========== (PID=$PID) from $0 =============\n${COLOR_REST}"
  source "$AUTOLOG_HOME/utils/preprocess.sh"

  #========================================================
  #                       Arguments
  # Defined in utils/preprocess.sh
  #   $LOG_FP     => output log file path
  #   $ACT_LOG_FP => interactive log output file path
  #   $LOG_DIR    => output directory of log
  #   $LOG_DT     => datetime from log file name
  #   $SCENARIO_NUM => scenario number
  #========================================================
  MODULE_ARG1=$1
  MODULE_ARG2=$2
  MODULE_ARG3=$3
  AIRPLAY_SCENARIO_NUM=$SCENARIO_NUM
  AIRPLAY_LOG_FP="$(GenLogPath "airplay_an.log")"

  echo -e "${COLOR_YELLOW}===============================${COLOR_REST}"
  echo -e "${COLOR_YELLOW}AirPlay(An) AutoLog-script START${COLOR_REST}"
  echo -e "${COLOR_YELLOW}Version: ${version}${COLOR_REST}"
  echo -e "${COLOR_YELLOW}Date: ${LOG_DT}${COLOR_REST}"
  echo -e "${COLOR_YELLOW}Path: ${LOG_DIR}${COLOR_REST}"
  echo -e "${COLOR_YELLOW}Reproducing Scenario: ${AIRPLAY_SCENARIO_NUM}${COLOR_REST}"
  echo -e "${COLOR_YELLOW}===============================\n${COLOR_REST}"

  #========================================================
  #                   Main codes here
  #       You can modify codes under this section
  #========================================================
  airplay_logcat_pid=0
  ### Log On
  INIT_PLATFORM_ANDROID_AIRPLAY
  ### Reproduce issue and finishing record
  message="${COLOR_RED}After issue appears, press ANY key and ENTER to finish logs recording!${COLOR_REST}"
  hint=$(prompt "$message")
  ### Log Off
  CLOSE_PLATFORM_ANDROID_AIRPLAY
  sleep 1s
  echo -e "${COLOR_YELLOW}===========================================================${COLOR_REST}"
  echo -e "${COLOR_YELLOW}AIRPLAY(An) AutoLog-script END${COLOR_REST}"
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
