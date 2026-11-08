#!/usr/bin/env sh
source "$AUTOLOG_HOME/utils/imports.sh"

ImportUtil "loggers.sh"
ImportUtil "colors.sh"

BASE_ON_AUTO_LOG_VERSION="1.0.4"

INIT_PLATFORM_FFGA_COMMON()
{
  echo "Initialize PLATFORM.FFGA.COMMON log configs..."

  SCENARIO_NUM="$1"
  LOG_PATH=$2
  echo "FFGA IN $SCENARIO_NUM"
  
  # Open log by scenario number
  Import platform ffga scenario ffga_$SCENARIO_NUM.sh
  ffga_log_open $LOG_PATH

  echo -e "FFGA Init log Success!\n"
}


CLOSE_PLATFORM_FFGA_COMMON()
{
  SCENARIO_NUM="$1"
  echo "close ffga scenario id: $SCENARIO_NUM"

  Import platform ffga scenario ffga_$SCENARIO_NUM.sh
  ffga_log_close
  
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
  source "$AUTOLOG_HOME/utils/preprocess.sh"  

  ### Arguments
  # $log_fp => output log file path
  # $act_log_fp => interactive log output file path
  module_arg1=$1
  module_arg2=$2
  module_arg3=$3

  #--------------------------------------
  #Need to open/key log before issue appears  
  echo -e "Wait for ffga log initialization ...\n"

  # Set log path
  MAIN_LOG_FP="$(GenLogPath "FFGA_MAIN.log")"
  #ex: # MAIN_LOG_FP=/data/platform/ffga/2020-07-08-150215-platform_mm_mm_demo.sh_10101-FFGA_MAIN.log
  echo "MAIN_LOG_FP=$MAIN_LOG_FP"

  # Open log
  INIT_PLATFORM_FFGA_COMMON $SCENARIO_NUM $MAIN_LOG_FP

  rst1=$(IsOverQuestion $LOG_FP)

  # Close log
  CLOSE_PLATFORM_FFGA_COMMON $SCENARIO_NUM
}


if [ "$*" = "--source-only" ]; then
  :
else
  MAIN $*
fi
