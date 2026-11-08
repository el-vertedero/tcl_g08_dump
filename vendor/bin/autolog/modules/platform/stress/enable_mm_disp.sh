echo "======enable mm & display log======"
logcat -G 256M
setprop vendor.mstar.vsync_bridge.log 1
setprop vendor.mstar.vdec.log 2
setprop vendor.mtk.displink.bm.profile 1
setprop vendor.mtk.c2.enable.comp.log 2
setprop vendor.mtk.c2.enable.vdec.log 2
setprop vendor.mtktv.c2.enable.vdec.log 2
setprop vendor.mtktv.c2.enable.bm.log 2
setprop vendor.mtk.codec2.log 2
setprop mtk.exoplayer.debug.level 11
setprop vendor.mtk.vcodecvideo.log 2
setprop vendor.mtk.vcodecvdecimpl.log 3
setprop vendor.mtk.tpchwc.log 1
setprop vendor.mtk.vsyncbridge.log 1
setprop vendor.mtk.displink.log 1
setprop vendor.mtk.subhalvideo.log 0x40
setprop vendor.hal.c2.audio.log.level VERBOSE
setprop vendor.hal.audio.log.level VERBOSE
setprop vendor.mtk.mipq.debuglevel F0
setprop vendor.mtk.tpc.debug.log 4
setprop vendor.mtk.displink.wrapper.log 1
setprop vendor.mtk.pqlink.setwin.info 1
setprop vendor.mtk.pqlink.performance.profile 1
setprop vendor.mtk.pqlink.log 1
setprop vendor.mtk.mirender.debuglevel 40
setprop vendor.mtk.mirender.debuginfo 417E0000
setprop vendor.mtk.capture_hal.loglevel A
echo 0xFF > /sys/module/drm/parameters/debug
echo 0x400FFFF > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/log_level
echo "======enable mm & display log======[finish]"

