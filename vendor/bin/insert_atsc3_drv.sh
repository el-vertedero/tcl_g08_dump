#!/vendor/bin/sh
#The following module will insert as the same time as bootanimation.
    grep -q Support_Demod=ATSC3 /proc/cmdline
    if [ $? -eq 0 ];then
        #insmod /vendor/lib/modules/cxd2878.ko
        modprobe -d /vendor/lib/modules/ cxd2878.ko
    fi

    grep -q Support_Demod=ISDBS3 /proc/cmdline
    if [ $? -eq 0 ];then
       modprobe -d /vendor/lib/modules/ cxd2857.ko pj593.ko mtk_sc.ko
    fi

    grep -q Support_Demod=0 /proc/cmdline
    if [ $? -eq 0 ];then
        modprobe -d /vendor/lib/modules/ spi-mtkdtv-ci.ko
    fi
