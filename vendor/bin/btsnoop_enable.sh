#!/system/bin/sh

dir_bt_stack_conf=/vendor/etc/bluetooth/
bt_stack_conf_origin=bt_stack_origin.conf
bt_stack_conf_enable_log=bt_stack_enable_btsnoop.conf


bt_stack_conf_origin_file=$dir_bt_stack_conf$bt_stack_conf_origin
bt_stack_conf_enable_log_file=$dir_bt_stack_conf$bt_stack_conf_enable_log


echo "$bt_stack_conf_origin_file"
echo "$bt_stack_conf_enable_log_file"


# check parameters
if [ $# != 1 ];then
    echo "USAGE: $0 0/1"
    echo " ----> open btsnoop log failed !!! <-----"
    exit 1;
fi

echo "bt snoop enable $1"

echo "1. mount system"
mount -o rw,remount /

# check mount operation
if [ 0 != $? ];then
    echo " mount system failed ... "
    echo " ----> open btsnoop log failed !!! <-----"
    exit 2;
fi

# check configure file 
if [ ! -e $bt_stack_conf_origin_file -o ! -e $bt_stack_conf_enable_log_file ];then
    echo "bt config not exit ... "
    echo " ----> open btsnoop log failed !!! <-----"
    exit 3;
fi

case $1 in
1)
echo "2. copy bt_stack_enable_btsnoop.conf replace origin"
cp -rf $bt_stack_conf_enable_log_file /vendor/etc/bluetooth/bt_stack.conf
echo "    setprop persist.bluetooth.btsnooplogmode  full"
setprop persist.bluetooth.btsnooplogmode  "full"
echo "    setprop persist.bluetooth.btsnoopsize 0xFFFFF"
setprop persist.bluetooth.btsnoopsize 0xFFFFF
echo "    setprop persist.vendor.bluetooth.btsnoopsavelast true"
setprop persist.vendor.bluetooth.btsnoopsavelast "true"
echo "    setprop persist.bluetooth.btsnoopenable true"
setprop persist.bluetooth.btsnoopenable "true"
;;
0)
echo "2. copy origin bt_stack.conf replace previos"
cp -rf $bt_stack_conf_origin_file /vendor/etc/bluetooth/bt_stack.conf
echo "    setprop persist.bluetooth.btsnooplogmode  disabled"
setprop persist.bluetooth.btsnooplogmode  "disabled"
;;
*)
echo "invalid parameters!!!"
exit 1
;;
esac

chmod 644 /vendor/etc/bluetooth/bt_stack.conf

echo "3. setprop persist.bluetooth.btsnooppath \"/data/misc/bluetooth/logs/btsnoop_hci.log\" "
setprop persist.bluetooth.btsnooppath "/data/misc/bluetooth/logs/btsnoop_hci.log"

echo "4. check prop: "
echo $(getprop persist.bluetooth.btsnooplogmode)
echo $(getprop persist.bluetooth.btsnooppath)

sync
echo "3. please reboot TV"
