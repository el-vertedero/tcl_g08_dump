#!/vendor/bin/sh

if [ -e /vendor/bin/cpu_audio ] ; then
	echo ""
	echo "CPU_AUDIO is running!"
    /vendor/bin/cpu_audio &
    wait
    echo "cpu_audio end"
fi
