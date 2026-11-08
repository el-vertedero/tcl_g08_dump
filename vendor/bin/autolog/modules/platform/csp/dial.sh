#!/usr/bin/env sh
#set -x
#. "$AUTOLOG_HOME/utils/imports.sh"
#ImportUtil "loggers.sh"
#ImportUtil "colors.sh"
#ImportUtil "helpers.sh"
#ImportUtil "sys.sh"

#-------------------------------------------------------------------------------------------
#========================================================
#          Import modules functions you need
# if you want to call modules/bsp/audio/audio.sh
#                  =>  Import bsp audio audio.sh
#========================================================
#Import bsp video common.sh
#Import bsp audio audio_demo.sh


INIT_PLATFORM_DIAL()
{
    #for linux
    touch /cache/dial_debug
    #for android
    touch /data/vendor/3rd_rw/dial_debug

    #for linux
    echo ":am,am,:stop=dialserver" > /tmp/fifo_am_write
    #for android
    echo ":am,am,:stop=dialserver" > /data/vendor/fifo/fifo_am_write
    echo ":am,am,:stop=dialserver" > /mnt/vendor/tmp/fifo_am_write
    echo "${COLOR_RED} Please wait 4s dial restart ${COLOR_REST}"
    sleep 2s

    #for linux
    echo ":am,am,:start=dialserver" > /tmp/fifo_am_write
    #for android
    echo ":am,am,:start=dialserver" > /data/vendor/fifo/fifo_am_write
    echo ":am,am,:start=dialserver" > /mnt/vendor/tmp/fifo_am_write

    sleep 2s
    echo "${COLOR_RED}Init dial log Success!${COLOR_REST}"
}


CLOSE_PLATFORM_DIAL()
{
    #for linux
    rm -rf /cache/dial_debug
    #for android
    rm -rf /data/vendor/3rd_rw/dial_debug

    #for linux
    echo ":am,am,:stop=dialserver" > /tmp/fifo_am_write
    #for android
    echo ":am,am,:stop=dialserver" > /data/vendor/fifo/fifo_am_write
    echo ":am,am,:stop=dialserver" > /mnt/vendor/tmp/fifo_am_write
    echo "${COLOR_RED} Please wait 4s dial restart ${COLOR_REST}"

    sleep 2s
    #for linux
    echo ":am,am,:start=dialserver" > /tmp/fifo_am_write
    #for android
    echo ":am,am,:start=dialserver" > /data/vendor/fifo/fifo_am_write
    echo ":am,am,:start=dialserver" > /mnt/vendor/tmp/fifo_am_write

    sleep 2s
    echo "${COLOR_RED}Close dial log Success!${COLOR_REST}"
}


MAIN()
{
    PID=$$
    version="v1.0"

    #========================================================
    echo "=========== (PID=$PID) from $0 ============="
    . "$AUTOLOG_HOME/utils/preprocess.sh"

    #========================================================

    module_arg1=$1
    module_arg2=$2
    module_arg3=$3
    
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

    echo "LOG_FP=$LOG_FP"
    echo "ACT_LOG_FP=$ACT_LOG_FP"
    echo "LOG_DIR=$LOG_DIR"
    echo "LOG_DT=$LOG_DT"
    echo "SCENARIO_NUM=$SCENARIO_NUM"
    echo "MODULE_ARG1=$MODULE_ARG1"
    echo "MODULE_ARG2=$MODULE_ARG2"
    echo "MODULE_ARG3=$MODULE_ARG3"


    #--------------------------------------
    #Need to open/key log before issue appears
    script_debug_mode=0
    
    echo -e "Wait for DIAL log initialization ...\n"

    if [ "$script_debug_mode" -gt 0 ]
    then
        echo "script debug mode: on"
        set -x
    fi

    # Open log
    INIT_PLATFORM_DIAL

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
    CLOSE_PLATFORM_DIAL
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
