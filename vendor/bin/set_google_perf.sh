#!/bin/sh

if [ $1 == "1" ]
then
	echo 0 >  /sys/block/mmcblk0/queue/iostats
	echo 2048 > /sys/block/mmcblk0/queue/read_ahead_kb
	echo 256 > /sys/block/mmcblk0/queue/nr_requests
	echo  2 > /sys/block/mmcblk0/queue/rq_affinity
	echo 128 > /sys/module/dm_verity/parameters/prefetch_cluster

	for i in /sys/block/dm-*
	do
		echo 0 > $i/queue/iostats
		echo 2048 > $i/queue/read_ahead_kb
		echo 2 > $i/queue//rq_affinity
	done
else
	sleep 15
	# improve performace from Google's suggestion
	echo 100000 > /proc/sys/kernel/sched_migration_cost_ns
	echo 1000000 > /proc/sys/kernel/sched_wakeup_granularity_ns
	echo 1500000 > /proc/sys/kernel/sched_min_granularity_ns
	echo 1000000 > /proc/sys/kernel/sched_latency_ns

	echo 1 >  /sys/block/mmcblk0/queue/iostats
	echo 128 > /sys/block/mmcblk0/queue/read_ahead_kb
	echo 128 > /sys/block/mmcblk0/queue/nr_requests
	echo  1 > /sys/block/mmcblk0/queue/rq_affinity

	for i in /sys/block/dm-*
	do
		echo 1 > $i/queue/iostats
		echo 128 > $i/queue/read_ahead_kb
		echo 0 > $i/queue/rq_affinity
	done
fi


