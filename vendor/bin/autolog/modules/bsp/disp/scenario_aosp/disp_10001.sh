#!/usr/bin/env sh

disp_log_open()
{
    chmod 777 /data
    logcat -c && logcat -G 128M && dmesg -C
    LOGCAT_LOG_FP="$(GenLogPath "logcat.log")"

    echo "LOGCAT_LOG_FP=$LOGCAT_LOG_FP"
    echo "Start to enable disp loglevel..."

    echo dbglevel render 0xff >> /proc/MI_DISP
    echo dbginfo render 0x407E0000 >> /proc/MI_DISP
    echo dbglevel disp 0xff >> /proc/MI_DISP
    echo dbginfo disp 0x400000ff >> /proc/MI_DISP
    echo dbglevel pq 0x40 >> /proc/MI_DISP
    echo 1 > /proc/sys/kernel/printk
    echo 0xdff > /sys/devices/platform/mtk-pq/mtk_dbg/log_level
    echo 0x003F0003 > /sys/devices/platform/scriptmanagement/mtk_dbg/log_level
    echo 0x35 > /sys/module/drm/parameters/debug
    echo 0xFFFFFFFF > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/log_level

    echo " Enable disp loglevel Done!"
    logcat -f $LOGCAT_LOG_FP &
    LOGCAT_PID=$!
    echo "logcat pid: $LOGCAT_PID"
}

disp_log_close()
{
    echo dbglevel render 0 >> /proc/MI_DISP
    echo dbginfo render 0 >> /proc/MI_DISP
    echo dbglevel disp 0 >> /proc/MI_DISP
    echo dbginfo disp 0 >> /proc/MI_DISP
    echo dbglevel pq 0 >> /proc/MI_DISP
    echo 1 > /proc/sys/kernel/printk
    echo 0 > /sys/devices/platform/mtk-pq/mtk_dbg/log_level
    echo 0 > /sys/devices/platform/scriptmanagement/mtk_dbg/log_level
    echo 0 > /sys/module/drm/parameters/debug
    echo 0 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/log_level

    echo "kill $LOGCAT_PID"
    kill $LOGCAT_PID

    echo "Finish to dump disp log..."
}
