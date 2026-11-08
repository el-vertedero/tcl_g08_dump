#!/bin/bash

echo "start to check ""$1"

LOCAL_LOG_PATH="$2"

CHECK_RENDER_DURATION=3
isRenderInFinalSec() {
	LAST_TIME=`egrep -e " I [^ ][^:]*:| D [^ ][^:]*:| V [^ ][^:]*:| E [^ ][^:]*:" $1 | tail -1 | egrep -o -e "^[^:]*:[^:]*:[^.]*"`
	LAST_SEC=`echo $LAST_TIME | egrep -o -e "[^:]*$"`;
	LAST_MIN=`echo $LAST_TIME | sed -e 's/^[^:]*://g; s/:[^:]*$//g'`;
	LAST_HOUR=`echo $LAST_TIME | sed -e 's/^[^ ]*[ ]*//g; s/:.*$//g'`;
	LAST_DAY=`echo $LAST_TIME | grep -o -e "^[^ ]*" | grep -o -e "[^-]*$"`;
	LAST_MON=`echo $LAST_TIME | grep -o -e "^[^ ]*" | grep -o -e "^[^-]*"`;
	if [ -z $LAST_SEC ]; then
		echo "log missing time!!"
		return 1
	fi
	if [ $LAST_SEC -ge `expr $CHECK_RENDER_DURATION` ]; then
		BEFORE_SEC=`expr $LAST_SEC - $CHECK_RENDER_DURATION`
		if [ $BEFORE_SEC -lt 10 ]; then
			BEFORE_SEC="0""$BEFORE_SEC"
		fi
	    BEFORE_MIN=$LAST_MIN
	else
		BEFORE_SEC=`expr 60 + $LAST_SEC - $CHECK_RENDER_DURATION`
		if [ $LAST_MIN -eq 0 ]
		then
			BEFORE_MIN=`expr 60 + $LAST_MIN - 1`
		else
	    	BEFORE_MIN=`expr $LAST_MIN - 1`
	    fi
	fi
	LAST_SEC_LOG=`egrep -m 1 -n "$BEFORE_MIN:$BEFORE_SEC" $1 | egrep -oh "^[0-9]*"`
	if [ -z $LAST_SEC_LOG ]; then
		return 1
	fi
	LOG_LAST_FEW_SECONDS="$LOCAL_LOG_PATH/log_last_few_seconds.txt"
	sed -e "1,""$LAST_SEC_LOG""d" $1 > $LOG_LAST_FEW_SECONDS;
	LAST_SECS_VIDEO_FRAME_RENDER_LOG=`egrep -m 1 -e "call onVideoFrameRendered()|onVideoFrameRendered: presentationTimeUs|PlaybackSession: onVideoFrameRendered" $LOG_LAST_FEW_SECONDS`
	if [ ! -z "$LAST_SECS_VIDEO_FRAME_RENDER_LOG" ]; then
		LAST_SECS_RENDERING_START_LOG=`egrep -m 1 -e "notify rendering start" $LOG_LAST_FEW_SECONDS`
		if [ -z "$LAST_SECS_RENDERING_START_LOG" ]; then
			FIRST_UNMUTE_LOG=`egrep -m 1 -e "Mute 0, UserMute 0" $LOG_LAST_FEW_SECONDS`
			if [ ! -z "$FIRST_UNMUTE_LOG" ]; then
				echo "====Analysis result Begin===="
				echo "$LAST_SECS_VIDEO_FRAME_RENDER_LOG"
				echo "$FIRST_UNMUTE_LOG"
				echo "In last ""$CHECK_RENDER_DURATION"" sec, onVideoFrameRendered still exist"
				echo "check unmute ok"
				echo -e "Assign to \033[31mDisplay\033[0m"
				return 0
			else
				echo "In last ""$CHECK_RENDER_DURATION"" sec, onVideoFrameRendered still exist, but no unmute"
				return 1
			fi
		else
			echo "====Analysis result Begin===="
			echo "$LAST_SECS_RENDERING_START_LOG"
			echo "notify rendering start too late !!"
			echo -e "Assign to \033[31mTV exoplayer\033[0m"
			return 0
		fi
	fi
	return 1
}

LOG_AFTER_LAST_GET_CHANNELLIST="$LOCAL_LOG_PATH/log_after_last_getchannellist.txt"
LAST_GET_CHANNELLIST=`egrep -n "init : getChannelListId" $1 | egrep -oh "^[0-9]*" | tail -1`
FIRST_CHANNEL=0
if [ ! -z $LAST_GET_CHANNELLIST ]; then
	if [ $LAST_GET_CHANNELLIST -ne 1 ]; then
		DELETE_LINE=`expr $LAST_GET_CHANNELLIST - 1`
		sed -e "1,""$DELETE_LINE""d" $1 > $LOG_AFTER_LAST_GET_CHANNELLIST
	else
		LOG_AFTER_LAST_GET_CHANNELLIST="$1"
	fi
    ONTUNE_COUNT=`egrep -n "onTune:\[uri:" $LOG_AFTER_LAST_GET_CHANNELLIST | wc -l`
	if [ "$ONTUNE_COUNT" == "1" ]; then
		FIRST_CHANNEL=1
		echo "Happened on first channel"
	fi
fi
LAST_REAL_TUNE=`egrep -n "@@real tune@@" $1 | egrep -oh "^[0-9]*" | tail -1`
LOG_AFTER_LAST_REAL_TUNE="$LOCAL_LOG_PATH/LOG_AFTER_LAST_REAL_TUNE.txt"

# Find last onTune:[uri:
if [ -z $LAST_REAL_TUNE ]
then
	echo "====Analysis result Begin===="
	echo "Log \"@@real tune@@\" is missing";
	echo -e "Assign to \033[31mTv Apk\033[0m";
	echo "====Analysis result End===="
    exit 1
elif [ $LAST_REAL_TUNE -ne 1 ]; then
    DELETE_LINE=`expr $LAST_REAL_TUNE - 1`
	sed -e "1,""$DELETE_LINE""d" $1 > $LOG_AFTER_LAST_REAL_TUNE
else
	LOG_AFTER_LAST_REAL_TUNE="$1"
fi

# Check if still Render in last X seconds or not
if isRenderInFinalSec $LOG_AFTER_LAST_REAL_TUNE; then
	echo "====Analysis result End===="
	exit 0
fi

PASSTHROUGH_MODE=`egrep -m 1 -n "passthrough_mode= 1" $1`
FIRST_REAL_TUNE=`egrep -n "@@real tune@@" $LOG_AFTER_LAST_REAL_TUNE | egrep -oh "^[0-9]*"`
DVB_TUNER=`egrep -m 1 -n "PlaybackSession: onTune" $LOG_AFTER_LAST_REAL_TUNE`
FIRST_ONTUNE_URI=`egrep -m 1 -n -e "onTune:\[uri:|PlaybackSession: onTune" $LOG_AFTER_LAST_REAL_TUNE | egrep -oh "^[0-9]*"`
FIRST_TUNE_SETTING=`egrep -m 1 -n "TuneSetting: service tune:true" $LOG_AFTER_LAST_REAL_TUNE | egrep -oh "^[0-9]*"`
FIRST_FREQ_CHANGE=`egrep -m 1 -n "status: 1, freq change: true" $LOG_AFTER_LAST_REAL_TUNE | egrep -oh "^[0-9]*"`
FIRST_PIPELINE_HANDLER_SIGNAL_LOCK=`egrep -m 1 -n -e "MtkTvServiceSelector[^$]*Signal locked" $LOG_AFTER_LAST_REAL_TUNE | egrep -oh "^[0-9]*"`
FIRST_PIPELINE_HANDLER_NOSIGNAL=`egrep -m 1 -n -e "MtkTvServiceSelector[^$]*No signal or lost lock" $LOG_AFTER_LAST_REAL_TUNE | egrep -oh "^[0-9]*"`
FIRST_ISLOCK=`egrep -m 1 -n "onEvent\(\) is lock" $LOG_AFTER_LAST_REAL_TUNE | egrep -oh "^[0-9]*"`
FIRST_TUNE_STATUS_RETURN_ZERO=`egrep -m 1 -n -e "MtkTvServiceSelector[^$]*tune Frequency, returnValue: 0" $LOG_AFTER_LAST_REAL_TUNE | egrep -oh "^[0-9]*"`
FIRST_TABLE_STATUS=`egrep -m 1 -n "onTableStatus: status" $LOG_AFTER_LAST_REAL_TUNE | egrep -oh "^[0-9]*"`
FIRST_PMT_UPDATED=`egrep -m 1 -n -e "\[CONN_MNGR\]\[BRDCST\]PMT updated|parse: PMT is discovered" $LOG_AFTER_LAST_REAL_TUNE | egrep -oh "^[0-9]*"`
FIRST_STREAM_AVAILABLE=`egrep -m 1 -n "StreamComponentCallback: onStreamComponentAvaliable|pmt getMtkTvStreamComponentInfos" $LOG_AFTER_LAST_REAL_TUNE | egrep -oh "^[0-9]*"`
FIRST_EXTRACTOR_OPEN_FILTER=`egrep -m 1 -n "HwTsExtractor: open filter for track" $LOG_AFTER_LAST_REAL_TUNE | egrep -oh "^[0-9]*"`
FIRST_FILTERTHREAD_START=`egrep -m 1 -n "filter threadLoop start" $LOG_AFTER_LAST_REAL_TUNE | egrep -oh "^[0-9]*"`
if [ -z $FIRST_ONTUNE_URI ]; then
echo "====Analysis result Begin===="
	sed -n -e "$FIRST_REAL_TUNE""p" $LOG_AFTER_LAST_REAL_TUNE;
	echo "=> onTune:[uri: is missing after this log"
	echo -e "Assign to \033[31mRegion TIS layer\033[0m"
	echo "====Analysis result End===="
	exit 0
elif [ -z $FIRST_TUNE_SETTING ]; then
echo "====Analysis result Begin===="
	sed -n -e "$FIRST_ONTUNE_URI""p" $LOG_AFTER_LAST_REAL_TUNE;
	echo "=> TuneSetting: service tune:true is missing after this log"
	echo -e "Assign to \033[31mRegion TIS SI\033[0m"
	echo "====Analysis result End===="
	exit 0
elif [ -z $FIRST_PIPELINE_HANDLER_SIGNAL_LOCK ] && [ ! -z $FIRST_FREQ_CHANGE ]; then
	echo "different freq"
	if [ ! -z $FIRST_PIPELINE_HANDLER_NOSIGNAL ]; then
		echo "====Analysis result Begin===="
		sed -n -e "$FIRST_PIPELINE_HANDLER_NOSIGNAL""p" $LOG_AFTER_LAST_REAL_TUNE;
		echo "=> no signal or lost lock"
		echo -e "Assign to \033[31mSignal\033[0m"
		echo "====Analysis result End===="
		exit 0
	else
		echo "====Analysis result Begin===="
		sed -n -e "$FIRST_TABLE_STATUS""p" $LOG_AFTER_LAST_REAL_TUNE;
		echo "=> MtkTvServiceSelector: Signal locked is missing after this log"
		echo -e "Assign to \033[31mPipelineHandler\033[0m"
		echo "====Analysis result End===="
		exit 0
	fi
elif [ -z $FIRST_ISLOCK ] && [ ! -z $FIRST_FREQ_CHANGE ]; then
	echo "different freq"
	FIRST_TUNER_FRONTEND=`egrep -m 1 -n "mdbgin_frontend_tunerhal" $1 | egrep -oh "^[0-9]*"`
	if [ ! -z "$FIRST_TUNER_FRONTEND" ]; then
		echo "====Analysis result Begin===="
		sed -n -e "$FIRST_ONTUNE_URI""p" $LOG_AFTER_LAST_REAL_TUNE;
		echo "=> Log \"onEvent\(\) is lock\" is missing after this log !!";
		sed -n -e "$FIRST_TUNER_FRONTEND""p" $LOG_AFTER_LAST_REAL_TUNE;
		echo "=> And mdbgin_frontend_tunerhal log is exist"
		echo -e "Assign to \033[31mtunerhal-frontend\033[0m"
		echo "====Analysis result End===="
		exit 0
	else
		echo "====Analysis result Begin===="
		sed -n -e "$FIRST_ONTUNE_URI""p" $LOG_AFTER_LAST_REAL_TUNE;
		echo "=> Log \"onEvent\(\) is lock\" is missing after this log, but no mdbgin_frontend_tunerhal log !!";
		echo -e "Assign to \033[31mTIS SI\033[0m"
		echo "====Analysis result End===="
		exit 0
	fi
elif [ -z $FIRST_TUNE_STATUS_RETURN_ZERO ] && [ ! -z $FIRST_FREQ_CHANGE ]; then
	echo "different freq"
	echo "====Analysis result Begin===="
	sed -n -e "$FIRST_TABLE_STATUS""p" $LOG_AFTER_LAST_REAL_TUNE;
	echo "Log\"MtkTvServiceSelector: tune Frequency, returnValue: 0\" is missing after this log !!";
	echo -e "Assign to \033[31mTvServiceSelector\033[0m"
	echo "====Analysis result End===="
	exit 0
elif [ -z $FIRST_TABLE_STATUS ]; then
	echo "====Analysis result Begin===="
	sed -n -e "$FIRST_TUNE_SETTING""p" $LOG_AFTER_LAST_REAL_TUNE;
	echo "onTableStatus: status is missing after this log"
	echo -e "Assign to \033[31mTableMnanger\033[0m"
	echo "====Analysis result End===="
	exit 0
elif [ -z $FIRST_PMT_UPDATED ]; then
	echo "====Analysis result Begin===="
	sed -n -e "$FIRST_ISLOCK""p" $LOG_AFTER_LAST_REAL_TUNE;
	echo "Log\"parse: PMT is discovered\" is missing after this log !!";
	echo -e "Assign to \033[31mPMT\033[0m"
	echo "====Analysis result End===="
	exit 0
elif [ -z $FIRST_STREAM_AVAILABLE ]; then
	echo "====Analysis result Begin===="
	sed -n -e "$FIRST_PMT_UPDATED""p" $LOG_AFTER_LAST_REAL_TUNE;
	echo "Log \"pmt getMtkTvStreamComponentInfos\" is missing after this log !!";
	echo -e "Assign to \033[31mSCDB\033[0m"
	echo "====Analysis result End===="
	exit 0
elif [ -z $FIRST_EXTRACTOR_OPEN_FILTER ]; then
	echo "====Analysis result Begin===="
	sed -n -e "$FIRST_STREAM_AVAILABLE""p" $LOG_AFTER_LAST_REAL_TUNE;
	echo "Log \"HwTsExtractor: open filter for track\" is missing after this log !!";
	echo -e "Assign to \033[31mHwTsExtractor\033[0m"
	echo "====Analysis result End===="
	exit 0
elif [ -z $FIRST_FILTERTHREAD_START ]; then
	echo "====Analysis result Begin===="
	sed -n -e "$FIRST_EXTRACTOR_OPEN_FILTER""p" $LOG_AFTER_LAST_REAL_TUNE;
	echo "Log \"filter threadLoop start\" is missing after this log !!";
	echo -e "Assign to \033[31mDemux\033[0m"
	echo "====Analysis result End===="
	exit 0
fi


function checkDataFlow() {
	echo "check data flow for ""$1"
	FIRST_AVHANDLE_CALLBACK=`egrep -m 1 -n "avHandleCallback" $1 | egrep -oh "^[0-9]*"`
	FIRST_ONFILTER_EVENT=`egrep -m 1 -n "onFilterEvent_1_1" $1 | egrep -oh "^[0-9]*"`
	#QUEUE_BLOCKBUFFER=`egrep -n "queueInputLinearBlockBuffer end" $1 | egrep -oh "^[0-9]*" | wc -l`
	FIRST_QUEUE_BLOCKBUFFER=`egrep -m 1 -n "queueInputLinearBlockBuffer end" $1 | egrep -oh "^[0-9]*"`
	FIRST_VDEC_PUSH=`egrep -m 1 -n "VCODEC_VDEC_IMPL: \[0\] Push:" $1 | egrep -oh "^[0-9]*"`
	FIRST_VDEC_POP=`egrep -m 1 -n "VCODEC_VDEC_IMPL: \[0\] Pop:" $1 | egrep -oh "^[0-9]*"`
	FIRST_VDEC_GET=`egrep -m 1 -n "VCODEC_VDEC_IMPL: \[0\] Get:" $1 | egrep -oh "^[0-9]*" `
	FIRST_FLIP_PQ_DONE=`egrep -m 1 -n "flip to PQ done" $1 | egrep -oh "^[0-9]*"`
	FIRST_PQ_FLIP_SYNCQ_DONE=`egrep -m 1 -n "PQ flip to syncQ" $1 | egrep -oh "^[0-9]*"`
	FIRST_FLIP_RENDER=`egrep -m 1 -n "\[performance\] flip to render done" $1 | egrep -oh "^[0-9]*"`
	FIRST_VIDEO_FRAME_RENDER=`egrep -m 1 -n -e "call onVideoFrameRendered()|onVideoFrameRendered: presentationTimeUs|PlaybackSession: onVideoFrameRendered" $1 | egrep -oh "^[0-9]*"`
	FIRST_RENDERING_START=`egrep -m 1 -n "notify rendering start" $1 | egrep -oh "^[0-9]*"`
	if [ -z $FIRST_AVHANDLE_CALLBACK ]; then
		echo "====Analysis result Begin===="
		sed -n -e "1p" $1;
		echo "Log \"avHandleCallback\" is missing after this log !!";
		echo -e "Assign to \033[31mAVHandleCallback\033[0m"
		return 0
	elif [ -z $FIRST_ONFILTER_EVENT ]; then
		echo "====Analysis result Begin===="
		sed -n -e "$FIRST_AVHANDLE_CALLBACK""p" $1;
		echo "Log \"onFilterEvent_1_1\" is missing after this log !!";
		echo -e "Assign to \033[31mTIS SI\033[0m"
		return 0
	elif [ -z "$PASSTHROUGH_MODE" ] && [ -z "$FIRST_QUEUE_BLOCKBUFFER" ]; then
		echo "====Analysis result Begin===="
		sed -n -e "$FIRST_ONFILTER_EVENT""p" $1;
		echo "Log \"queueInputLinearBlockBuffer end\" is missing after this log !!";
		echo -e "Assign to \033[31mTV exoplayer\033[0m"
		return 0
	elif [ -z $FIRST_VDEC_PUSH ]; then
		echo "====Analysis result Begin===="
		if [ -z "$PASSTHROUGH_MODE" ]; then
			sed -n -e "$FIRST_QUEUE_BLOCKBUFFER""p" $1;
		else
			sed -n -e "$FIRST_ONFILTER_EVENT""p" $1;
		fi
		echo "Log \"VCODEC_VDEC_IMPL: [0] Push:\" is missing after this log !!";
		echo -e "Assign to \033[31mMI Vdec\033[0m"
		return 0
	elif [ -z $FIRST_VDEC_POP ]; then
		echo "====Analysis result Begin===="
		sed -n -e "$FIRST_VDEC_PUSH""p" $1;
		echo "Log \"VCODEC_VDEC_IMPL: [0] Pop:\" is missing after this log !!";
		echo -e "Assign to \033[31mMI Vdec\033[0m"
		return 0
	elif [ -z $FIRST_VDEC_GET ]; then
		echo "====Analysis result Begin===="
		sed -n -e "$FIRST_VDEC_POP""p" $1;
		echo "Log \"VCODEC_VDEC_IMPL: [0] Get:\" is missing after this log !!";
		echo -e "Assign to \033[31mMI Vdec\033[0m"
		return 0
	elif [ -z $FIRST_FLIP_PQ_DONE ]; then
		echo "====Analysis result Begin===="
		sed -n -e "$FIRST_VDEC_GET""p" $1;
		echo "Log \"flip to PQ done\" is missing after this log !!";
		echo -e "Assign to \033[31mVCodecDTV\033[0m"
		return 0
	elif [ -z $FIRST_PQ_FLIP_SYNCQ_DONE ]; then
		echo "====Analysis result Begin===="
		sed -n -e "$FIRST_FLIP_PQ_DONE""p" $1;
		echo "Log \"PQ flip to syncQ\" is missing after this log !!";
		echo -e "Assign to \033[31mXC\033[0m"
		return 0
	elif [ -z $FIRST_FLIP_RENDER ]; then
		echo "====Analysis result Begin===="
		sed -n -e "$FIRST_PQ_FLIP_SYNCQ_DONE""p" $1;
		echo "Log \"[performance] flip to render done\" is missing after this log !!";
		echo -e "Assign to \033[31mDispLink\033[0m"
		return 0
	elif [ -z $FIRST_RENDERING_START ]; then
		echo "====Analysis result Begin===="
		sed -n -e "$FIRST_FLIP_RENDER""p" $1;
		echo "Log \"notify rendering start\" is missing after this log !!";
		echo -e "Assign to \033[31mTV exoplayer render\033[0m"
		return 0
	elif [ -z $FIRST_VIDEO_FRAME_RENDER ]; then
		echo "====Analysis result Begin===="
		sed -n -e "$FIRST_RENDERING_START""p" $1;
		echo "Log \"onVideoFrameRendered\" is missing after this log !!";
		echo -e "Assign to \033[31mDisplay\033[0m"
		return 0
	else
		LOG_AFTER_RENDERING_START_TMP="$LOCAL_LOG_PATH/log_after_RenderingStart_tmp.txt"
		DELETE_LINE=`expr $FIRST_RENDERING_START - 1`
		sed -e "1,""$DELETE_LINE""d" $1 > $LOG_AFTER_RENDERING_START_TMP;
		FIRST_MUTEVIDEO_T=`egrep -m 1 -n -e "muteVideo\(false\)" $LOG_AFTER_RENDERING_START_TMP | egrep -oh "^[0-9]*"`
		FIRST_SETMUTE_FALSE=`egrep -m 1 -n -e "MediaCodecVideoRenderer: ---setMute.*enable:false" $LOG_AFTER_RENDERING_START_TMP | egrep -oh "^[0-9]*"`
		FIRST_UNMUTE_LOG=`egrep -m 1 -e "Mute 0, UserMute 0" $LOG_AFTER_RENDERING_START_TMP | egrep -oh "^[0-9]*"`
		# Check mute flow, bypass DVB
		if [ "$FIRST_CHANNEL" == "1" ]; then
			echo "First channel doesn't need to check mute"
		elif [ -z "$FIRST_MUTEVIDEO_T" ] && [ -z "$DVB_TUNER" ]; then
			echo "====Analysis result Begin===="
			sed -n -e "$FIRST_RENDERING_START""p" $1;
			echo "call RENDERING_START, but no \"muteVideo(false)\" log"
			echo "assign to TIS mute"
			return 0
		elif [ -z "$FIRST_SETMUTE_FALSE" ] && [ -z "$DVB_TUNER" ]; then
			echo "====Analysis result Begin===="
			sed -n -e "$FIRST_RENDERING_START""p" $1;
			sed -n -e "$FIRST_MUTEVIDEO_T""p" $LOG_AFTER_RENDERING_START_TMP;
			echo "call RENDERING_START and mutevideo exist, but no \"MediaCodecVideoRenderer: ---setMute.*enable:false\" log"
			echo -e "Assign to \033[31mMediaCodecVideoRenderer\033[0m"
			return 0
		elif [ -z "$FIRST_UNMUTE_LOG" ]; then
			echo "====Analysis result Begin===="
			sed -n -e "$FIRST_RENDERING_START""p" $1;
			if [ ! -z "$DVB_TUNER" ]; then
				sed -n -e "$FIRST_MUTEVIDEO_T""p" $LOG_AFTER_RENDERING_START_TMP;
				sed -n -e "$FIRST_SETMUTE_FALSE""p" $LOG_AFTER_RENDERING_START_TMP;
				echo "check unmute ok, but still black screen"
			else
				echo "DVB should not mute"
			fi
			echo -e "Assign to \033[31mDispLink mute\033[0m"
			return 0
		fi
	fi
	return 1
}

# Analyze log after filter threadLoop start
LOG_AFTER_FIRST_FILTERTHREAD_START="$LOCAL_LOG_PATH/log_after_filterthreadLoop_start.txt"
sed -e "/filter threadLoop start/,\$!d" $LOG_AFTER_LAST_REAL_TUNE > $LOG_AFTER_FIRST_FILTERTHREAD_START;
if checkDataFlow $LOG_AFTER_FIRST_FILTERTHREAD_START ;then
	echo "====Analysis result End===="
	exit 0
fi

# Analyze log after notify rendering start
FIRST_RENDERING_START=`egrep -m 1 -n "notify rendering start" $LOG_AFTER_LAST_REAL_TUNE | egrep -oh "^[0-9]*"`
LOG_AFTER_RENDERING_START="$LOCAL_LOG_PATH/log_after_RenderStart.txt"
sed -e "/notify rendering start/,\$!d" $LOG_AFTER_LAST_REAL_TUNE > $LOG_AFTER_RENDERING_START;
if checkDataFlow $LOG_AFTER_RENDERING_START; then
	echo "====Analysis result End===="
	exit 0
fi

COUNT_VDEC_PUSH=`egrep -n "VCODEC_VDEC_IMPL: \[0\] Push:" $LOG_AFTER_RENDERING_START | egrep -oh "^[0-9]*" | wc -l`
COUNT_VDEC_POP=`egrep -n "VCODEC_VDEC_IMPL: \[0\] Pop:" $LOG_AFTER_RENDERING_START | egrep -oh "^[0-9]*" | wc -l`
COUNT_VDEC_GET=`egrep -n "VCODEC_VDEC_IMPL: \[0\] Get:" $LOG_AFTER_RENDERING_START | egrep -oh "^[0-9]*" | wc -l`
COUNT_FLIP_PQ_DONE=`egrep -n "flip to PQ done" $LOG_AFTER_RENDERING_START | egrep -oh "^[0-9]*" | wc -l`
COUNT_PQ_FLIP_SYNCQ_DONE=`egrep -n "PQ flip to syncQ" $LOG_AFTER_RENDERING_START | egrep -oh "^[0-9]*" | wc -l`
COUNT_FLIP_RENDER=`egrep -n "\[performance\] flip to render done" $LOG_AFTER_RENDERING_START | egrep -oh "^[0-9]*" | wc -l`
COUNT_VIDEO_FRAME_RENDER=`egrep -n -e "call onVideoFrameRendered()|onVideoFrameRendered: presentationTimeUs" $LOG_AFTER_RENDERING_START | egrep -oh "^[0-9]*" | wc -l`

echo "COUNT_VDEC_PUSH=""$COUNT_VDEC_PUSH"
echo "COUNT_VDEC_POP=""$COUNT_VDEC_POP"
echo "COUNT_VDEC_GET=""$COUNT_VDEC_GET"
echo "COUNT_FLIP_PQ_DONE=""$COUNT_FLIP_PQ_DONE"
echo "COUNT_PQ_FLIP_SYNCQ_DONE=""$COUNT_PQ_FLIP_SYNCQ_DONE"
echo "COUNT_FLIP_RENDER=""$COUNT_FLIP_RENDER"
echo "COUNT_VIDEO_FRAME_RENDER=""$COUNT_VIDEO_FRAME_RENDER"

function findCrashLib() {
    LOG_PATH=$1
	CRASH_LIB=`egrep -e "\.apk\!.*.so" $1 | sed -e 's/.*apk!//g; s/\.so .*/\.so/g'`
	if [ ! -z "$CRASH_LIB" ]; then
    	echo -e "\033[31m$CRASH_LIB\033[0m""\033[31m is crashed!!\033[0m"
	    echo -e "\033[31mDispatch to owner of \033[0m""\033[31m$CRASH_LIB\033[0m"
		return 0
	fi
	return 1
}

#findCrashLib $LOG_AFTER_LAST_REAL_TUNE
echo "====Analysis result Begin===="
echo "check log done"
echo -e "Assign to \033[31mTIS SI\033[0m";
echo "====Analysis result End===="
