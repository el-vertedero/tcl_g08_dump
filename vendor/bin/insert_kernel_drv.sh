#!/vendor/bin/sh
#The following module will insert as the same time as bootanimation.

    insmod /vendor/lib/modules/mtk-pmu-keypad.ko
    grep -q Support_Demod=0 /proc/cmdline
    if [ $? -eq 0 ];then
        insmod /vendor/lib/modules/mtk_msb9121.ko
        insmod /vendor/lib/modules/mtk_pcmcia.ko
    fi

    grep -q Support_Demod=ISDBS3 /proc/cmdline
    if [ $? -eq 0 ];then
        insmod /vendor/lib/modules/mtk_sc.ko
    fi

    insmod /vendor/lib/modules/mtk-smi-tv.ko
    insmod /vendor/lib/modules/test_power.ko
