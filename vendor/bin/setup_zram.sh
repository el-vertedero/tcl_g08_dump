#!/sbin/sh

#mknod /dev/zram0 b 253 0
#mknod /dev/block/zram0 b 253 0
#mknod /dev/zram1 b 253 1
#mknod /dev/block/zram1 b 253 1

# wait for ueventd to create /dev/block/zram0

insmod /vendor/lib/modules/mzc-mtk.ko
insmod /vendor/lib/modules/mzc.ko
insmod /vendor/lib/modules/mzc_hybrid.ko
insmod /vendor/lib/modules/mtk_zram_genpool.ko
insmod /vendor/lib/modules/mtk_zsmalloc.ko
insmod /vendor/lib/modules/mtk_zram.ko

wait /dev/block/mtk-zram0
if [ -f "/dev/block/mtk-zram0" ]; then
	MTK_ZRAM="mtk-zram0"
else
	MTK_ZRAM="zram0"
fi
/vendor/bin/restorecon /dev/block/${MTK_ZRAM}

# wait for ueventd to create /dev/block/zram1
wait /dev/block/zram1
/vendor/bin/restorecon /dev/block/zram1

# By default, the Linux kernel swaps in 8 pages of memory at a time. When
# using ZRAM, the incremental cost of reading 1 page at a time is negligible
# and may help in case the device is under extreme memory pressure.
/vendor/bin/echo 0 > /proc/sys/vm/page-cluster

# ZRAM in Linux free memory
# ifdef VENDOR_EDIT
# lei6.yao@tcl.com,2023/11/03,modify zram 896M
ZRAM_SIZE=896 # unit: MB , 0 = disable
# endif /* VENDOR_EDIT */
if [ ${ZRAM_SIZE} -ne 0 ] ; then
    /vendor/bin/echo $((${ZRAM_SIZE}*1024*1024)) > /sys/block/${MTK_ZRAM}/disksize
    /vendor/bin/mkswap /dev/block/${MTK_ZRAM}
    # Set higher priority than swam in FBM
    /vendor/bin/swapon /dev/block/${MTK_ZRAM} -p 0
fi
/vendor/bin/echo 1 > /data/vendor/tmp/zram_start