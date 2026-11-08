#feature to enable
mtk_video_atrace=1
drm_vblank=1
record_tgid=0
binder=0
irq=0
logcat=1
v4l2=0
cpu_freq=0
android_trace=0
TRACING_PATH="/sys/kernel/debug/tracing"

mtk_video_atrace_enable()
{
	enable=$1
  if [ $mtk_video_atrace -eq 1 ]; then
	setenforce 0
    setprop vendor.mtk.atrace.enable.displink $enable
    setprop vendor.mtk.atrace.enable.pqhal $enable
    setprop vendor.mtk.atrace.enable.mipq $enable
    setprop vendor.mtk.pqlink.atrace.enable $enable
    setprop vendor.mtk.atrace.enable.c2 $enable
    setprop vendor.mtk.atrace.enable.mivideo $enable
    setprop vendor.mtk.atrace.enable.mirender $enable
    setprop vendor.mtk.atrace.enable.miinputsrc $enable
    echo $enable > /sys/devices/platform/mtk-pq/mtk_dbg/atrace_enable
    echo $enable > /sys/devices/platform/mtk-tvpqu/mtk_dbg/atrace_enable
    echo $enable > /sys/devices/platform/mtk_srccap0/mtk_dbg/atrace_enable
    echo $enable > /sys/devices/platform/mtk_srccap1/mtk_dbg/atrace_enable
    echo $enable > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/atrace_enable
    
#dd off
	echo 0x0 > /sys/devices/platform/mtk-pq/mtk_dbg/log_level
	echo 0x0 > /sys/devices/platform/mtk-tvpqu/mtk_dbg/log_level
	echo 0x0 > /sys/module/drm/parameters/debug
	echo 0x0 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/log_level
#pq
	setprop vendor.mtk.mipq.debuglevel 0
	setprop vendor.mtk.pqhal.debuglevel 5

	setprop vendor.mstar.vsync_bridge.log 1
	setprop vendor.mtk.vsyncbridge.log 1
	setprop vendor.mtk.tpchwc.log 1
#displink
	setprop vendor.mtk.displink.bm.profile 1
	setprop vendor.mtk.displink.log 1
	setprop vendor.mtk.pqlink.log 1
	setprop vendor.mtk.pqlink.performance.profile 1
#c2 & vdec
	setprop vendor.mtk.c2.enable.comp.log 2
	setprop vendor.mtk.c2.enable.vdec.log 2
	setprop vendor.mtktv.c2.enable.vdec.log 2
	setprop vendor.mtktv.c2.enable.bm.log 2
	setprop vendor.mtk.vcodecvideo.log 2
	setprop vendor.mtk.vcodecvdecimpl.log 3
#tpc
	setprop vendor.mtk.sharemem.debug.log 2
	setprop vendor.mtk.tpc.debug.log 4

	logcat -G 256M
	logcat -c
  fi
}
kernel_trace_enable()
{
	enable=$1
	# print tgid for all context switch in atrace
  if [ $record_tgid -eq 1 ]; then
    echo $enable > $TRACING_PATH/options/record-tgid
 		echo 32768 >  $TRACING_PATH/saved_cmdlines_size
  fi

  if [ $cpu_freq -eq 1 ]; then
  	echo $enable > $TRACING_PATH/events/power/cpu_frequency/enable
  fi
  #irq
  if [ $irq -eq 1 ]; then
  	arch_timer_irq=`cat /proc/interrupts | grep arch_timer | cut -f 1 -d":"| cut -b 2-`
  	echo "arch_timer='$arch_timer_irq'"
    echo "irq!=$arch_timer_irq" > $TRACING_PATH/events/irq/irq_handler_exit/filter
    echo "irq!=$arch_timer_irq" > $TRACING_PATH/events/irq/irq_handler_entry/filter
    echo $enable > $TRACING_PATH/events/irq/irq_handler_entry/enable
    echo $enable > $TRACING_PATH/events/irq/irq_handler_exit/enable
  fi

	#v4l2
  if [ $v4l2 -eq 1 ]; then
		echo $enable > /sys/kernel/tracing/events/v4l2/enable
		echo $enable > /sys/kernel/tracing/events/vb2/enable
	fi
	#drm
	if [ $drm_vblank -eq 1 ]; then
		echo $enable > /sys/kernel/tracing/events/drm/drm_vblank_event/enable
		echo $enable > /sys/kernel/tracing/events/drm/drm_vblank_event_queued/enable
		echo $enable > /sys/kernel/tracing/events/drm/drm_vblank_event_delivered/enable
	fi
	#cpu freq
	if [ $cpu_freq -eq 1 ]; then
		echo $enable > $TRACING_PATH/events/power/cpu_frequency/enable
	fi
	if [ $android_trace -eq 1 ]; then
  	setprop debug.egl.traceGpuCompletion 1
  	setprop debug.atrace.tags.enableflags 0x3ffffe
	else
		setprop debug.egl.traceGpuCompletion 0
		setprop debug.atrace.tags.enableflags 0
	fi
}

if test -f "/sys/kernel/debug/tracing/tracing_on"; then
    TRACING_PATH="/sys/kernel/debug/tracing"
elif test -f "/sys/kernel/tracing/tracing_on"; then
    TRACING_PATH="/sys/kernel/tracing"
fi
echo set TRACING_PATH=$TRACING_PATH


if [ "$1" == "start" ]; then
    echo "atrace start..."
    if [ ! -d /sys/kernel/debug/tracing ]; then
        mount -t debugfs nodev /sys/kernel/debug
    fi
    echo 20480 > $TRACING_PATH/buffer_size_kb
	#Clear tracing
    echo >  $TRACING_PATH/trace
    # overwrite mode by default
    echo 1 > /sys/kernel/tracing/options/overwrite

    #Process sched
    echo 1 > $TRACING_PATH/events/sched/sched_wakeup/enable
    echo 1 > $TRACING_PATH/events/sched/sched_wakeup_new/enable
    #echo 1 > $TRACING_PATH/events/sched/sched_waking/enable
    echo 1 > $TRACING_PATH/events/sched/sched_switch/enable
    echo 1 > $TRACING_PATH/events/sched/sched_process_fork/enable
    echo 1 > $TRACING_PATH/events/sched/sched_pi_setprio/enable

		#trace enable
		kernel_trace_enable 1

    #logcat support
		rm /data/logcat.log
    if [ $logcat -eq 1 ]; then
			logcat -G 256M
			setenforce 0
			killall logcat
			logcat -c
			echo "start time :"
			date
			logcat -v threadtime -f /data/logcat.log 2>/dev/null 1>/dev/null &
    fi

    #Enable tracing
    echo 1 > $TRACING_PATH/tracing_on
elif [ "$1" == "stop" ]; then
    echo "atrace stop ....."
    echo 0 > $TRACING_PATH/tracing_on
   if [ $logcat -eq 1 ]; then
			echo "stop time :"
			date
			killall logcat
    fi
    #cat $TRACING_PATH/trace > /mnt/ftrace.log
    dd if=$TRACING_PATH/trace of=/mnt/ftrace.log bs=2048
	echo "Download log - adb pull /mnt/ftrace.log"
	echo "Trace disable"
	kernel_trace_enable 0
	mtk_video_atrace_enable 0
elif [ "$1" == "dump" ]; then
    echo "atrace dump ....."
     if [ "$logcat" == "1" ]; then
			echo "dump time :"
			date
    fi
    #cat $TRACING_PATH/trace > /mnt/ftrace.log
    dd if=$TRACING_PATH/trace of=/mnt/ftrace.log bs=2048
	echo "Download log - adb pull /mnt/ftrace.log"
elif [ "$1" == "config" ]; then
	echo "Enable atrace before you start to play video"
	mtk_video_atrace_enable 1
	#stop;start
else
    echo "usage:atrace.sh config/start/stop"
fi
