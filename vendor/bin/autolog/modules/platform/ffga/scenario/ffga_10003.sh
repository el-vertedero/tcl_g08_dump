#!/usr/bin/env sh

ffga_log_open()
{
	LOG_PATH=$1
	echo "Open ffga log path: $LOG_PATH"
	setenforce 0
	logcat -G 64M
	setprop vendor.mtk.mic.led.log.level VERBOSE
	setprop log.tag.assistant_led VERBOSE 
	#audio_hw_primary
	setprop vendor.mstar.audio.log.level VERBOSE
	setprop log.tag.SoundTriggerHw V
	setprop log.tag.KtnsVoiceInteractionSrv VERBOSE 
	#KatnissConverstationSta
	setprop log.tag.KatnissConversationStateListener VERBOSE 
	logcat -v threadtime | grep -iE "assistant_led|audio_hw_primary|SoundTriggerHw|KtnsVoiceInteractionSrv|KatnissConverstationSta|HotWordContentProvider|FarFieldMicContentProvider" > $LOG_PATH & 

}

ffga_log_close()
{

	kill `pidof logcat`
	echo "Disable FFGA log "
	sync
	sync

  echo -e "Close Platform FFGA log Success!\n"
}

