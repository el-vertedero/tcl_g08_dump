#!/usr/bin/env sh
source "$AUTOLOG_HOME/utils/imports.sh"

ImportUtil "loggers.sh"
ImportUtil "colors.sh"

BASE_ON_AUTO_LOG_VERSION="1.0.2"
AUDIO_VERSION="v1.0.2.1"

INIT_BSP_AUDIO_COMMON()
{
  echo "Initialize BSP.AUDIO.COMMON log configs..."

  SCENARIO_NUM="$1"
  echo "AUDIO IN $SCENARIO_NUM"
  
  # Open log by scenario number
  Import bsp audio scenario audio_$SCENARIO_NUM.sh
  audio_log_open

  echo -e "Audio Init log Success!\n"
}


CLOSE_BSP_AUDIO_COMMON()
{
  SCENARIO_NUM="$1"
  echo "close audio scenario id: $SCENARIO_NUM"

  Import bsp audio scenario audio_$SCENARIO_NUM.sh
  audio_log_close
  
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
  echo "AUDIO_VERSION: $AUDIO_VERSION"
  source "$AUTOLOG_HOME/utils/preprocess.sh"  

  ### Arguments
  # $log_fp => output log file path
  # $act_log_fp => interactive log output file path
  module_arg1=$1
  module_arg2=$2
  module_arg3=$3

  #--------------------------------------
  #Need to open/key log before issue appears  
  echo -e "Wait for audio log initialization ...\n"

  # Open log
  INIT_BSP_AUDIO_COMMON $SCENARIO_NUM

  MAIN_LOG_FP="$(GenLogPath "Audio_MAIN.log")"
  echo "MAIN_LOG_FP=$MAIN_LOG_FP"

  rst1=$(IsOverQuestion $LOG_FP)

  # Close log
  CLOSE_BSP_AUDIO_COMMON $SCENARIO_NUM
}


if [ "$*" = "--source-only" ]; then
  :
else
  MAIN $*
fi
