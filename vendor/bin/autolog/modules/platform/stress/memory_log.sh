#!/bin/bash
#echo "\033[1m \033[4m"
#echo "[AUTOLOG] In memory_log.sh: $1|$2|$3\033[0m"

if [ "$2" == "" ]; then
    path=/data
else
    path=$2
fi

if [ "$3" == "" ]; then
    sleepTime=600
else
    sleepTime=$3
fi

platform=$1
dir=""
mem_summary=""
dump_count=1

if [ "$platform" == "fusion_an" ] || [ "$platform" == "fusion_linux" ]; then
    if [ "$path" == "" ]; then
        tmp_dir="/data"
    else
        tmp_dir=$path
    fi
    busybox=""
    mmap_file="/vendor/tvconfig/config/MMAP_MI.h"
    cusdata_mmap_file="/vendor/cusdata/bsp/common/MMAP_MI.h"
elif [ "$platform" == "sn_linux" ]; then
    if [ "$path" == "" ]; then
        tmp_dir="/OAD"
    else
        tmp_dir=$path
    fi
    busybox=""
    mmap_file="/config/mmap.ini"
elif [ "$platform" == "sn_an" ]; then
    if [ "$path" == "" ]; then
        tmp_dir="/data"
    else
        tmp_dir=$path
    fi
    busybox="busybox"
    mmap_file="/tvconfig/config/mmap.ini"
elif [ "$platform" == "merak" ]; then
    if [ "$path" == "" ]; then
        tmp_dir="/data"
    else
        tmp_dir=$path
    fi
    busybox=""
    mmap_dtbo_path="/proc/device-tree/mmap_info"
else
    if [ "$path" == "" ]; then
        tmp_dir="/data"
    else
        tmp_dir=$path
    fi
    busybox=""
    mmap_file="/vendor/tvconfig/config/MMAP_MI.h"
fi

memblock_memory_file="/sys/kernel/debug/memblock/memory"
cpuinfo_file="/proc/cpuinfo"
kernel_version_file="/proc/version"
ion_dir="/sys/kernel/debug/ion"
cma_dir="/sys/kernel/debug/cma"
bufinfo_file="/sys/kernel/debug/dma_buf/bufinfo"
debugfs_mma_meminfo_file="/sys/kernel/debug/mma/meminfo"
sysfs_mma_meminfo_file="/sys/kernel/mma/meminfo"
sti_iommu_file="/sys/class/iommu/mtk-dtv-iommu/mtk_dbg/meminfo"
media_mem_file="/proc/media-mem"
cmainfo_file="/proc/cmainfo"
comp_algorithm_file="/sys/block/zram0/comp_algorithm"
mm_stat_file="/sys/block/zram0/mm_stat"
orig_data_size_file="/sys/block/zram0/orig_data_size"
compr_data_size_file="/sys/block/zram0/compr_data_size"
mem_used_total_file="/sys/block/zram0/mem_used_total"
zero_pages_file="/sys/block/zram0/zero_pages"
proc_meminfo_file="/proc/meminfo"
vmstat_file="/proc/vmstat"
zoneinfo_file="/proc/zoneinfo"
slabinfo_file="/proc/slabinfo"
vmallocinfo_file="/proc/vmallocinfo"
kernel_config_file="/proc/config.gz"
bootargs_file="/proc/cmdline"
pagetypeinfo_file="/proc/pagetypeinfo"

func_init()
{
    mem_summary=""
    
    KERNEL_BITS="0"
    KERNEL_VERSION="0"
    LX_SIZE="0"
    DRAM_SIZE="0"
    VMALLOCINFO_VMALLOC_TOTAL_SIZE="0"
    VMALLOCINFO_VMALLOC_PAGE_ALLOC_SIZE="0"
    VMALLOCINFO_LOAD_MODULE_SIZE="0"
    VMALLOCINFO_DRV_ALLOC_SIZE="0"
    SLABINFO_SLAB_UNRECLAIM_SIZE="0"
    SLABINFO_KMALLOC_SIZE="0"
    SLABINFO_KRN_SRC_SIZE="0"
    CMAINFO_CMA_HWIP_USED_SIZE="0"
    PROC_MEMINFO_MEMTOTAL_SIZE="0"
    PROC_MEMINFO_MEMFREE_SIZE="0"
    PROC_MEMINFO_MEMAVAILABLE_SIZE="0"
    PROC_MEMINFO_BUFFERS_SIZE="0"
    PROC_MEMINFO_CACHED_SIZE="0"
    PROC_MEMINFO_SWAPCACHED_SIZE="0"
    PROC_MEMINFO_ACTIVE_SIZE="0"
    PROC_MEMINFO_INACTIVE_SIZE="0"
    PROC_MEMINFO_ACTIVE_ANON_SIZE="0"
    PROC_MEMINFO_INACTIVE_ANON_SIZE="0"
    PROC_MEMINFO_ACTIVE_FILE_SIZE="0"
    PROC_MEMINFO_INACTIVE_FILE_SIZE="0"
    PROC_MEMINFO_UNEVICTABLE_SIZE="0"
    PROC_MEMINFO_MLOCKED_SIZE="0"
    PROC_MEMINFO_HIGHTOTAL_SIZE="0"
    PROC_MEMINFO_HIGHFREE_SIZE="0"
    PROC_MEMINFO_LOWTOTAL_SIZE="0"
    PROC_MEMINFO_LOWFREE_SIZE="0"
    PROC_MEMINFO_SWAPTOTAL_SIZE="0"
    PROC_MEMINFO_SWAPFREE_SIZE="0"
    PROC_MEMINFO_DIRTY_SIZE="0"
    PROC_MEMINFO_WRITEBACK_SIZE="0"
    PROC_MEMINFO_ANONPAGES_SIZE="0"
    PROC_MEMINFO_MAPPED_SIZE="0"
    PROC_MEMINFO_SHMEM_SIZE="0"
    PROC_MEMINFO_SLAB_SIZE="0"
    PROC_MEMINFO_SRECLAIMABLE_SIZE="0"
    PROC_MEMINFO_SUNRECLAIM_SIZE="0"
    PROC_MEMINFO_KERNELSTACK_SIZE="0"
    PROC_MEMINFO_PAGETABLES_SIZE="0"
    PROC_MEMINFO_NFS_UNSTABLE_SIZE="0"
    PROC_MEMINFO_BOUNCE_SIZE="0"
    PROC_MEMINFO_WRITEBACKTMP_SIZE="0"
    PROC_MEMINFO_COMMITLIMIT_SIZE="0"
    PROC_MEMINFO_COMMITTED_AS_SIZE="0"
    PROC_MEMINFO_VMALLOCTOTAL_SIZE="0"
    PROC_MEMINFO_VMALLOCUSED_SIZE="0"
    PROC_MEMINFO_VMALLOCCHUNK_SIZE="0"
    PROC_MEMINFO_PERCPU_SIZE="0"
    PROC_MEMINFO_CMATOTAL_SIZE="0"
    PROC_MEMINFO_CMAFREE_SIZE="0"
    PROC_MEMINFO_CMA_USED_SIZE="0"
    PROC_MEMINFO_SWAP_USED_SIZE="0"
    PROC_MEMINFO_ZRAM_MINUS_SWAP_SIZE="0"
    PROC_MEMINFO_CACHED_KERNEL_SIZE="0"
    PROC_MEMINFO_FREE_RAM_SIZE="0"
    DUMPSYS_MEMINFO_NATIVE_SIZE="0"
    DUMPSYS_MEMINFO_SYSTEM_SIZE="0"
    DUMPSYS_MEMINFO_PERSISTENT_SIZE="0"
    DUMPSYS_MEMINFO_PERSISTENT_SERVICE_SIZE="0"
    DUMPSYS_MEMINFO_FOREGROUND_SIZE="0"
    DUMPSYS_MEMINFO_VISIBLE_SIZE="0"
    DUMPSYS_MEMINFO_PERCEPTIBLE_SIZE="0"
    DUMPSYS_MEMINFO_BACKUP_SIZE="0"
    DUMPSYS_MEMINFO_HEAVY_WEIGHT_SIZE="0"
    DUMPSYS_MEMINFO_A_SERVICE_SIZE="0"
    DUMPSYS_MEMINFO_HOME_SIZE="0"
    DUMPSYS_MEMINFO_PREVIOUS_SIZE="0"
    DUMPSYS_MEMINFO_B_SERVICE_SIZE="0"
    DUMPSYS_MEMINFO_CACHED_SIZE="0"
    DUMPSYS_MEMINFO_DTV_SVC_SIZE="0"
    DUMPSYS_MEMINFO_MIDAEMON_SIZE="0"
    DUMPSYS_MEMINFO_APP_MAN_SIZE="0"
    DUMPSYS_MEMINFO_TVOS_SIZE="0"
    DUMPSYS_MEMINFO_TOTAL_RAM_SIZE="0"
    DUMPSYS_MEMINFO_FREE_RAM_SIZE="0"
    DUMPSYS_MEMINFO_CACHED_PSS_SIZE="0"
    DUMPSYS_MEMINFO_CACHED_KERNEL_SIZE="0"
    DUMPSYS_MEMINFO_FREE_SIZE="0"
    DUMPSYS_MEMINFO_USED_RAM_SIZE="0"
    DUMPSYS_MEMINFO_USED_PSS_SIZE="0"
    DUMPSYS_MEMINFO_KERNEL_SIZE="0"
    DUMPSYS_MEMINFO_LOST_RAM_SIZE="0"
    DUMPSYS_MEMINFO_SWAP_TOTAL_SIZE="0"
    DUMPSYS_MEMINFO_SWAP_USED_SIZE="0"
    DUMPSYS_MEMINFO_ZRAM_TOTAL_SIZE="0"
    DUMPSYS_MEMINFO_GL_MTRACK_SIZE="0"
    DUMPSYS_MEMINFO_EGL_MTRACK_SIZE="0"
    DUMPSYS_MEMINFO_NETFLIX_SIZE="0"
    DUMPSYS_MEMINFO_AMAZON_PRIMEVIDEO_SIZE="0"
    DUMPSYS_MEMINFO_YOUTUBE_SIZE="0"
    DUMPSYS_MEMINFO_TOTAL_PSS_WO_SWAP_SIZE="0"
    DUMPSYS_MEMINFO_TOTAL_SWAP_PSS_SIZE="0"
    DUMPSYS_MEMINFO_TV_DAEMON_SIZE="0"
    DUMPSYS_MEMINFO_ANDROID_USAGE_SIZE="0"
    DUMPSYS_MEMINFO_CUSTOMER_USAGE_SIZE="0"
    DUMPSYS_MEMINFO_VENDOR_USAGE_SIZE="0"
    DUMPSYS_MEMINFO_CSP_USAGE_SIZE="0"
    DUMPSYS_MEMINFO_ZRAM_MINUS_SWAP_SIZE="0"
    DUMPSYS_MEMINFO_ION_SIZE="0"
    DUMPSYS_MEMINFO_ION_MAPPED_SIZE="0"
    PROCRANK_TOTAL_PSS_SIZE="0"
    PROCRANK_TOTAL_SWAP_PSS_SIZE="0"
    PROCRANK_DTV_SVC_SIZE="0"
    PROCRANK_MI_DAEMON_SYS_SIZE="0"
    PROCRANK_TVOS_SIZE="0"
    PROCRANK_JARVES_SIZE="0"
    PROCRANK_NETFLIX_SIZE="0"
    PROCRANK_AMAZON_PRIMEVIDEO_SIZE="0"
    PROCRANK_YOUTUBE_SIZE="0"
    PROCRANK_USED_PSS_SIZE="0"
    PROCRANK_TV_DAEMON_SIZE="0"
    GPU_MEMORY_MALI_TOTAL_SIZE="0"
    GPU_MEMORY_NETFLIX_MALI_SIZE="0"
    GPU_MEMORY_AMAZON_PRIMEVIDEO_MALI_SIZE="0"
    GPU_MEMORY_YOUTUBE_MALI_SIZE="0"
    NETFLIX_MEMORY_USAGE="0"
    AMAZON_PRIMEVIDEO_MEMORY_USAGE="0"
    YOUTUBE_MEMORY_USAGE="0"
    BUFINFO_ION_SIZE="0"
    IOMMU_TOTAL_SIZE="0"
    IOMMU_VDEC_FB_SIZE="0"
    IOMMU_VDEC_ES_SIZE="0"
    IOMMU_SHM_BUF_VDEC_SIZE="0"
    IOMMU_MAP_SG_SIZE="0"
    IOMMU_XC_FRC_SIZE="0"
    IOMMU_XC_MAIN_SIZE="0"
    IOMMU_MALI_GOP_SIZE="0"
    IOMMU_DIRECTFB_FRAME_SIZE="0"
    IOMMU_TSP_FIQ_SIZE="0"
    IOMMU_XC_HSE_SIZE="0"
    IOMMU_TSP_PVR_SIZE="0"
    IOMMU_TSP_FILEIN="0"
    IOMMU_INJECT_FILEIN="0"
    ZRAM_ORIG_DATA_SIZE="0"
    ZRAM_COMPR_DATA_SIZE="0"
    ZRAM_MEM_USED_TOTAL="0"
    ZRAM_ZERO_PAGES_SIZE="0"
    ZRAM_COMP_ALGORITHM="0"
    SYSTEM_MMAP_PREALLOCATED_SIZE="0"
    SYSTEM_HW_IP_TOTAL_USED_SIZE="0"
    SYSTEM_ZRAM_COMPR_RATIO="0"
    SYSTEM_KERNEL_RESERVED_SIZE="0"
    SYSTEM_KERNEL_SPACE_USAGE_SIZE="0"
    SYSTEM_USER_SPACE_USAGE_SIZE="0"
    SYSTEM_LOST_RAM_SIZE="0"
    SYSTEM_BSP_SIZE="0"
    SYSTEM_ANDROID_TOTAL_SIZE="0"
}

func_dump_meminfo()
{
    echo -e "<MEM_ANALYZER> BEGIN DUMP MEMINFO"

    rm -rf $tmp_dir/meminfo_log/$dir
    mkdir -p $tmp_dir/meminfo_log/$dir
    cd $tmp_dir/meminfo_log/$dir

    if [ "$platform" == "merak" ]; then
        for FILE in $mmap_dtbo_path/*; do [[ -f "$FILE/reg" ]] && ((echo "$FILE" | awk -F'/' '{printf $5" "}' && xxd $FILE/reg -g4 | awk '{print $5}') >> mmap_dtbo.log); done;
        awk 1 $mmap_dtbo_path/MMAP_PROPERTY/mmap_size >> mmap_dtbo.log
    else
    [[ -f "$mmap_file" ]] && (cat "$mmap_file" > mmap.log) || ([[ -f "$cusdata_mmap_file" ]] && cat "$cusdata_mmap_file" > mmap.log)
    fi
    [[ -f "$memblock_memory_file" ]] && (cat "$memblock_memory_file" > memblock_memory.log)
    [[ -f "$cpuinfo_file" ]] && (cat "$cpuinfo_file" > cpuinfo.log)
    [[ -f "$kernel_version_file" ]] && (cat "$kernel_version_file" > kernel_version.log)
    [[ -d "$ion_dir" ]] && (cp -r "$ion_dir" ./)
    [[ -d "$cma_dir" ]] && (cp -r "$cma_dir" ./)
    [[ -f "$bufinfo_file" ]] && (cat "$bufinfo_file" > bufinfo.log)
    [[ -f "$debugfs_mma_meminfo_file" ]] && (cat "$debugfs_mma_meminfo_file" > iommu.log) ||
        ([[ -f "$sysfs_mma_meminfo_file" ]] && echo 3 > "$sysfs_mma_meminfo_file"; dmesg -C && cat "$sysfs_mma_meminfo_file" && dmesg | grep "mma:" > iommu.log; sed -i "s/.*mma://g" iommu.log ||
        (buf_tags=$(echo 2 > $sti_iommu_file; cat $sti_iommu_file > iommu_buf_tags.log; sed -i "1d;/buf_tag/d;/Total size/d;/CMA size/d" iommu_buf_tags.log; ${busybox} awk '{print $1}' iommu_buf_tags.log); for i in $buf_tags; do echo $i > $sti_iommu_file; cat $sti_iommu_file >> iommu.log; done; sed -i "s/.*IOMMU://g" iommu.log))
    [[ -f "$media_mem_file" ]] && (cat "$media_mem_file" > media-mem.log)
    [[ -f "$cmainfo_file" ]] && (cat "$cmainfo_file" > cmainfo.log)
    cat /sys/kernel/debug/mali*/gpu_memory > gpu_memory.log
    if [ ! -s "./gpu_memory.log" ]; then
        for ctx in `ls /proc/mali/ctx`; do 
            tmp_pid=$(echo -n $ctx | cut -d "_" -f 1)
            tmp_mali=$(cat /proc/mali/ctx/$ctx/memory_current)
            echo "$tmp_pid $tmp_mali" >> proc_mali_ctx.log
        done
    fi
    lsmod | sort -k2rn > lsmod.log
    sysctl -ae 2>/dev/null | grep "vm." > vm_attribute.log

    [[ -f "$comp_algorithm_file" ]] && (cat "$comp_algorithm_file" > zram_comp_algorithm.log)
    [[ -f "$mm_stat_file" ]] && (cat "$mm_stat_file" > zram_mm_stat.log)
    if [ ! -s "./zram_mm_stat.log" ]; then
        [[ -f "$orig_data_size_file" ]] && (cat "$orig_data_size_file" > zram_orig_data_size.log)
        [[ -f "$compr_data_size_file" ]] && (cat "$compr_data_size_file" > zram_compr_data_size.log)
        [[ -f "$mem_used_total_file" ]] && (cat "$mem_used_total_file" > zram_mem_used_total.log)
        [[ -f "$zero_pages_file" ]] && (cat "$zero_pages_file" > zram_zero_pages.log)
    fi

    if [ "$platform" == "sn_linux" ]; then
        mount -o remount,rw /applications
        chmod 777 /applications/bin/showmap.sh
        sed -i 's/\/ps\/d/\/ ps\/d/g' /applications/bin/showmap.sh
        /applications/bin/showmap.sh > procrank.log
    elif [ "$platform" == "fusion_linux" ]; then
        procrank > builtin_procrank.log
        /data/showmap.sh > procrank.log
    else
        procrank > builtin_procrank.log
        dumpsys -t 60 meminfo -S > dumpsys_meminfo.log
        is_rss=$(grep RSS dumpsys_meminfo.log)
        [[ -n "$is_rss" ]] && (mv dumpsys_meminfo.log rss_dumpsys_meminfo.log ; cat rss_dumpsys_meminfo.log | tac | ${busybox} sed '/Total PSS by process:/{p:a;N;$!ba;d}' | tac > dumpsys_meminfo.log)
        getprop | grep "ro.build.version.release" > an_version.log
        dumpsys SurfaceFlinger > dumpsys_surfaceflinger.log
        getprop > getprop.log
        /system/bin/dmabuf_dump -a >> bufinfo.log
    fi

    [[ -f "$proc_meminfo_file" ]] && (cat "$proc_meminfo_file" > meminfo.log)
    [[ -f "$vmstat_file" ]] && (cat "$vmstat_file" > vmstat.log)
    [[ -f "$zoneinfo_file" ]] && (cat "$zoneinfo_file" > zoneinfo.log)
    [[ -f "$slabinfo_file" ]] && (cat "$slabinfo_file" > slabinfo.log)
    [[ -f "$vmallocinfo_file" ]] && (cat "$vmallocinfo_file" > vmallocinfo.log)
    [[ -f "$pagetypeinfo_file" ]] && (cat "$pagetypeinfo_file" > pagetypeinfo.log)
    [[ -f "$bootargs_file" ]] && (cat "$bootargs_file" > bootargs.log)
    [[ -f "$kernel_config_file" ]] && (zcat "$kernel_config_file" > kernel_config.log)

    if [ "$platform" == "sn_linux" ] || [ "$platform" == "sn_an" ]; then
        ps > ps.log
    elif [ "$platform" == "fusion_linux" ]; then
        ps ax > ps.log
    else
        ps -A > ps.log
    fi

    echo -e "<MEM_ANALYZER> END DUMP MEMINFO"
}

func_parse_proc_meminfo()
{
    if [ -s "./meminfo.log" ]; then
        PROC_MEMINFO_MEMTOTAL_SIZE=$(op=$(cat meminfo.log | ${busybox} awk '$1 == "MemTotal:" {print $2}');[ -z "$op" ] && echo "0" || echo "$op")
        PROC_MEMINFO_MEMFREE_SIZE=$(op=$(cat meminfo.log | ${busybox} awk '$1 == "MemFree:" {print $2}');[ -z "$op" ] && echo "0" || echo "$op")
        PROC_MEMINFO_BUFFERS_SIZE=$(op=$(cat meminfo.log | ${busybox} awk '$1 == "Buffers:" {print $2}');[ -z "$op" ] && echo "0" || echo "$op")
        PROC_MEMINFO_CACHED_SIZE=$(op=$(cat meminfo.log | ${busybox} awk '$1 == "Cached:" {print $2}');[ -z "$op" ] && echo "0" || echo "$op")
        PROC_MEMINFO_SWAPTOTAL_SIZE=$(op=$(cat meminfo.log | ${busybox} awk '$1 == "SwapTotal:" {print $2}');[ -z "$op" ] && echo "0" || echo "$op")
        PROC_MEMINFO_SWAPFREE_SIZE=$(op=$(cat meminfo.log | ${busybox} awk '$1 == "SwapFree:" {print $2}');[ -z "$op" ] && echo "0" || echo "$op")
        PROC_MEMINFO_MAPPED_SIZE=$(op=$(cat meminfo.log | ${busybox} awk '$1 == "Mapped:" {print $2}');[ -z "$op" ] && echo "0" || echo "$op")
        PROC_MEMINFO_SHMEM_SIZE=$(op=$(cat meminfo.log | ${busybox} awk '$1 == "Shmem:" {print $2}');[ -z "$op" ] && echo "0" || echo "$op")
        PROC_MEMINFO_SLAB_SIZE=$(op=$(cat meminfo.log | ${busybox} awk '$1 == "Slab:" {print $2}');[ -z "$op" ] && echo "0" || echo "$op")
        PROC_MEMINFO_SRECLAIMABLE_SIZE=$(op=$(cat meminfo.log | ${busybox} awk '$1 == "SReclaimable:" {print $2}');[ -z "$op" ] && echo "0" || echo "$op")
        PROC_MEMINFO_SUNRECLAIM_SIZE=$(op=$(cat meminfo.log | ${busybox} awk '$1 == "SUnreclaim:" {print $2}');[ -z "$op" ] && echo "0" || echo "$op")
        PROC_MEMINFO_KERNELSTACK_SIZE=$(op=$(cat meminfo.log | ${busybox} awk '$1 == "KernelStack:" {print $2}');[ -z "$op" ] && echo "0" || echo "$op")
        PROC_MEMINFO_PAGETABLES_SIZE=$(op=$(cat meminfo.log | ${busybox} awk '$1 == "PageTables:" {print $2}');[ -z "$op" ] && echo "0" || echo "$op")
        PROC_MEMINFO_CMATOTAL_SIZE=$(op=$(cat meminfo.log | ${busybox} awk '$1 == "CmaTotal:" {print $2}');[ -z "$op" ] && echo "0" || echo "$op")
        PROC_MEMINFO_CMAFREE_SIZE=$(op=$(cat meminfo.log | ${busybox} awk '$1 == "CmaFree:" {print $2}');[ -z "$op" ] && echo "0" || echo "$op")
    fi
}

func_parse_dumpsys_meminfo()
{
    if [ -s "./dumpsys_meminfo.log" ]; then
        DUMPSYS_MEMINFO_DTV_SVC_SIZE=$(op=$(cat dumpsys_meminfo.log | ${busybox} sed '/Total PSS by OOM adjustment:/,$d' | grep "dtv_svc" | ${busybox} sed "s/K://g; s/,//g" | ${busybox} awk '{sum+=$1} END{print sum}');[ -z "$op" ] && echo "0" || echo "$op")
        DUMPSYS_MEMINFO_MIDAEMON_SIZE=$(op=$(cat dumpsys_meminfo.log | ${busybox} sed '/Total PSS by OOM adjustment:/,$d' | grep "midaemon" | ${busybox} sed "s/K://g; s/,//g" | ${busybox} awk '{sum+=$1} END{print sum}');[ -z "$op" ] && echo "0" || echo "$op")
        DUMPSYS_MEMINFO_APP_MAN_SIZE=$(op=$(cat dumpsys_meminfo.log | ${busybox} sed '/Total PSS by OOM adjustment:/,$d' | grep "app_man" | ${busybox} sed "s/K://g; s/,//g" | ${busybox} awk '{sum+=$1} END{print sum}');[ -z "$op" ] && echo "0" || echo "$op")
        DUMPSYS_MEMINFO_TVOS_SIZE=$(op=$(cat dumpsys_meminfo.log | ${busybox} sed '/Total PSS by OOM adjustment:/,$d' | grep "tvos" | ${busybox} sed "s/K://g; s/,//g" | ${busybox} awk '{sum+=$1} END{print sum}');[ -z "$op" ] && echo "0" || echo "$op")
        DUMPSYS_MEMINFO_TOTAL_RAM_SIZE=$(op=$(grep "Total RAM:" dumpsys_meminfo.log | ${busybox} sed "s/K//g; s/,//g" | ${busybox} awk '{print $3}');[ -z "$op" ] && echo "0" || echo "$op")
        DUMPSYS_MEMINFO_FREE_RAM_SIZE=$(op=$(grep "Free RAM:" dumpsys_meminfo.log | ${busybox} sed "s/K//g; s/,//g" | ${busybox} awk '{print $3}');[ -z "$op" ] && echo "0" || echo "$op")
        DUMPSYS_MEMINFO_CACHED_PSS_SIZE=$(op=$(grep "cached pss" dumpsys_meminfo.log | ${busybox} awk '{print $(NF-9)}' | ${busybox} sed "s/(//g; s/K//g; s/,//g");[ -z "$op" ] && echo "0" || echo "$op")
        DUMPSYS_MEMINFO_CACHED_KERNEL_SIZE=$(op=$(grep "cached kernel" dumpsys_meminfo.log | ${busybox} awk '{print $9}' | ${busybox} sed "s/(//g; s/K//g; s/,//g");[ -z "$op" ] && echo "0" || echo "$op")
        DUMPSYS_MEMINFO_FREE_SIZE=$(op=$(grep "cached kernel" dumpsys_meminfo.log | ${busybox} awk '{print $(NF-1)}' | ${busybox} sed "s/(//g; s/K//g; s/,//g");[ -z "$op" ] && echo "0" || echo "$op")
        DUMPSYS_MEMINFO_ION_SIZE=$(op=$(grep "ION:" dumpsys_meminfo.log | ${busybox} sed "s/K//g; s/,//g" | ${busybox} awk '{print $2}');[ -z "$op" ] && echo "0" || echo "$op")
        DUMPSYS_MEMINFO_ION_MAPPED_SIZE=$(op=$(grep "ION:" dumpsys_meminfo.log | ${busybox} sed "s/K//g; s/,//g" | ${busybox} awk '{print $4}');[ -z "$op" ] && echo "0" || echo "$op")
        DUMPSYS_MEMINFO_USED_RAM_SIZE=$(op=$(grep "Used RAM:" dumpsys_meminfo.log | ${busybox} sed "s/K//g; s/,//g" | ${busybox} awk '{print $3}');[ -z "$op" ] && echo "0" || echo "$op")
        DUMPSYS_MEMINFO_USED_PSS_SIZE=$(op=$(grep "used pss" dumpsys_meminfo.log | ${busybox} awk '{print $(NF-5)}' | ${busybox} sed "s/(//g; s/K//g; s/,//g");[ -z "$op" ] && echo "0" || echo "$op")
        DUMPSYS_MEMINFO_KERNEL_SIZE=$(op=$(grep "used pss" dumpsys_meminfo.log | ${busybox} awk '{print $(NF-1)}' | ${busybox} sed "s/(//g; s/K//g; s/,//g");[ -z "$op" ] && echo "0" || echo "$op")
        DUMPSYS_MEMINFO_LOST_RAM_SIZE=$(op=$(grep "Lost RAM:" dumpsys_meminfo.log | ${busybox} awk '{print $3}' | ${busybox} sed "s/K//g; s/,//g");[ -z "$op" ] && echo "0" || echo "$op")
        DUMPSYS_MEMINFO_SWAP_TOTAL_SIZE=$(op=$(grep "ZRAM:" dumpsys_meminfo.log | ${busybox} awk '{print $(NF-2)}' | ${busybox} sed "s/(//g; s/K//g; s/,//g");[ -z "$op" ] && echo "0" || echo "$op")
        DUMPSYS_MEMINFO_SWAP_USED_SIZE=$(op=$(grep "ZRAM:" dumpsys_meminfo.log | ${busybox} awk '{print $6}' | ${busybox} sed "s/K//g; s/,//g");[ -z "$op" ] && echo "0" || echo "$op")
        DUMPSYS_MEMINFO_ZRAM_TOTAL_SIZE=$(op=$(grep "ZRAM:" dumpsys_meminfo.log | ${busybox} awk '{print $2}' | ${busybox} sed "s/K//g; s/,//g");[ -z "$op" ] && echo "0" || echo "$op")
        DUMPSYS_MEMINFO_GL_MTRACK_SIZE=$(op=$(cat dumpsys_meminfo.log | grep " GL mtrack" | ${busybox} sed "s/K://g; s/,//g" | ${busybox} awk 'NR==1{print $1}');[ -z "$op" ] && echo "0" || echo "$op")
        DUMPSYS_MEMINFO_EGL_MTRACK_SIZE=$(op=$(cat dumpsys_meminfo.log | grep " EGL mtrack" | ${busybox} sed "s/K://g; s/,//g" | ${busybox} awk 'NR==1{print $1}');[ -z "$op" ] && echo "0" || echo "$op")
        DUMPSYS_MEMINFO_NETFLIX_SIZE=$(op=$(cat dumpsys_meminfo.log | ${busybox} sed '/: Cached/,$d' | tac | ${busybox} sed '/Total PSS by OOM adjustment:/,$d' | grep "ninja" | ${busybox} sed "s/K://g; s/,//g" | ${busybox} awk 'NR==1{print $1}');[ -z "$op" ] && echo "0" || echo "$op")
        DUMPSYS_MEMINFO_AMAZON_PRIMEVIDEO_SIZE=$(op=$(cat dumpsys_meminfo.log | ${busybox} sed '/: Cached/,$d' | tac | ${busybox} sed '/Total PSS by OOM adjustment:/,$d' | grep "amazonvideo.livingroom" | ${busybox} sed "s/K://g; s/,//g" | ${busybox} awk 'NR==1{print $1}');[ -z "$op" ] && echo "0" || echo "$op")
        DUMPSYS_MEMINFO_YOUTUBE_SIZE=$(op=$(cat dumpsys_meminfo.log | ${busybox} sed '/: Cached/,$d' | tac | ${busybox} sed '/Total PSS by OOM adjustment:/,$d' | grep "youtube.tv (" | ${busybox} sed "s/K://g; s/,//g" | ${busybox} awk 'NR==1{print $1}');[ -z "$op" ] && echo "0" || echo "$op")
        if [ "$platform" == "merak" ]; then
            DUMPSYS_MEMINFO_USED_PSS_SIZE=$((${DUMPSYS_MEMINFO_USED_PSS_SIZE}-${DUMPSYS_MEMINFO_ION_MAPPED_SIZE}))
            DUMPSYS_MEMINFO_TVCENTER_SIZE=$(op=$(cat dumpsys_meminfo.log | ${busybox} sed '/: Cached/,$d' | tac | ${busybox} sed '/Total PSS by OOM adjustment:/,$d' | grep "tv.oneworld.tvcenter" | ${busybox} sed "s/K://g; s/,//g" | ${busybox} awk 'NR==1{print $1}');[ -z "$op" ] && echo "0" || echo "$op")
            DUMPSYS_MEMINFO_TVAGENT_SIZE=$(op=$(cat dumpsys_meminfo.log | ${busybox} sed '/: Cached/,$d' | tac | ${busybox} sed '/Total PSS by OOM adjustment:/,$d' | grep "tv.agent" | ${busybox} sed "s/K://g; s/,//g" | ${busybox} awk 'NR==1{print $1}');[ -z "$op" ] && echo "0" || echo "$op")
            DUMPSYS_MEMINFO_MVIEW_PLAYER_SIZE=$(op=$(cat dumpsys_meminfo.log | ${busybox} sed '/: Cached/,$d' | tac | ${busybox} sed '/Total PSS by OOM adjustment:/,$d' | grep "muti_playback" | ${busybox} sed "s/K://g; s/,//g" | ${busybox} awk 'NR==1{print $1}');[ -z "$op" ] && echo "0" || echo "$op")
            DUMPSYS_MEMINFO_ATSCTUNER_SIZE=$(op=$(cat dumpsys_meminfo.log | ${busybox} sed '/: Cached/,$d' | tac | ${busybox} sed '/Total PSS by OOM adjustment:/,$d' | grep "dtv.tvinput.atsctuner" | ${busybox} sed "s/K://g; s/,//g" | ${busybox} awk 'NR==1{print $1}');[ -z "$op" ] && echo "0" || echo "$op")
            DUMPSYS_MEMINFO_DVBTUNER_SIZE=$(op=$(cat dumpsys_meminfo.log | ${busybox} sed '/: Cached/,$d' | tac | ${busybox} sed '/Total PSS by OOM adjustment:/,$d' | grep "dtv.tvinput.dvbtuner" | ${busybox} sed "s/K://g; s/,//g" | ${busybox} awk 'NR==1{print $1}');[ -z "$op" ] && echo "0" || echo "$op")
            DUMPSYS_MEMINFO_ISDBTUNER_SIZE=$(op=$(cat dumpsys_meminfo.log | ${busybox} sed '/: Cached/,$d' | tac | ${busybox} sed '/Total PSS by OOM adjustment:/,$d' | grep "dtv.tvinput.isdbtuner" | ${busybox} sed "s/K://g; s/,//g" | ${busybox} awk 'NR==1{print $1}');[ -z "$op" ] && echo "0" || echo "$op")
            DUMPSYS_MEMINFO_DTMBTUNER_SIZE=$(op=$(cat dumpsys_meminfo.log | ${busybox} sed '/: Cached/,$d' | tac | ${busybox} sed '/Total PSS by OOM adjustment:/,$d' | grep "dtv.tvinput.dtmbtuner" | ${busybox} sed "s/K://g; s/,//g" | ${busybox} awk 'NR==1{print $1}');[ -z "$op" ] && echo "0" || echo "$op")
            DUMPSYS_MEMINFO_TIS_SIZE=$(op=$(cat dumpsys_meminfo.log | ${busybox} sed '/: Cached/,$d' | tac | ${busybox} sed '/Total PSS by OOM adjustment:/,$d' | grep "tis (" | ${busybox} sed "s/K://g; s/,//g" | ${busybox} awk 'NR==1{print $1}');[ -z "$op" ] && echo "0" || echo "$op")
            DUMPSYS_MEMINFO_EXTSERVICE_SIZE=$(op=$(cat dumpsys_meminfo.log | ${busybox} sed '/: Cached/,$d' | tac | ${busybox} sed '/Total PSS by OOM adjustment:/,$d' | grep "com.mediatek.extservice" | ${busybox} sed "s/K://g; s/,//g" | ${busybox} awk '{sum+=$1} END{print sum}');[ -z "$op" ] && echo "0" || echo "$op")
            DUMPSYS_MEMINFO_METRICS_SIZE=$(op=$(cat dumpsys_meminfo.log | ${busybox} sed '/: Cached/,$d' | tac | ${busybox} sed '/Total PSS by OOM adjustment:/,$d' | grep "com.mediatek.metrics" | ${busybox} sed "s/K://g; s/,//g" | ${busybox} awk '{sum+=$1} END{print sum}');[ -z "$op" ] && echo "0" || echo "$op")
        fi
    fi
}

func_parse_procrank()
{
    if [ -s "./procrank.log" ]; then
        PROCRANK_TOTAL_PSS_SIZE=$(op=$(grep "TOTAL" procrank.log | ${busybox} awk '{print $1}' | ${busybox} sed 's/K//g');[ -z "$op" ] && echo "0" || echo "$op")
        PROCRANK_TOTAL_SWAP_PSS_SIZE=$(op=$(grep "TOTAL" procrank.log | ${busybox} awk '{print $4}' | ${busybox} sed 's/K//g');[ -z "$op" ] && echo "0" || echo "$op")
        PROCRANK_DTV_SVC_SIZE=$(op=$(cat procrank.log | grep "dtv_svc" | ${busybox} sed "s/K//g" | ${busybox} awk '{sum=sum+$4+$7} END{print sum}');[ -z "$op" ] && echo "0" || echo "$op")
        PROCRANK_MI_DAEMON_SYS_SIZE=$(op=$(cat procrank.log | grep "mi_daemon_sys" | ${busybox} sed "s/K//g" | ${busybox} awk '{sum=sum+$4+$7} END{print sum}');[ -z "$op" ] && echo "0" || echo "$op")
        PROCRANK_TVOS_SIZE=$(op=$(cat procrank.log | grep "tvos" | ${busybox} sed "s/K//g" | ${busybox} awk '{sum=sum+$4+$7} END{print sum}');[ -z "$op" ] && echo "0" || echo "$op")
        PROCRANK_JARVES_SIZE=$(op=$(cat procrank.log | grep "jarves" | ${busybox} sed "s/K//g" | ${busybox} awk '{sum=sum+$4+$7} END{print sum}');[ -z "$op" ] && echo "0" || echo "$op")
        PROCRANK_NETFLIX_SIZE=$(op=$(grep "netflix" procrank.log | ${busybox} sed "s/K//g" | ${busybox} awk '{sum=sum+$4+$7} END{print sum}');[ -z "$op" ] && echo "0" || echo "$op")
        PROCRANK_AMAZON_PRIMEVIDEO_SIZE=$(op=$(grep "amazon" procrank.log | ${busybox} sed "s/K//g" | ${busybox} awk '{sum=sum+$4+$7} END{print sum}');[ -z "$op" ] && echo "0" || echo "$op")
        PROCRANK_YOUTUBE_SIZE=$(op=$(grep "cobalt" procrank.log | ${busybox} sed "s/K//g" | ${busybox} awk '{sum=sum+$4+$7} END{print sum}');[ -z "$op" ] && echo "0" || echo "$op")
    fi
}

func_get_kernel_bit()
{
    if [ -s "./cpuinfo.log" ]; then
        KERNEL_BITS=$(op=$(cat cpuinfo.log | grep -E "ARMv7|v7l" | head -n1);[ -z "$op" ] && echo "64-bit" || echo "32-bit")
    fi
}

func_get_kernel_version()
{
    if [ -s "./kernel_version.log" ]; then
        KERNEL_VERSION=$(op=$(cat kernel_version.log | ${busybox} awk '{print $3}');[ -z "$op" ] && echo "0" || echo "$op")
    fi
}

func_get_lx_size()
{
    if [ -s "./memblock_memory.log" ]; then
        LX_SIZE=$(op=$(cat memblock_memory.log | ${busybox} sed 's/..0x/ 0x/g' | ${busybox} awk '{cmd="printf %d " $2; cmd2="printf %d " $3; cmd | getline result; close(cmd); cmd2 | getline result2; close(cmd2); print result " " result2}' | ${busybox} awk '{total=total+($2-$1)};END {print int(total/1024)}');[ -z "$op" ] && echo "0" || echo "$op")
        if [ "$LX_SIZE" == "0" ]; then
            LX_SIZE=$(op=$(cat memblock_memory.log | ${busybox} sed 's/..0x/ 0x/g' | ${busybox} awk '{print strtonum($2),strtonum($3)}' | ${busybox} awk '{total=total+($2-$1)};END {print int(total/1024)}');[ -z "$op" ] && echo "0" || echo "$op")
        fi
    elif [ -s "./mmap.log" ]; then
        LX_SIZE=$(op=$(cat mmap.log | grep -E "MI_KERNEL_POOL1_LEN|MI_KERNEL_POOL2_LEN" | ${busybox} awk '{cmd="printf %d " $3; cmd | getline result; close(cmd); print result}' | ${busybox} awk '{total+=$1}; END {print int(total/1024)}');[ -z "$op" ] && echo "0" || echo "$op")
    elif [ -s "./mmap_dtbo.log" ]; then
        LX_SIZE=$(op=$(cat mmap_dtbo.log | grep -E "MI_KERNEL_POOL1|MI_KERNEL_POOL2" | ${busybox} awk '{cmd="printf %d " "0x"$2; cmd | getline result; close(cmd); print result}' | ${busybox} awk '{total+=$1}; END {print int(total/1024)}');[ -z "$op" ] && echo "0" || echo "$op")
    
    fi
}

func_get_dram_size()
{
    if [ -s "./mmap.log" ]; then
        DRAM_SIZE=$(op=$(cat mmap.log | grep "END_ADR" | ${busybox} awk '{cmd="printf %d " $3; cmd | getline result; close(cmd); print result}' | ${busybox} awk '{total+=$1};END {print int(total/1024)}');[ -z "$op" ] && echo "0" || echo "$op")
        if [ "$DRAM_SIZE" == "0" ]; then
            DRAM_SIZE=$(op=$(${busybox} awk '/END_ADR/{print strtonum($3)}' mmap.log | ${busybox} awk '{total+=$1};END {print int(total/1024)}');[ -z "$op" ] && echo "0" || echo "$op")
        fi
    elif [ -s "./mmap_dtbo.log" ]; then
        DRAM_SIZE=$(op=$(tail -1 mmap_dtbo.log | ${busybox} awk -F'G' '{print int($1*1024*1024)}');[ -z "$op" ] && echo "0" || echo "$op")
    fi
}

func_get_vmalloc_relative_size()
{
    if [ -s "./vmallocinfo.log" ]; then
        VMALLOCINFO_VMALLOC_TOTAL_SIZE=$(op=$(cat vmallocinfo.log | ${busybox} awk '{total+=$2};END {print int(total/1024)}');[ -z "$op" ] && echo "0" || echo "$op")
        VMALLOCINFO_VMALLOC_PAGE_ALLOC_SIZE=$(op=$(cat vmallocinfo.log | grep "pages" | grep -Ev "_do_fork|copy_process" | ${busybox} awk '{split($0,p,"pages=")}{print p[2]}' | ${busybox} awk '{total+=$1};END {print int(total*4096/1024)}');[ -z "$op" ] && echo "0" || echo "$op")
        VMALLOCINFO_LOAD_MODULE_SIZE=$(op=$(grep -E "load_module|module_alloc" vmallocinfo.log | ${busybox} awk '{split($0,p,"pages=")}{print p[2]}' | ${busybox} awk '{total+=$1};END {print int(total*4096/1024)}');[ -z "$op" ] && echo "0" || echo "$op")
        VMALLOCINFO_DRV_ALLOC_SIZE=$((${VMALLOCINFO_VMALLOC_PAGE_ALLOC_SIZE}-${VMALLOCINFO_LOAD_MODULE_SIZE}))
    fi
}

func_get_slab_relative_size()
{
    if [ -s "./slabinfo.log" ]; then
        SLABINFO_SLAB_UNRECLAIM_SIZE=$(op=$(cat slabinfo.log | grep -Ev "inode|buffer" | ${busybox} awk '{if($3*$4 > 1){print $1,$3*$4}}' | ${busybox} awk '{total+=$2};END {print int(total/1024)}');[ -z "$op" ] && echo "0" || echo "$op")
        SLABINFO_KMALLOC_SIZE=$(op=$(cat slabinfo.log | grep "kmalloc-" | ${busybox} awk '{if($3*$4 > 1){print $1,$3*$4}}' | ${busybox} awk '{total+=$2};END {print int(total/1024)}');[ -z "$op" ] && echo "0" || echo "$op")
        SLABINFO_KRN_SRC_SIZE=$((${SLABINFO_SLAB_UNRECLAIM_SIZE}-${SLABINFO_KMALLOC_SIZE}))
    fi
}

func_get_cma_hwip_used_size()
{
    if [ -s "./cmainfo.log" ]; then
        CMAINFO_CMA_HWIP_USED_SIZE=$(op=$(cat cmainfo.log | ${busybox} awk 'NR==2{for(i=1;i<=NF;i++){print $i}}' | grep "(" | ${busybox} sed "s/(//g; s/kb//g" | ${busybox} awk '{total+=$1}END{print total}');[ -z "$op" ] && echo "0" || echo "$op")
    fi
}

func_get_mali_driver_size()
{
    if [ -s "./gpu_memory.log" ]; then
        is_utgard=$(cat gpu_memory.log | grep "Mali mem usage:")
        if [ ! -z "$is_utgard" ]; then
            GPU_MEMORY_MALI_TOTAL_SIZE=$(op=$(cat gpu_memory.log | grep "Mali mem usage:" | ${busybox} awk '{print int($4/1024)}');[ -z "$op" ] && echo "0" || echo "$op")
        else
            GPU_MEMORY_MALI_TOTAL_SIZE=$(op=$(grep "mali0" gpu_memory.log | ${busybox} awk '{print int($2*4096/1024)}');[ -z "$op" ] && echo "0" || echo "$op")
        fi

        if [ "$platform" == "sn_linux" ] || [ "$platform" == "fusion_linux" ]; then
            nfx_pid=$(cat ps.log | grep "netflix" | ${busybox} awk '{print $1}')
            amazon_pid=$(cat ps.log | grep "amazon" | ${busybox} awk '{print $1}')
            youtube_pid=$(cat ps.log | grep "cobalt" | ${busybox} awk '{print $1}')
        else
            nfx_pid=$(cat ps.log | grep "ninja$" | ${busybox} awk '{print $2}')
            amazon_pid=$(cat ps.log | grep "amazonvideo.livingroom$" | ${busybox} awk '{print $2}')
            youtube_pid=$(cat ps.log | grep "youtube.tv$" | ${busybox} awk '{print $2}')
        fi

        if [ ! -z "$nfx_pid" ]; then
            if [ ! -z "$is_utgard" ]; then
                GPU_MEMORY_NETFLIX_MALI_SIZE=$(op=$(cat gpu_memory.log | grep ${nfx_pid} | ${busybox} awk '{print int($3/1024)}');[ -z "$op" ] && echo "0" || echo "$op")
            else
                GPU_MEMORY_NETFLIX_MALI_SIZE=$(op=$(cat gpu_memory.log | grep ${nfx_pid} | ${busybox} awk '{print int($(NF-1)*4096/1024)}');[ -z "$op" ] && echo "0" || echo "$op")
            fi
            if [ "$platform" == "sn_linux" ] || [ "$platform" == "fusion_linux" ]; then
                NETFLIX_MEMORY_USAGE=$((${PROCRANK_NETFLIX_SIZE}+${GPU_MEMORY_NETFLIX_MALI_SIZE}))
            else
                if [ "$DUMPSYS_MEMINFO_GL_MTRACK_SIZE" == "0" ]; then
                    NETFLIX_MEMORY_USAGE=$((${DUMPSYS_MEMINFO_NETFLIX_SIZE}+${GPU_MEMORY_NETFLIX_MALI_SIZE}))
                else
                    NETFLIX_MEMORY_USAGE=${DUMPSYS_MEMINFO_NETFLIX_SIZE}
                fi
            fi
        fi

        if [ ! -z "$amazon_pid" ]; then
            if [ ! -z "$is_utgard" ]; then
                GPU_MEMORY_AMAZON_PRIMEVIDEO_MALI_SIZE=$(op=$(cat gpu_memory.log | grep ${amazon_pid} | ${busybox} awk '{print int($3/1024)}');[ -z "$op" ] && echo "0" || echo "$op")
            else
                GPU_MEMORY_AMAZON_PRIMEVIDEO_MALI_SIZE=$(op=$(cat gpu_memory.log | grep ${amazon_pid} | ${busybox} awk '{print int($(NF-1)*4096/1024)}');[ -z "$op" ] && echo "0" || echo "$op")
            fi
            if [ "$platform" == "sn_linux" ] || [ "$platform" == "fusion_linux" ]; then
                AMAZON_PRIMEVIDEO_MEMORY_USAGE=$((${PROCRANK_AMAZON_PRIMEVIDEO_SIZE}+${GPU_MEMORY_AMAZON_PRIMEVIDEO_MALI_SIZE}))
            else
                if [ "$DUMPSYS_MEMINFO_GL_MTRACK_SIZE" == "0" ]; then
                    AMAZON_PRIMEVIDEO_MEMORY_USAGE=$((${DUMPSYS_MEMINFO_AMAZON_PRIMEVIDEO_SIZE}+${GPU_MEMORY_AMAZON_PRIMEVIDEO_MALI_SIZE}))
                else
                    AMAZON_PRIMEVIDEO_MEMORY_USAGE=${DUMPSYS_MEMINFO_AMAZON_PRIMEVIDEO_SIZE}
                fi
            fi
        fi

        if [ ! -z "$youtube_pid" ]; then
            if [ ! -z "$is_utgard" ]; then
                GPU_MEMORY_YOUTUBE_MALI_SIZE=$(op=$(cat gpu_memory.log | grep ${youtube_pid} | ${busybox} awk '{print int($3/1024)}');[ -z "$op" ] && echo "0" || echo "$op")
            else
                GPU_MEMORY_YOUTUBE_MALI_SIZE=$(op=$(cat gpu_memory.log | grep ${youtube_pid} | ${busybox} awk '{print int($(NF-1)*4096/1024)}');[ -z "$op" ] && echo "0" || echo "$op")
            fi
            if [ "$platform" == "sn_linux" ] || [ "$platform" == "fusion_linux" ]; then
                YOUTUBE_MEMORY_USAGE=$((${PROCRANK_YOUTUBE_SIZE}+${GPU_MEMORY_YOUTUBE_MALI_SIZE}))
            else
                if [ "$DUMPSYS_MEMINFO_GL_MTRACK_SIZE" == "0" ]; then
                    YOUTUBE_MEMORY_USAGE=$((${DUMPSYS_MEMINFO_YOUTUBE_SIZE}+${GPU_MEMORY_YOUTUBE_MALI_SIZE}))
                else
                    YOUTUBE_MEMORY_USAGE=${DUMPSYS_MEMINFO_YOUTUBE_SIZE}
                fi
            fi
        fi
    else
        GPU_MEMORY_MALI_TOTAL_SIZE=${DUMPSYS_MEMINFO_GL_MTRACK_SIZE}
    fi
}

func_get_iommu_size()
{
    if [ -s "./iommu.log" ]; then
        #is_symbol=$(cat iommu.log | grep "4096")
        #if [ ! -z "$is_symbol" ]; then
        #    IOMMU_TOTAL_SIZE=$(op=$(cat iommu.log | ${busybox} sed "1d" | ${busybox} awk '{total+=$4}; END {print int(total/1024)}');[ -z "$op" ] && echo "0" || echo "$op")
        #    IOMMU_VDEC_FB_SIZE=$(op=$(cat iommu.log | grep "vdec_fb" | ${busybox} awk '{total+=$4}; END {print int(total/1024)}');[ -z "$op" ] && echo "0" || echo "$op")
        #    IOMMU_VDEC_ES_SIZE=$(op=$(cat iommu.log | grep "vdec_es" | ${busybox} awk '{total+=$4}; END {print int(total/1024)}');[ -z "$op" ] && echo "0" || echo "$op")
        #    IOMMU_XC_FRC_SIZE=$(op=$(cat iommu.log | grep "xc_frc" | ${busybox} awk '{total+=$4}; END {print int(total/1024)}');[ -z "$op" ] && echo "0" || echo "$op")
        #    IOMMU_XC_MAIN_SIZE=$(op=$(cat iommu.log | grep "xc_main" | ${busybox} awk '{total+=$4}; END {print int(total/1024)}');[ -z "$op" ] && echo "0" || echo "$op")
        #    IOMMU_MALI_GOP_SIZE=$(op=$(cat iommu.log | grep "mali_gop " | awk '{total+=$4}; END {print int(total/1024)}');[ -z "$op" ] && echo "0" || echo "$op")
        #    IOMMU_MALI_GOP_DMA_SIZE=$(op=$(cat iommu.log | grep "mali_gop_dma" | awk '{total+=$4}; END {print int(total/1024)}');[ -z "$op" ] && echo "0" || echo "$op")
        #    IOMMU_DIRECTFB_FRAME_SIZE=$(op=$(cat iommu.log | grep "directfb_frame" | awk '{total+=$4}; END {print int(total/1024)}');[ -z "$op" ] && echo "0" || echo "$op")
        #    IOMMU_TSP_FIQ_SIZE=$(op=$(cat iommu.log | grep "tsp_fiq" | ${busybox} awk '{total+=$4}; END {print int(total/1024)}');[ -z "$op" ] && echo "0" || echo "$op")
        #    IOMMU_XC_HSE_SIZE=$(op=$(cat iommu.log | grep "xc_hse" | ${busybox} awk '{total+=$4}; END {print int(total/1024)}');[ -z "$op" ] && echo "0" || echo "$op")
        #    IOMMU_TSP_PVR_SIZE=$(op=$(cat iommu.log | grep "tsp_pvr" | ${busybox} awk '{total+=$4}; END {print int(total/1024)}');[ -z "$op" ] && echo "0" || echo "$op")
        #    IOMMU_TSP_FILEIN=$(op=$(cat iommu.log | grep "tsp_filein" | ${busybox} awk '{total+=$4}; END {print int(total/1024)}');[ -z "$op" ] && echo "0" || echo "$op")
        #    IOMMU_INJECT_FILEIN=$(op=$(cat iommu.log | grep "inject_filein" | ${busybox} awk '{total+=$4}; END {print int(total/1024)}');[ -z "$op" ] && echo "0" || echo "$op")
        #else
            is_sysfs_dbg0=$(cat iommu.log | grep "Total size")
            is_buftagid=$(cat iommu.log | grep "buftag_id")
            if [ ! -z "$is_sysfs_dbg0" ]; then
                num='3'
            elif [ ! -z "$is_buftagid" ]; then
                num='5'
            else
                num='4'
            fi
            IOMMU_TOTAL_SIZE=$(op=$(cat iommu.log | grep "Total size:" | ${busybox} awk '{cmd="printf %d " $num; cmd | getline result; close(cmd); print result}' num=$num | ${busybox} awk '{total+=$1}; END {print int(total/1024)}');[ -z "$op" ] && echo "0" || echo "$op")
            if [ "$IOMMU_TOTAL_SIZE" == "0" ]; then
                IOMMU_TOTAL_SIZE=$(op=$(cat iommu.log | ${busybox} sed "1d" | ${busybox} awk '{print strtonum("0x"$num)}' num=$num | ${busybox} awk '{total+=$1}; END {print int(total/1024)}');[ -z "$op" ] && echo "0" || echo "$op")
                IOMMU_VDEC_FB_SIZE=$(op=$(cat iommu.log | grep "vdec_fb" | ${busybox} awk '{print strtonum("0x"$num)}' num=$num | ${busybox} awk '{total+=$1}; END {print int(total/1024)}');[ -z "$op" ] && echo "0" || echo "$op")
                IOMMU_VDEC_ES_SIZE=$(op=$(cat iommu.log | grep "vdec_es" | ${busybox} awk '{print strtonum("0x"$num)}' num=$num | ${busybox} awk '{total+=$1}; END {print int(total/1024)}');[ -z "$op" ] && echo "0" || echo "$op")
                IOMMU_SHM_BUF_VDEC_SIZE=$(op=$(cat iommu.log | grep "shm_buf_vdec" | ${busybox} awk '{print strtonum("0x"$num)}' num=$num | ${busybox} awk '{total+=$1}; END {print int(total/1024)}');[ -z "$op" ] && echo "0" || echo "$op")
                IOMMU_MAP_SG_SIZE=$(op=$(cat iommu.log | grep "map_sg" | ${busybox} awk '{print strtonum("0x"$num)}' num=$num | ${busybox} awk '{total+=$1}; END {print int(total/1024)}');[ -z "$op" ] && echo "0" || echo "$op")
                IOMMU_XC_FRC_SIZE=$(op=$(cat iommu.log | grep "xc_frc" | ${busybox} awk '{print strtonum("0x"$num)}' num=$num | ${busybox} awk '{total+=$1}; END {print int(total/1024)}');[ -z "$op" ] && echo "0" || echo "$op")
                IOMMU_XC_MAIN_SIZE=$(op=$(cat iommu.log | grep "xc_main" | ${busybox} awk '{print strtonum("0x"$num)}' num=$num | ${busybox} awk '{total+=$1}; END {print int(total/1024)}');[ -z "$op" ] && echo "0" || echo "$op")
                IOMMU_MALI_GOP_SIZE=$(op=$(cat iommu.log | grep "mali_gop" | ${busybox} awk '{print strtonum("0x"$num)}' num=$num | awk '{total+=$1}; END {print int(total/1024)}');[ -z "$op" ] && echo "0" || echo "$op")
                IOMMU_DIRECTFB_FRAME_SIZE=$(op=$(cat iommu.log | grep "directfb_frame" | ${busybox} awk '{print strtonum("0x"$num)}' num=$num | awk '{total+=$1}; END {print int(total/1024)}');[ -z "$op" ] && echo "0" || echo "$op")
                IOMMU_TSP_FIQ_SIZE=$(op=$(cat iommu.log | grep "tsp_fiq" | ${busybox} awk '{print strtonum("0x"$num)}' num=$num | ${busybox} awk '{total+=$1}; END {print int(total/1024)}');[ -z "$op" ] && echo "0" || echo "$op")
                IOMMU_XC_HSE_SIZE=$(op=$(cat iommu.log | grep "xc_hse" | ${busybox} awk '{print strtonum("0x"$num)}' num=$num | ${busybox} awk '{total+=$1}; END {print int(total/1024)}');[ -z "$op" ] && echo "0" || echo "$op")
                IOMMU_TSP_PVR_SIZE=$(op=$(cat iommu.log | grep "tsp_pvr" | ${busybox} awk '{print strtonum("0x"$num)}' num=$num | ${busybox} awk '{total+=$1}; END {print int(total/1024)}');[ -z "$op" ] && echo "0" || echo "$op")
                IOMMU_TSP_FILEIN=$(op=$(cat iommu.log | grep "tsp_filein" | ${busybox} awk '{print strtonum("0x"$num)}' num=$num | ${busybox} awk '{total+=$1}; END {print int(total/1024)}');[ -z "$op" ] && echo "0" || echo "$op")
                IOMMU_INJECT_FILEIN=$(op=$(cat iommu.log | grep "inject_filein" | ${busybox} awk '{print strtonum("0x"$num)}' num=$num | ${busybox} awk '{total+=$1}; END {print int(total/1024)}');[ -z "$op" ] && echo "0" || echo "$op")
            else
                num=5 # column of size
                IOMMU_VDEC_FB_SIZE=$(op=$(cat iommu.log | grep "vdec_fb" | ${busybox} awk '{cmd="printf %d " "0x"$num; cmd | getline result; close(cmd); print result}' num=$num | ${busybox} awk '{total+=$1}; END {print int(total/1024)}');[ -z "$op" ] && echo "0" || echo "$op")
                IOMMU_VDEC_ES_SIZE=$(op=$(cat iommu.log | grep "vdec_es" | ${busybox} awk '{cmd="printf %d " "0x"$num; cmd | getline result; close(cmd); print result}' num=$num | ${busybox} awk '{total+=$1}; END {print int(total/1024)}');[ -z "$op" ] && echo "0" || echo "$op")
                IOMMU_SHM_BUF_VDEC_SIZE=$(op=$(cat iommu.log | grep "shm_buf_vdec" | ${busybox} awk '{cmd="printf %d " "0x"$num; cmd | getline result; close(cmd); print result}' num=$num | ${busybox} awk '{total+=$1}; END {print int(total/1024)}');[ -z "$op" ] && echo "0" || echo "$op")
                IOMMU_MAP_SG_SIZE=$(op=$(cat iommu.log | grep "map_sg" | ${busybox} awk '{cmd="printf %d " "0x"$num; cmd | getline result; close(cmd); print result}' num=$num | ${busybox} awk '{total+=$1}; END {print int(total/1024)}');[ -z "$op" ] && echo "0" || echo "$op")
                IOMMU_XC_FRC_SIZE=$(op=$(cat iommu.log | grep "xc_frc" | ${busybox} awk '{cmd="printf %d " "0x"$num; cmd | getline result; close(cmd); print result}' num=$num | ${busybox} awk '{total+=$1}; END {print int(total/1024)}');[ -z "$op" ] && echo "0" || echo "$op")
                IOMMU_XC_MAIN_SIZE=$(op=$(cat iommu.log | grep -E "xc_main|disp_" | ${busybox} awk '{cmd="printf %d " "0x"$num; cmd | getline result; close(cmd); print result}' num=$num | ${busybox} awk '{total+=$1}; END {print int(total/1024)}');[ -z "$op" ] && echo "0" || echo "$op")
                IOMMU_MALI_GOP_SIZE=$(op=$(cat iommu.log | grep "mali_gop" | ${busybox} awk '{cmd="printf %d " "0x"$num; cmd | getline result; close(cmd); print result}' num=$num | awk '{total+=$1}; END {print int(total/1024)}');[ -z "$op" ] && echo "0" || echo "$op")
                IOMMU_DIRECTFB_FRAME_SIZE=$(op=$(cat iommu.log | grep "directfb_frame" | ${busybox} awk '{cmd="printf %d " "0x"$num; cmd | getline result; close(cmd); print result}' num=$num | awk '{total+=$1}; END {print int(total/1024)}');[ -z "$op" ] && echo "0" || echo "$op")
                IOMMU_TSP_FIQ_SIZE=$(op=$(cat iommu.log | grep "tsp_fiq" | ${busybox} awk '{cmd="printf %d " "0x"$num; cmd | getline result; close(cmd); print result}' num=$num | ${busybox} awk '{total+=$1}; END {print int(total/1024)}');[ -z "$op" ] && echo "0" || echo "$op")
                IOMMU_XC_HSE_SIZE=$(op=$(cat iommu.log | grep "xc_hse" | ${busybox} awk '{cmd="printf %d " "0x"$num; cmd | getline result; close(cmd); print result}' num=$num | ${busybox} awk '{total+=$1}; END {print int(total/1024)}');[ -z "$op" ] && echo "0" || echo "$op")
                IOMMU_TSP_PVR_SIZE=$(op=$(cat iommu.log | grep "tsp_pvr" | ${busybox} awk '{cmd="printf %d " "0x"$num; cmd | getline result; close(cmd); print result}' num=$num | ${busybox} awk '{total+=$1}; END {print int(total/1024)}');[ -z "$op" ] && echo "0" || echo "$op")
                IOMMU_TSP_FILEIN=$(op=$(cat iommu.log | grep "tsp_filein" | ${busybox} awk '{cmd="printf %d " "0x"$num; cmd | getline result; close(cmd); print result}' num=$num | ${busybox} awk '{total+=$1}; END {print int(total/1024)}');[ -z "$op" ] && echo "0" || echo "$op")
                IOMMU_INJECT_FILEIN=$(op=$(cat iommu.log | grep "inject_filein" | ${busybox} awk '{cmd="printf %d " "0x"$num; cmd | getline result; close(cmd); print result}' num=$num | ${busybox} awk '{total+=$1}; END {print int(total/1024)}');[ -z "$op" ] && echo "0" || echo "$op")
            fi
        #fi
    else
        IOMMU_TOTAL_SIZE=${DUMPSYS_MEMINFO_ION_SIZE}
    fi
}

func_get_hisi_iommu_size()
{
    if [ -s "./media-mem.log" ]; then
        IOMMU_TOTAL_SIZE=$(op=$(cat media-mem.log | grep "Iommu Used" -A2 | grep "MB" | ${busybox} awk '{print $3*1024}' | ${busybox} sed 's/MB//g');[ -z "$op" ] && echo "0" || echo "$op")
        CMAINFO_CMA_HWIP_USED_SIZE=$(op=$(cat media-mem.log | grep "CMA Used" -A2 | grep "MB" | ${busybox} awk '{print $3*1024}' | ${busybox} sed 's/MB//g');[ -z "$op" ] && echo "0" || echo "$op")
        
    fi
}

func_get_zram_relative_size()
{
    if [ -s "./zram_mm_stat.log" ]; then
        ZRAM_ORIG_DATA_SIZE=$(op=$(cat zram_mm_stat.log | ${busybox} awk '{print int($1/1024)}');[ -z "$op" ] && echo "0" || echo "$op")
        ZRAM_COMPR_DATA_SIZE=$(op=$(cat zram_mm_stat.log | ${busybox} awk '{print int($2/1024)}');[ -z "$op" ] && echo "0" || echo "$op")
        ZRAM_MEM_USED_TOTAL=$(op=$(cat zram_mm_stat.log | ${busybox} awk '{print int($3/1024)}');[ -z "$op" ] && echo "0" || echo "$op")
        ZRAM_ZERO_PAGES_SIZE=$(op=$(cat zram_mm_stat.log | ${busybox} awk '{print int($6*4096/1024)}');[ -z "$op" ] && echo "0" || echo "$op")
    else
        if [ -s "./zram_orig_data_size.log" ]; then
            ZRAM_ORIG_DATA_SIZE=$(op=$(cat zram_orig_data_size.log | ${busybox} awk '{print int($1/1024)}');[ -z "$op" ] && echo "0" || echo "$op")
        fi
        if [ -s "./zram_compr_data_size.log" ]; then
            ZRAM_COMPR_DATA_SIZE=$(op=$(cat zram_compr_data_size.log | ${busybox} awk '{print int($1/1024)}');[ -z "$op" ] && echo "0" || echo "$op")
        fi
        if [ -s "./zram_mem_used_total.log" ]; then
            ZRAM_MEM_USED_TOTAL=$(op=$(cat zram_mem_used_total.log | ${busybox} awk '{print int($1/1024)}');[ -z "$op" ] && echo "0" || echo "$op")
        fi
        if [ -s "./zram_zero_pages.log" ]; then
            ZRAM_ZERO_PAGES_SIZE=$(op=$(cat zram_zero_pages.log | ${busybox} awk '{print int($1*4096/1024)}');[ -z "$op" ] && echo "0" || echo "$op")
        fi
    fi
    if [ -s "./zram_comp_algorithm.log" ]; then
        ZRAM_COMP_ALGORITHM=$(op=$(cat zram_comp_algorithm.log | awk '{for(i=1;i<=NF;i++){print $i}}' | grep "\[" | sed "s/\[//g; s/\]//g");[ -z "$op" ] && echo "0" || echo "$op")
    fi
}

func_get_more_from_dumpsys_meminfo()
{
    if [ -s "./dumpsys_meminfo.log" ]; then
        DUMPSYS_MEMINFO_TOTAL_PSS_WO_SWAP_SIZE=$(op=$(cat dumpsys_meminfo.log | ${busybox} sed '/Total RAM:/,$d' | tac | ${busybox} sed '/Total PSS by category:/,$d' | ${busybox} sed "s/K://g; s/,//g" | ${busybox} awk '{sum+=$1} END{print sum}');[ -z "$op" ] && echo "0" || echo "$op")
        DUMPSYS_MEMINFO_TOTAL_SWAP_PSS_SIZE=$((${DUMPSYS_MEMINFO_USED_PSS_SIZE}+${DUMPSYS_MEMINFO_CACHED_PSS_SIZE}-${DUMPSYS_MEMINFO_TOTAL_PSS_WO_SWAP_SIZE}))
        DUMPSYS_MEMINFO_TV_DAEMON_SIZE=$((${DUMPSYS_MEMINFO_DTV_SVC_SIZE}+${DUMPSYS_MEMINFO_MIDAEMON_SIZE}+${DUMPSYS_MEMINFO_APP_MAN_SIZE}+${DUMPSYS_MEMINFO_TVOS_SIZE}))
        DUMPSYS_MEMINFO_ANDROID_USAGE_SIZE=$(op=$(cat dumpsys_meminfo.log | tac | ${busybox} sed '/Total PSS by OOM adjustment:/,$d' | tac | ${busybox} sed '/K: Cached/,$d' | grep pid | grep -Evi "mstar|mediatek|Mtk|dtv_svc|midaemon|app_man|tvserver|MiSysSrv|AIPQService|aiaq|tvservice|realtek|rtk|Dignosis|hisilicon|histreamingservice|hiavplayer|hiaoservice|ninja|amazon|youtube|vudu|eater|hbbtv|browser|native-window-size|freeview|exoplayer|iflytek|cibn|ktcp|airplay|weshare|keylab|bajintech|kookong|konka|hisense|hstvos|svcxfar_x|jamdeo|skyworth|tianci|coocaa|tcl|sitatvservice|appmanager|tmmgr|DAI_MGR|DAI_MONITOR|vibra_lite|mi3daemon|dvbtuner|muti_playback" | ${busybox} sed "s/K://g; s/,//g" | ${busybox} awk '{sum+=$1} END{print sum}');[ -z "$op" ] && echo "0" || echo "$op")
        DUMPSYS_MEMINFO_CUSTOMER_USAGE_SIZE=$(op=$(cat dumpsys_meminfo.log | tac | ${busybox} sed '/Total PSS by OOM adjustment:/,$d' | tac | ${busybox} sed '/K: Cached/,$d' | grep pid | grep -Ei "konka|hisense|hstvos|svcxfar_x|jamdeo|skyworth|tianci|coocaa|tcl|sitatvservice|appmanager|tmmgr" | ${busybox} sed "s/K://g; s/,//g" | ${busybox} awk '{sum+=$1} END{print sum}');[ -z "$op" ] && echo "0" || echo "$op")
        DUMPSYS_MEMINFO_VENDOR_USAGE_SIZE=$(op=$(cat dumpsys_meminfo.log | tac | ${busybox} sed '/Total PSS by OOM adjustment:/,$d' | tac | ${busybox} sed '/K: Cached/,$d' | grep pid | grep -Ei "mstar|mediatek|Mtk|dtv_svc|midaemon|app_man|tvserver|MiSysSrv|AIPQService|aiaq|tvservice|realtek|rtk|Dignosis|hisilicon|histreamingservice|hiavplayer|hiaoservice|DAI_MGR|DAI_MONITOR|mi3daemon|dvbtuner|muti_playback" | ${busybox} sed "s/K://g; s/,//g" | ${busybox} awk '{sum+=$1} END{print sum}');[ -z "$op" ] && echo "0" || echo "$op")
        DUMPSYS_MEMINFO_CSP_USAGE_SIZE=$(op=$(cat dumpsys_meminfo.log | tac | sed '/Total PSS by OOM adjustment:/,$d' | tac | sed '/Total PSS by category:/,$d' | grep pid | grep -Ei "ninja|amazon|youtube|vudu|eater|hbbtv|browser|native-window-size|freeview|exoplayer|iflytek|cibn|ktcp|airplay|weshare|keylab|bajintech|kookong|vibra_lite" | ${busybox} sed "s/K://g; s/,//g" | ${busybox} awk '{sum+=$1} END{print sum}');[ -z "$op" ] && echo "0" || echo "$op")
        DUMPSYS_MEMINFO_ZRAM_MINUS_SWAP_SIZE=$((${DUMPSYS_MEMINFO_ZRAM_TOTAL_SIZE}-${DUMPSYS_MEMINFO_SWAP_USED_SIZE}))
    fi
}

func_get_more_from_procrank()
{
    if [ -s "./procrank.log" ]; then
        PROCRANK_USED_PSS_SIZE=$((${PROCRANK_TOTAL_PSS_SIZE}+${PROCRANK_TOTAL_SWAP_PSS_SIZE}))
        PROCRANK_TV_DAEMON_SIZE=$((${PROCRANK_DTV_SVC_SIZE}+${PROCRANK_MI_DAEMON_SYS_SIZE}+${PROCRANK_TVOS_SIZE}+${PROCRANK_JARVES_SIZE}))
    fi
}

func_get_more_from_proc_meminfo()
{
    PROC_MEMINFO_CMA_USED_SIZE=$((${PROC_MEMINFO_CMATOTAL_SIZE}-${PROC_MEMINFO_CMAFREE_SIZE}))
    PROC_MEMINFO_SWAP_USED_SIZE=$((${PROC_MEMINFO_SWAPTOTAL_SIZE}-${PROC_MEMINFO_SWAPFREE_SIZE}))
    PROC_MEMINFO_ZRAM_MINUS_SWAP_SIZE=$((${ZRAM_MEM_USED_TOTAL}-${PROC_MEMINFO_SWAP_USED_SIZE}))
    PROC_MEMINFO_CACHED_KERNEL_SIZE=$((${PROC_MEMINFO_SRECLAIMABLE_SIZE}+${PROC_MEMINFO_BUFFERS_SIZE}+${PROC_MEMINFO_CACHED_SIZE}-${PROC_MEMINFO_MAPPED_SIZE}))
    PROC_MEMINFO_FREE_RAM_SIZE=$((${PROC_MEMINFO_CACHED_KERNEL_SIZE}+${PROC_MEMINFO_MEMFREE_SIZE}))
    PROC_MEMINFO_MEMUSED_SIZE=$((${PROC_MEMINFO_MEMTOTAL_SIZE}-${PROC_MEMINFO_MEMFREE_SIZE}-${PROC_MEMINFO_CACHED_SIZE}))
}

func_check_exception()
{
    if [ "$DRAM_SIZE" == "0" ]; then
        if [ -s "./media-mem.log" ]; then
            DRAM_SIZE=${LX_SIZE}
        elif [ "$LX_SIZE" -lt "$PROC_MEMINFO_MEMTOTAL_SIZE" ]; then
            DRAM_SIZE=${PROC_MEMINFO_MEMTOTAL_SIZE}
        else
            DRAM_SIZE=$((${LX_SIZE}+1025))
        fi
    fi
}

func_get_ion_size()
{
    if [ "$IOMMU_TOTAL_SIZE" == "0" ] || [ -s "./media-mem.log" ]; then
        BUFINFO_ION_SIZE=$(cat bufinfo.log | grep -E "ion" | ${busybox} awk '{total+=int($1/1024)};END{print total}')
        [ -z "$BUFINFO_ION_SIZE" ] && BUFINFO_ION_SIZE=0
    fi
}

func_get_system_overview()
{
    SYSTEM_MMAP_PREALLOCATED_SIZE=$((${DRAM_SIZE}-${LX_SIZE}))
    SYSTEM_HW_IP_TOTAL_USED_SIZE=$((${SYSTEM_MMAP_PREALLOCATED_SIZE}+${CMAINFO_CMA_HWIP_USED_SIZE}+${IOMMU_TOTAL_SIZE}+${BUFINFO_ION_SIZE}+${GPU_MEMORY_MALI_TOTAL_SIZE}))
    if [ "$ZRAM_ORIG_DATA_SIZE" != "0" ]; then
        SYSTEM_ZRAM_COMPR_RATIO=$((${ZRAM_COMPR_DATA_SIZE}*100/${ZRAM_ORIG_DATA_SIZE}))
        SYSTEM_ZRAM_COMPR_RATIO="${SYSTEM_ZRAM_COMPR_RATIO}%"
    fi
    SYSTEM_KERNEL_RESERVED_SIZE=$((${LX_SIZE}-${PROC_MEMINFO_MEMTOTAL_SIZE}))
    SYSTEM_KERNEL_SPACE_USAGE_SIZE=$((${PROC_MEMINFO_SHMEM_SIZE}+${PROC_MEMINFO_KERNELSTACK_SIZE}+${PROC_MEMINFO_PAGETABLES_SIZE}+${SLABINFO_SLAB_UNRECLAIM_SIZE}+${VMALLOCINFO_VMALLOC_PAGE_ALLOC_SIZE}+${SYSTEM_KERNEL_RESERVED_SIZE}))
    if [ "$platform" == "sn_linux" ] || [ "$platform" == "fusion_linux" ]; then
        SYSTEM_USER_SPACE_USAGE_SIZE=${PROCRANK_USED_PSS_SIZE}
        SYSTEM_LOST_RAM_SIZE=$((${DRAM_SIZE}-${SYSTEM_HW_IP_TOTAL_USED_SIZE}-${SYSTEM_KERNEL_SPACE_USAGE_SIZE}-${SYSTEM_USER_SPACE_USAGE_SIZE}-(${PROC_MEMINFO_ZRAM_MINUS_SWAP_SIZE})-${PROC_MEMINFO_FREE_RAM_SIZE}))
    else
        if [ "$DUMPSYS_MEMINFO_GL_MTRACK_SIZE" == "0" ]; then
            SYSTEM_USER_SPACE_USAGE_SIZE=${DUMPSYS_MEMINFO_USED_PSS_SIZE}
            SYSTEM_ANDROID_TOTAL_SIZE=$((${DUMPSYS_MEMINFO_USED_PSS_SIZE}+${GPU_MEMORY_MALI_TOTAL_SIZE}))
        else
            SYSTEM_USER_SPACE_USAGE_SIZE=$((${DUMPSYS_MEMINFO_USED_PSS_SIZE}-${DUMPSYS_MEMINFO_GL_MTRACK_SIZE}))
            SYSTEM_ANDROID_TOTAL_SIZE=${DUMPSYS_MEMINFO_USED_PSS_SIZE}
        fi
        SYSTEM_LOST_RAM_SIZE=$((${DRAM_SIZE}-${SYSTEM_HW_IP_TOTAL_USED_SIZE}-${SYSTEM_KERNEL_SPACE_USAGE_SIZE}-${SYSTEM_USER_SPACE_USAGE_SIZE}-(${DUMPSYS_MEMINFO_ZRAM_MINUS_SWAP_SIZE})-${DUMPSYS_MEMINFO_FREE_RAM_SIZE}))
    fi
    SYSTEM_BSP_SIZE=$((${SYSTEM_HW_IP_TOTAL_USED_SIZE}+${SYSTEM_KERNEL_SPACE_USAGE_SIZE}+${SYSTEM_LOST_RAM_SIZE}))
}

func_analyze_meminfo()
{
    echo -e "<MEM_ANALYZER> BEGIN ANALYZE MEMINFO"

    cd $tmp_dir/meminfo_log/$dir

    func_parse_proc_meminfo
    if [ "$platform" == "sn_linux" ] || [ "$platform" == "fusion_linux" ]; then
        func_parse_procrank
        func_get_more_from_procrank
    else
        func_parse_dumpsys_meminfo
        func_get_more_from_dumpsys_meminfo
    fi
    func_get_kernel_bit
    func_get_kernel_version
    func_get_lx_size
    func_get_dram_size
    func_get_vmalloc_relative_size
    func_get_slab_relative_size
    func_get_cma_hwip_used_size
    func_get_iommu_size
    func_get_hisi_iommu_size
    func_get_ion_size
    func_get_zram_relative_size
    func_get_mali_driver_size
    func_get_more_from_proc_meminfo
    func_check_exception
    func_get_system_overview

    echo -e "<MEM_ANALYZER> END ANALYZE MEMINFO\n"
}

func_save_data_to_file()
{
    mem_summary="$mem_summary<MEM_ANALYZER> Memory Detail Info"
    mem_summary="$mem_summary\nKERNEL_BITS = $KERNEL_BITS"
    mem_summary="$mem_summary\nKERNEL_VERSION = $KERNEL_VERSION"
    mem_summary="$mem_summary\nVMALLOC_TOTAL = $VMALLOCINFO_VMALLOC_TOTAL_SIZE"
    mem_summary="$mem_summary\nLOAD_MODULE = $VMALLOCINFO_LOAD_MODULE_SIZE"
    mem_summary="$mem_summary\nKMALLOC = $SLABINFO_KMALLOC_SIZE"
    if [ "$platform" == "sn_linux" ] || [ "$platform" == "fusion_linux" ]; then
        mem_summary="$mem_summary\nDTV_SVC = $PROCRANK_DTV_SVC_SIZE"
        mem_summary="$mem_summary\nMI_DAEMON_SYS = $PROCRANK_MI_DAEMON_SYS_SIZE"
        mem_summary="$mem_summary\nTVOS = $PROCRANK_TVOS_SIZE"
        mem_summary="$mem_summary\nNETFLIX = $PROCRANK_NETFLIX_SIZE"
        mem_summary="$mem_summary\nYOUTUBE = $PROCRANK_YOUTUBE_SIZE"
    else
        mem_summary="$mem_summary\nDTV_SVC = $DUMPSYS_MEMINFO_DTV_SVC_SIZE"
        mem_summary="$mem_summary\nMIDAEMON = $DUMPSYS_MEMINFO_MIDAEMON_SIZE"
        mem_summary="$mem_summary\nAPP_MAN = $DUMPSYS_MEMINFO_APP_MAN_SIZE"
        mem_summary="$mem_summary\nTVOS = $DUMPSYS_MEMINFO_TVOS_SIZE"
        mem_summary="$mem_summary\nNETFLIX = $DUMPSYS_MEMINFO_NETFLIX_SIZE"
        mem_summary="$mem_summary\nYOUTUBE = $DUMPSYS_MEMINFO_YOUTUBE_SIZE"
    fi
    if [ "$platform" == "merak" ]; then
        mem_summary="$mem_summary\nTVCENTER = $DUMPSYS_MEMINFO_TVCENTER_SIZE"
        mem_summary="$mem_summary\nTVAGENT = $DUMPSYS_MEMINFO_TVAGENT_SIZE"
        mem_summary="$mem_summary\nMVIEW_PLAYER = $DUMPSYS_MEMINFO_MVIEW_PLAYER_SIZE"
        mem_summary="$mem_summary\nATSCTUNER = $DUMPSYS_MEMINFO_ATSCTUNER_SIZE"
        mem_summary="$mem_summary\nDVBTUNER = $DUMPSYS_MEMINFO_DVBTUNER_SIZE"
        mem_summary="$mem_summary\nISDBTUNER = $DUMPSYS_MEMINFO_ISDBTUNER_SIZE"
        mem_summary="$mem_summary\nDTMBTUNER = $DUMPSYS_MEMINFO_DTMBTUNER_SIZE"
        mem_summary="$mem_summary\nTIS = $DUMPSYS_MEMINFO_TIS_SIZE"
        mem_summary="$mem_summary\nEXTSERVICE = $DUMPSYS_MEMINFO_EXTSERVICE_SIZE"
        mem_summary="$mem_summary\nMETRICS = $DUMPSYS_MEMINFO_METRICS_SIZE"
    fi
    mem_summary="$mem_summary\nNETFLIX_MALI = $GPU_MEMORY_NETFLIX_MALI_SIZE"
    mem_summary="$mem_summary\nYOUTUBE_MALI = $GPU_MEMORY_YOUTUBE_MALI_SIZE"
    mem_summary="$mem_summary\nORIG_DATA_SIZE = $ZRAM_ORIG_DATA_SIZE"
    mem_summary="$mem_summary\nCOMPR_DATA_SIZE = $ZRAM_COMPR_DATA_SIZE"
    mem_summary="$mem_summary\nMEM_USED_TOTAL = $ZRAM_MEM_USED_TOTAL"
    mem_summary="$mem_summary\nCOMP_ALGORITHM = $ZRAM_COMP_ALGORITHM"
    mem_summary="$mem_summary\nPROC_MEMINFO_SRECLAIMABLE = $PROC_MEMINFO_SRECLAIMABLE_SIZE"
    mem_summary="$mem_summary\nPROC_MEMINFO_CACHED = $PROC_MEMINFO_CACHED_SIZE"
    mem_summary="$mem_summary\nPROC_MEMINFO_BUFFERS = $PROC_MEMINFO_BUFFERS_SIZE"
    mem_summary="$mem_summary\nPROC_MEMINFO_MAPPED = $PROC_MEMINFO_MAPPED_SIZE"
    mem_summary="$mem_summary\nPROC_MEMINFO_CMATOTAL = $PROC_MEMINFO_CMATOTAL_SIZE"
    mem_summary="$mem_summary\nPROC_MEMINFO_CMA_USED = $PROC_MEMINFO_CMA_USED_SIZE"
    mem_summary="$mem_summary\nPROC_MEMINFO_SWAPTOTAL = $PROC_MEMINFO_SWAPTOTAL_SIZE"
    mem_summary="$mem_summary\nPROC_MEMINFO_SWAP_USED = $PROC_MEMINFO_SWAP_USED_SIZE"
    mem_summary="$mem_summary\nPROC_MEMINFO_MEMTOTAL = $PROC_MEMINFO_MEMTOTAL_SIZE"
    mem_summary="$mem_summary\nPROC_MEMINFO_MEMUSED = $PROC_MEMINFO_MEMUSED_SIZE"
    mem_summary="$mem_summary\nANDROID = $SYSTEM_ANDROID_TOTAL_SIZE"
    mem_summary="$mem_summary\nIOMMU_VDEC_FB = $IOMMU_VDEC_FB_SIZE"
    mem_summary="$mem_summary\nIOMMU_VDEC_ES = $IOMMU_VDEC_ES_SIZE"
    mem_summary="$mem_summary\nIOMMU_SHM_BUF_VDEC_SIZE = $IOMMU_SHM_BUF_VDEC_SIZE"
    mem_summary="$mem_summary\nIOMMU_MAP_SG_SIZE = $IOMMU_MAP_SG_SIZE"
    mem_summary="$mem_summary\nIOMMU_XC_FRC = $IOMMU_XC_FRC_SIZE"
    mem_summary="$mem_summary\nIOMMU_XC_MAIN = $IOMMU_XC_MAIN_SIZE"
    mem_summary="$mem_summary\nIOMMU_MALI_GOP = $IOMMU_MALI_GOP_SIZE"
    mem_summary="$mem_summary\nIOMMU_DIRECTFB_FRAME = $IOMMU_DIRECTFB_FRAME_SIZE"
    mem_summary="$mem_summary\nIOMMU_TSP_FIQ = $IOMMU_TSP_FIQ_SIZE"
    mem_summary="$mem_summary\nIOMMU_XC_HSE = $IOMMU_XC_HSE_SIZE"
    mem_summary="$mem_summary\nIOMMU_TSP_PVR = $IOMMU_TSP_PVR_SIZE"
    mem_summary="$mem_summary\nIOMMU_TSP_FILEIN = $IOMMU_TSP_FILEIN"
    mem_summary="$mem_summary\nIOMMU_INJECT_FILEIN = $IOMMU_INJECT_FILEIN"
    if [ "$platform" == "sn_linux" ] || [ "$platform" == "fusion_linux" ]; then
        mem_summary="$mem_summary\nTV_DAEMON = $PROCRANK_TV_DAEMON_SIZE"
    else
        mem_summary="$mem_summary\nTV_DAEMON = $DUMPSYS_MEMINFO_TV_DAEMON_SIZE"
    fi
    mem_summary="$mem_summary\nNETFLIX_MEMORY_USAGE = $NETFLIX_MEMORY_USAGE"
    mem_summary="$mem_summary\nYOUTUBE_MEMORY_USAGE = $YOUTUBE_MEMORY_USAGE"

    mem_summary="$mem_summary\n\n<MEM_ANALYZER> Memory Summary"
    mem_summary="$mem_summary\nDRAM = $DRAM_SIZE"
    mem_summary="$mem_summary\nLX = $LX_SIZE"
    mem_summary="$mem_summary\nHW_IP = $SYSTEM_HW_IP_TOTAL_USED_SIZE" 
    mem_summary="$mem_summary\nMMAP_PREALLOCATED = $SYSTEM_MMAP_PREALLOCATED_SIZE"
    mem_summary="$mem_summary\nCMA_HWIP_USED = $CMAINFO_CMA_HWIP_USED_SIZE"
    mem_summary="$mem_summary\nIOMMU_TOTAL = $IOMMU_TOTAL_SIZE"
    mem_summary="$mem_summary\nION = $BUFINFO_ION_SIZE"
    mem_summary="$mem_summary\nMALI = $GPU_MEMORY_MALI_TOTAL_SIZE"
    mem_summary="$mem_summary\nKERNEL_SPACE = $SYSTEM_KERNEL_SPACE_USAGE_SIZE"
    mem_summary="$mem_summary\nSHMEM = $PROC_MEMINFO_SHMEM_SIZE"
    mem_summary="$mem_summary\nSLAB_UNRECLAIM = $SLABINFO_SLAB_UNRECLAIM_SIZE"
    mem_summary="$mem_summary\nKERNELSTACK = $PROC_MEMINFO_KERNELSTACK_SIZE"
    mem_summary="$mem_summary\nPAGETABLES = $PROC_MEMINFO_PAGETABLES_SIZE"
    mem_summary="$mem_summary\nVMALLOC = $VMALLOCINFO_VMALLOC_PAGE_ALLOC_SIZE"
    mem_summary="$mem_summary\nKERNEL_RESERVED = $SYSTEM_KERNEL_RESERVED_SIZE"
    mem_summary="$mem_summary\nLOST_RAM = $SYSTEM_LOST_RAM_SIZE"
    mem_summary="$mem_summary\nBSP_SIZE = $SYSTEM_BSP_SIZE"
    mem_summary="$mem_summary\nUSER_SPACE = $SYSTEM_USER_SPACE_USAGE_SIZE"
    if [ "$platform" == "sn_linux" ] || [ "$platform" == "fusion_linux" ]; then
        mem_summary="$mem_summary\nSWAP_USED = $PROC_MEMINFO_SWAP_USED_SIZE"
        mem_summary="$mem_summary\nZRAM_USED = $ZRAM_MEM_USED_TOTAL"
        mem_summary="$mem_summary\nZRAM_USED - SWAP = $PROC_MEMINFO_ZRAM_MINUS_SWAP_SIZE"
        mem_summary="$mem_summary\nZRAM_COMPR_RATIO = $SYSTEM_ZRAM_COMPR_RATIO, [$ZRAM_COMP_ALGORITHM]"
        mem_summary="$mem_summary\nFREE_RAM = $PROC_MEMINFO_FREE_RAM_SIZE"
        mem_summary="$mem_summary\nMEMFREE = $PROC_MEMINFO_MEMFREE_SIZE"
        mem_summary="$mem_summary\nCACHED_KERNEL = $PROC_MEMINFO_CACHED_KERNEL_SIZE"
    else
        mem_summary="$mem_summary\nANDROID_USAGE = $DUMPSYS_MEMINFO_ANDROID_USAGE_SIZE"
        mem_summary="$mem_summary\nCUSTOMER_USAGE = $DUMPSYS_MEMINFO_CUSTOMER_USAGE_SIZE"
        mem_summary="$mem_summary\nVENDOR_USAGE = $DUMPSYS_MEMINFO_VENDOR_USAGE_SIZE"
        mem_summary="$mem_summary\nCSP_USAGE = $DUMPSYS_MEMINFO_CSP_USAGE_SIZE"
        mem_summary="$mem_summary\nSWAP_USED = $DUMPSYS_MEMINFO_SWAP_USED_SIZE"
        mem_summary="$mem_summary\nZRAM_USED = $DUMPSYS_MEMINFO_ZRAM_TOTAL_SIZE"
        mem_summary="$mem_summary\nZRAM_USED - SWAP = $DUMPSYS_MEMINFO_ZRAM_MINUS_SWAP_SIZE"
        mem_summary="$mem_summary\nZRAM_COMPR_RATIO = $SYSTEM_ZRAM_COMPR_RATIO, [$ZRAM_COMP_ALGORITHM]"
        mem_summary="$mem_summary\nFREE_RAM = $DUMPSYS_MEMINFO_FREE_RAM_SIZE"
        mem_summary="$mem_summary\nMEMFREE = $DUMPSYS_MEMINFO_FREE_SIZE"
        mem_summary="$mem_summary\nCACHED_KERNEL = $DUMPSYS_MEMINFO_CACHED_KERNEL_SIZE"
        mem_summary="$mem_summary\nCACHED_PSS = $DUMPSYS_MEMINFO_CACHED_PSS_SIZE"
    fi
    echo -e "${mem_summary}" > mem_summary.log
}

IFS="
"
while true
do
echo -e "<MEM_ANALYZER> $dump_count time dump start..."
    dir=`date +%Y%m%d%H%M%S`
    func_dump_meminfo;
    func_init;
    func_analyze_meminfo;
    func_save_data_to_file;
    echo -e "${mem_summary}\n"

cd $tmp_dir/meminfo_log
tar zcf $dir.tar.gz $dir
rm -rf $dir
echo -e "<MEM_ANALYZER> The data is located at $tmp_dir/meminfo_log/$dir"
echo -e "<MEM_ANALYZER> If want to stop dump meminfo, just input \"kill -9 $$\""
echo -e "<MEM_ANALYZER> $dump_count time dump end..."
(( dump_count++ ))

if [ "$sleepTime" == "" ]; then
    sleep 600
else
    sleep $sleepTime
fi
done
exit 0
