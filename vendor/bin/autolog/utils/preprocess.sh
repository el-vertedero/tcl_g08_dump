#!/usr/bin/env sh


GenLogPath()
{
  ### Generate file path that follow the naming rule of autolog framework
  ### Usage:
  ###   GenLogPath "Extra_log.log"
  ###     => /data/platform/mm/2020-07-08-150215-platform_mm_mm_demo.sh_10101-Extra_log.log
  LOG_NAME_POST_FIX="$1"
  NEW_PATH="$(echo "$LOG_FP" | sed -e "s/kernel\.log/${LOG_NAME_POST_FIX}/")"
  echo "$NEW_PATH"
}


if [ "$*" = "--source-only" ]; then
  :
else
  LOG_FP=$1
  LOG_DT=$2
  SCENARIO_NUM=$3

  LOG_DIR="$(dirname "$LOG_FP")"
  ACT_LOG_FP="$(echo "$LOG_FP" | sed -e 's/kernel\.log/interactive\.log/')"
  INIT_HISTORY_FP="$(echo "$LOG_FP" | sed -e 's/kernel\.log/init_history\.log/')"
  shift 3

  ### Wrtie command information into LOG_FP
  echo "$(date +"%Y-%m-%d %H:%M:%S"),script_version=$version" >> "$ACT_LOG_FP"
fi
