#!/vendor/bin/sh

#AUDIO KO

insmod /vendor/lib/modules/mtk-tvsnd-dsp-loader.ko
insmod /vendor/lib/modules/mtk-tvsnd-platform.ko
insmod /vendor/lib/modules/mtk-tvsnd-machine.ko

setprop vendor.mtk.audio_ko 1
