#!/usr/bin/env sh

MAIN()
{
    #Disp hal log level setting
    if [ "$ANDROID_VERSION" -ge 14 ]; then
      dumpsys vendor.mediatek.hardware.ExternIn.IExternIn/default --dbglevel 4
    else
      lshal debug vendor.mediatek.hardware.ExternIn@1.0::IExternIn/ExternIn --dbglevel 4
    fi
    setprop vendor.mtk.tvexoplayer.log all
    setprop vendor.mtk.pqhal.debuglevel 2
    setprop vendor.mtk.mipq.debuglevel 40
    setprop vendor.mtk.mirender.debuglevel 40
    setprop vendor.mtk.mirender.debuginfo 417E0000

    #Disp kernel log level setting
    echo 0 > /proc/sys/kernel/printk
    echo 0xdff > /sys/devices/platform/mtk-pq/mtk_dbg/log_level
    echo 0x003F0003 > /sys/devices/platform/scriptmanagement/mtk_dbg/log_level
    echo 0x35 > /sys/module/drm/parameters/debug
    echo 0xFFFFFFFF > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/log_level
    #Mark this as temp solution
    #echo 6 > /sys/devices/platform/mtk_srccap0/mtk_dbg/log_level
    #Arm PQU
    echo 0x006 > /sys/devices/platform/mtk-tvpqu/mtk_dbg/log_level
    #RV55 PQU
    echo 0x9 | tee /sys/bus/rpmsg/devices/virtio1.pq-pqu-ept.-*/mtk_dbg/log_level
    echo 0x9 | tee /sys/bus/rpmsg/devices/virtio2.pq-pqu-ept.-*/mtk_dbg/log_level
    echo 0x1 | tee /sys/bus/rpmsg/devices/virtio1.pqu-vuart.-*/mtk_dbg/record_log
    echo 0x1 | tee /sys/bus/rpmsg/devices/virtio2.pqu-vuart.-*/mtk_dbg/record_log
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