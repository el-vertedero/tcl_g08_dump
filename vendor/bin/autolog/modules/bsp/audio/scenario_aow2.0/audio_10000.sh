#!/usr/bin/env sh

DUMP_AP_FP="$(GenLogPath "dump_ap.txt")"
echo "DUMP_AP_FP=$DUMP_AP_FP"

DUMP_AF_FP="$(GenLogPath "dump_af.txt")"
echo "DUMP_AF_FP=$DUMP_AF_FP"

DUMP_AUDIO_FP="$(GenLogPath "dump_audio.txt")"
echo "DUMP_AUDIO_FP=$DUMP_AUDIO_FP"

DUMP_AUDIO_HDMI="$(GenLogPath "dump_hdmi.txt")"
echo "DUMP_AUDIO_HDMI=$DUMP_AUDIO_HDMI"

DUMP_AUDIO_OUT_STATUS="$(GenLogPath "dump_out_status.txt")"
echo "DUMP_AUDIO_OUT_STATUS=$DUMP_AUDIO_OUT_STATUS"

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

	setprop log.tag.APM_AudioPolicyManager V
	echo apaf_log_level=info > /mnt/vendor/tmp/apaf/D
	setprop log.tag.audio_hw_primary V
	setprop vendor.hal.audio.log.level VERBOSE
	setprop log.tag.thal_audio V
	setprop vendor.hal.audio.astream.log.level VERBOSE
	setprop log.tag.AStreamClient V
	setprop log.tag.AStreamService V

	setprop vendor.hal.C2.AD.status 1
	setprop vendor.hal.c2.audio.log.level VERBOSE
	setprop vendor.mtk.codec2.log 2

	echo 7 > /sys/devices/platform/1c2e5800.mtk-tv-offload-soc/mtk_dbg/log_level
	echo debug_level=3 > /sys/devices/platform/mtk-tv-offload-platform/mtk_dbg/utopia_mdb
	echo 0 > /proc/sys/kernel/printk

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
	   date
	   date > $DUMP_AUDIO_HDMI
	         cat /sys/devices/platform/mtk_srccap0/mtk_dbg/hdmirx/HDMI_INFO >> $DUMP_AUDIO_HDMI
	         cat /sys/devices/platform/mtk_srccap0/mtk_dbg/hdmirx/TIMING_DETECT >> $DUMP_AUDIO_HDMI
	         cat /sys/devices/platform/mtk_srccap0/mtk_dbg/hdmirx/0/pkt_all >> $DUMP_AUDIO_HDMI
	         cat /sys/devices/platform/mtk_srccap0/mtk_dbg/hdmirx/1/pkt_all >> $DUMP_AUDIO_HDMI
	         cat /sys/devices/platform/mtk_srccap0/mtk_dbg/hdmirx/2/pkt_all >> $DUMP_AUDIO_HDMI
	         cat /sys/devices/platform/mtk_srccap0/mtk_dbg/hdmirx/3/pkt_all >> $DUMP_AUDIO_HDMI
	         cat /sys/devices/platform/mtk_srccap0/mtk_dbg/hdmirx/0/edid >> $DUMP_AUDIO_HDMI
	         cat /sys/devices/platform/mtk_srccap0/mtk_dbg/hdmirx/1/edid >> $DUMP_AUDIO_HDMI
	         cat /sys/devices/platform/mtk_srccap0/mtk_dbg/hdmirx/2/edid >> $DUMP_AUDIO_HDMI
	         cat /sys/devices/platform/mtk_srccap0/mtk_dbg/hdmirx/3/edid >> $DUMP_AUDIO_HDMI
	   date
	   date > $DUMP_AUDIO_OUT_STATUS
	         cat /sys/devices/platform/mtk-tv-offload-platform/mtk_dbg/output_status >> $DUMP_AUDIO_OUT_STATUS
	   date
	   echo "------ platform info ------"

	         adriver_tool --read-bank-8bit-mode 9502
	         adriver_tool --read-bank-8bit-mode 9503
	         adriver_tool --read-bank-8bit-mode 9504
	         adriver_tool --read-bank-8bit-mode 9507
	         adriver_tool --read-bank-8bit-mode 9515
	         sleep 1
	         echo debug_level=1 > /sys/devices/platform/mtk-tv-offload-platform/mtk_dbg/utopia_mdb
	         echo 3 > /proc/sys/kernel/printk
	         echo audio_status > /sys/devices/platform/mtk-tv-offload-platform/mtk_dbg/utopia_mdb
	         echo dts_status > /sys/devices/platform/mtk-tv-offload-platform/mtk_dbg/utopia_mdb
	         echo apaf_debug_list=print > /mnt/vendor/tmp/apaf/D
	         echo apaf_debug_list=status > /mnt/vendor/tmp/apaf/D
	         echo 0 > /proc/sys/kernel/printk
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
