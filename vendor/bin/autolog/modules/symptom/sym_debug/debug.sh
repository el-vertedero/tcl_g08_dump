#!/usr/bin/env sh
#set -x
source "$AUTOLOG_HOME/utils/imports.sh"
ImportUtil "loggers.sh"
ImportUtil "colors.sh"
ImportUtil "sys.sh"
Import platform mm mm_aow_an.sh
Import platform cec cec.sh
Import platform camera camera_aow_an.sh
Import bsp audio audio_aow_soxy.sh
Import bsp disp disp_aow.sh
Import platform bluetooth bluetooth_android.sh
Import platform broadcast broadcast_auto_log.sh
Import platform apk apk_auto_log.sh
Import platform graphic graphic_auto_log.sh
Import platform csp netflix_an.sh
Import platform perf input_src_perf_aow.sh

#========================================================
#          Import modules functions you need
# if you want to call modules/bsp/audio/audio.sh
#                  =>  Import bsp audio audio.sh
#========================================================
INIT_SYMPTOM_DEBUG_SYSTEM_COMMON()
{
    #echo "IN INIT_SYMPTOM_DEBUG_SYSTEM_COMMON"
    #echo "AUTOLOG_LOG_DEFAULT_DIR=$AUTOLOG_LOG_DEFAULT_DIR"
    #echo "AUTOLOG_LOG_DIR=$AUTOLOG_LOG_DIR"

    if [ -d $AUTOLOG_LOG_DIR ]; then
        rm -rf $AUTOLOG_LOG_DIR
    fi

    if [ ! -d $AUTOLOG_LOG_DEFAULT_DIR ]; then
        mkdir -p $AUTOLOG_LOG_DEFAULT_DIR
    fi
    mkdir -p $AUTOLOG_LOG_DEFAULT_DIR

    if [ $AUTOLOG_LOG_DIR != $AUTOLOG_LOG_DEFAULT_DIR ]; then
        mkdir -p $AUTOLOG_LOG_DIR
        if [ ! -d $AUTOLOG_LOG_DIR ]; then
            echo "${COLOR_RED}[AUTOLOG] Failed to create $AUTOLOG_LOG_DIR ${COLOR_REST}"
            exit 1
        fi
    fi

    if [ -d $AUTOLOG_LOG_DEFAULT_TEMP_DIR ]; then
        rm -rf $AUTOLOG_LOG_DEFAULT_TEMP_DIR
    fi
    mkdir -p $AUTOLOG_LOG_DEFAULT_TEMP_DIR
}

INIT_SYMPTOM_DEBUG()
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
  SCENARIO="$1"
  SYMPTOM="$2"
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
  case "$SYMPTOM" in
    "abnormal_func")
      ######################################################
      #              ( abnormal_func )  Symptom - abnormal_func
      #
      # Switch to different scenario
      #
      ######################################################
      #echo "IN abnormal_func"
      DEBUG_SYMPTOM_ABNORMAL_FUNC $SCENARIO
      DEBUG_SYMPTOM_SYSTEM_COMMON
    ;;

    "func")
      ######################################################
      #              ( abnormal_func )  Symptom - abnormal_func
      #
      # Switch to different scenario
      #
      ######################################################
      #echo "IN abnormal_func"
      DEBUG_SYMPTOM_ABNORMAL_FUNC $SCENARIO
      DEBUG_SYMPTOM_SYSTEM_COMMON
    ;;

    "abnormal_perf")
      ######################################################
      #              ( abnormal_perf )  Symptom - abnormal_perf
      #
      # Switch to different scenario
      #
      ######################################################
      #echo "IN abnormal_perf"
      DEBUG_SYMPTOM_ABNORMAL_PERF $SCENARIO
      DEBUG_SYMPTOM_SYSTEM_COMMON
    ;;

    "perf")
      ######################################################
      #              ( abnormal_func )  Symptom - abnormal_func
      #
      # Switch to different scenario
      #
      ######################################################
      #echo "IN abnormal_perf"
      DEBUG_SYMPTOM_ABNORMAL_PERF $SCENARIO
      DEBUG_SYMPTOM_SYSTEM_COMMON
    ;;

    "abnormal_photo")
      ######################################################
      #              ( abnormal_photo )  Symptom - abnormal_photo
      #
      # Switch to different scenario
      #
      ######################################################
      #echo "IN abnormal_photo"
      DEBUG_SYMPTOM_ABNORMAL_PHOTO $SCENARIO
      DEBUG_SYMPTOM_SYSTEM_COMMON
    ;;

    "photo")
      ######################################################
      #              ( abnormal_func )  Symptom - abnormal_func
      #
      # Switch to different scenario
      #
      ######################################################
      #echo "IN abnormal_photo"
      DEBUG_SYMPTOM_ABNORMAL_PHOTO $SCENARIO
      DEBUG_SYMPTOM_SYSTEM_COMMON
    ;;

    "abnormal_audio")
      ######################################################
      #              ( abnormal_audio )  Symptom - abnormal_audio
      #
      # Switch to different scenario
      #
      ######################################################
      #echo "IN abnormal_audio"
      DEBUG_SYMPTOM_ABNORMAL_AUDIO $SCENARIO
      DEBUG_SYMPTOM_SYSTEM_COMMON
    ;;

    "audio")
      ######################################################
      #              ( audio )  Symptom - abnormal_audio
      #
      # Switch to different scenario
      #
      ######################################################
      #echo "IN abnormal_audio"
      DEBUG_SYMPTOM_ABNORMAL_AUDIO $SCENARIO
      DEBUG_SYMPTOM_SYSTEM_COMMON
    ;;

    "abnormal_video")
      ######################################################
      #              ( abnormal_video )  Symptom - abnormal_video
      #
      # Switch to different scenario
      #
      ######################################################
      #echo "IN abnormal_video"
      DEBUG_SYMPTOM_ABNORMAL_VIDEO $SCENARIO
      DEBUG_SYMPTOM_SYSTEM_COMMON
    ;;

    "video")
      ######################################################
      #              ( video )  Symptom - abnormal_video
      #
      # Switch to different scenario
      #
      ######################################################
      #echo "IN abnormal_video"
      DEBUG_SYMPTOM_ABNORMAL_VIDEO $SCENARIO
      DEBUG_SYMPTOM_SYSTEM_COMMON
    ;;


    "abnormal_avsync")
      ######################################################
      #              ( abnormal_avsync )  Symptom - abnormal_avsync
      #
      # Switch to different scenario
      #
      ######################################################
      #echo "IN abnormal_avsync"
      DEBUG_SYMPTOM_ABNORMAL_AVSYNC $SCENARIO
      DEBUG_SYMPTOM_SYSTEM_COMMON
    ;;

    "avsync")
      ######################################################
      #              ( avsync )  Symptom - abnormal_avsync
      #
      # Switch to different scenario
      #
      ######################################################
      #echo "IN abnormal_avsync"
      DEBUG_SYMPTOM_ABNORMAL_AVSYNC $SCENARIO
      DEBUG_SYMPTOM_SYSTEM_COMMON
    ;;

    "abnormal_hang")
      ######################################################
      #              ( abnormal_hang )  Symptom - abnormal_hang
      #
      # Switch to different scenario
      #
      ######################################################
      #echo "IN abnormal_hang"
      DEBUG_SYMPTOM_ABNORMAL_HANG $SCENARIO
      DEBUG_SYMPTOM_SYSTEM_COMMON
    ;;

    "hang")
      ######################################################
      #              ( hang )  Symptom - abnormal_hang
      #
      # Switch to different scenario
      #
      ######################################################
      #echo "IN abnormal_hang"
      DEBUG_SYMPTOM_ABNORMAL_HANG $SCENARIO
      DEBUG_SYMPTOM_SYSTEM_COMMON
    ;;

    "all")
      ######################################################
      #              ( all )  Symptom - all
      #
      # Switch to different scenario
      #
      ######################################################
      #echo "IN all"
      DEBUG_SYMPTOM_ALL $SCENARIO
    ;;

    *)
      ######################################################
      #              ( * )  symptom not defined
      #
      ######################################################
      echo "${COLOR_RED}[AUTOLOG] SCENARIO='$SCENARIO'+SYMPTOM='$SYMPTOM' is not defined in debug.sh!${COLOR_REST}"
      exit 1
    ;;
  esac

#  set +e
  echo -e "${COLOR_GREEN}[AUTOLOG] Init symptom debug successfully!${COLOR_REST}\n"
}

DEBUG_SYMPTOM_SYSTEM_COMMON()
{
  sh $AUTOLOG_MODULES_DIR/symptom/sym_debug/debug_system_common_aow.sh
}

DEBUG_SYMPTOM_ABNORMAL_PERF()
{
  #echo "IN DEBUG_SYMPTOM_ABNORMAL_PERF"
  SCENARIO="$1"
  case "$SCENARIO" in
    "mmp")
      #echo "IN mmp"
      INIT_PLATFORM_MM_MM 39012

    ;;
    "input_source")
      #echo "IN input_source"
      INIT_INPUT_SOURCE_PERF

    ;;
    *)
      echo "${COLOR_RED}[AUTOLOG] SCENARIO='$SCENARIO'+SYMPTOM='$SYMPTOM' is not defined in debug.sh!${COLOR_REST}"
      exit 1
    ;;
  esac

}

DEBUG_SYMPTOM_ABNORMAL_PHOTO()
{
  #echo "IN DEBUG_SYMPTOM_ABNORMAL_PHOTO"
  SCENARIO="$1"
  case "$SCENARIO" in
    "mmp")
      #echo "IN mmp"
      INIT_PLATFORM_MM_MM 30005
      INIT_PLATFORM_APK_APK_AUTO_LOG 10101 "$AUTOLOG_LOG_DIR"

    ;;
    *)
      echo "${COLOR_RED}[AUTOLOG] SCENARIO='$SCENARIO'+SYMPTOM='$SYMPTOM' is not defined in debug.sh!${COLOR_REST}"
      exit 1
    ;;
  esac

}

DEBUG_SYMPTOM_ABNORMAL_FUNC()
{
  #echo "IN DEBUG_SYMPTOM_ABNORMAL_FUNC"
  SCENARIO="$1"
  case "$SCENARIO" in
    "netflix")
      #echo "IN netflix"
      INIT_PLATFORM_CSP_NETFLIX 00000

    ;;
    "prime_video")
      #echo "IN prime_video"
      INIT_PLATFORM_CSP_NETFLIX 10001

    ;;
    "vudu")
      #echo "IN vudu"
      INIT_PLATFORM_CSP_NETFLIX 10001

    ;;
    "mmp")
      #echo "IN mmp"
      INIT_PLATFORM_MM_MM 39010
      setprop mtk.exoplayer.debug.level 11
      INIT_PLATFORM_APK_APK_AUTO_LOG 10101 "$AUTOLOG_LOG_DIR"

    ;;
    "camera")
      #echo "IN camera"
      INIT_PLATFORM_CAMERA 10001
    ;;
    "streaming_app")
      #echo "IN streaming_app"
      INIT_PLATFORM_MM_MM 39010

    ;;
    "dtv")
      #echo "IN dtv"
      INIT_PLATFORM_BROADCAST_AUTO_LOG 20101 "$AUTOLOG_LOG_DIR"
    ;;
    "input_source")
      #echo "IN input_source"
      INIT_PLATFORM_CEC_CEC 20001
      INIT_PLATFORM_BROADCAST_AUTO_LOG 20201 "$AUTOLOG_LOG_DIR"
    ;;
    "bluetooth")
      #echo "IN bluetooth"
      DEBUG_SYMPTOM_BLUETOOTH_ANDROID_COMMON
    ;;
    "ethernet")
      #echo "IN ethernet"
      DEBUG_SYMPTOM_ETHERNET_ANDROID_COMMON
    ;;
    "p2p")
      #echo "IN p2p"
      DEBUG_SYMPTOM_WIFI_ANDROID_COMMON
    ;;
    "wifi")
      #echo "IN wifi"
      DEBUG_SYMPTOM_WIFI_ANDROID_COMMON
    ;;
    "system")
      #echo "IN system"
      DEBUG_SYMPTOM_KERNEL
      DEBUG_SYMPTOM_ANDROID_DUMPSYS power &
      DUMPSYS_POWER_PID=$!
      echo "dumpsys_power_pid=$DUMPSYS_POWER_PID" >> $AUTOLOG_LOG_DEFAULT_TEMP_DIR/running_pids.log
      DEBUG_SYMPTOM_ANDROID_DUMPSYS suspend_control_internal &
      DUMPSYS_SUSPEND_CONTROL_INTERNAL_PID=$!
      echo "dumpsys_suspend_control_internal_pid=$DUMPSYS_SUSPEND_CONTROL_INTERNAL_PID" >> $AUTOLOG_LOG_DEFAULT_TEMP_DIR/running_pids.log
      DEBUG_SYMPTOM_ANDROID_GETEVENT
    ;;
    *)
      echo "${COLOR_RED}[AUTOLOG] SCENARIO='$SCENARIO'+SYMPTOM='$SYMPTOM' is not defined in debug.sh!${COLOR_REST}"
      exit 1
    ;;
  esac
}

DEBUG_SYMPTOM_ABNORMAL_AUDIO()
{
  #echo "IN DEBUG_SYMPTOM_ABNORMAL_AUDIO"
  SCENARIO="$1"
  case "$SCENARIO" in
    "netflix")
      #echo "IN netflix"
      INIT_BSP_AUDIO_COMMON 60101
    ;;
    "prime_video")
      #echo "IN prime_video"
      INIT_BSP_AUDIO_COMMON 60102
    ;;
    "vudu")
      #echo "IN vudu"
      INIT_BSP_AUDIO_COMMON 60103
    ;;
    "mmp")
      #echo "IN mmp"
      setprop mtk.exoplayer.debug.level 11
      INIT_BSP_AUDIO_COMMON 60104
    ;;
    "streaming_app")
      #echo "IN streaming_app"
      INIT_BSP_AUDIO_COMMON 60105
    ;;
    "dtv")
      #echo "IN dtv"
      INIT_BSP_AUDIO_COMMON 60106
    ;;
    "input_source")
      #echo "IN input_source"
      INIT_BSP_AUDIO_COMMON 60106
    ;;
    *)
      echo "${COLOR_RED}[AUTOLOG] SCENARIO='$SCENARIO'+SYMPTOM='$SYMPTOM' is not defined in debug.sh!${COLOR_REST}"
      exit 1
    ;;
  esac
}

DEBUG_SYMPTOM_ABNORMAL_VIDEO()
{
  #echo "IN DEBUG_SYMPTOM_ABNORMAL_VIDEO"
  SCENARIO="$1"
  case "$SCENARIO" in
    "netflix")
      #echo "IN netflix"
      INIT_BSP_DISP_DUMP 60001 "$DOMAIN_DISPLAY_DUMP_LOG_DIR"
      INIT_PLATFORM_MM_MM 39010
      INIT_PLATFORM_GRAPHIC_AUTO_LOG   10001 "$DOMAIN_DISPLAY_DUMP_LOG_DIR"
      sh $AUTOLOG_MODULES_DIR/symptom/sym_debug/debug_abnormal_video.sh
    ;;
    "prime_video")
      #echo "IN prime_video"
      INIT_BSP_DISP_DUMP 60001 "$DOMAIN_DISPLAY_DUMP_LOG_DIR"
      INIT_PLATFORM_MM_MM 39010
      INIT_PLATFORM_GRAPHIC_AUTO_LOG   10001 "$DOMAIN_DISPLAY_DUMP_LOG_DIR"
      sh $AUTOLOG_MODULES_DIR/symptom/sym_debug/debug_abnormal_video.sh
    ;;
    "vudu")
      #echo "IN vudu"
      INIT_BSP_DISP_DUMP 60001 "$DOMAIN_DISPLAY_DUMP_LOG_DIR"
      INIT_PLATFORM_MM_MM 39010
      INIT_PLATFORM_GRAPHIC_AUTO_LOG   10001 "$DOMAIN_DISPLAY_DUMP_LOG_DIR"
      sh $AUTOLOG_MODULES_DIR/symptom/sym_debug/debug_abnormal_video.sh
    ;;
    "mmp")
      #echo "IN mmp"
      INIT_BSP_DISP_DUMP 60001 "$DOMAIN_DISPLAY_DUMP_LOG_DIR"
      INIT_PLATFORM_MM_MM 39010
      INIT_PLATFORM_APK_APK_AUTO_LOG 10101 "$DOMAIN_DISPLAY_DUMP_LOG_DIR"
      INIT_PLATFORM_GRAPHIC_AUTO_LOG   10001 "$DOMAIN_DISPLAY_DUMP_LOG_DIR"
      sh $AUTOLOG_MODULES_DIR/symptom/sym_debug/debug_abnormal_video.sh
    ;;
    "streaming_app")
      #echo "IN streaming_app"
      INIT_BSP_DISP_DUMP 60001 "$DOMAIN_DISPLAY_DUMP_LOG_DIR"
      INIT_PLATFORM_MM_MM 39010
      INIT_PLATFORM_GRAPHIC_AUTO_LOG   10001 "$DOMAIN_DISPLAY_DUMP_LOG_DIR"
      sh $AUTOLOG_MODULES_DIR/symptom/sym_debug/debug_abnormal_video.sh
    ;;
    "camera")
      #echo "IN camera"
      INIT_BSP_DISP_DUMP 60001 "$DOMAIN_DISPLAY_DUMP_LOG_DIR"
      INIT_PLATFORM_CAMERA 10001
      INIT_PLATFORM_MM_MM 39010
      sh $AUTOLOG_MODULES_DIR/symptom/sym_debug/debug_abnormal_video.sh
    ;;
    "dtv")
      #echo "IN dtv"
      INIT_BSP_DISP_DUMP 60001 "$DOMAIN_DISPLAY_DUMP_LOG_DIR"
      INIT_PLATFORM_MM_MM 39010
      INIT_PLATFORM_BROADCAST_AUTO_LOG 20101 "$DOMAIN_DISPLAY_DUMP_LOG_DIR"
      sh $AUTOLOG_MODULES_DIR/symptom/sym_debug/debug_abnormal_video.sh
    ;;
    "input_source")
      #echo "IN input_source"
      INIT_BSP_DISP_DUMP 60001 "$DOMAIN_DISPLAY_DUMP_LOG_DIR"
      INIT_PLATFORM_MM_MM 39010
      INIT_PLATFORM_BROADCAST_AUTO_LOG 20101 "$DOMAIN_DISPLAY_DUMP_LOG_DIR"
      sh $AUTOLOG_MODULES_DIR/symptom/sym_debug/debug_abnormal_video_input_src.sh
    ;;
    *)
      echo "${COLOR_RED}[AUTOLOG] SCENARIO='$SCENARIO'+SYMPTOM='$SYMPTOM' is not defined in debug.sh!${COLOR_REST}"
      exit 1
    ;;
  esac
}

DEBUG_SYMPTOM_ABNORMAL_AVSYNC()
{
  #echo "IN DEBUG_SYMPTOM_ABNORMAL_AVSYNC"
  SCENARIO="$1"
  case "$SCENARIO" in
    "netflix")
      #echo "IN netflix"
      INIT_PLATFORM_MM_MM 39003
    ;;
    "prime_video")
      #echo "IN prime_video"
      INIT_PLATFORM_MM_MM 39003
    ;;
    "vudu")
      #echo "IN vudu"
      INIT_PLATFORM_MM_MM 39003
    ;;
    "mmp")
      #echo "IN mmp"
      INIT_PLATFORM_MM_MM 39003
    ;;
    "streaming_app")
      #echo "IN streaming_app"
      INIT_PLATFORM_MM_MM 39003
    ;;
    "input_source")
      #echo "IN input_source"
      INIT_PLATFORM_BROADCAST_AUTO_LOG 20101 "$AUTOLOG_LOG_DIR"

    ;;
    *)
      echo "${COLOR_RED}[AUTOLOG] SCENARIO='$SCENARIO'+SYMPTOM='$SYMPTOM' is not defined in debug.sh!${COLOR_REST}"
      exit 1
    ;;
  esac
}

DEBUG_SYMPTOM_ABNORMAL_HANG()
{
  #echo "IN DEBUG_SYMPTOM_ABNORMAL_HANG"
  SCENARIO="$1"
  case "$SCENARIO" in
    "system")
      #echo "IN system"
      sh $AUTOLOG_MODULES_DIR/symptom/sym_debug/debug_system_hang.sh $AUTOLOG_LOG_DIR
    ;;
    *)
      echo "${COLOR_RED}[AUTOLOG] SCENARIO='$SCENARIO'+SYMPTOM='$SYMPTOM' is not defined in debug.sh!${COLOR_REST}"
      exit 1
    ;;
  esac
}

DEBUG_SYMPTOM_ALL()
{
  #echo "IN DEBUG_SYMPTOM_ALL"
  SCENARIO="$1"
  case "$SCENARIO" in
    "stress")
      CloseCommandDebuger
      echo "CloseCommandDebuger IN stress"
      #echo "IN stress"
      sh $AUTOLOG_MODULES_DIR/platform/stress/enable_broadcast.sh
      sh $AUTOLOG_MODULES_DIR/platform/stress/enable_displinkvdec.sh
      sh $AUTOLOG_MODULES_DIR/platform/stress/stress_test_AOW.sh start SQA $AUTOLOG_LOG_DIR &
    ;;
    *)
      echo "${COLOR_RED}[AUTOLOG] SCENARIO='$SCENARIO'+SYMPTOM='$SYMPTOM' is not defined in debug.sh!${COLOR_REST}"
      exit 1
    ;;
  esac
}

DEBUG_SYMPTOM_BLUETOOTH_ANDROID_COMMON()
{
  BLUETOOTH_EN_LOG=$AUTOLOG_LOG_DEFAULT_TEMP_DIR/bluetooth_en_log
  echo "IN DEBUG_SYMPTOM_BLUETOOTH_ANDROID_COMMON"
  echo "start catching logcat log"
  touch $BLUETOOTH_EN_LOG
  PROCFS_PLATFORM_BLUETOOTH_BLUETOOTH_ANDROID_PERFORMANCE
}

DEBUG_SYMPTOM_WIFI_ANDROID_COMMON()
{
  echo "IN DEBUG_SYMPTOM_WIFI_ANDROID_COMMON"
  echo "start running wifi_dump tool"
  wifi_dump &
  echo "start catching logcat log"
  WIFI_LOGCAT_LOG_FP="$(GenLogPath "logcat_wifi.log")"
  echo "WIFI_LOGCAT_LOG_PATH = $WIFI_LOGCAT_LOG_FP"
  echo "enabled wifi framework verbose"
  cmd wifi set-verbose-logging enabled
  setprop log.tag.WifiTracker V
  echo "enabled supplicant verbose"
  wpa_cli -i wlan0 -g@android:wpa_wlan0 IFNAME=wlan0 log_level DEBUG
  logcat -b main -b kernel -f $WIFI_LOGCAT_LOG_FP &
  echo "${COLOR_RED}<<<<now please reproduce your issues...>>>>${COLOR_REST}"
}

DEBUG_SYMPTOM_ETHERNET_ANDROID_COMMON()
{
  echo "IN DEBUG_SYMPTOM_ETHERNET_ANDROID_COMMON"

  echo "${COLOR_RED}<<<<Start catching logcat log...>>>>${COLOR_REST}"
  echo "${COLOR_RED}<<<<Please press CTRL+C when you want to stop catching logcat log...>>>>${COLOR_REST}"

  ETHERNET_LOGCAT_LOG_FP="$(GenLogPath "logcat.log")"
  echo "${COLOR_RED}ETHERNET_LOGCAT_LOG_FP = $ETHERNET_LOGCAT_LOG_FP${COLOR_REST}"
#  logcat -c
  logcat > $ETHERNET_LOGCAT_LOG_FP &
  CHILD_PID=$!

  echo "${COLOR_RED}<<<<Start printing debug command result...>>>>${COLOR_REST}"
  echo "${COLOR_RED}<<<<Please copy the debug command result and save to a file (e.g. console_debug.log) for RD debug...>>>>${COLOR_REST}"

  echo "-----------------------------------------------"
  echo "ip route list table eth0 =>"
  ip route list table eth0
  echo "-----------------------------------------------"
  echo "ipconfig =>"
  ifconfig
  echo "-----------------------------------------------"
  echo "cat /data/vendor/tmp/resolv.conf =>"
  cat /data/vendor/tmp/resolv.conf
  echo "-----------------------------------------------"
  echo "cat /data/vendor/etc/resolv.conf =>"
  cat /data/vendor/etc/resolv.conf
  echo "-----------------------------------------------"
  echo "cat /etc/resolv.conf =>"
  cat /etc/resolv.conf
  echo "-----------------------------------------------"
  echo "cat /data/vendor/3rd_rw/dhcp_server =>"
  cat /data/vendor/3rd_rw/dhcp_server
  echo "-----------------------------------------------"
  echo "cat /sys/devices/virtual/net/eth0/carrier =>"
  cat /sys/devices/virtual/net/eth0/carrier
  echo "-----------------------------------------------"
  echo "cat /sys/class/net/eth0/carrier =>"
  cat /sys/class/net/eth0/carrier
  echo "-----------------------------------------------"
  echo "ps -ef | grep network =>"
  ps -ef | grep network
  echo "-----------------------------------------------"
  echo "dumpsys package com.mediatek.network | grep path =>"
  dumpsys package com.mediatek.network | grep path
  echo "-----------------------------------------------"
  echo "dumpsys connectivity =>"
  dumpsys connectivity
  echo "-----------------------------------------------"
  echo "dumpsys dnsresolver =>"
  dumpsys dnsresolver

  echo "${COLOR_RED}<<<<End printing debug command result...>>>>${COLOR_REST}"
}

DEBUG_SYMPTOM_KERNEL()
{
  if [ -f /sys/power/pm_debug_messages ]; then
    echo 1 > /sys/power/pm_debug_messages
  fi
  if [ -f /sys/module/printk/parameters/console_suspend ]; then
    echo 0 > /sys/module/printk/parameters/console_suspend
  fi
}

DEBUG_SYMPTOM_ANDROID_DUMPSYS()
{
    SERVICE="$1"
    DUMP_DIR=$AUTOLOG_LOG_DIR/"dumpsys_"$SERVICE
    mkdir -p $DUMP_DIR
    if [ ! -d $DUMP_DIR ]; then
        echo "${COLOR_RED}[AUTOLOG] Failed to create $DUMP_DIR ${COLOR_REST}"
        exit 1
    fi

    STOP_STRESS_LOG=$AUTOLOG_LOG_DEFAULT_TEMP_DIR/stop_stress_log

    while [ -d $DUMP_DIR ]
    do
        tname=`date +%Y_%m_%d_%H_%M`
        DUMP_FILE=$DUMP_DIR/${tname}.txt
        dumpsys $SERVICE > $DUMP_FILE
        sync
        if [ -f $STOP_STRESS_LOG ]; then
            return 0
        fi
        sleep 60
    done
}

DEBUG_SYMPTOM_ANDROID_GETEVENT()
{
    EVENTLOG_FILE=$AUTOLOG_LOG_DIR/getevent.txt
    getevent -lt > $EVENTLOG_FILE &
    GETEVENT_PID=$!
    echo "getevent_pid=$GETEVENT_PID" >> $AUTOLOG_LOG_DEFAULT_TEMP_DIR/running_pids.log
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
  MODULE_ARG1=$1
  #MODULE_ARG2=$2
  #MODULE_ARG3=$3

  #echo "LOG_FP=$LOG_FP"
  #echo "ACT_LOG_FP=$ACT_LOG_FP"
  #echo "LOG_DIR=$LOG_DIR"
  #echo "LOG_DT=$LOG_DT"
  echo "${COLOR_YELLOW}[AUTOLOG] SCENARIO=$SCENARIO_NUM${COLOR_REST}"
  echo "${COLOR_YELLOW}[AUTOLOG] SYMPTOM=$MODULE_ARG1${COLOR_REST}"
  #echo "MODULE_ARG2=$MODULE_ARG2"
  #echo "MODULE_ARG3=$MODULE_ARG3"

  #========================================================
  #                   Main codes here
  # You can modify codes under this section
  #========================================================

  ### Import functions from other modules/scripts
  ### DO SOMETHING
  INIT_SYMPTOM_DEBUG_SYSTEM_COMMON
  INIT_DISP_FOLDER
  OpenCommandDebuger $INIT_HISTORY_FP
  INIT_SYMPTOM_DEBUG $SCENARIO_NUM $MODULE_ARG1
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
