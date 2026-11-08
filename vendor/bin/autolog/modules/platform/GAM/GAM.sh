#!/usr/bin/env sh
#set -x
#-------------------------------------------------------------------------------------------

#========================================================
#          Import modules functions you need
# if you want to call modules/bsp/audio/audio.sh
#                  =>  Import bsp audio audio.sh
#========================================================
#Import bsp video common.sh
#Import bsp audio audio_demo.sh


INIT_PLATFORM_GAM()
{
    #for linux
    echo ":am,am,:am_log_on=9" > /tmp/fifo_am_write
    #for android
    echo ":am,am,:am_log_on=9" > /data/vendor/fifo/fifo_am_write
    echo ":am,am,:am_log_on=9" > /mnt/vendor/tmp/fifo_am_write

    echo -e "Init GAM log Success!\n"
}


CLOSE_PLATFORM_GAM()
{
    #for linux
    echo ":am,am,:am_log_on=1" > /tmp/fifo_am_write
    #for android
    echo ":am,am,:am_log_on=1" > /data/vendor/fifo/fifo_am_write
    echo ":am,am,:am_log_on=1" > /mnt/vendor/tmp/fifo_am_write
    echo -e "close GAM log Success!\n"
}


MAIN()
{
    PID=$$
    version="v1.0"

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
    #
    # The number of arguments for this script are not limited.
    # You can use $n to add & declare the argument you need
    #   $module_arg<n> = Arguments passed from main script
    #========================================================
    
    module_arg1=$1
    module_arg2=$2
    module_arg3=$3

    echo "LOG_FP=$LOG_FP"
    echo "ACT_LOG_FP=$ACT_LOG_FP"
    echo "LOG_DIR=$LOG_DIR"
    echo "LOG_DT=$LOG_DT"
    echo "SCENARIO_NUM=$SCENARIO_NUM"

    #--------------------------------------
    #Need to open/key log before issue appears
    script_debug_mode=0

    echo -e "Wait for GAM log initialization ...\n"

    if [ "$script_debug_mode" -gt 0 ]
    then
        echo "script debug mode: on"
        set -x
    fi

    # Open log
    INIT_PLATFORM_GAM

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


    # Close log
    CLOSE_PLATFORM_GAM
}


if [ "$*" = "--source-only" ]; then
    :
else
    MAIN $*
fi


