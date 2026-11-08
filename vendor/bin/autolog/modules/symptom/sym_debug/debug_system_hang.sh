#!/usr/bin/env sh

MAIN()
{
  ### Import functions from other modules/scripts
  ### DO SOMETHING
  #echo "\033[1m \033[4m"
  #echo "In debug_system_hang.sh\033[0m"
  if [ -f /sys/kernel/debug/kmemleak ]; then
    sh $AUTOLOG_MODULES_DIR/platform/stress/get-kmemleak.sh $AUTOLOG_LOG_DIR 600 &
    KMEMLEAK_LOG_PID=$!
    #echo "kmemleak_log_pid=$KMEMLEAK_LOG_PID"
    echo "kmemleak_log_pid=$KMEMLEAK_LOG_PID" >> $AUTOLOG_LOG_DEFAULT_TEMP_DIR/running_pids.log
  fi
  sleep 1
  if [ -d /sys/kernel/debug/slab ]; then
    sh $AUTOLOG_MODULES_DIR/platform/stress/slab_user_kmalloc.sh $AUTOLOG_LOG_DIR 600 &
    SLAB_LOG_PID=$!
    #echo "slab_log_pid=$SLAB_LOG_PID"
    echo "slab_log_pid=$SLAB_LOG_PID" >> $AUTOLOG_LOG_DEFAULT_TEMP_DIR/running_pids.log
  fi
  sleep 1
  sh $AUTOLOG_MODULES_DIR/platform/stress/memory_log.sh merak $AUTOLOG_LOG_DIR 600 > $AUTOLOG_LOG_DIR/memory_log_consolelog.txt &
  MEMORY_LOG_PID=$!
  #echo "memory_log_pid=$MEMORY_LOG_PID"
  echo "memory_log_pid=$MEMORY_LOG_PID" >> $AUTOLOG_LOG_DEFAULT_TEMP_DIR/running_pids.log

  if [ -f /sys/power/pm_debug_messages ]; then
    echo 1 > /sys/power/pm_debug_messages
  fi
  if [ -f /sys/module/printk/parameters/console_suspend ]; then
    echo 0 > /sys/module/printk/parameters/console_suspend
  fi
  #echo "\033[1m \033[4m"
  #echo "Out debug_system_hang.sh\033[0m"
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
