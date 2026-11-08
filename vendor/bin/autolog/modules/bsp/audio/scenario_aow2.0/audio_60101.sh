#!/usr/bin/env sh
# for sony symptom

# AUTOLOG_LOG_DIR use system path
#AUTOLOG_LOG_DIR=/data/autolog

DUMP_AP_FP="$AUTOLOG_LOG_DIR/dump_ap.txt"
echo "DUMP_AP_FP=$DUMP_AP_FP"

DUMP_AF_FP="$AUTOLOG_LOG_DIR/dump_af.txt"
echo "DUMP_AF_FP=$DUMP_AF_FP"

DUMP_AUDIO_FP="$AUTOLOG_LOG_DIR/dump_audio.txt"
echo "DUMP_AUDIO_FP=$DUMP_AUDIO_FP"

#DUMP_DIR="$(GenLogPath "audio_dump_bin")"
DUMP_DIR="$AUTOLOG_LOG_DIR/audio_dump_bin_folder"
echo "mkdir -p $DUMP_DIR"

DUMP_DEC_R2="$AUTOLOG_LOG_DIR/audio_dec_r2.log"
echo "DUMP_DEC_R2=$DUMP_DEC_R2"

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

	echo 0 > /proc/sys/kernel/printk
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

	echo apaf_log_level=info > /mnt/vendor/tmp/apaf/D

if [ -d /sys/devices/platform/1dc48000.mtk-tv-offload-soc ]; then
	echo 7 > /sys/devices/platform/1dc48000.mtk-tv-offload-soc/mtk_dbg/log_level
	adriver_tool --write-byte 0x95078A,0x01,0x01
	adriver_tool --data-process 2 --write-byte 0x95079E,0xFF,0x17 > $DUMP_DEC_R2&
else
	echo 7 > /sys/devices/platform/1c2e5800.mtk-tv-offload-soc/mtk_dbg/log_level
	adriver_tool --write-byte 0x95048A,0x01,0x01
	adriver_tool --data-process 2 --write-byte 0x95049E,0xFF,0x17 > $DUMP_DEC_R2&
fi
	echo 4 > /sys/devices/platform/mtk-tv-offload-platform/mtk_dbg/offload_log_level
	echo 4 > /sys/devices/platform/mtk-tv-duplex-platform/mtk_dbg/mm_log_level
	echo 4 > /sys/devices/platform/mtk-tv-capture-platform/mtk_dbg/ext_device_log_level

	echo debug_level=3 > /sys/devices/platform/mtk-tv-offload-platform/mtk_dbg/utopia_mdb
	echo module_debug_level=5 > /sys/devices/platform/mtk-tv-offload-platform/mtk_dbg/utopia_mdb

#        rst1=$(IsDumpSysQuestion $ACT_LOG_FP)
#        if [ "${rst1}" == "Y" ] || [ "${rst1}" == "y" ]; then
#	   echo "------ dump policy ------"
#	   date > $DUMP_AP_FP
#           dumpsys media.audio_policy >> $DUMP_AP_FP
#           echo "------ dump flinger ------"
#	   date > $DUMP_AF_FP
#           dumpsys media.audio_flinger >> $DUMP_AF_FP
#           echo "------ dump audio ------"
#	   date > $DUMP_AUDIO_FP
#           dumpsys audio >> $DUMP_AUDIO_FP
#        else
#	   echo "------ not dumpsys ------"
#        fi
}

audio_log_close()
{
	setprop vendor.hal.audio.dump.hal 0
	echo apaf_log_level=none > /mnt/vendor/tmp/apaf/D

	echo "------ dump policy ------"
	date > $DUMP_AP_FP
	dumpsys media.audio_policy >> $DUMP_AP_FP
	echo "------ dump flinger ------"
	date > $DUMP_AF_FP
	dumpsys media.audio_flinger >> $DUMP_AF_FP
	echo "------ dump audio ------"
	date > $DUMP_AUDIO_FP
	dumpsys audio >> $DUMP_AUDIO_FP

	echo "kill adriver_tool"
	killall -9 adriver_tool

	echo "kill $LOGCAT_PID"
	kill $LOGCAT_PID

	mkdir -p $DUMP_DIR

	chmod 777 "/data/dump_audio_hal_out"*
	cp "/data/dump_audio_hal_out"* "$DUMP_DIR"
}
