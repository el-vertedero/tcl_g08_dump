echo "======enable displink and vdec log======"
setprop vendor.mtk.tpc.runtime.syncmode.enable 1
lshal debug vendor.mediatek.hardware.dispservice@1.0::IDispService/default --enable
setprop vendor.mtk.displink.log 1
setprop vendor.mtk.subhalvdec.log 0x40
setprop vendor.mtk.vcodecvideo.log 2
setprop vendor.mtk.vcodecvdecimpl.log 3
setprop vendor.mtk.dispservice.mediator.info.log 1
setprop vendor.mtk.c2bwm.log 3

#################################################
