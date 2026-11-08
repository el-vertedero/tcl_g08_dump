#!/usr/bin/env sh
#set -x

. "$AUTOLOG_HOME/utils/imports.sh"
ImportUtil "loggers.sh"
ImportUtil "colors.sh"
ImportUtil "sys.sh"

#========================================================
#          Import modules functions you need
# if you want to call modules/bsp/audio/audio.sh
#                  =>  Import bsp audio audio.sh
#========================================================
Import bsp optee optee.sh

INIT_PLATFORM_SECURITY_INTERTACA()
{
    #========================================================
    #                   Define Scenarios
    # In this section, you have to design log switches for
    #   each kinds of scenarios.
    # For example:
    #    Scenario A (10101) is related to log_a, log_b, log_c
    #        => Enable log_a, log_b, log_c
    #    Scenario A' (10102) is a light version of scenario A.
    #      only enable log_a, log_b
    #        => Enable log_a, log_b
    #    Scenario B (10201) is only related to log_b
    #        => Just have to enable log_b
    #========================================================
    echo "[INTERCA] Initialize PLATFORM.SECURITY.INTERTACA log configs..."
    SCENARIO_NUM="$1"
#set -e

    #========================================================
    #                   Common part  (CAUTION!!)
    #  Commands defined here will been executed while user
    #  call this function EVERY TIME.
    #========================================================

    ### Enable logs by scenario number
    ### You can setup kinds of scenario here
    ### Scenario Number is
    case "$SCENARIO_NUM" in
        "10001")
            #############################################################
            #              ( 10001 )  Scenario A - enable OPTEE log
            #
            # Enable OPTEE normal log
            #
            #############################################################
            echo "[INTERCA] IN INTERTACA 10001"
            INIT_BSP_OPTEE_OPTEE 10002
        ;;
        "20001")
            #############################################################
            #              ( 20001 )  Scenario A - enable Factory log
            #
            # Enable Factory log
            #
            #############################################################
            echo "[INTERCA] IN INTERTACA 20001"
            INTERCA_LOG_FP="$LOG_DIR/$LOG_DT-platform_security_intertaca.sh_${SCENARIO_NUM}.log"
            INIT_BSP_OPTEE_OPTEE 10002
            logcat -c
            logcat | grep -ie MtkTvFApi* -ie MI3 > $INTERCA_LOG_FP &
        ;;
        *)
            ######################################################
            #              ( * )  Scenario not defined
            #
            ######################################################
            echo "[INTERCA] SCENARIO_NUM='$SCENARIO_NUM' is not defined in intertaca.sh, please check or contact related RD"
            exit 1
        ;;
    esac

    echo -e "[INTERCA] Init Platform Security InterTACa log Success!\n"
}

CLOSE_PLATFORM_SECURITY_INTERTACA()
{
    kill `pidof logcat`
    echo "[INTERCA] Disable InterTACa log "
    sync
#set -e
    CLOSE_BSP_OPTEE_OPTEE
#set +e
    echo -e "[INTERCA] Close Platform Security InterTACa log Success!\n"
}

EXIT_PLATFORM_SECURITY_INTERTACA()
{
    echo "[INTERCA] Record InterTACa log done"
    echo "[INTERCA] log path: $LOG_FP"
    CLOSE_PLATFORM_SECURITY_INTERTACA
    exit 0
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

    echo "LOG_DIR=$LOG_DIR"
    echo "SCENARIO_NUM=$SCENARIO_NUM"
    INTERTACA_SCENARIO_NUM=$SCENARIO_NUM

    #========================================================
    #                   Main codes here
    # You can modify codes under this section
    #========================================================

    ### Import functions from other modules/scripts
    ### DO SOMETHING
    OpenCommandDebuger $INIT_HISTORY_FP
    INIT_PLATFORM_SECURITY_INTERTACA $SCENARIO_NUM
    CloseCommandDebuger
    PrintCommandDebuger $INIT_HISTORY_FP

    #--------------------------------------
    #Reproduce issue and finishing record.
    case "$INTERTACA_SCENARIO_NUM" in
        "10001")
            trap EXIT_PLATFORM_SECURITY_INTERTACA SIGINT
            echo -e "[INTERCA] Please also record the log on tera term(console), preferably with time"
            echo -e "[INTERCA] Please press [Ctrl+Z] and type 'bg' to make process run in the background"
            echo -e "[INTERCA] After InterTACa issue appears, type 'fg' and press [Ctrl+C] to finishing recording"

            while :
            do
                sleep 1
            done
        ;;
        *)
            echo -e "[INTERCA] Please also record the log on tera term(console), preferably with time"
            echo -e "[INTERCA] After InterTACa issue appears, press [enter] to finishing recording !!!"
            read "abc"
            CLOSE_PLATFORM_SECURITY_INTERTACA
        ;;
    esac
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
