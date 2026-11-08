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
Import bsp audio audio.sh
Import bsp video video.sh
#Import bsp disp disp.sh
Import platform mm mm_aow_an.sh


#========================================================
#                   Default values
#========================================================

#========================================================
#          Autolog Framework Implementation
#========================================================
#-------------------------------------------------------------------------------------------
INIT_PLATFORM_CSP_NETFLIX()
{
  #========================================================
  #                   Common part  (CAUTION!!)
  #  Commands defined here will been executed while user
  #  call this function EVERY TIME.
  #========================================================

  echo "Initialize PLATFORM.csp.netflix/prime_video/vudu log configs..."
  SCENARIO_NUM="$1"
  MODULE_ARG="$2"

  #========================================================
  #                  Scenario Definition
  # 000XX : Netflix launch/Exit/Crash/Graphic
  # 100XX : MMDBG category
  # 101XX : Playback with Logs
  # 102XX : Playback with Patterns
  # 110XX : On-the-Fly related
  # 800XX : Others
  #========================================================
  case "$SCENARIO_NUM" in
    "00000")
      ####################################################################
      # Scenario ( 00000 )
      # Enable Logcat Only Log/Dump setting
      ####################################################################
      NFX_LOGCAT_FP="$LOG_DIR/$LOG_DT-00000-logcat.log"

      NOTIFICATION_PLATFORM_CSP_NETFLIX
      PROCFS_PLATFORM_CSP_NETFLIX_LOGCATONLY
      PROCFS_PLATFORM_CSP_NETFLIX_LOGCAT_START
      ;;
    "10001")
      ####################################################################
      # Scenario ( 10001 )
      # Enable Logcat Only Log/Dump setting for other APK
      ####################################################################
      NFX_LOGCAT_FP="$LOG_DIR/$LOG_DT-00000-logcat.log"

      PROCFS_PLATFORM_CSP_NETFLIX_LOGCAT_START
      ;;
    "10002")
      ####################################################################
      # Scenario ( 10002 )
      # enable MMDBG Log/Dump setting for Audio
      ####################################################################
      # reserved for fusion platform
      ;;
    "10101")
      ####################################################################
      # Scenario ( 10101 )
      # Enable Other Playback Logs
      ####################################################################
      # reserved for fusion platform
      ;;
    "10102")
      ####################################################################
      # Scenario ( 10102 )
      # Enable EP Logs
      ####################################################################
      setenforce 0
      if [ "$MODULE_ARG" -eq 1 ]; then
        NFX_LOGCAT_FP="$LOG_DIR/$LOG_DT-10101-1-logcat.log"
        PROCFS_PLATFORM_CSP_NETFLIX_LOGCAT_CLEAR
        PROCFS_PLATFORM_CSP_NETFLIX_EYEPATCHLOG_1
        PROCFS_PLATFORM_CSP_NETFLIX_LOGCAT_START
      fi
      ;;
    "11001")
      ####################################################################
      # Scenario ( 11001 )
      # Enable On-The-Fly Log/Dump setting
      ####################################################################
      NFX_LOGCAT_FP="$LOG_DIR/$LOG_DT-11001-logcat.log"
      NOTIFICATION_PLATFORM_CSP_NETFLIX
      PROCFS_PLATFORM_CSP_NETFLIX_LOGCAT_CLEAR
      PROCFS_PLATFORM_CSP_NETFLIX_ONTHEFLYLOG
      PROCFS_PLATFORM_CSP_NETFLIX_LOGCAT_START
      ;;
    *)
      echo -e "${COLOR_RED}[Netflix] Unknown scenario type, please check it!!!!!${COLOR_REST}"
      exit 1
      ;;
  esac
  echo -e "${COLOR_GREEN}Init Netflix Auto Log Success!${COLOR_REST}"
  echo -e "${COLOR_GREEN}===========================================================${COLOR_REST}"
}

CLOSE_PLATFORM_CSP_NETFLIX()
{
  PROCFS_PLATFORM_CSP_NETFLIX_LOGCAT_STOP
  echo -e "${COLOR_GREEN}Close Netflix Auto Log Success!${COLOR_REST}"
  echo -e "${COLOR_GREEN}===========================================================${COLOR_REST}"
}
#-------------------------------------------------------------------------------------------
NOTIFICATION_PLATFORM_CSP_NETFLIX()
{
  echo -e "${COLOR_RED}===========================================================${COLOR_REST}"
  echo -e "${COLOR_RED}==  Please make sure you are using Netflix Debug APK!!!  ==${COLOR_REST}"
  echo -e "${COLOR_RED}==  Please make sure you are using Netflix Debug APK!!!  ==${COLOR_REST}"
  echo -e "${COLOR_RED}==  Please make sure you are using Netflix Debug APK!!!  ==${COLOR_REST}"
  echo -e "${COLOR_RED}===========================================================${COLOR_REST}"
  sleep 1s
}


PROCFS_PLATFORM_CSP_NETFLIX_GENBUGREPORT()
{
  SYS_BUGREPORT_FP="/data/user_de/0/com.android.shell/files/bugreports/"

  echo -e "${COLOR_RED}== Generating bugreport, please wait patiently!!! ==${COLOR_REST}"
  rm -rf $SYS_BUGREPORT_FP
  rm -rf $LOG_DIR/$LOG_DT-bugreports
  bugreportz -p
  cp -r $SYS_BUGREPORT_FP $LOG_DIR/$LOG_DT-bugreports
  sync
  echo -e "${COLOR_RED}== Generating bugreport Done!!! ==${COLOR_REST}"
}

PROCFS_PLATFORM_CSP_NETFLIX_CPANRTOMBSTONE()
{
  SYS_BUGREPORT_FP="/data/user_de/0/com.android.shell/files/bugreports/"

  echo -e "${COLOR_RED}== Copying anr and tombstones, please wait patiently!!! ==${COLOR_REST}"

  mkdir -p $LOG_DIR/$LOG_DT-anr
  cp -r /data/anr/ $LOG_DIR/$LOG_DT-anr/
  mkdir -p $LOG_DIR/$LOG_DT-tombstones
  cp -r /data/tombstones/ $LOG_DIR/$LOG_DT-tombstones/

  sync
  echo -e "${COLOR_RED}== Copying anr and tombstones Done!!! ==${COLOR_REST}"
}


PROCFS_PLATFORM_CSP_NETFLIX_LOGCAT_CLEAR()
{
  echo -e "${COLOR_GREEN}===========================================================${COLOR_REST}"

  #rm -rf $LOG_DIR/*

  #rm -fr /data/anr/*
  #rm -fr /data/tombstones/*

  killall logcat
  logcat -c
  sync
  echo -e "${COLOR_GREEN}******* Clear logcat *******${COLOR_REST}"
  echo -e "${COLOR_GREEN}===========================================================${COLOR_REST}"
}

PROCFS_PLATFORM_CSP_NETFLIX_LOGCAT_START()
{
  echo -e "${COLOR_GREEN}===========================================================${COLOR_REST}"
  echo "${COLOR_RED}NFX_LOGCAT_FP = $NFX_LOGCAT_FP${COLOR_REST}"
  killall logcat
  logcat -c
  # set logcat buffer size
  logcat -G 64M  
  logcat -v threadtime > $NFX_LOGCAT_FP &
  LOGCAT_PID=$!
  echo -e "${COLOR_GREEN}Start Auto Log, logcat PID: $LOGCAT_PID${COLOR_REST}"
  echo -e "${COLOR_GREEN}===========================================================${COLOR_REST}"
}
#-------------------------------------------------------------------------------------------
PROCFS_PLATFORM_CSP_NETFLIX_LOGCAT_STOP()
{
  echo -e "${COLOR_GREEN}===========================================================${COLOR_REST}"
  sync
  sync
  kill $LOGCAT_PID
  sync
  sync

  PROCFS_PLATFORM_CSP_NETFLIX_GENBUGREPORT
  PROCFS_PLATFORM_CSP_NETFLIX_CPANRTOMBSTONE

  echo -e "${COLOR_GREEN}Stop CSP APK Auto Log, logcat PID: $LOGCAT_PID${COLOR_REST}"
  echo -e "${COLOR_GREEN}===========================================================${COLOR_REST}"
}
#-------------------------------------------------------------------------------------------

PROCFS_PLATFORM_CSP_NETFLIX_LOGCATONLY()
{
  echo -e "${COLOR_GREEN}===========================================================${COLOR_REST}"

  # set netflix log level
  setprop debug.nrdp.log.module 7

  sync
  echo -e "${COLOR_GREEN}Enable Logcat only!${COLOR_REST}"
  echo -e "${COLOR_GREEN}===========================================================${COLOR_REST}"
}

PROCFS_PLATFORM_CSP_NETFLIX_ONTHEFLYLOG()
{
  echo -e "${COLOR_GREEN}===========================================================${COLOR_REST}"
  # set logcat buffer size
  logcat -G 8M

  # set netflix log level
  setprop debug.nrdp.log.module 1

  # on-the-fly related log
  setprop log.tag.AudioTrack V
  setprop log.tag.AudioFlinger V
  setprop log.tag.APM_AudioPolicyManager V
  setprop media.acodec.verbose.log 1
  setprop media.mediacodec.verbose.log 1
  setprop media.acodecbufferchannel.verbose.log 1
  setprop vendor.hal.audio.log.level VERBOSE

  sync
  echo -e "${COLOR_GREEN}Enable On-The-Fly Log!${COLOR_REST}"
  echo -e "${COLOR_GREEN}===========================================================${COLOR_REST}"
}

PROCFS_PLATFORM_CSP_NETFLIX_EYEPATCHLOG_1()
{
  echo -e "${COLOR_GREEN}===========================================================${COLOR_REST}"
  # set logcat buffer size
  logcat -G 256M

  echo 0 > /proc/sys/kernel/printk

  setprop log.tag.AudioTrack V
  setprop log.tag.AudioFlinger V
  setprop log.tag.APM_AudioPolicyManager V
  setprop media.acodec.verbose.log 1
  setprop media.mediacodec.verbose.log 1
  setprop media.acodecbufferchannel.verbose.log 1
  setprop vendor.hal.audio.log.level VERBOSE

  echo 0xdff > /sys/devices/platform/mtk-pq/mtk_dbg/log_level
  echo 0x6 > /sys/devices/platform/mtk-tvpqu/mtk_dbg/log_level
  setprop vendor.mtk.displink.bm.profile 1
  setprop vendor.mtk.c2.enable.comp.log 2
  setprop vendor.mtk.c2.enable.vdec.log 2
  setprop vendor.mtktv.c2.enable.vdec.log 2
  setprop vendor.mtktv.c2.enable.bm.log 2
  setprop vendor.mtk.vcodecvideo.log 2
  setprop vendor.mtk.vcodecvdecimpl.log 3
  setprop vendor.mtk.mi.video.log 80
  setprop vendor.mtk.mi.vdec.log 80
  setprop vendor.mtk.tpchwc.log 1
  setprop vendor.mtk.vsyncbridge.log 1
  setprop vendor.mtk.displink.log 1
  setprop vendor.mtk.debug.hwcomposer20 17
  setprop vendor.mtk.pqlink.log 1
  setprop vendor.mtk.pqlink.setwin.info 1
  setprop vendor.mtk.pqlink.performance.profile 1
  setprop vendor.mtk.mipq.debuglevel F0
  setprop vendor.hal.audio.log.level VERBOSE

  sync
  echo -e "${COLOR_GREEN}Enable FrameFreeze/FrameDrop/ShortFrame Log!${COLOR_REST}"
  echo -e "${COLOR_GREEN}===========================================================${COLOR_REST}"
}

#-------------------------------------------------------------------------------------------
MAIN()
{
  PID=$$
  BASE_ON_AUTO_LOG_VERSION="1.0.1"
  version="v${BASE_ON_AUTO_LOG_VERSION}_20211211"

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

  echo -e "${COLOR_GREEN}===========================================================${COLOR_REST}"
  echo -e "${COLOR_GREEN}Netflix Auto Log START${COLOR_REST}"
  echo -e "${COLOR_GREEN}Version: ${version}${COLOR_REST}"
  echo -e "${COLOR_GREEN}Date: ${LOG_DT}${COLOR_REST}"
  echo -e "${COLOR_GREEN}Path: ${LOG_DIR}${COLOR_REST}"
  echo -e "${COLOR_GREEN}Reproducing Scenario: ${NFX_SCENARIO_NUM}${COLOR_REST}"
  echo -e "${COLOR_GREEN}===========================================================${COLOR_REST}"

  NFX_LOGCAT_FP="$LOG_DIR/$LOG_DT-logcat.log"



  #========================================================
  #                   Main codes here
  #       You can modify codes under this section
  #========================================================

  INIT_PLATFORM_CSP_NETFLIX
  ### Reproduce issue and finishing record
  echo -e "${COLOR_YELLOW}Press ENTER to stop recording logcat!${COLOR_REST}"
  read "enterkeytostop"
  sleep 1s
  ### Log Off
  CLOSE_PLATFORM_CSP_NETFLIX
  sleep 1s
  echo -e "${COLOR_GREEN}===========================================================${COLOR_REST}"
  echo -e "${COLOR_GREEN}Netflix Auto Log END${COLOR_REST}"
  echo -e "${COLOR_GREEN}===========================================================${COLOR_REST}"
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
