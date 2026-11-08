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

INIT_PLATFORM_BLUETOOTH_BLUETOOTH_ANDROID()
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
  echo "Initialize PLATFORM.BLUETOOTH.BLUETOOTH_ANDROID log configs..."
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
      ######################################################
      #              ( 10101 )  Scenario A - Common
      #
      # Enable hci log
      # Catch logcat for bluetooth
      #
      ######################################################
      echo "IN 10101"

          PROCFS_PLATFORM_BLUETOOTH_BLUETOOTH_ANDROID_COMMON
    ;;
    "10102")
      ######################################################
      #              ( 10102 )  Scenario B - Performance
      #
      # Enable hci log for bluetooth performance test
      # Catch logcat for bluetooth
      #
      ######################################################
      echo "IN 10102"
          PROCFS_PLATFORM_BLUETOOTH_BLUETOOTH_ANDROID_PERFORMANCE
    ;;
    "10103")
      ######################################################
      #              ( 10103 )  Scenario B - Dump
      #
      # Catch hci log for bluetooth
      # Dump audio and bluetooth status
      #
      ######################################################
      echo "IN 10103"
          PROCFS_PLATFORM_BLUETOOTH_BLUETOOTH_ANDROID_DUMP
    ;;
      ######################################################
      #              ( * )  Scenario not defined
      #
      ######################################################
    *)
      echo "SCENARIO_NUM='$SCENARIO_NUM' is not defined in bluetooth.sh, please check or contact related RD"
      exit 1
    ;;
  esac

#  set +e
  echo -e "Init Platform Bluetooth Bluetooth log Success!\n"
}


PROCFS_PLATFORM_BLUETOOTH_BLUETOOTH_ANDROID_COMMON(){

    echo "******* enable hci log *******"
    setprop persist.bluetooth.btsnooplogmode full
    setprop persist.bluetooth.btsnoopsize 0xFFFFF
    setprop persist.vendor.bluetooth.btsnoopsavelast true

    echo "******* clear logcat and increase log buffer size *******"
    killall logcat
    logcat -c
    logcat -G 32M

    echo "*******  kill picus ******* "
    killall picus

    echo "******* restart bluetooth process *******"
    pkill -f com.android.bluetooth
    sleep 1s

    echo "******* clear last hci log *******"
    rm /data/misc/bluetooth/logs/*last*

    BLUETOOTH_ANDROID_LOGCAT_LOG_FP="$(GenLogPath "logcat.log")"
    echo "${COLOR_RED}BLUETOOTH_ANDROID_LOGCAT_LOG_FP = $BLUETOOTH_ANDROID_LOGCAT_LOG_FP${COLOR_REST}"
    logcat -v threadtime > $BLUETOOTH_ANDROID_LOGCAT_LOG_FP &
    CHILD_PID=$!

    BLUETOOTH_ANDROID_PICUS_LOG_FP=${LOG_DIR}/${LOG_DT}_picus
    echo "${COLOR_RED}BLUETOOTH_ANDROID_PICUS_LOG_FP = $BLUETOOTH_ANDROID_PICUS_LOG_FP${COLOR_REST}"
    picus -f -n 100 -p $BLUETOOTH_ANDROID_PICUS_LOG_FP &
    CHILD_PID=$!
}

PROCFS_PLATFORM_BLUETOOTH_BLUETOOTH_ANDROID_PERFORMANCE(){

    echo "******* enable hci log for performance *******"
    setprop persist.vendor.bluetooth.btsnooplogmode full
    PROCFS_PLATFORM_BLUETOOTH_BLUETOOTH_ANDROID_COMMON

}
PROCFS_PLATFORM_BLUETOOTH_BLUETOOTH_ANDROID_DUMP(){

    BLUETOOTH_ANDROID_HCI_LOG_FP=${LOG_DIR}/${LOG_DT}_hci
    echo "******* copy hci log *******"
    echo "${COLOR_RED}BLUETOOTH_ANDROID_HCI_LOG_FP = $BLUETOOTH_ANDROID_HCI_LOG_FP${COLOR_REST}"
    cp -r /data/misc/bluetooth/logs/ $BLUETOOTH_ANDROID_HCI_LOG_FP &

    BLUETOOTH_ANDROID_TOMBSTONES_LOG_FP=${LOG_DIR}/${LOG_DT}_tombstones
    echo "******* copy tombstones log *******"
    echo "${COLOR_RED}BLUETOOTH_ANDROID_TOMBSTONES_LOG_FP = $BLUETOOTH_ANDROID_TOMBSTONES_LOG_FP${COLOR_REST}"
    cp -r /data/tombstones $BLUETOOTH_ANDROID_TOMBSTONES_LOG_FP &

    dump_audio_info=${LOG_DIR}/${LOG_DT}_dump_audio_info.log
    dump_bluetooth_info=${LOG_DIR}/${LOG_DT}_dump_bluetooth_info.log
    dump_fw_ver_info=${LOG_DIR}/${LOG_DT}_dump_fw_ver_info.log
    dump_sys_info=${LOG_DIR}/${LOG_DT}_dump_sys_info.log

    echo "******* dumpsys audio *******">> $dump_audio_info
    dumpsys audio >> $dump_audio_info
    echo "******* dumpsys media.audio_flinger *******">> $dump_audio_info
    dumpsys media.audio_flinger >> $dump_audio_info
    echo "******* dumpsys media.audio_policy *******">> $dump_audio_info
    dumpsys dumpsys media.audio_policy >> $dump_audio_info

    echo "dumpsys bluetooth manager..." >> $dump_bluetooth_info
    dumpsys bluetooth_manager >> $dump_bluetooth_info

    echo "fw version..." > $dump_fw_ver_info
    head -c 40 /vendor/firmware/*.bin >> $dump_fw_ver_info
    echo "picus version..." >> $dump_fw_ver_info

    echo "picus version..." >> $dump_fw_ver_info
    strings /vendor/bin/picus | grep 6.0. >> $dump_fw_ver_info

    echo "driver version..." >> $dump_fw_ver_info
    strings /vendor/lib/modules/btmtk_usb_unify.ko | grep ^version= >> $dump_fw_ver_info
    strings /vendor/lib/modules/btmtk_usb.ko | grep ^version= >> $dump_fw_ver_info

    echo "wifi version..." >> $dump_fw_ver_info
    iwpriv wlan0 driver "ver" >> $dump_fw_ver_info

    echo "TV load version..." >> $dump_fw_ver_info
    strings /vendor/lib/libdtv_common.so | grep t-apollo >> $dump_fw_ver_info

    echo "FW tag version..." >> $dump_fw_ver_info
    strings /vendor/firmware/*.bin | grep t-neptune >> $dump_fw_ver_info

    echo "top info...." > $dump_sys_info
    top -b -n 1 >> $dump_sys_info

    echo "mem info...." >> $dump_sys_info
    dumpsys meminfo >> $dump_sys_info

    echo "dumpsys meminfo info...." >> $dump_sys_info
    dumpsys meminfo >> $dump_sys_info

    echo "mem info...." >> $dump_sys_info
    cat /proc/meminfo >> $dump_sys_info

    echo "ifconfig info...." >> $dump_sys_info
    ifconfig >> $dump_sys_info

}

CLOSE_PLATFORM_BLUETOOTH_BLUETOOTH_ANDROID()
{
  echo -e "Close Platform BLUETOOTH BLUETOOTH ANDROID log Success!\n"
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
  #MODULE_ARG1=$1
  #MODULE_ARG2=$2
  #MODULE_ARG3=$3

  echo "LOG_FP=$LOG_FP"
  echo "ACT_LOG_FP=$ACT_LOG_FP"
  echo "LOG_DIR=$LOG_DIR"
  echo "LOG_DT=$LOG_DT"
  echo "SCENARIO_NUM=$SCENARIO_NUM"
  #echo "MODULE_ARG1=$MODULE_ARG1"
  #echo "MODULE_ARG2=$MODULE_ARG2"
  #echo "MODULE_ARG3=$MODULE_ARG3"

  #========================================================
  #                   Main codes here
  # You can modify codes under this section
  #========================================================

  ### Import functions from other modules/scripts
  ### DO SOMETHING
  OpenCommandDebuger $INIT_HISTORY_FP
  INIT_PLATFORM_BLUETOOTH_BLUETOOTH_ANDROID $SCENARIO_NUM
  CloseCommandDebuger
  PrintCommandDebuger $INIT_HISTORY_FP
  PrintCpuMemUsage "$ACT_LOG_FP"

  ### CLOSE LOGs
  CLOSE_PLATFORM_BLUETOOTH_BLUETOOTH_ANDROID

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
