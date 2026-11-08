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

INIT_PLATFORM_SECURITY_GATEKEEPER()
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
    echo "[GATEKEEPER] Initialize PLATFORM.SECURITY.GATEKEEPER log configs..."
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
            #              ( 20001 )  Scenario A - enable normal log
            #
            # Enable normal log
            #
            #############################################################
            echo "[GATEKEEPER] IN GATEKEEPER 10001"
            GATEKEEPER_LOG_FP="$LOG_DIR/$LOG_DT-platform_security_gatekeeper.sh_${SCENARIO_NUM}.log"
            INIT_BSP_OPTEE_OPTEE 10002
            logcat -c
            kill `ps -A | grep gatekeeper | grep service | awk '{print $2}'`
            logcat | grep -i gatekeeper > $GATEKEEPER_LOG_FP &
        ;;
        *)
            ######################################################
            #              ( * )  Scenario not defined
            #
            ######################################################
            echo "[GATEKEEPER] SCENARIO_NUM='$SCENARIO_NUM' is not defined in gatekeeper.sh, please check or contact related RD"
            exit 1
        ;;
    esac

    echo -e "[GATEKEEPER] Init Platform Security GateKeeper log Success!\n"
}

CLOSE_PLATFORM_SECURITY_GATEKEEPER()
{
    kill `pidof logcat`
    echo "[GATEKEEPER] Disable GateKeeper log "
    sync
#set -e
    CLOSE_BSP_OPTEE_OPTEE
#set +e
    echo -e "[GATEKEEPER] Close Platform Security GateKeeper log Success!\n"
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

    #========================================================
    #                   Main codes here
    # You can modify codes under this section
    #========================================================

    ### Import functions from other modules/scripts
    ### DO SOMETHING
    OpenCommandDebuger $INIT_HISTORY_FP
    INIT_PLATFORM_SECURITY_GATEKEEPER $SCENARIO_NUM
    CloseCommandDebuger
    PrintCommandDebuger $INIT_HISTORY_FP

    #--------------------------------------
    #Reproduce issue and finishing record.
    echo -e "[GATEKEEPER] Please also record the log on tera term(console), preferably with time"
    echo -e "[GATEKEEPER] After GateKeeper issue appears, press [enter] to finishing recording !!!"
    read "abc"
    CLOSE_PLATFORM_SECURITY_GATEKEEPER
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
