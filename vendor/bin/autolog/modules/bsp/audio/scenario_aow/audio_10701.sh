#!/usr/bin/env sh

DUMP_AP_FP="$(GenLogPath "dump_ap.txt")"
echo "DUMP_AP_FP=$DUMP_AP_FP"

DUMP_AF_FP="$(GenLogPath "dump_af.txt")"
echo "DUMP_AF_FP=$DUMP_AF_FP"

DUMP_AUDIO_FP="$(GenLogPath "dump_audio.txt")"
echo "DUMP_AUDIO_FP=$DUMP_AUDIO_FP"

IsDumpSysQuestion()
{
  local OUTPUT_FP="$1"
  message="${COLOR_RED} After reproduce issue, key in [Y/y] to dumpsys:  ${COLOR_REST}"
  ### This will call prompt function from utils/helpers.sh
  ### prompt(message, log_file_path)
  ###   => Use read command to ask user questions, and record it into log_file_path
  bug=$(prompt "$message" "$OUTPUT_FP")
  echo "$bug"  # Return answer
}

audio_log_open()
{
	setenforce 0
	chmod 777 /data
	logcat -c && logcat -G 64M	
	LOGCAT_LOG_FP="$(GenLogPath "logcat.log")"
	echo "LOGCAT_LOG_FP=$LOGCAT_LOG_FP"
	
	setprop vendor.hal.audio.log.level VERBOSE
	setprop vendor.hal.c2.audio.log.level VERBOSE
	setprop vendor.hal.audio.astream.log.level VERBOSE
        setprop log.tag.audio_hw_primary V
        setprop log.tag.AStreamImpl_Service V
        setprop log.tag.MS12Server V
	lshal debug vendor.mediatek.hardware.adecode@1.0::IADecode/adecode debug 2
	setprop vendor.hal.C2.AD.status 1
	setprop vendor.hal.c2.dec.log.verbose true
	setprop vendor.hal.audio.dump.hal 1

	setprop log.tag.APM_AudioPolicyManager V
	setprop media.acodec.verbose.log 1
	setprop media.mediacodec.verbose.log 1

	echo apaf_log_level=sync > /mnt/vendor/tmp/apaf/D

	echo 7 > /sys/devices/platform/mtk-sound-playback-platform/mtk_dbg/spk_log_level
	echo 7 > /sys/devices/platform/mtk-sound-dplayback-platform/mtk_dbg/arc_nonpcm_log_level
	echo 7 > /sys/devices/platform/mtk-sound-dplayback-platform/mtk_dbg/arc_pcm_log_level
	echo 7 > /sys/devices/platform/mtk-sound-dplayback-platform/mtk_dbg/earc_nonpcm_log_level
	echo 7 > /sys/devices/platform/mtk-sound-dplayback-platform/mtk_dbg/earc_nonpcm_synth
	echo 7 > /sys/devices/platform/mtk-sound-dplayback-platform/mtk_dbg/earc_pcm_log_level
	echo 7 > /sys/devices/platform/mtk-sound-dplayback-platform/mtk_dbg/spdif_nonpcm_log_level
	echo 7 > /sys/devices/platform/mtk-sound-dplayback-platform/mtk_dbg/spdif_pcm_log_level
	
	logcat -f $LOGCAT_LOG_FP &
	LOGCAT_PID=$!
	echo "logcat pid: $LOGCAT_PID"

        rst1=$(IsDumpSysQuestion $ACT_LOG_FP)
        if [ "${rst1}" == "Y" ] || [ "${rst1}" == "y" ]; then
	   echo "------ dump policy ------"
	   date > $DUMP_AP_FP
           dumpsys media.audio_policy >> $DUMP_AP_FP
           echo "------ dump flinger ------"
	   date > $DUMP_AF_FP
           dumpsys media.audio_flinger >> $DUMP_AF_FP
           echo "------ dump audio ------"
	   date > $DUMP_AUDIO_FP
           dumpsys audio >> $DUMP_AUDIO_FP
        else
	   echo "------ not dumpsys ------"
        fi
}

audio_log_close()
{
	setprop vendor.hal.audio.dump.hal 0
	echo apaf_log_level=none > /mnt/vendor/tmp/apaf/D

	echo "kill $LOGCAT_PID"
	kill $LOGCAT_PID
	
	DUMP_DIR="$(GenLogPath "audio_dump")"
	echo "mkdir -p $DUMP_DIR"
	mkdir -p $DUMP_DIR
	
	chmod 777 "/data/dump_audio_hal_out"*
	cp "/data/dump_audio_hal_out"* "$DUMP_DIR"
}
