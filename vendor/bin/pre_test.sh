#!/vendor/bin/sh
echo "$(date) [IA_M6][AT] before setup AT scripts"
svc bluetooth disable
echo 5 > /proc/sys/kernel/panic
echo "$(date) [IA_M6][AT] after setup AT scripts"

if [ `getprop persist.vendor.mtk.setupAT.mmdbg` == 1 ]; then
logcat -G 64M
setprop vendor.mtk.c2.enable.comp.log 2
setprop vendor.mtk.c2.enable.vdec.log 2
setprop vendor.mtktv.c2.enable.vdec.log 2
setprop vendor.mtktv.c2.enable.bm.log 2
setprop vendor.mtk.vcodecvideo.log 2
setprop vendor.mtk.vcodecvdecimpl.log 3
setprop vendor.mtk.displink.log 1
setprop vendor.mtk.tpchwc.log 1
setprop vendor.mtk.pqlink.log 1
setprop vendor.mtk.tpc.debug.log 4
setprop vendor.mstar.vsync_bridge.log 1
setprop vendor.mstar.vdec.log 2
setprop vendor.mtk.displink.bm.profile 1
setprop vendor.mtk.vsyncbridge.log 1
setprop vendor.mtk.subhalvideo.log 0x40
setprop vendor.mtk.codec2.log 2
setprop vendor.mtk.c2bwm.log 3
setprop vendor.mtk.dispservice.mediator.info.log 1
fi
