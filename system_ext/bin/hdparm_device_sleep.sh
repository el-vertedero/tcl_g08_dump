#!/bin/bash

echo "hdparm device sleep start." > /data/tcl_log/log.txt

function StartHdparm(){
    device=`getprop vold.tcl.device.sleep`
    echo "hdparm device is ${device}" > /data/tcl_log/log.txt
    /system_ext/bin/hdparm -y ${device}
    echo "hdparm sleep ok." >> /data/tcl_log/log.txt
    /system_ext/bin/hdparm -C ${device} > /data/tcl_log/result.txt
    echo "hdparm get status ok." > /data/tcl_log/log.txt
    setprop vold.tcl.device.sleep success
}

StartHdparm

echo "hdparm device sleep end." > /data/tcl_log/log.txt
