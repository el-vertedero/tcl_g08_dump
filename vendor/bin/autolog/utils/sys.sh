#!/usr/bin/env sh


OpenCommandDebuger()
{
  DEBUG_FP="$1"
  exec 3>$DEBUG_FP
  exec 2>&3
  if [ "$AUTOLOG_PLATFORM" = "android" ]; then
    set -o inherit-xtrace
  else
    set -x
  fi
}


CloseCommandDebuger()
{
  if [ "$AUTOLOG_PLATFORM" = "android" ]; then
    set +o inherit-xtrace
  else
    set +x
  fi
  exec 3>&-
  exec 2>/dev/tty
}


PrintCommandDebuger()
{
  #  + INIT_PLATFORM_MM_MM 10101
  #  + echo 'Initialize PLATFORM.MM.MM log configs...'
  #  + SCENARIO_NUM=10101
  #  + echo debug_level=4
  #  + case "$SCENARIO_NUM" in
  #  + echo 'IN 10101'
  #  + INIT_BSP_AUDIO_AUDIO 10101
  #  + echo 'Initialize BSP.AUDIO.AUDIO log configs...'
  #  + SCENARIO_NUM=10101
  #  + echo debug_level=4
  #  + case "$SCENARIO_NUM" in
  #  + echo 'IN 10101'
  #  + echo dbg MI_AUDIO 0x40
  #  + echo dbg MI_AOUT 0x40
  #  + echo dbg MI_AEXTIN 0x40
  #  + echo -e 'Audio Init log Success!\n'
  #  + INIT_BSP_VIDEO_COMMON 30101
  #  + echo dbg MI_AOUT 0xf0
  #  + echo -e 'Init Platform MM MM log Success!\n'
  #  + set +x

  DEBUG_FP="$1"
  cat "$DEBUG_FP" | grep "^+" | grep -v "echo -e" | grep -v "echo '" | grep -v "set +x" | grep -v "+ case " | grep -v "+ SCENARIO_NUM"| sort
}


GetCpuUsage()
{
  DURATION=$1
  if [ -z $DURATION ]; then
    DURATION=0.5
  fi

  # CPU Usage (%) = diff(work) / diff(work, idle) * 100
  usage_t1=$(grep 'cpu ' /proc/stat | awk '{work=$2+$4; idle=$5; print work, idle}')
  sleep $DURATION
  usage_t2=$(grep 'cpu ' /proc/stat | awk '{work=$2+$4; idle=$5; print work, idle}')

  work_t1=$(echo $usage_t1 | awk '{print $1}')
  idle_t1=$(echo $usage_t1 | awk '{print $2}')
  work_t2=$(echo $usage_t2 | awk '{print $1}')
  idle_t2=$(echo $usage_t2 | awk '{print $2}')

  work="$(echo "$work_t2" "$work_t1" | awk '{printf "%f", $1-$2}')"
  idle="$(echo "$idle_t2" "$idle_t1" | awk '{printf "%f", $1-$2}')"
  total="$(echo "$work" "$idle" | awk '{printf "%f", $1+$2}')"
  echo "$(echo "$work $total" | awk '{printf "%.2f", $1/$2*100}')"
}


GetMemoryUsage()
{
  # Mem usage (%) = Used Memory / Total Memory * 100

  # MLR
  # top command show memory like following format
  # GiB Mem : 37.5/0.8      [|||||||||||||                                   ]
  memoryUsage="$(top -bn1 | grep "GiB Mem" | grep -v "grep" | awk '{split($4,a,"/");print a[1]}')"

  # Android R
  if [ -z "$memoryUsage" ]; then
    # Mem:   905676K total,   879384K used,  26923008 free,  29081600 buffers
    memoryUsage=$(top -bn 1 | grep 'Mem:' | grep -v "grep" | awk '{printf "%.2f", $4/$2*100}')
  fi

  # Linux
  if [ -z "$memoryUsage" ]; then
    # KiB Mem :  8010104 total,  4895904 free,   732724 used,  2381476 buff/cache
    memoryUsage=$(top -bn 1 | grep '^KiB Mem' | grep -v "grep" | awk '{printf "%.2f", $8/$4*100}')
  fi
  echo "$memoryUsage"
}


PrintCpuMemUsage()
{
  OUTPUT_FP="$1"
  CPU="$(GetCpuUsage)"
  MEM="$(GetMemoryUsage)"

  if [ -n "$OUTPUT_FP" ]; then
    echo "$(date +"%Y-%m-%d %H:%M:%S"),cpu=$CPU,memory=$MEM" >> "$OUTPUT_FP"
  fi

  echo "CPU Usage: $CPU%, Memory Usage: $MEM%"
}


OpenKernelLog()
{
  KERNEL_FP="$1"

  DMESG_PIDS=$(ps -ef | grep "dmesg --follow" | grep -v grep | grep "$$" | awk '$3 != 1{print $2}')
  if [ -n "$DMESG_PIDS" ]; then
    echo -e "dmesg was opened($DMESG_PIDS), skip."
  else
    dmesg --follow -r >> "$KERNEL_FP" &
    CHILD_PID=$!
    echo -e "Open dmesg recorder($CHILD_PID), write kernel log into path: $KERNEL_FP"
  fi
}


KillKernelLog()
{
  DMESG_PIDS=$(ps -ef | grep "dmesg --follow" | grep -v grep | grep "$$" | awk '$3 != 1{print $2}')
  if [ -n "$DMESG_PIDS" ]; then
    echo "$DMESG_PIDS" | xargs kill -9

    sync
    sync
    sync
  fi
}

KillOrphanDmesg()
{
  # Kill orphan dmesg commands
  # Kill dmesg PID where PPID=1 like shown below
  #   PID  PPID
  #   9422 1
  #   9481 1
  #   9515 1
  DMESG_PIDS=$(ps -ef | grep dmesg | grep -v grep | awk '$3 == 1{print $2}')
  if [ -n "$DMESG_PIDS" ]; then
    echo "$DMESG_PIDS" | xargs kill -9

    sync
    sync
    sync
  fi
}

