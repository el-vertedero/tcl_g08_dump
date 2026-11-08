#!/usr/bin/env sh
source "$AUTOLOG_HOME/utils/imports.sh"

ImportUtil "loggers.sh"
ImportUtil "colors.sh"

#========================================================
#          Import modules functions you need
# if you want to call modules/bsp/audio/audio.sh
#                  =>  Import bsp audio audio.sh
#========================================================
#Import bsp disp disp.sh

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

PROCFS_BSP_VIDEO_VIDEO()
{
  echo "PROCFS_BSP_VIDEO_VIDEO not support yet..."
  echo "need module owner to update control command...."
  echo "==============================================="
  #Reserved
}


INIT_BSP_VIDEO_VIDEO()
{
  echo "Initialize BSP.VIDEO.VIDEO log configs..."
#  set -e

  SCENARIO_NUM="$1"


  # Open log by scenario number
  ### You can setup kinds of scenario here
  case "$SCENARIO_NUM" in
    "10001")
      # 10001 => For Common Scenario Used
      echo "IN 10001"
      #PROCFS_BSP_VIDEO_VIDEO
      #MI_DISP Log On
      #INIT_BSP_DISP_DISP 90001
      #INIT_BSP_DISP_DISP 10101
      #MI_VIDEO Log On
      echo set vdec debuglevel 0x40 > /sys/kernel/mik/MI_VDEC
      echo 9 > /sys/module/mtk_vcu_vdec/parameters/mtk_vcu_wrap
      echo 7 > /sys/module/mtk_vcu_vdec/parameters/comhal_debug
      echo 0x24F > /sys/module/mtk_vcu_vdec/parameters/u4LogLevel
      echo 5 > /sys/module/mtk_vcu_vdec/parameters/mtk_vcu_vdec_debug
      echo 5 > /sys/module/mtk_vcu_vdec/parameters/vdec_rm_debug
      echo 3 > /sys/module/mtk_vcu_vdec/parameters/vesparser_debug
      echo 1 > /sys/module/mtk_vcodec_dec/parameters/mtk_vcodec_dbg
      echo 7 > /sys/module/mtk_vcodec_dec/parameters/mtk_v4l2_dbg_level
    ;;
    "10101")
      # 10101 => For MM/CSP used
      echo "IN 10101"
      echo set vdec debuglevel 0x40 > /sys/kernel/mik/MI_VDEC
      echo 9 > /sys/module/mtk_vcu_vdec/parameters/mtk_vcu_wrap
      echo 7 > /sys/module/mtk_vcu_vdec/parameters/comhal_debug
      echo 0x24F > /sys/module/mtk_vcu_vdec/parameters/u4LogLevel
      echo 5 > /sys/module/mtk_vcu_vdec/parameters/mtk_vcu_vdec_debug
      echo 5 > /sys/module/mtk_vcu_vdec/parameters/vdec_rm_debug
      echo 3 > /sys/module/mtk_vcu_vdec/parameters/vesparser_debug
      echo 1 > /sys/module/mtk_vcodec_dec/parameters/mtk_vcodec_dbg
      echo 7 > /sys/module/mtk_vcodec_dec/parameters/mtk_v4l2_dbg_level
    ;;
    "10201")
      # 10201 => For DTV used
      echo "IN 10201"
      echo set vdec debuglevel 0x40 > /sys/kernel/mik/MI_VDEC
      echo 9 > /sys/module/mtk_vcu_vdec/parameters/mtk_vcu_wrap
      echo 7 > /sys/module/mtk_vcu_vdec/parameters/comhal_debug
      echo 0x24F > /sys/module/mtk_vcu_vdec/parameters/u4LogLevel
      echo 5 > /sys/module/mtk_vcu_vdec/parameters/mtk_vcu_vdec_debug
      echo 5 > /sys/module/mtk_vcu_vdec/parameters/vdec_rm_debug
      echo 3 > /sys/module/mtk_vcu_vdec/parameters/vesparser_debug
      echo 1 > /sys/module/mtk_vcodec_dec/parameters/mtk_vcodec_dbg
      echo 7 > /sys/module/mtk_vcodec_dec/parameters/mtk_v4l2_dbg_level
    ;;
    "20001")
      # 20001 => For Display used
      echo "IN 20001"
      echo set vdec debuglevel 0x40 > /sys/kernel/mik/MI_VDEC
      echo 9 > /sys/module/mtk_vcu_vdec/parameters/mtk_vcu_wrap
      echo 7 > /sys/module/mtk_vcu_vdec/parameters/comhal_debug
      echo 0x24F > /sys/module/mtk_vcu_vdec/parameters/u4LogLevel
      echo 5 > /sys/module/mtk_vcu_vdec/parameters/mtk_vcu_vdec_debug
      echo 5 > /sys/module/mtk_vcu_vdec/parameters/vdec_rm_debug
      echo 3 > /sys/module/mtk_vcu_vdec/parameters/vesparser_debug
      echo 1 > /sys/module/mtk_vcodec_dec/parameters/mtk_vcodec_dbg
      echo 7 > /sys/module/mtk_vcodec_dec/parameters/mtk_v4l2_dbg_level
    ;;
    "20101")
      # 20101 => For Audio used
      echo "IN 20101:Reserved"
    ;;
    "90001")
      # 90001 => For after issue used
      echo "IN 90001:Reserved"
      PROCFS_BSP_VIDEO_VIDEO
    ;;
    *)

      echo "SCENARIO_NUM='$SCENARIO_NUM' is not defined in video.sh, please check or contact related RD"
      return 1
    ;;
  esac

  #common

#  set +e
  echo -e "Video Init log Success!\n"
}


CLOSE_BSP_VIDEO_VIDEO()
{
#  set -e
  #Log Off
  #CLOSE_BSP_DISP_DISP
  echo set vdec debuglevel 0x0 > /sys/kernel/mik/MI_VDEC
  echo 0 > /sys/module/mtk_vcu_vdec/parameters/mtk_vcu_wrap
  echo 0 > /sys/module/mtk_vcu_vdec/parameters/comhal_debug
  echo 0x0 > /sys/module/mtk_vcu_vdec/parameters/u4LogLevel
  echo 0 > /sys/module/mtk_vcu_vdec/parameters/mtk_vcu_vdec_debug
  echo 0 > /sys/module/mtk_vcu_vdec/parameters/vdec_rm_debug
  echo 0 > /sys/module/mtk_vcu_vdec/parameters/vesparser_debug
  echo 0 > /sys/module/mtk_vcodec_dec/parameters/mtk_vcodec_dbg
  echo 0 > /sys/module/mtk_vcodec_dec/parameters/mtk_v4l2_dbg_level

  #Procfs
  #PROCFS_BSP_VIDEO_VIDEO

#  set +e
  echo -e "Close Video log Success!\n"
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
  INIT_BSP_VIDEO_VIDEO $SCENARIO_NUM

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
  #INIT_BSP_DISP_DISP 90001
  #CLOSE_BSP_DISP_DISP
  CLOSE_BSP_VIDEO_VIDEO


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
