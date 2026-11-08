#!/usr/bin/env sh
#set -x
HBBTV_LOG_VERSION="1.0.0"
HBBTV_VERSION="v1.0.0"

function LogOnForBrowser()
{
  #Enable level 2(Info)
  am broadcast -a com.mediatek.browservice.MBF_CLI --es type "Log" --es func "setLogLevel" --ei Loglevel 2  -p "com.mediatek.browservice"
}

function LogOffForBrowser()
{
  #Switch to level 6(Error)
  am broadcast -a com.mediatek.browservice.MBF_CLI --es type "Log" --es func "setLogLevel" --ei Loglevel 6  -p "com.mediatek.browservice"
}

function LogOnForBrowserVendor()
{
  #To-Do: Currently,info for all module is ok for iwedia per their feedback,we need to breakdown to each module in future if needed.
  #Enable level 3(Info) and module 0(All module)
  am broadcast -a com.mediatek.browservice.MBF_CLI --es type "UT" --es func "setBrowserVendorLogLevel"  --ei log_level 3 --ei log_module 0 -p "com.mediatek.browservice"
}

function LogOffForBrowserVendor()
{
  #Switch to level 0(Fatal) and module 0(All module)
  am broadcast -a com.mediatek.browservice.MBF_CLI --es type "UT" --es func "setBrowserVendorLogLevel"  --ei log_level 0 --ei log_module 0 -p "com.mediatek.browservice"
}

INIT_PLATFORM_HBBTV_HBBTV_AUTO_LOG ()
{

  SCENARIO_NUM="$1"
  LOG_DIR="$2"
  
  echo "USE case :$LOG_DIR"

  LOGCAT_LOG="${LOG_DIR}/hbbtv_logcat.log"

  case "$SCENARIO_NUM" in
    "10101")
      echo "IN 10101\n"
      echo "Enable HbbTV debug level......\n"
      #su
      logcat -c
      logcat -G 128M
      LogOnForBrowserVendor
      logcat > $LOGCAT_LOG &
      echo "Please start to reproduce this issue!!!\n"
    ;;
    "10102")
      echo "IN 10102"
      echo "Enable HbbTV debug level......\n"
      #su;
      logcat -c
      logcat -G 128M
	  setprop mtk.wpfstreamplayer.loglevel 11
	  setprop vendor.debug.cmpb.level 3
      logcat > $LOGCAT_LOG &
      echo "Please start to reproduce this issue!!!\n"
    ;;
	"10103")
      echo "IN 10103"
      echo "Enable HbbTV debug level......\n"
      #su;
      logcat -c
      logcat -G 128M
      setprop vendor.mtk.dash.log_level 0
      setprop vendor.mtk.mtkstream.log_level 0
      setprop mtk.wpfstreamplayer.loglevel 11
      setprop vendor.debug.cmpb.level 3
      LogOnForBrowserVendor
      logcat > $LOGCAT_LOG &
      echo "Please start to reproduce this issue!!!\n"
    ;;
	"10104")
      echo "IN 10104"
      echo "Enable HbbTV debug level......\n"
      #su;
	  logcat -c
	  logcat -G 128M
      setprop vendor.mtk.broadcast.log.level D
      logcat > $LOGCAT_LOG &
      echo "Please start to reproduce this issue!!!\n"
    ;;
    *)
      echo "SCENARIO_NUM='$SCENARIO_NUM' is not defined , please check or contact with Tan.Wang\n"
      exit 1
      ;;
  esac
  echo "case done."
}


CLOSE_PLATFORM_HBBTV_HBBTV_AUTO_LOG()
{
  echo -e "If you want to disable HbbTV debug level, please reboot your TV!!!\n"
  echo -e "Close Platform HBBTV HBBTV AUTO LOG log Success!\n"
}


MAIN()
{
  echo "HBBTV_LOG_VERSION: $HBBTV_LOG_VERSION"
  echo "HBBTV_VERSION: $HBBTV_VERSION"
  
  PID=$$
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

  INIT_PLATFORM_HBBTV_HBBTV_AUTO_LOG $SCENARIO_NUM $LOG_DIR
  CLOSE_PLATFORM_HBBTV_HBBTV_AUTO_LOG
}

if [  "$*" = "--source-only" ];then
  :
else
  MAIN $*
fi
