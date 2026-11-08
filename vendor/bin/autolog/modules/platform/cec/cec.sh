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
#========================================================
CHECK_10001_SUCCESS()
{
    echo -e "Check 10001 success or not"
    ls -l /data/local.prop
    ls -l /data/tkui.print
    getprop | grep log.tag
}

Wait_finish()
{
    message="${COLOR_RED}After issue appears, press keyin any words to finishing recording!${COLOR_REST}"
    bug=$(prompt "$message")
    echo "$bug"
    sleep 1s
}
INIT_PLATFORM_CEC_CEC()
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
  echo "Initialize PLATFORM_CEC_CEC log configs..."
  SCENARIO_NUM="$1"
#  set -e
  #========================================================
  #                   Common part  (CAUTION!!)
  #  Commands defined here will been executed while user
  #  call this function EVERY TIME.
  #========================================================
  #echo debug_level=4 > /proc/utopia_mdb/audio
  CHECK_10001_SUCCESS
  ### Enable logs by scenario number
  ### You can setup kinds of scenario here
  ### Scenario Number is
  case "$SCENARIO_NUM" in
    "10001")
      ######################################################
      #              ( 10001 )  Common - Enable LOG and reboot
      #
      ######################################################
      echo "IN 10001, init CEC prop and MTKAP log"
      echo "System will reboot, please wait..."
      echo log.tag.HDMI=DEBUG > /data/local.prop;
      chmod 644 /data/local.prop;
      touch /data/tkui.print;
      sync;
      reboot;
    ;;
    "10002")
      ######################################################
      #              ( 10002 ) Common - Presetting and get log
      #
      # <Please describe this Scenario in this block>
      #
      ######################################################
      echo "dumpsys hdmi_control before reproducing....."
      sleep 1
      dumpsys hdmi_control
      dumpsys hdmi_audio
      # Setup for tis log
      setprop vendor.mtk.broadcast.log.level D
      setprop vendor.mtk.tvexoplayer.log all
      setprop vendor.debug.tuner.service.log 1
      # ExternIn HAL log
      if [ "$ANDROID_VERSION" -ge 14 ]; then
        dumpsys vendor.mediatek.hardware.ExternIn.IExternIn/default --dbglevel 4
      else
        lshal debug vendor.mediatek.hardware.ExternIn@1.0::IExternIn/ExternIn --dbglevel 4
      fi
      logcat -c;
      logcat -G 64M;
      logcat -v time > /data/mycec.log &
      dumpsys hdmi_control
      dumpsys hdmi_audio
    ;;
    "10003")
      ######################################################
      #              ( 10003 ) Common - Presetting and get log without clear logcat
      #
      # <Please describe this Scenario in this block>
      #
      ######################################################
      echo "dumpsys hdmi_control before reproducing....."
      sleep 1
      dumpsys hdmi_control
      dumpsys hdmi_audio
      # Setup for tis log
      setprop vendor.mtk.broadcast.log.level D
      setprop vendor.mtk.tvexoplayer.log all
      setprop vendor.debug.tuner.service.log 1
      # ExternIn HAL log
      if [ "$ANDROID_VERSION" -ge 14 ]; then
        dumpsys vendor.mediatek.hardware.ExternIn.IExternIn/default --dbglevel 4
      else
        lshal debug vendor.mediatek.hardware.ExternIn@1.0::IExternIn/ExternIn --dbglevel 4
      fi
      logcat -v time > /data/mycec.log &
      dumpsys hdmi_control
      dumpsys hdmi_audio
    ;;
    "20001") #for autolog v2.0
      echo "dumpsys hdmi_control before reproducing....."
      echo "dumpsys hdmi_control before reproducing....." >> $AUTOLOG_LOG_DIR/cec_eARC.log
      sleep 1
      echo -e "\n dumpsys hdmi_control" >> $AUTOLOG_LOG_DIR/cec_eARC.log
      dumpsys hdmi_control >> $AUTOLOG_LOG_DIR/cec_eARC.log
      echo -e "\n dumpsys hdmi_audio" >> $AUTOLOG_LOG_DIR/cec_eARC.log
      dumpsys hdmi_audio >> $AUTOLOG_LOG_DIR/cec_eARC.log
      # Setup for tis log
      setprop vendor.mtk.broadcast.log.level D
      setprop vendor.mtk.tvexoplayer.log all
      setprop vendor.debug.tuner.service.log 1
      # ExternIn HAL log
      if [ "$ANDROID_VERSION" -ge 14 ]; then
        echo -e "\n dumpsys vendor.mediatek.hardware.ExternIn.IExternIn/default --dbglevel 4" >> $AUTOLOG_LOG_DIR/cec_eARC.log
        dumpsys vendor.mediatek.hardware.ExternIn.IExternIn/default --dbglevel 4 >> $AUTOLOG_LOG_DIR/cec_eARC.log
      else
        echo -e "\n lshal debug vendor.mediatek.hardware.ExternIn@1.0::IExternIn/ExternIn --dbglevel 4" >> $AUTOLOG_LOG_DIR/cec_eARC.log
        lshal debug vendor.mediatek.hardware.ExternIn@1.0::IExternIn/ExternIn --dbglevel 4 >> $AUTOLOG_LOG_DIR/cec_eARC.log
      fi
      echo "done....."
    ;;
    "20002") #for autolog v2.0
      echo "dump CEC/ARC/eARC related logs after reproduced"
      echo "dump CEC/ARC/eARC related logs after reproduced" >> $AUTOLOG_LOG_DIR/cec_eARC_bugreport.log
      sleep 1
      echo -e "\n settings get GLOBAL avr_capability_ddp_atmos: " >> $AUTOLOG_LOG_DIR/cec_eARC_bugreport.log
      settings get GLOBAL avr_capability_ddp_atmos >> $AUTOLOG_LOG_DIR/cec_eARC_bugreport.log

      echo -e "\n settings get Global nrdp_audio_platform_capabilities: " >> $AUTOLOG_LOG_DIR/cec_eARC_bugreport.log
      settings get Global nrdp_audio_platform_capabilities >> $AUTOLOG_LOG_DIR/cec_eARC_bugreport.log

      echo -e "\n dump ExternIn related logs" >> $AUTOLOG_LOG_DIR/cec_eARC_bugreport.log

      if [ "$ANDROID_VERSION" -ge 14 ]; then
        echo "\n dumpsys vendor.mediatek.hardware.ExternIn.IExternIn/default --dumpHdmiEdidContent" >> $AUTOLOG_LOG_DIR/cec_eARC_bugreport.log
        dumpsys vendor.mediatek.hardware.ExternIn.IExternIn/default --dumpHdmiEdidContent

        echo "\n dumpsys vendor.mediatek.hardware.ExternIn.IExternIn/default --dumpSadInfo" >> $AUTOLOG_LOG_DIR/cec_eARC_bugreport.log
        dumpsys vendor.mediatek.hardware.ExternIn.IExternIn/default --dumpSadInfo
      else
        echo "\n lshal debug vendor.mediatek.hardware.ExternIn@1.0::IExternIn/ExternIn --dumpHdmiEdidContent" >> $AUTOLOG_LOG_DIR/cec_eARC_bugreport.log
        lshal debug vendor.mediatek.hardware.ExternIn@1.0::IExternIn/ExternIn --dumpHdmiEdidContent >> $AUTOLOG_LOG_DIR/cec_eARC_bugreport.log

        echo "\n lshal debug vendor.mediatek.hardware.ExternIn@1.0::IExternIn/ExternIn --dumpSadInfo" >> $AUTOLOG_LOG_DIR/cec_eARC_bugreport.log
        lshal debug vendor.mediatek.hardware.ExternIn@1.0::IExternIn/ExternIn --dumpSadInfo >> $AUTOLOG_LOG_DIR/cec_eARC_bugreport.log
      fi

      echo -e "\n dumpsys hdmi_control" >> $AUTOLOG_LOG_DIR/cec_eARC_bugreport.log
      dumpsys hdmi_control >> $AUTOLOG_LOG_DIR/cec_eARC_bugreport.log

      echo -e "\n dumpsys tv_input" >> $AUTOLOG_LOG_DIR/cec_eARC_bugreport.log
      dumpsys tv_input >> $AUTOLOG_LOG_DIR/cec_eARC_bugreport.log

      echo -e "\n dumpsys hdmi_audio" >> $AUTOLOG_LOG_DIR/cec_eARC_bugreport.log
      dumpsys hdmi_audio >> $AUTOLOG_LOG_DIR/cec_eARC_bugreport.log

      echo -e "\n dumpsys media.audio_policy" >> $AUTOLOG_LOG_DIR/cec_eARC_bugreport.log
      dumpsys media.audio_policy >> $AUTOLOG_LOG_DIR/cec_eARC_bugreport.log

      echo -e "\n dumpsys audio" >> $AUTOLOG_LOG_DIR/cec_eARC_bugreport.log
      dumpsys audio >> $AUTOLOG_LOG_DIR/cec_eARC_bugreport.log

      # Setup for tis log
      echo -e "\n cat /sys/devices/platform/mtk_earc/mtk_dbg/eARC/EarcStatus \n" >> $AUTOLOG_LOG_DIR/cec_eARC_bugreport.log
      cat /sys/devices/platform/mtk_earc/mtk_dbg/eARC/EarcStatus >> $AUTOLOG_LOG_DIR/cec_eARC_bugreport.log

      echo "echo 0 > /sys/devices/platform/mtk_earc/RD/Info" >> $AUTOLOG_LOG_DIR/cec_eARC_bugreport.log
      echo 0 > /sys/devices/platform/mtk_earc/RD/Info

      echo -e "\n cat /sys/devices/platform/mtk_earc/RD/Info" >> $AUTOLOG_LOG_DIR/cec_eARC_bugreport.log
      cat /sys/devices/platform/mtk_earc/RD/Info >> $AUTOLOG_LOG_DIR/cec_eARC_bugreport.log

      echo "echo 1 > /sys/devices/platform/mtk_earc/RD/Info" >> $AUTOLOG_LOG_DIR/cec_eARC_bugreport.log
      echo 1 > /sys/devices/platform/mtk_earc/RD/Info

      echo -e "\n cat /sys/devices/platform/mtk_earc/RD/Info" >> $AUTOLOG_LOG_DIR/cec_eARC_bugreport.log
      cat /sys/devices/platform/mtk_earc/RD/Info >> $AUTOLOG_LOG_DIR/cec_eARC_bugreport.log

      echo "done....."
    ;;
    esac
}
CLOSE_PLATFORM_CEC_CEC()
{
    echo -e "Close CEC log Success!\n"
    echo -e "Dump final status..................."
    sleep 1
    echo -e "settings get GLOBAL avr_capability_ddp_atmos"
    settings get GLOBAL avr_capability_ddp_atmos
    echo -e "settings get Global nrdp_audio_platform_capabilities"
    settings get Global nrdp_audio_platform_capabilities
    echo -e "dump externIn related logs"
    if [ "$ANDROID_VERSION" -ge 14 ]; then
      dumpsys vendor.mediatek.hardware.ExternIn.IExternIn/default --dumpHdmiEdidContent
      dumpsys vendor.mediatek.hardware.ExternIn.IExternIn/default --dumpSadInfo
    else
      lshal debug vendor.mediatek.hardware.ExternIn@1.0::IExternIn/ExternIn --dumpHdmiEdidContent
      lshal debug vendor.mediatek.hardware.ExternIn@1.0::IExternIn/ExternIn --dumpSadInfo
    fi
    echo -e "dumpsys hdmi_control"
    dumpsys hdmi_control
    echo -e "dumpsys tv_input"
    dumpsys tv_input
    echo -e "check earc status"
    cat /sys/devices/platform/mtk_earc/mtk_dbg/eARC/EarcStatus

    echo 0 > /sys/devices/platform/mtk_earc/RD/Info

    cat /sys/devices/platform/mtk_earc/RD/Info

    echo 1 > /sys/devices/platform/mtk_earc/RD/Info

    cat /sys/devices/platform/mtk_earc/RD/Info
    dumpsys hdmi_audio
    sleep 1
    dumpsys media.audio_policy
    sleep 1
    dumpsys audio

    pkill logcat
}
question1()
{
  local OUTPUT_FP="$1"
  msg1=" Settings -> Channels&Inputs -> External inputs-> HDMI control and related settings are set correctly\n"
  message="${COLOR_RED}$msg1 Please check if the Settings are set correctly! [Y/N]? ${COLOR_REST}"
  ### This will call prompt function from utils/helpers.sh
  ### prompt(message, log_file_path)
  ###   => Use read command to ask user questions, and record it into log_file_path
  bug=$(prompt "$message" "$OUTPUT_FP")
  echo "$bug"  # Return answer
}
question2()
{
  local OUTPUT_FP="$1"
  message="${COLOR_RED} Is this issue reproduced only with specific device?[Y/N]? ${COLOR_REST}"
  bug=$(prompt "$message" "$OUTPUT_FP")
  echo "$bug" # Return answer
}
question3()
{
  local OUTPUT_FP="$1"
  message="${COLOR_RED} Is this issue reproduced 100%? [Y/N]? ${COLOR_REST}"
  bug=$(prompt "$message" "$OUTPUT_FP")
  echo "$bug" # Return answer
}
question4()
{
  local OUTPUT_FP="$1"
  message="${COLOR_RED} Is this issue related to ARC / eARC/ Amplifier? [Y/N]? ${COLOR_REST}"
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
  echo "SCENARIO_NUM=$1"
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
  INIT_PLATFORM_CEC_CEC $SCENARIO_NUM
  Wait_finish
  CloseCommandDebuger
  PrintCommandDebuger $INIT_HISTORY_FP
  PrintCpuMemUsage "$ACT_LOG_FP"
  ################################
  ### Demo interactive flow
  #echo "-------- Interactive demo --------"
  ### Questions flow control
  rst1=$(question1 $ACT_LOG_FP)
  #if [ "$rst1" = "Y" ] || [ "$rst1" = "y" ]; then
  rst2=$(question2 $ACT_LOG_FP)
  rst3=$(question3 $ACT_LOG_FP)
  rst4=$(question4 $ACT_LOG_FP)
  if [ "$rst4" = "N" ] || [ "$rst4" = "n" ]; then
      #do nothing here;
      sleep 1;
  else
    # dump audio related log for audio member
    # TODO, call audio autoLog if needed
    dumpsys audio
    dumpsys media.audio_policy
    sleep 1;
  fi
  #fi
  ################################
  ### CLOSE LOGs
  PrintCpuMemUsage "$ACT_LOG_FP"
  CLOSE_PLATFORM_CEC_CEC
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
