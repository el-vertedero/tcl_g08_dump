#!/usr/bin/env sh
. "$AUTOLOG_HOME/utils/imports.sh"

ImportUtil "loggers.sh"
ImportUtil "colors.sh"


INIT_BSP_OPTEE_OPTEE()
{
  echo "Initialize BSP.OPTEE.OPTEE log configs..."
#  set -e

  SCENARIO_NUM="$1"

  # Open log by scenario number
  case "$SCENARIO_NUM" in
    ### Basic Debug
    "10001")
      echo "IN 10001 Basic debug TRACE_ERROR level"
      echo 1 >/proc/tz_mstar/log_level
      echo 1 >/proc/tz2_mstar/log_level
    ;;
    "10002")
      echo "IN 10002 Basic debug TRACE_INFO level"
      echo 2 >/proc/tz_mstar/log_level
      echo 2 >/proc/tz2_mstar/log_level
    ;;
    "10003")
      echo "IN 10003 Basic debug TRACE_DEBUG level"
      echo 3 >/proc/tz_mstar/log_level
      echo 3 >/proc/tz2_mstar/log_level
    ;;
    "10004")
      echo "IN 10004 Basic debug TRACE_FLOW level"
      echo 4 >/proc/tz_mstar/log_level
      echo 4 >/proc/tz2_mstar/log_level
    ;;
    ### TRACE_TSMS Debug
    "10101")
      echo "IN 10101 TRACE_TSMS debug TRACE_ERROR level"
      echo 17 >/proc/tz_mstar/log_level
      echo 17 >/proc/tz2_mstar/log_level
    ;;
    "10102")
      echo "IN 10102 TRACE_TSMS debug TRACE_INFO level"
      echo 18 >/proc/tz_mstar/log_level
      echo 18 >/proc/tz2_mstar/log_level
    ;;
    "10103")
      echo "IN 10103 TRACE_TSMS debug TRACE_DEBUG level"
      echo 19 >/proc/tz_mstar/log_level
      echo 19 >/proc/tz2_mstar/log_level
    ;;
    "10104")
      echo "IN 10104 TRACE_TSMS debug TRACE_FLOW level"
      echo 20 >/proc/tz_mstar/log_level
      echo 20 >/proc/tz2_mstar/log_level
    ;;
    ### TRACE_MMU Debug
    "10201")
      echo "IN 10201 TRACE_MMU debug TRACE_ERROR level"
      echo 33 >/proc/tz_mstar/log_level
      echo 33 >/proc/tz2_mstar/log_level
    ;;
    "10202")
      echo "IN 10202 TRACE_MMU debug TRACE_INFO level"
      echo 34 >/proc/tz_mstar/log_level
      echo 34 >/proc/tz2_mstar/log_level
    ;;
    "10203")
      echo "IN 10203 TRACE_MMU debug TRACE_DEBUG level"
      echo 35 >/proc/tz_mstar/log_level
      echo 35 >/proc/tz2_mstar/log_level
    ;;
    "10204")
      echo "IN 10204 TRACE_MMU debug TRACE_FLOW level"
      echo 36 >/proc/tz_mstar/log_level
      echo 36 >/proc/tz2_mstar/log_level
    ;;
    ### TRACE_MMAP Debug
    "10301")
      echo "IN 10301 TRACE_MMAP debug TRACE_ERROR level"
      echo 65 >/proc/tz_mstar/log_level
      echo 65 >/proc/tz2_mstar/log_level
    ;;
    "10302")
      echo "IN 10302 TRACE_MMAP debug TRACE_INFO level"
      echo 66 >/proc/tz_mstar/log_level
      echo 66 >/proc/tz2_mstar/log_level
    ;;
    "10303")
      echo "IN 10303 TRACE_MMAP debug TRACE_DEBUG level"
      echo 67 >/proc/tz_mstar/log_level
      echo 67 >/proc/tz2_mstar/log_level
    ;;
    "10304")
      echo "IN 10304 TRACE_MMAP debug TRACE_FLOW level"
      echo 68 >/proc/tz_mstar/log_level
      echo 68 >/proc/tz2_mstar/log_level
    ;;
    ### TRACE_MMU_MMA Debug
    "10401")
      echo "IN 10401 TRACE_MMU_MMA debug TRACE_ERROR level"
      echo 129 >/proc/tz_mstar/log_level
      echo 129 >/proc/tz2_mstar/log_level
    ;;
    "10402")
      echo "IN 10402 TRACE_MMU_MMA debug TRACE_INFO level"
      echo 130 >/proc/tz_mstar/log_level
      echo 130 >/proc/tz2_mstar/log_level
    ;;
    "10403")
      echo "IN 10403 TRACE_MMU_MMA debug TRACE_DEBUG level"
      echo 131 >/proc/tz_mstar/log_level
      echo 131 >/proc/tz2_mstar/log_level
    ;;
    "10404")
      echo "IN 10404 TRACE_MMU_MMA debug TRACE_FLOW level"
      echo 132 >/proc/tz_mstar/log_level
      echo 132 >/proc/tz2_mstar/log_level
    ;;
    ### TRACE_SVP Debug
    "10501")
      echo "IN 10501 TRACE_SVP debug TRACE_ERROR level"
      echo 257 >/proc/tz_mstar/log_level
      echo 257 >/proc/tz2_mstar/log_level
    ;;
    "10502")
      echo "IN 10502 TRACE_SVP debug TRACE_INFO level"
      echo 258 >/proc/tz_mstar/log_level
      echo 258 >/proc/tz2_mstar/log_level
    ;;
    "10503")
      echo "IN 10503 TRACE_SVP debug TRACE_DEBUG level"
      echo 259 >/proc/tz_mstar/log_level
      echo 259 >/proc/tz2_mstar/log_level
    ;;
    "10504")
      echo "IN 10504 TRACE_SVP debug TRACE_FLOW level"
      echo 260 >/proc/tz_mstar/log_level
      echo 260 >/proc/tz2_mstar/log_level
    ;;
    ### TRACE_PERF Debug
    "10601")
      echo "IN 10601 TRACE_PERF debug TRACE_ERROR level"
      echo 513 >/proc/tz_mstar/log_level
      echo 513 >/proc/tz2_mstar/log_level
    ;;
    "10602")
      echo "IN 10602 TRACE_PERF debug TRACE_INFO level"
      echo 514 >/proc/tz_mstar/log_level
      echo 514 >/proc/tz2_mstar/log_level
    ;;
    "10603")
      echo "IN 10603 TRACE_PERF debug TRACE_DEBUG level"
      echo 515 >/proc/tz_mstar/log_level
      echo 515 >/proc/tz2_mstar/log_level
    ;;
    "10604")
      echo "IN 10604 TRACE_PERF debug TRACE_FLOW level"
      echo 516 >/proc/tz_mstar/log_level
      echo 516 >/proc/tz2_mstar/log_level
    ;;
    *)
      echo "SCENARIO_NUM='$SCENARIO_NUM' is not defined in optee.sh, please check or contact related RD"
      return 1
    ;;
  esac


#  set +e
  echo -e "OPTEE SVP Init log Success!\n"
}

CLOSE_BSP_OPTEE_OPTEE()
{
#  set -e
  #Log Off
  ##OPTEE SVP log off:
  echo 1 >/proc/tz_mstar/log_level
  echo 1 >/proc/tz2_mstar/log_level
#  set +e
  echo -e "Close OPTEE SVP log Success!\n"
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

  #--------------------------------------
  #Need to open/key log before issue appears
  script_debug_mode=0

  echo -e "Wait for svp log initialization ...\n"

  if [ "$script_debug_mode" -gt 0 ]
  then
      echo "script debug mode: on"
    set -x
  fi

  # Open log
  INIT_BSP_OPTEE_OPTEE $SCENARIO_NUM

  #--------------------------------------
  #Reproduce issue and finishing record.
  echo -e "After issue appears, press enter to finishing recording!"
  if [ "$script_debug_mode" -gt 0 ]
  then
    set +x && read "abc" && set -x
  else
    read "abc"
  fi
  sleep 1s
}


if [ "$*" = "--source-only" ]; then
  :
else
  MAIN $*
fi
