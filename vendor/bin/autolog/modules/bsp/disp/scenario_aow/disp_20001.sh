#!/usr/bin/env sh

disp_log_open()
{
    setenforce 0
    chmod 777 /data
    logcat -c && logcat -G 128M && dmesg -C
    LOGCAT_LOG_FP="$(GenLogPath "logcat.log")"
    echo "LOGCAT_LOG_FP=$LOGCAT_LOG_FP"
    echo "Start to enable disp loglevel..."
    if [ "$ANDROID_VERSION" -ge 14 ]; then
      dumpsys vendor.mediatek.hardware.ExternIn.IExternIn/default --dbglevel 4
    else
      lshal debug vendor.mediatek.hardware.ExternIn@1.0::IExternIn/ExternIn --dbglevel 4
    fi
    setprop vendor.mtk.vcodeccomponent.log.level 3
    setprop vendor.mtk.tvexoplayer.log all
    setprop vendor.mtk.pqhal.debuglevel 2
    setprop vendor.mtk.mipq.debuglevel 40
    setprop vendor.mtk.mirender.debuglevel 40
    setprop vendor.mtk.mirender.debuginfo 417E0000

    echo 0 > /proc/sys/kernel/printk
    echo 0xdff > /sys/devices/platform/mtk-pq/mtk_dbg/log_level
    echo 0x003F0003 > /sys/devices/platform/scriptmanagement/mtk_dbg/log_level
    echo 0x35 > /sys/module/drm/parameters/debug
    echo 0xFFFFFFFF > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/log_level
    echo 6 > /sys/devices/platform/mtk_srccap0/mtk_dbg/log_level

    echo " Enable disp loglevel Done!"
    logcat -f $LOGCAT_LOG_FP &
    LOGCAT_PID=$!
    echo "logcat pid: $LOGCAT_PID"
}

disp_log_close()
{
    if [ "$ANDROID_VERSION" -ge 14 ]; then
      dumpsys vendor.mediatek.hardware.ExternIn.IExternIn/default --dbglevel 2
    else
      lshal debug vendor.mediatek.hardware.ExternIn@1.0::IExternIn/ExternIn --dbglevel 2
    fi
    setprop vendor.mtk.vcodeccomponent.log.level 0
    setprop vendor.mtk.tvexoplayer.log info
    setprop vendor.mtk.pqhal.debuglevel 0
    setprop vendor.mtk.mipq.debuglevel 0
    setprop vendor.mtk.mirender.debuglevel 0
    setprop vendor.mtk.mirender.debuginfo 0

    echo 1 > /proc/sys/kernel/printk
    echo 0 > /sys/devices/platform/mtk-pq/mtk_dbg/log_level
    echo 0 > /sys/devices/platform/scriptmanagement/mtk_dbg/log_level
    echo 0 > /sys/module/drm/parameters/debug
    echo 0 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/log_level
    echo 0 > /sys/devices/platform/mtk_srccap0/mtk_dbg/log_level

    echo "kill $LOGCAT_PID"
    kill $LOGCAT_PID

    echo "Finish to dump disp log..."
}
