#!/usr/bin/env sh

ffga_log_sys_dump()
{
	LOG_SYS_PATH=$1.system
	echo "Dump ffga sys log path: $LOG_SYS_PATH"
	echo "Dump network status" > $LOG_SYS_PATH
	ifconfig >> $LOG_SYS_PATH
	echo "Ping google dns test" >> $LOG_SYS_PATH
	ping -c 1 -W 1 8.8.8.8 >> $LOG_SYS_PATH 2>> $LOG_SYS_PATH
	echo "===================" >> $LOG_SYS_PATH
	echo "Dump sound card device status" >> $LOG_SYS_PATH
	cat /proc/asound/pcm >> $LOG_SYS_PATH
	echo "===================" >> $LOG_SYS_PATH
}

ffga_log_audio_dump_open()
{
	LOG_AUDIO_PATH=$1_dump/
	TMP_AUDIO_PATH=/data/local/tmp/voicesdk/
	SIZE=${#LOG_AUDIO_PATH}
	tinymix-master -D 86 get "MtkEc dump path"
	if [ $? -eq 0 ]; then
		echo "Open dump audio path: $LOG_AUDIO_PATH"
		export LOG_AUDIO_PATH
		export TMP_AUDIO_PATH

		mkdir -p $TMP_AUDIO_PATH
		chmod 777 $TMP_AUDIO_PATH -R
		for i in $(seq 0 $SIZE)
		do
			DUMP_PATH=$DUMP_PATH' '$(printf "%d" "'${TMP_AUDIO_PATH:$i:1}")
		done
		tinymix-master -D 86 set "MtkEc dump path" $DUMP_PATH
	fi
}

ffga_log_audio_dump_close()
{
	tinymix-master -D 86 get "MtkEc dump path"
	if [ $? -eq 0 ]; then
		echo "Close dump audio path"
		tinymix-master -D 86 set "MtkEc dump path" 0
		if [ ! -z $LOG_AUDIO_PATH ]; then
			cp -r $TMP_AUDIO_PATH $LOG_AUDIO_PATH
		fi
	fi
}

ffga_log_open()
{
	LOG_PATH=$1
	echo "Open ffga log path: $LOG_PATH"
	setenforce 0
	logcat -G 64M
	setprop vendor.mtk.mic.led.log.level VERBOSE
	setprop log.tag.assistant_led VERBOSE
	setprop vendor.mstar.audio.log.level VERBOSE  #audio_hw_primary
	setprop log.tag.SoundTriggerHw V
	setprop log.tag.KtnsVoiceInteractionSrv VERBOSE
	setprop log.tag.KatnissConversationStateListener VERBOSE #KatnissConverstationSta
	ffga_log_sys_dump $LOG_PATH
	ffga_log_audio_dump_open $LOG_PATH
	logcat -v threadtime | grep -iE "assistant_led|audio_hw_primary|SoundTriggerHw|KtnsVoiceInteractionSrv|KatnissConverstationSta|voicesdk_server" > $LOG_PATH &

	#enable dump file
	chmod 777 /data
	setprop vendor.mtk.voc.hal.dump 1
	setprop vendor.mtk.voc.input.dump 1

}

ffga_log_close()
{
	ffga_log_audio_dump_close
	kill `pidof logcat`
	echo "Disable FFGA log "

	setprop vendor.mtk.voc.hal.dump 0
	setprop vendor.mtk.voc.input.dump 0
	echo "Disable Dump file check the /data/dump_pcm_capture_xxx.pcm and mi_voc_dump.pcm"

	sync
	sync

  echo -e "Close Platform FFGA log Success!\n"
}

