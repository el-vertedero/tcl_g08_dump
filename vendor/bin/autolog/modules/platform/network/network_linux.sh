#!/usr/bin/env sh
. "$AUTOLOG_HOME/utils/imports.sh"

ImportUtil "loggers.sh"
ImportUtil "colors.sh"
ImportUtil "sys.sh"


INIT_PLATFORM_NETWORK_NETWORK_LINUX()
{
    echo "Initialize PLATFORM.NETWORK.NETWORK_LINUX log configs..."
    #  set -e

    SCENARIO_NUM="$1"
case "$SCENARIO_NUM" in
    "10001")
    echo "eth mode"
    cat /proc/sys/net/ipv6/conf/eth0/accept_ra
    cat /proc/sys/net/ipv6/conf/eth0/autoconf
    ;;

    "10002")
    echo "wireless mode"
    cat /proc/sys/net/ipv6/conf/wlan0/accept_ra
    cat /proc/sys/net/ipv6/conf/wlan0/autoconf
    wpa_cli -iwlan0 status
    ;;
esac

    ifconfig -a
    cat /etc/resolv.conf
    route -n
    cat /etc/gai.conf
    ping -c 3 8.8.8.8
    #  set +e
    echo -e "DRMP Init log Success!\n"
}


CLOSE_PLATFORM_NETWORK_NETWORK_LINUX()
{
    #  set -e
    #Log Off
    #  set +e
    echo -e "Close NETWORK log Success!\n"
}


MAIN()
{
    version="v1.0"
    . "$AUTOLOG_HOME/utils/preprocess.sh"


    ### Arguments
    # $log_fp => output log file path
    # $act_log_fp => interactive log output file path
    module_arg1=$1

    ### log settings
    # back-up log level
    #org_printk=$(cat /proc/sys/kernel/printk)
    # start kernel log

    #--------------------------------------
    #Need to open/key log before issue appears
    script_debug_mode=0

    # Open log


    #--------------------------------------
    #Reproduce issue and finishing record.
    echo -e "After issue appears, press enter to finishing recording!"
    if [ "$script_debug_mode" -gt 0 ];then
    set +x && read "abc" && set -x
    else
    read "abc"
    fi
    sleep 1s

    INIT_PLATFORM_NETWORK_NETWORK_LINUX $SCENARIO_NUM

    # Close log
    CLOSE_PLATFORM_NETWORK_NETWORK_LINUX


    ### log settings
    # re-cover log level
    #echo $org_printk > /proc/sys/kernel/printk || echo -e "${COLOR_RED}Change printk error! Permission Denied${COLOR_REST}"

    # stop dmesg running in background jobs
}


if [ "$*" = "--source-only" ]; then
    :
else
    MAIN $*
fi
