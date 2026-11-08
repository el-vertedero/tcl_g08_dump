#!/usr/bin/env sh
source "$AUTOLOG_HOME/utils/imports.sh"

ImportUtil "loggers.sh"
ImportUtil "colors.sh"

Import bsp video video.sh
Import platform mm mm_aow_an.sh

BASE_ON_AUTO_LOG_VERSION="1.0.2"
DISP_VERSION="v1.0.2.0"
SCENARIO_DIR='scenario_aow'

INIT_BSP_DISP_COMMON()
{
  echo "Initialize BSP.DISP.COMMON log configs $1..."

  SCENARIO_NUM="$1"

  TMP_SCENARIO_NUM="$SCENARIO_NUM"
  echo "DISP IN $SCENARIO_NUM $TMP_SCENARIO_NUM"

  case "$SCENARIO_NUM" in
    "10001")
      echo "MM/DTV Source"
      Import bsp disp $SCENARIO_DIR disp_$SCENARIO_NUM.sh
      disp_log_open
      INIT_BSP_VIDEO_VIDEO 20001
    ;;
    "20001")
      echo "Ypbpr Source"
      Import bsp disp $SCENARIO_DIR disp_$SCENARIO_NUM.sh
      disp_log_open
    ;;
    "30001")
      echo "CVBS Source"
      Import bsp disp $SCENARIO_DIR disp_$SCENARIO_NUM.sh
      disp_log_open
    ;;
    "40001")
      echo "ATV Source"
      Import bsp disp $SCENARIO_DIR disp_$SCENARIO_NUM.sh
      disp_log_open
    ;;
    "50001")
      echo "HDMI Source"
      Import bsp disp $SCENARIO_DIR disp_$SCENARIO_NUM.sh
      disp_log_open
    ;;
    "90001")
      echo "Ypbpr/CVBS/ATV/HDMI/MM/DTV Test Pattern Check"
      Import bsp disp $SCENARIO_DIR disp_$SCENARIO_NUM.sh
      disp_log_open
    ;;
    "90002")
      echo "Black screen issue Test Pattern Check"
      Import bsp disp $SCENARIO_DIR disp_$SCENARIO_NUM.sh
      disp_log_open
    ;;
    "90003")
      echo "Dynamic content with Moving Test Pattern Check"
      Import bsp disp $SCENARIO_DIR disp_$SCENARIO_NUM.sh
      disp_log_open
    ;;
    "90011")
      echo "Ypbpr/CVBS/ATV/HDMI/MM/DTV Test Pattern Check for Mokona"
      Import bsp disp $SCENARIO_DIR disp_$SCENARIO_NUM.sh
      disp_log_open
    ;;
    *)
      echo "SCENARIO_NUM='$SCENARIO_NUM' is not defined in INIT_BSP_DISP_COMMON, please check or contact related RD"
      return 1
    ;;
  esac
  INIT_PLATFORM_MM_MM 10002
  SCENARIO_NUM="$TMP_SCENARIO_NUM"

  echo -e "Disp Init log Success!\n"
}

INIT_BSP_DISP_DUMP()
{
  echo "Initialize BSP.DISP.DUMP log configs $1 log path $2..."

  SCENARIO_NUM="$1"
  LOG_PATH="$2"

  TMP_SCENARIO_NUM="$SCENARIO_NUM"

  case "$SCENARIO_NUM" in
    "60001")
      echo "Lshal Init"
      Import bsp disp $SCENARIO_DIR disp_$SCENARIO_NUM.sh
      disp_lshal_init
    ;;
    "60002")
      echo "Lshal Dump"
      Import bsp disp $SCENARIO_DIR disp_$SCENARIO_NUM.sh
      disp_lshal_dump "$LOG_PATH"
    ;;
    *)
      echo "SCENARIO_NUM='$SCENARIO_NUM' is not defined in INIT_BSP_DISP_DUMP, please check or contact related RD"
      return 1
    ;;
  esac
  SCENARIO_NUM="$TMP_SCENARIO_NUM"

  echo -e "Disp dump log Success!\n"
}

CLOSE_BSP_DISP_COMMON()
{

  SCENARIO_NUM="$1"
  echo "close disp scenario id: $SCENARIO_NUM"
  Import bsp disp $SCENARIO_DIR disp_$SCENARIO_NUM.sh
  disp_log_close

  CLOSE_BSP_VIDEO_VIDEO
  CLOSE_PLATFORM_MM_MM

  echo "Close Disp log Success!"
  sync
  sync
}

IsOverQuestion()
{
  local OUTPUT_FP="$1"
  message="${COLOR_RED} After finishing reproduce, key in [Y/y] to continue:  ${COLOR_REST}"
  ### This will call prompt function from utils/helpers.sh
  ### prompt(message, log_file_path)
  ###   => Use read command to ask user questions, and record it into log_file_path
  bug=$(prompt "$message" "$OUTPUT_FP")
  echo "$bug"  # Return answer
}

MAIN()
{
  echo "AUTO_LOG_VERSION: $BASE_ON_AUTO_LOG_VERSION (see README.html)"
  echo "DISP_VERSION: $DISP_VERSION"
  source "$AUTOLOG_HOME/utils/preprocess.sh"

  ### Arguments
  # $log_fp => output log file path
  # $act_log_fp => interactive log output file path
  module_arg1=$1
  module_arg2=$2
  module_arg3=$3

  #--------------------------------------
  #Need to open/key log before issue appears
  echo -e "Wait for disp log initialization ...\n"

  # Open log
  INIT_BSP_DISP_COMMON $SCENARIO_NUM

  while :
  do
    rst1=$(IsOverQuestion $ACT_LOG_FP)
    if [ "${rst1}" == "Y" ] || [ "${rst1}" == "y" ]; then
       break
    fi
  done
  echo -e "Logging finished, Wait log output...!"

  # Close log
  CLOSE_BSP_DISP_COMMON $SCENARIO_NUM
}


if [ "$*" = "--source-only" ]; then
  :
else
  MAIN $*
fi
