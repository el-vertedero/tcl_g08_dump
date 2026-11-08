#!/usr/bin/env sh
. "$AUTOLOG_HOME/utils/imports.sh"

ImportUtil "loggers.sh"
ImportUtil "colors.sh"
ImportUtil "sys.sh"
#========================================================
#          Import modules functions you need
# if you want to call modules/bsp/audio/audio.sh
#                  =>  Import bsp audio audio.sh
#========================================================
Import bsp audio audio.sh
Import bsp video video.sh
Import bsp disp disp.sh
Import platform mm mm_aow_an.sh

##############################################################################
# 100--01 video common scenario               #                              #
# 101--01 application used level MM/CSP       #  External used               #
# 101 \02 To-do                               #                              #
# 102--01 application used level DTV/PVR      #                              #
# 102 \02 To-do                               #                              #
# 200--01 For Display used                    #  External used               #
# 201--01 For Audio used                      #  External used               #
#                                             #                              #
# 900--01 common dump after issue occurred    #                              #
##############################################################################


INIT_FLATFORM_CSP_ANAZON()
{
  echo "Initialize FLATFORM.CSP.ANAZON log configs..."
#  set -e

  SCENARIO_NUM="$1"

  # Open log by scenario number
  ### You can setup kinds of scenario here
  case "$SCENARIO_NUM" in
    "10001")
      # 10001 => For Common Scenario Used
      echo "IN 10001"
      #only logcat
      LOGCAT_FP="$LOG_DIR/$LOG_DT-platform_csp_amazon.sh_10001-logcat.log"
      echo "LOGCAT_FP: $LOGCAT_FP"
      logcat -G 64M
      logcat -c
      logcat -v threadtime > $LOGCAT_FP&

    ;;
    "10101")
      # 10101 => For Acodec used
      echo "IN 10101"
      #video framework
      #setprop
      LOGCAT_FP="$LOG_DIR/$LOG_DT-platform_csp_amazon.sh_10101-logcat.log"
      echo "LOGCAT_FP: $LOGCAT_FP"
      logcat -G 64M
      setprop vendor.mtk.c2.enable.comp.log 2
      setprop vendor.mtk.c2.enable.vdec.log 2
      setprop vendor.mtktv.c2.enable.vdec.log 2
      setprop vendor.mtktv.c2.enable.bm.log 2
      setprop vendor.mtk.codec2.log 2
      setprop vendor.mstar.vdec.log 2
      setprop vendor.mtk.vcodecvideo.log 2
      setprop vendor.mtk.vcodecvdecimpl.log 3
      setprop vendor.mtk.tpchwc.log 1
      setprop vendor.mtk.vsyncbridge.log 1
      setprop vendor.mtk.displink.log 1
      setprop vendor.mtk.displink.bm.profile 1
      logcat -c
      logcat -v threadtime > $LOGCAT_FP&

    ;;
    "90001")
      # 90001 => For after issue used
      echo "IN 90001"

    ;;
    *)

      echo "SCENARIO_NUM='$SCENARIO_NUM' is not defined in video.sh, please check or contact related RD"
      exit 1
    ;;
  esac

  #common

#  set +e
  echo -e "AMAZON Init log Success!\n"
}


CLOSE_FLATFORM_CSP_ANAZON()
{
#  set -e
  #Log Off
  CLOSE_PLATFORM_MM_MM
#  set +e
  echo -e "Close AMAZON log Success!\n"
}

issue_appear_question()
{
  local LOG_FP="$1"
  message="${COLOR_RED} After issue appears, press enter Y/y to finishing recording! ${COLOR_REST}"
  bug=$(prompt "$message" "$LOG_FP")
  echo "$bug"
}

MAIN()
{
  version="v1.0"
  . "$AUTOLOG_HOME/utils/preprocess.sh"


  ### Arguments
  # $log_fp => output log file path
  # $act_log_fp => interactive log output file path
  module_arg1=$1
  module_arg2=$2
  module_arg3=$3

  ### log settings
  # back-up log level
  #org_printk=$(cat /proc/sys/kernel/printk)
  # start kernel log
  #echo 0 > /proc/sys/kernel/printk || echo -e "${COLOR_RED}Change printk error! Permission Denied${COLOR_REST}"
  #dmesg --follow -r >> $LOG_FP &
  #child_pid=$!

  #--------------------------------------
  #Need to open/key log before issue appears
  script_debug_mode=0

  echo -e "Wait for video log initialization ...\n"

  if [ "$script_debug_mode" -gt 0 ]
  then
      echo "script debug mode: on"
    set -x
  fi

  # Open log
  INIT_FLATFORM_CSP_ANAZON $SCENARIO_NUM

  #--------------------------------------
  #Reproduce issue and finishing record.
  while :
  do
    rst1=$(issue_appear_question $ACT_LOG_FP)
    if [ "${rst1}" == "Y" ] || [ "${rst1}" == "y" ]; then
       break
    fi
  done
  echo -e "Logging finished, Wait log output...!"

  #echo -e "After issue appears, press enter to finishing recording!"
  #if [ "$script_debug_mode" -gt 0 ]
  #then
    #set +x && read "abc" && set -x
  #else
    #read "abc"
  #fi
  #sleep 1s


  # Close log
  CLOSE_FLATFORM_CSP_ANAZON


  ### log settings
  # re-cover log level
  #echo $org_printk > /proc/sys/kernel/printk || echo -e "${COLOR_RED}Change printk error! Permission Denied${COLOR_REST}"

  # stop dmesg running in background jobs
  #kill -9 $child_pid
  #sync
  #sync
}


if [ "$*" = "--source-only" ]; then
  :
else
  MAIN $*
fi