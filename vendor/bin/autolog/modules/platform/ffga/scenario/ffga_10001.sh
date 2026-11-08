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
	setprop log.tag.APM_AudioPolicyManager VERBOSE
	setprop log.tag.AudioFlinger V
	#audio_hw_primary
	setprop vendor.mstar.audio.log.level VERBOSE
	setprop log.tag.SoundTriggerHw V
	setprop log.tag.KtnsVoiceInteractionSrv VERBOSE
	setprop log.tag.KatnissConversationStateListener VERBOSE
	ffga_log_sys_dump $LOG_PATH
	ffga_log_audio_dump_open $LOG_PATH
	logcat -v threadtime > $LOG_PATH &

}

ffga_log_close()
{
	ffga_log_audio_dump_close
	kill `pidof logcat`
	echo "Disable FFGA log "
	sync
	sync

  echo -e "Close Platform FFGA log Success!\n"
}

