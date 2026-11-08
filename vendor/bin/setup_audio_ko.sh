#!/vendor/bin/sh

#AUDIO KO
amp_model=$(cat /sys/firmware/devicetree/base/mtk-tvsnd-machine/amp-model-cnt)

if [ "$amp_model" ]; then
	for i in $(seq 1 $amp_model)
	do
		cur_amp=$(cat /sys/firmware/devicetree/base/mtk-tvsnd-machine/amp-${i}-name)
		insmod /vendor/lib/modules/snd-amp-${cur_amp}.ko
	done
fi

insmod /vendor/lib/modules/mtk-tvsnd-platform.ko
insmod /vendor/lib/modules/mtk-tvsnd-machine.ko

setprop vendor.mtk.audio_ko 1
