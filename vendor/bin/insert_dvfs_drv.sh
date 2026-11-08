#!/bin/sh

if [ "$1" = "early-boot" ]
then
    /vendor/bin/modprobe -d /vendor/lib/modules mtktv-regulator-mt5876.ko mtktv-thermal.ko mtktv-cpufreq.ko cpu-freq-adapter.ko mtktv-gpu-thermal.ko
    echo performance > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
else
    sleep 60
    echo conservative > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
fi