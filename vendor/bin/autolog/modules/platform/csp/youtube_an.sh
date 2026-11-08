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
INIT_PLATFORM_ANDROID_YOUTUBE()
{
  dumpSystemStatus "OPEN"
  #========================================================
  #                   Common part  (CAUTION!!)
  #  Commands defined here will been executed while user
  #  call this function EVERY TIME.
  #========================================================
  #========================================================
  #                  Scenario Definition
  # 000XX : YOUTUBE General
  #========================================================
  case $YOUTUBE_SCENARIO_NUM in
    00001)
      ####################################################################
      # Scenario ( 00001 )
      # General YOUTUBE logs
      ####################################################################
      echo "[YOUTUBE] 00001 IN : General YOUTUBE logs"
      logcat -c
      logcat -v threadtime > $YT_LOG_FP &
      yt_logcat_pid=$!
      ;;
    00002)
      ####################################################################
      # Scenario ( 00002 )
      # Screencap & YOUTUBE logs
      ####################################################################
      echo "[YOUTUBE] 00002 IN : Screencap & YOUTUBE logs"
      logcat -c
      logcat -v threadtime > $YT_LOG_FP &
      yt_logcat_pid=$!
      ;;
    00003)
      ####################################################################
      # Scenario ( 00003 )
      # Screencap
      ####################################################################
      ;;
    00004)
      ####################################################################
      # Scenario ( 00004 )
      # Screenrecord
      ####################################################################
      ;;
    10001)
      ####################################################################
      # Scenario ( 10001 )
      # General Audio logs
      ####################################################################
      echo "[YOUTUBE] 10001 IN : Audio dump & logs"
      logcat -G 64M
      setprop log.tag.APM_AudioPolicyManager V
      setprop vendor.mstar.audio.log.level VERBOSE
      setprop vendor.mstar.audioparser.log.level VERBOSE
      setprop vendor.mstar.omx.log 1
      setprop vendor.ms.adec.log_on 99
      settings put system sound_effects_enabled 0
      setenforce 0
      chmod 777 /data
      setprop vendor.mstar.audio.dump.hal 1
      logcat -v threadtime > $YT_LOG_FP &
      yt_logcat_pid=$!
      ;;
    *)
      ####################################################################
      # Scenario ( Unknown )
      # General logs
      ####################################################################
      echo -e "${COLOR_RED}[YOUTUBE] Unknown scenario type, please check it.${COLOR_REST}"
      exit 1
      ;;
  esac
  echo -e "${COLOR_YELLOW}Init YOUTUBE AutoLog Success!${COLOR_REST}"
}
#-------------------------------------------------------------------------------------------
CLOSE_PLATFORM_ANDROID_YOUTUBE()
{
  dumpSystemStatus "CLOSE"
  #========================================================
  #                  Scenario Definition
  # 000XX : YOUTUBE General
  #========================================================
  case $YOUTUBE_SCENARIO_NUM in
    00001)
      ####################################################################
      # Scenario ( 00001 )
      # General YOUTUBE logs
      ####################################################################
      echo "[YOUTUBE] 00001 OUT"
      kill -9 $yt_logcat_pid
      ;;
    00002)
      ####################################################################
      # Scenario ( 00002 )
      # Screencap & YOUTUBE logs
      ####################################################################
      echo "[YOUTUBE] 00002 OUT"
      kill -9 $yt_logcat_pid
      osd_FP="$(GenLogPath "youtube_ui01.png")"
      screencap -p $osd_FP
      osd_FP="$(GenLogPath "youtube_ui02.png")"
      screencap -p $osd_FP
      osd_FP="$(GenLogPath "youtube_ui03.png")"
      screencap -p $osd_FP
      ;;
    00003)
      ####################################################################
      # Scenario ( 00003 )
      # Screencap
      ####################################################################
      echo "[YOUTUBE] 00003 IN : Screencap"
      osd_FP="$(GenLogPath "youtube_ui01.png")"
      screencap -p $osd_FP
      osd_FP="$(GenLogPath "youtube_ui02.png")"
      screencap -p $osd_FP
      osd_FP="$(GenLogPath "youtube_ui03.png")"
      screencap -p $osd_FP
      ;;
    00004)
      ####################################################################
      # Scenario ( 00004 )
      # Screenrecord
      ####################################################################
      echo "[YOUTUBE] 00004 IN : Screenrecord"
      osd_FP="$(GenLogPath "youtube_ui.mp4")"
      rm -rf $osd_FP
      screenrecord --size 1920x1080 --bit-rate 40000000 --time-limit 30 $osd_FP
      ;;
    10001)
      ####################################################################
      # Scenario ( 10001 )
      # General Audio logs
      ####################################################################
      echo "[YOUTUBE] 10001 OUT"
      dump_ap_FP="$(GenLogPath "dump_ap.txt")"
      dump_af_FP="$(GenLogPath "dump_af.txt")"
      dump_audio_FP="$(GenLogPath "dump_audio.txt")"
      dumpsys media.audio_policy > $dump_ap_FP
      dumpsys media.audio_flinger > $dump_af_FP
      dumpsys audio > $dump_audio_FP
      settings put system sound_effects_enabled 1
      kill -9 $yt_logcat_pid
      setenforce 1
      ;;
  esac
  sync
  echo -e "${COLOR_YELLOW}Close YOUTUBE AutoLog Success!${COLOR_REST}"
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
  YOUTUBE_SCENARIO_NUM=$SCENARIO_NUM
  YT_LOG_FP="$(GenLogPath "YouTube_An.log")"

  echo -e "${COLOR_YELLOW}===============================${COLOR_REST}"
  echo -e "${COLOR_YELLOW}YouTube(An) AutoLog-script START${COLOR_REST}"
  echo -e "${COLOR_YELLOW}Version: ${version}${COLOR_REST}"
  echo -e "${COLOR_YELLOW}Date: ${LOG_DT}${COLOR_REST}"
  echo -e "${COLOR_YELLOW}Path: ${LOG_DIR}${COLOR_REST}"
  echo -e "${COLOR_YELLOW}Reproducing Scenario: ${YOUTUBE_SCENARIO_NUM}${COLOR_REST}"
  echo -e "${COLOR_YELLOW}===============================\n${COLOR_REST}"

  #========================================================
  #                   Main codes here
  #       You can modify codes under this section
  #========================================================
  yt_logcat_pid=0
  ### Log On
  INIT_PLATFORM_ANDROID_YOUTUBE
  ### Reproduce issue and finishing record
  message="${COLOR_RED}After issue appears, press ANY key and ENTER to finish logs recording!${COLOR_REST}"
  hint=$(prompt "$message")
  ### Log Off
  CLOSE_PLATFORM_ANDROID_YOUTUBE
  sleep 1s
  echo -e "${COLOR_YELLOW}===========================================================${COLOR_REST}"
  echo -e "${COLOR_YELLOW}YouTube(An) AutoLog-script END${COLOR_REST}"
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
