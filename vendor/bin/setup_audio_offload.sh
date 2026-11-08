#!/vendor/bin/sh

grep -q Support_Demod=ISDBS3 /proc/cmdline
    if [ $? -eq 0 ];then
    vendor/bin/modprobe -d /vendor/lib/modules \
    mtk-tvsnd-soc-JP.ko audio-public-if.ko audio-ipauth.ko
        echo "JP here."
        region=JP
else
    vendor/bin/modprobe -d /vendor/lib/modules \
    mtk-tvsnd-soc.ko audio-public-if.ko audio-ipauth.ko
        echo "Global here."
        region=Global
fi

setprop vendor.mtk.audio_offload $region