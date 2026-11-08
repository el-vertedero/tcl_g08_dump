#!/usr/bin/env sh

ffga_log_open()
{
	LOG_PATH=$1
	echo "Open ffga log path: $LOG_PATH"
	setenforce 0
	logcat -G 64M
	setprop log.tag.APM_AudioPolicyManager VERBOSE 
	setprop log.tag.AudioFlinger V
	#audio_hw_primary
	setprop vendor.mstar.audio.log.level VERBOSE
	logcat -v threadtime | grep -iE "AudioFlinger|APM_AudioPolicyManager|audio_hw_primary" > $LOG_PATH & 

}

ffga_log_close()
{

	kill `pidof logcat`
	echo "Disable FFGA log "
	sync
	sync

  echo -e "Close Platform FFGA log Success!\n"
}

