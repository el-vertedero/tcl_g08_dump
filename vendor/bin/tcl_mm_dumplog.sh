#!/system/bin/sh
#set -x

AndroidHardWareId=$(getprop ro.hardware.version_id)

UniPlayer=$(getprop ro.feature.media_uniplayer)
time=$(date "+%m%d-%H%M")

DUMP_PATH=/data/tmp

setenforce 0
mount -o remount,rw /data
if [ ! -e $DUMP_PATH ];then
    mkdir -p $DUMP_PATH
    chmod 777 $DUMP_PATH
fi
echo 0 >/proc/sys/kernel/printk

isdumping=0
iscatching=0

help() {
    echo "Usage: sh tcl_mm_dumplog.sh [option] [option] ..."
    echo " "
    echo "Option list:"
    echo "        -h|--help           show help message"
    echo "        -u|--uniplayer_logprop     setUni_logprop"
    echo ""
    echo "        --disable_osd          disable_osd"
    echo "        --enable_osd          enable_osd"
    echo "        --enable_swrender          enable_swrender"
    echo "        --disable_swrender          disable_swrender"
    echo "        --enable_socplayer          enable_socplayer"
    echo "        --disable_socplayer          disable_socplayer"
    echo "        --enable_socextractor          enable_socextractor"
    echo "        --disable_socextractor          disable_socextractor"
    echo ""
    echo "        --dump_yuv          dump_yuv"
    echo "        --dump_video_es          dump_video_es"
    echo "        --dump_sourcedata          dump_sourcedata"
    echo "        --tcpdump_set          tcpdump_set"
    echo "        --dump_pcm          dump_pcm"
    echo "        --dump_audio_es          dump_audio_es"
    echo "        --dump_audiopacket          dump audio packet"
    echo "        --dump_videopacket          dump video packet"
    echo "        --finishdump          finishdump    include (disbale yuv/pcm、AES/VES、sourcedata、avpacket property, and kill tcpdump) "
    echo ""
    echo "        --enable_videoonly          video_only"
    echo "        --disable_videoonly          disbale video_only"
    echo "        --enable_norenderdrop          a/v will not sync "
    echo "        --disable_norenderdrop          restore a/v sync "
    echo "        --dumpsys_audio_info          dumpsys_audio_info    include (Audio、Audio_flinger、Audio_policy)"
    echo "        --dumpsys_display          dumpsys_display    include (SurfaceFlinger、Window、Activity)"
    echo "        --dumpsys_mediaextractor          dumpsys_mediaextractor"
    echo "        --dumpsys_mediaplayer          dumpsys_mediaplayer"
    echo "        --dumpsys_performance          dumpsys_performance    include (Meminfo、Cpuinfo、Trace)"
    echo "        --dumpsys_heserver_media          dumpsys_heserver_media"
}


function setUni_logprop {
    echo ""
    echo "You can use the following cmd 1 or 2, to set loglevel for the plug-in、module and all file source"
    echo "***********************************"
    echo "  ex:"
    echo "    1: tcl_mm_dumplog.sh *:2,*demux:3,tsdemux:6"
    echo ""
    echo "    2: setprop media.uniplayer.debug.cat.level *:2,*demux:3,tsdemux:6"
    echo ""
    echo "***********************************"
    echo ""
}

function set_logproperty {
    if [ "$UniPlayer" != "true" ] ; then
        setprop media.nuplayer.mediahttp.log 1;          #tcl MediaHTTP
        setprop media.nuplayer.extractor.log 1;          #tcl MediaExtractor
        setprop vendor.media.nuplayer.download.log 1;          #tcl GenericSource/HttpLiveSource
        setprop media.nuplayer.render.log 1;          #tcl NuplayerRender
        setprop media.nuplayer.mediacodec.log 1;          #tcl MediaCodec
        setprop media.acodec.verbose.log 1;          #tcl ACodec
        setprop persist.sys.logd.level V;
    else
        echo "UniPlayer is true";
        setprop media.uniplayer.debug.cat.level *:2;
    fi

    if [ $AndroidHardWareId == "MT9653" ] || [ $AndroidHardWareId == "T9652" ] ; then
        # decode
        setprop vendor.mstar.vdec.log 2;
        setprop vendor.mstar.omx.log 1;
        setprop vendor.ms.adec.log_on 99;
        # disp
        setprop vendor.mstar.vsync_bridge.log 1;
        setprop vendor.mstar.sideband.log 1;
        setprop vendor.mstar.dip.log 1;
        # exo
        setprop mtk.exoplayer.debug.level 95;
        # mediaCodec
        setprop media.mediacodec.dbg 1;
        setprop vendor.media.mediacodec.dbg 1;
        setprop media.acodec.verbose.log 1;
        setprop vendor.media.acodec.verbose.log 1;
        setprop debug.stagefright.omx-debug 5:OMX.MS.*.Decoder*;
        # audio
        setprop media.mediacodec.verbose.log 1;
        setprop vendor.mstar.audio.log.level VERBOSE;
        setprop log.tag.APM_AudioPolicyManager V;
        setprop vendor.mstar.audioparser.log.level VERBOSE;
        # hwc
        # setprop vendor.mstar.debug.hwcomposer20 14
        # extractor
        setprop vendor.mtk.mkv.verbose.log 1;
        setprop vendor.mtk.avi.extract.log 1;
        setprop vendor.mtk.avi.verbose.log 1;
        setprop vendor.asfff.dump.audio 1;
        setprop vendor.asfff.dump.video 1;
        setprop vendor.asfff.verbose.log 1;
        setprop vendor.mtk.mkv.verbose.log 1;
        setprop vendor.mtk.rm.verbose.log 1;
        setprop vendor.mtk.ts.verbose.log 1;
        setprop vendor.mtk.ps.verbose.log 1;
        setprop vendor.mtk.mp4.extract.log 1;
        setprop vendor.mtk.mp4.verbose.log 1;
        # nuplayer
        setprop vendor.media.nuplayer.verbose.log 0x7fffffff
        setprop media.nuplayer.verbose.log 0x7fffffff
        # eeplayer
        setprop media.eeplayer.render.loglevel 1;

    elif [ $AndroidHardWareId == "T982" ] || [ $AndroidHardWareId == "TC8000" ] || [ $AndroidHardWareId == "t963" ] || [ $AndroidHardWareId == "t972" ]; then
        setprop debug.stagefright.omx-debug 5;
        setprop vendor.mediahal.loglevels 15;
        setprop vendor.media.amnuplayer.debugtimeinfo 63;
        setprop media.omx.log_levels 255;
        setprop vendor.media.omx.log_levels 255;
        setprop vendor.mediahal.loglevels 31;
        setprop vendor.videodec.loglevels 0xFF;
        setprop media.ffmpegextractor.loglevel 48;
        setprop media.amnuplayer.debugtimeinfo 4;
        setprop media.hls.ptsdebug 2;
        setprop media.amsubtitle.debug true;
        setprop media.amnuplayer.hls.debuglog true;
        setprop vendor.media.ffmpegextractor.loglevel 48;
        setprop vendor.media.amnuplayer.debugtimeinfo 4;
        setprop vendor.media.hls.ptsdebug 2;
        setprop vendor.media.amsubtitle.debug true;
        setprop vendor.media.amnuplayer.hls.debuglog true;
        # eeplayer
        setprop media.eeplayer.render.loglevel 1;

    elif [ $AndroidHardWareId == "MT9653_Overseas" ] || [ $AndroidHardWareId == "MT9615" ] || [ $AndroidHardWareId == "MT9221" ]; then
        setprop media.acodec.verbose.log 1;
        setprop media.acodec.verbose.logfreq 1;
        setprop vendor.mtk.displink.bm.profile 1;
        setprop vendor.mtk.c2.enable.comp.log 2;
        setprop vendor.mtk.c2.enable.vdec.log 2;
        setprop vendor.mtktv.c2.enable.vdec.log 2;
        setprop vendor.mtktv.c2.enable.bm.log 2;
        setprop vendor.mtk.vcodecvideo.log 2;
        setprop vendor.mtk.vcodecvdecimpl.log 3;
        echo 8 > /sys/module/mtk_vcodec_dec/parameters/mtk_v4l2_dbg_level;
        setprop vendor.mtk.mi.video.log 80;
        setprop vendor.mtk.mi.vdec.log 80;
        setprop vendor.mtk.tpchwc.log 1;
        setprop vendor.mtk.displink.log 1;
        setprop vendor.mtk.displink.wrapper.log 1;
        setprop vendor.mtk.debug.hwcomposer20 17;
        setprop vendor.mtk.pqlink.setwin.info 1;
        setprop vendor.mtk.pqlink.performance.profile 1;
        setprop vendor.mtk.mipq.debuglevel 40;
        setprop vendor.hal.audio.log.level VERBOSE;
        setprop vendor.mtk.pqlink.log 1;
        setprop vendor.mtk.pqhal.debuglevel 5;
    fi
}

function set_decodercmd {
    if [ $AndroidHardWareId == "MT9653" ]; then
        echo 0 > /proc/sys/kernel/printk
        echo dbg MI_VMON 0xf0 > /sys/kernel/mik/MI_UTIL
        echo 0x3ffffffff,3   >/vendor/tvconfig/config/miflog
        echo set dbginfo 0x10> /sys/kernel/mik/MI_VIDEO
        echo dbg MI_VIDEO 0xf0f0 > /sys/kernel/mik/MI_UTIL
        echo set vdec debuglevel 0xf0 > /sys/kernel/mik/MI_VDEC
        echo 7 > /sys/module/mtk_vcodec_dec/parameters/mtk_v4l2_dbg_level
        echo 2 > /sys/module/mtk_vcu/parameters/mtk_vcu_debug
        echo 3 > /sys/module/mtk_vcu_vdec/parameters/mtk_vcu_wrap
        echo 3 > /sys/module/mtk_vcu_vdec/parameters/mtk_vcu_vdec_debug
        echo 5 > /sys/module/mtk_vcodec_dec/parameters/mtk_vcodec_dbg
        echo 0x21e > /sys/module/mtk_vcu_vdec/parameters/u4LogLeve
        echo 4 > /sys/module/mtk_vcu/parameters/mtk_vcu_debug
        echo 0xff >  /sys/module/mtk_vcu_vdec/parameters/mtk_vcu_wra
        echo 0xff > /sys/module/mtk_vcu_vdec/parameters/mtk_vcu_vdec_debug
        echo 0xff > /sys/module/mtk_vcu_vdec/parameters/vdec_rm_debug
        echo 4 > /sys/module/mtk_vcu_vdec/parameters/vesparser_debug
        echo 0x3FF > /sys/module/mtk_vcu_vdec/parameters/u4LogLevel
        echo set dbginfo 0xC00000ff > /sys/kernel/mik/MI_DISP
        echo dbg MI_DISP 0x1F0 > /sys/kernel/mik/MI_UTIL
        dmesg --follow > /data/dmesg_decoder.log&
        logcat -c; logcat -G 100M; logcat > /data/logcat_decoder.log &
        echo "save decode logcat_decoder.log to /data/logcat_decoder.log"
    elif [ $AndroidHardWareId == "T982" ] || [ $AndroidHardWareId == "TC8000" ]; then
        echo 0 > /sys/class/debug/atrace_tag
        echo 1 > /sys/class/debug/atrace_tag
        echo 2 > /sys/class/debug/atrace_tag
        echo 3 > /sys/class/debug/atrace_tag
        echo 4 > /sys/class/debug/atrace_tag
        echo 5 > /sys/class/debug/atrace_tag
        echo 6 > /sys/class/debug/atrace_tag
        echo 7 > /sys/class/debug/atrace_tag
        cat /sys/class/debug/atrace_tag
        echo 1 > /sys/module/decoder_common/parameters/dec_time_stat_flag
        echo 1 > /sys/kernel/debug/tracing/events/meson_atrace/enable
        atrace -b 25000 sched gfx irq freq video binder_driver memreclaim audio idle --async_start -o /data/local/tmp/trace
        echo "save trace to /data/local/tmp/trace"
        echo 0 > /proc/sys/kernel/printk
        echo 0xfff > /sys/module/amvdec_ports/parameters/debug_mode
        rm -rf /data/kernel-00.txt; dmesg -c > /dev/null;while true;do dmesg -c >> /data/kernel-00.txt;sync;done&
        export logdir=/data;
        echo 0 > /proc/sys/kernel/printk;
        setprop vendor.media.omx.log_levels 255;
        setprop vendor.mediahal.loglevels 19;
        rm -rf $logdir/logcat_decoder.log;
        logcat -c; logcat -G 100M; logcat > $logdir/logcat_decoder.log &
        echo "save decode logcat_decoder.log to /data/logcat_decoder.log"
    fi
}


#抓取log
function catchLog {
    iscatching=1
    logcat -c;logcat -G 150M;logcat -v threadtime -f /data/tmp/tcl_debug_${time}.log &
    echo "debug log to /data/tmp/tcl_debug_${time}.log"

    if [ $AndroidHardWareId == "MT9653" ]; then
        #echo 10 0 2 > /proc/utopia_mdb/vdec          #vdec
        echo debugmsglevel 5 > /proc/utopia_mdb/mvop          #mvop
        echo dbg MI_CAP 0xF0 > /sys/kernel/mik/MI_UTIL          #dip
        echo opendmslog=ON > /proc/utopia_mdb/dms          #dms
        echo DebugLevel=0x183 > /proc/utopia_mdb/xc          #xc
    fi

    #dmesg -C;dmesg -w >> $LogDir"kernel_dmesg.log" &
    dmesg -C;dmesg -w >> /data/tmp/tcl_dmesg_${time}.log &
    echo "kernel_dmesg log to /data/tmp/tcl_dmesg_${time}.log"
}


#脚本的参数
BOOT_ARGS=''
#捕获 Ctrl+C信号
#处理log文件.

function onCtrlC () {
    echo "onCtrlC"
    stty intr undef > /dev/null 2>&1
    sleep 1
    if [ $iscatching == 1 ]; then
        finishcatchLog
    elif [ $isdumping == 1 ]; then
        finishdump
    elif [ $iscatching == 1 ] && [ $isdumping == 1 ]; then
        finishcatchLog
        finishdump
    fi
    echo "----------------end----------------"
    stty intr ^c > /dev/null 2>&1
    exit 1
}

function finishcatchLog () {
    echo "finishcatchLog"
    islogging=$(ps -A |grep "logcat" |wc -l)
    if [ $((islogging)) -gt 0 ]; then
        echo "kill the logcat process"
        killall logcat
    fi

    islogging=$(ps -A |grep "dmesg" |wc -l)
    if [ $((islogging)) -gt 0 ]; then
        echo "kill the dmesg process"
        killall dmesg
    fi

    echo '------[CatchLog end]------'
    echo " "
}

function finishdump {
    #disbale property
    setprop media.eeplayer.dump.data 0;          #disable http SourceData
    setprop media.nuplayer.download.dump 0;          #disable dump hls ts data

    setprop vendor.mstar.frame.dump 0;          #disable mtk dump yuv data
    setprop vendor.mstar.frame.on 0;
    setprop vendor.mstar.frame.scale 0;
    setprop vendor.mstar.vdec.disable_mfcodec 0;
    setprop vendor.mstar.stream.dump 0;          #disable mtk dump ves data
    setprop vendor.mstar.stream.raw 0;
    setprop vendor.mstar.media.adec.dump_es 0;          #disable mtk dump aes data
    setprop vendor.mstar.media.adec.dump_pcm 0;          #disable mtk dump pcm data
    setprop vendor.mstar.audio.dump.hal 0;

    setprop vendor.media.omx.dumpCodec 0;          #disable aml dump ves data
    setprop vendor.media.omx.dumpRecv 0;
    setprop media.mediacodec.dump.es 0;          #disable tcl mediacodec es data
    setprop sys.tcl.audio.dump.enable 0;          #disable aml framework pcm
    setprop vendor.media.audiohal.a2dpdump false;          #disable aml audio hal pcm
    setprop vendor.media.audiohal.outdump false;
    setprop vendor.tcl.audio.dump.enable 0;
    setprop media.extractor.espacket.dump 0;          #disable mediaextractor espacket
    istcpdumping=$(ps -A |grep "tcpdump" |wc -l)          #kill tcp dump
    if [ $((istcpdumping)) -gt 0 ]; then
        echo "kill the tcpdump process"
        killall tcpdump
    fi

    echo "------[Dump end]------"
    echo " "
}

function dumpsys_set {
    echo "***********************************"
    echo "    1: dumpsys meminfo"
    echo "    2: dumpsys SurfaceFlinger"
    echo "    3: dumpsys cpuinfo"
    echo "    4: dumpsys audio"
    echo "    5: dumpsys media.audio_flinger"
    echo "***********************************"

    echo -e "\nplease choose dumpsys type:"
    read -n 1 chose_type
    echo " "

    if [ $chose_type = 1 ];then
        echo ""
        dumpsys meminfo >> $DUMP_PATH/meminfo_$(date '+%m%d-%H%M%S').log
    elif [ $chose_type = 2 ];then
        echo ""
        dumpsys SurfaceFlinger >> $DUMP_PATH/SurfaceFlinger_$(date '+%m%d-%H%M%S').log
    elif [ $chose_type = 3 ];then
        echo ""
        dumpsys cpuinfo >> $DUMP_PATH/cpuinfo_$(date '+%m%d-%H%M%S').log
    elif [ $chose_type = 4 ];then
        echo ""
        dumpsys audio >> $DUMP_PATH/audio_$(date '+%m%d-%H%M%S').log
    elif [ $chose_type = 5 ];then
        echo ""
        dumpsys media.audio_flinger >> $DUMP_PATH/audio_flinger_$(date '+%m%d-%H%M%S').log
    fi
        #sleep 1
    #done
}

function dumpsys_display {
    dumpsys SurfaceFlinger >> $DUMP_PATH/SurfaceFlinger_$(date '+%m%d-%H%M%S').txt
    dumpsys window -a >> $DUMP_PATH/Window_$(date '+%m%d-%H%M%S').txt
    dumpsys activity activities >> $DUMP_PATH/Activities_$(date '+%m%d-%H%M%S').txt
    echo "the data will dump to /data/tmp, please check"
}

function dumpsys_performance {
    dumpsys meminfo >> $DUMP_PATH/meminfo_$(date '+%m%d-%H%M%S').txt
    dumpsys cpuinfo >> $DUMP_PATH/cpuinfo_$(date '+%m%d-%H%M%S').txt
    atrace -z -b 32769 -t 10 gfx input view webview wm am sm hal res dalvik rs bionic power pm ss network video audio >> $DUMP_PATH/trace_$(date '+%m%d-%H%M%S').txt
    echo "the data will dump to /data/tmp, please check"
}

function dumpsys_audio_info {
    dumpsys audio >> $DUMP_PATH/Audio_$(date '+%m%d-%H%M%S').txt
    dumpsys media.audio_flinger >> $DUMP_PATH/Audio_flinger_$(date '+%m%d-%H%M%S').txt
    dumpsys media.audio_policy >>  $DUMP_PATH/Audio_policy_$(date '+%m%d-%H%M%S').txt
    echo "the data will dump to /data/tmp, please check"
}

function dumpsys_heserver_media {
    if [ $AndroidHardWareId == "MT9653" ] || [ $AndroidHardWareId == "TC8000" ]; then
        dumpsys android.heserver media >>  $DUMP_PATH/Heserver_$(date '+%m%d-%H%M%S').txt
        echo "the data will dump to /data/tmp, please check"
    else
        echo "platform not support dumpsys heserver"
    fi
}

function dumpsys_mediaplayer {
    dumpsys media.player >> $DUMP_PATH/media_player_$(date '+%m%d-%H%M%S').log
    echo "the data will dump to /data/tmp, please check"
}
function dumpsys_mediaextractor {
    dumpsys media.extractor >> $DUMP_PATH/media_extractor_$(date '+%m%d-%H%M%S').log
    echo "the data will dump to /data/tmp, please check"
}
function dump_sourcedata {
    isdumping=1
    chmod 777 /data/vendor/tcl
    #dump http sourcedata
    setprop media.eeplayer.dump.data 1;
    #dump hls ts data
    setprop media.nuplayer.download.dump 1;
    echo "the data will dump to /data/vendor/tcl/, please check"
}

function tcpdump_set {
    isdumping=1
    tcpdump -i any -w /data/tmp/dump_${time}.pcap &
    echo "the dump_xxx.pcap will saved /data/tmp/"
}

function esdata_dump_set {
    isdumping=1
    echo "***********************************"
    echo "    1: dump video file"
    echo "    2: dump audio file"
    echo "    3: dump A&V file (Supports dump when playing)"
    echo "***********************************"
    echo -e "\nplease choose dump type:"
    read -n 1 chose_type
    echo " "
    if [ $chose_type = 1 ];then
        dump_video_es
    elif [ $chose_type = 2 ];then
        dump_audio_es
    elif [ $chose_type = 3 ];then
        dump_av_es
    fi
}

function decoder_dump_set {
    isdumping=1
    echo "***********************************"
    echo "    1: dump video YUV"
    echo "    2: dump audio PCM"
    echo "***********************************"
    echo -e "\nplease choose dump type:"
    read -n 1 chose_type
    echo " "
    if [ $chose_type = 1 ];then
        dump_yuv
    elif [ $chose_type = 2 ];then
        dump_pcm
    fi
}

function dump_video_es {
    echo "AndroidHardWareId: "$AndroidHardWareId
    if [ $AndroidHardWareId == "MT9653" ] || [ $AndroidHardWareId == "T9652" ] || [ $AndroidHardWareId == "MT9615" ] || [ $AndroidHardWareId == "MT9221" ]; then
        chmod 777 -R /data/tmp
        chmod 777 -R /data/vendor/tcl
        setprop vendor.mstar.stream.dump 1;
        setprop vendor.mstar.stream.raw 1;
        setprop vendor.mstar.stream.dir data;
        setprop media.mediacodec.dump.es 1;
        echo "the data will dump to /data/ and /data/vendor/tcl, please check\n"
    elif [ $AndroidHardWareId == "T982" ] || [ $AndroidHardWareId == "TC8000" ]; then
        chmod 777 -R /data/tmp
        chmod 777 -R /data/vendor/tcl
        setprop vendor.media.omx.dumpCodec true;
        setprop vendor.media.omx.dumpRecv true;
        setprop media.mediacodec.dump.es 1;
        echo "the data will dump to /data/tmp/ and /data/vendor/tcl, please check\n"
    elif [ $AndroidHardWareId == "t963" ] || [ $AndroidHardWareId == "t972" ]; then
        echo "for t963/t972 platform there is no cmd to dump_video_es "
    elif [ $AndroidHardWareId == "MT9653_Overseas" ]; then
        mount -o rw,remount /vendor;
        mount -o rw,remount /;
        mount -o remount /data;
        rm -rf /data/vendor/tmp/dump;
        mkdir -p /data/vendor/tmp/dump;
        chmod -R 777 /data/vendor/tmp/dump;
        setprop vendor.mtk.disable_performance_guard 1;
        setprop vendor.mtk-codec2.dump 1;
        echo "the data will dump to /data/vendor/tmp/dump/, please check\n"
    elif [ $AndroidHardWareId == "MT9655" ]; then
        if [ -d "/data/vendor/tcl" ]; then
            chmod 777 -R /data/vendor/tcl
            setprop media.mediacodec.dump.es 1;
        else
            mkdir data/vendor/tcl
            chmod 777 -R /data/vendor/tcl
            setprop media.mediacodec.dump.es 1;
        fi
    fi
}

function dump_audio_es {
    if [ $AndroidHardWareId == "MT9653" ] || [ $AndroidHardWareId == "T9652" ] || [ $AndroidHardWareId == "MT9615" ] || [ $AndroidHardWareId == "MT9221" ]; then
        echo " "
        chmod 777 -R /data/vendor/tcl
        setprop vendor.mstar.media.adec.dump_es 1;
        setprop media.mediacodec.dump.es 2;
        echo "the data will dump to /data/vendor/tcl/, please check\n"
    elif [ $AndroidHardWareId == "T982" ] || [ $AndroidHardWareId == "TC8000" ]; then
        chmod 777 -R /data/vendor/tcl
        setprop media.mediacodec.dump.es 2;
        echo ""
        #echo "for amlogic platform, there is no cmd to dump audio es "
        echo "for lxos platform the mediacodec auido es will dump to /data/vendor/tcl,  please check\n"
    elif [ $AndroidHardWareId == "MT9653_Overseas" ]; then
        echo "for MT9618 there is no cmd to dump_audio_es"
    elif [ $AndroidHardWareId == "MT9655" ]; then
        if [ -d "/data/vendor/tcl" ]; then
            chmod 777 -R /data/vendor/tcl
            setprop media.mediacodec.dump.es 2;
        else
            mkdir data/vendor/tcl
            chmod 777 -R /data/vendor/tcl
            setprop media.mediacodec.dump.es 2;
        fi
    fi
}

function dump_yuv {
    if [ $AndroidHardWareId == "MT9653" ] || [ $AndroidHardWareId == "T9652" ] || [ $AndroidHardWareId == "MT9615" ] || [ $AndroidHardWareId == "MT9221" ]; then
        echo ""
        echo "dump yuv data"
        setprop vendor.mstar.frame.dump 1;
        setprop vendor.mstar.frame.on 1;
        setprop vendor.mstar.frame.scale 4;          #缩放因子，减轻dump yuv的时候系统非常卡
        setprop vendor.mstar.vdec.disable_mfcodec 1; #4K片源最好加上
        setprop vendor.mstar.frame.dir data;         #copy  /data/*.dump 出来
        echo "the data will dump to /data/, please check\n"
    elif [ $AndroidHardWareId == "T982" ]; then
        echo ""
        echo "dump yuv data"
        echo 0 1 60 > /sys/class/vdec/dump_yuv;          #对 TC8000 T963 T972命令不生效。 从第1帧开始, 连续dump 帧个数为60
        echo "the data will dump to /data/tmp, please check\n"
    elif [ $AndroidHardWareId == "TC8000" ] || [ $AndroidHardWareId == "t963" ] || [ $AndroidHardWareId == "t972" ]; then
        echo ""
        echo "the amlogic dump_yuv cmd have no effect"
    elif [ $AndroidHardWareId == "MT9653_Overseas" ]; then
        mount -o rw,remount /vendor;
        mount -o rw,remount /;
        mount -o remount /data;
        rm -rf /data/vendor/tmp/dump;
        mkdir -p /data/vendor/tmp/dump;
        chmod -R 777 /data/vendor/tmp/dump;
        setprop vendor.mtk.disable_performance_guard 1;
        setprop vendor.mtk-codec2.dump 2;
        echo "the data will dump to /data/vendor/tmp/dump/, please check\n"
    fi
}

function dump_pcm {
    if [ $AndroidHardWareId == "MT9653" ] || [ $AndroidHardWareId == "T9652" ] || [ $AndroidHardWareId == "MT9615" ] || [ $AndroidHardWareId == "MT9221" ]; then
        echo ""
        echo "dump adec pcm data"
        setprop vendor.mstar.media.adec.dump_pcm 1;
        setprop vendor.mstar.audio.dump.hal 1;
        echo "the data will dump to /data/, please check\n"
    elif [ $AndroidHardWareId == "T982" ] || [ $AndroidHardWareId == "TC8000" ]; then
        echo ""
        #framework开启：
        setprop sys.tcl.audio.dump.enable 1;
        #audio hal开启
        setprop vendor.media.audiohal.a2dpdump true;
        setprop vendor.media.audiohal.outdump true;
        echo "the data will dump to /data/audio_dump/, please check\n"
    elif [ $AndroidHardWareId == "t963" ] || [ $AndroidHardWareId == "t972" ]; then
        setprop vendor.tcl.audio.dump.enable 1
        echo "the data will dump to /data/audio_dump/, please check\n"
    elif [ $AndroidHardWareId == "MT9653_Overseas" ]; then
        echo "for MT9618 there is no cmd to dump_pcm "
    fi
}


function finishcatching {
    startTime=$(date +%s)
    while [ $iscatching -eq 1 ]
    do
        #read -t 10 inputdata
        #if [ -z $inputdata ]; then
        currentTime=$(date +%s)
        echo -ne "\r"
        echo -ne "...Running "`expr $currentTime - $startTime`" seconds,  press \e[33m Ctrl+C\e[0m to stop catching"
        sleep 10
        #fi
    done
}

function finishdumping {
    startTime=$(date +%s)
    while [ $isdumping -eq 1 ]
    do
        #read -t 10 inputdata
        #if [ -z $inputdata ]; then
        currentTime=$(date +%s)
        echo -ne "\r"
        echo -ne "...Running "`expr $currentTime - $startTime`" seconds,  press \e[33m Ctrl+C\e[0m to stop dumping"
        sleep 10
        #fi
    done
}

function disable_osd {
    echo "disable_osd"
    if [ $AndroidHardWareId == "MT9653" ] || [ $AndroidHardWareId == "T9652" ] || [ $AndroidHardWareId == "MT9615" ] || [ $AndroidHardWareId == "MT9221" ]; then
        setprop vendor.mstar.disable.osd 1   #关掉osd
    elif [ $AndroidHardWareId == "T982" ] || [ $AndroidHardWareId == "TC8000" ] || [ $AndroidHardWareId == "t963" ] || [ $AndroidHardWareId == "t972" ]; then
        echo 1 > /sys/class/graphics/fb0/osd_display_debug
        echo 1 > /sys/class/graphics/fb0/blank
    elif [ $AndroidHardWareId == "MT9653_Overseas" ]; then
        setprop vendor.mtk.hwc.osd.disable 0001
    fi
}

function enable_osd {
    if [ $AndroidHardWareId == "MT9653" ] || [ $AndroidHardWareId == "T9652" ] || [ $AndroidHardWareId == "MT9615" ] || [ $AndroidHardWareId == "MT9221" ]; then
        setprop vendor.mstar.disable.osd 0
    elif [ $AndroidHardWareId == "T982" ] || [ $AndroidHardWareId == "TC8000" ] || [ $AndroidHardWareId == "t963" ] || [ $AndroidHardWareId == "t972" ]; then
        echo 0 > /sys/class/graphics/fb0/osd_display_debug
        echo 0 > /sys/class/graphics/fb0/blank
    elif [ $AndroidHardWareId == "MT9653_Overseas" ]; then
        setprop vendor.mtk.hwc.osd.disable 0000
    fi
}

function enable_swrender {
    if [ $AndroidHardWareId == "MT9653" ] || [ $AndroidHardWareId == "T9652" ] || [ $AndroidHardWareId == "MT9615" ] || [ $AndroidHardWareId == "MT9221" ]; then
        setprop ms.vsync_bridge.swdetile 1;
        setprop vendor.mstar.render.planar  1;
        setprop vendor.mstar.vdec.disable_mfcodec 1;
    elif [ $AndroidHardWareId == "T982" ] || [ $AndroidHardWareId == "TC8000" ] || [ $AndroidHardWareId == "t963" ] || [ $AndroidHardWareId == "t972" ]; then
        setprop media.omx.display_mode 0;
        setprop vendor.media.omx.display_mode 0;
        setprop debug.stagefright.swcodec  1;   #切换sw decoder/sw render
    elif [ $AndroidHardWareId == "MT9653_Overseas" ]; then
        setprop vendor.mtk.render.planar 1
    fi
}

function disable_swrender {
    if [ $AndroidHardWareId == "MT9653" ] || [ $AndroidHardWareId == "T9652" ] || [ $AndroidHardWareId == "MT9615" ] || [ $AndroidHardWareId == "MT9221" ]; then
        setprop ms.vsync_bridge.swdetile 0;
        setprop vendor.mstar.render.planar  0;
        setprop vendor.mstar.vdec.disable_mfcodec 0;
    elif [ $AndroidHardWareId == "T982" ] || [ $AndroidHardWareId == "TC8000" ] || [ $AndroidHardWareId == "t963" ] || [ $AndroidHardWareId == "t972" ]; then
        setprop media.omx.display_mode 1;
        setprop vendor.media.omx.display_mode 1;
        setprop debug.stagefright.swcodec  0;   # 切换hw decoder/hw render
    elif [ $AndroidHardWareId == "MT9653_Overseas" ]; then
        setprop vendor.mtk.render.planar 0
    fi
}

function enable_socplayer {
    if [ $AndroidHardWareId == "MT9653" ]; then
        echo "MTK platform not support enable socplayer"
    elif [ $AndroidHardWareId == "T9652" ] || [ $AndroidHardWareId == "t963" ] || [ $AndroidHardWareId == "t972" ]; then
        setprop media.eeplayer.disable 1
    elif [ $AndroidHardWareId == "T982" ] || [ $AndroidHardWareId == "TC8000" ]; then
        setprop media.nuplayer.disable true
    fi
}

function disable_socplayer {
    if [ $AndroidHardWareId == "MT9653" ]; then
        echo "MTK platform not support disable socplayer"
    elif [ $AndroidHardWareId == "T9652" ] || [ $AndroidHardWareId == "t963" ] || [ $AndroidHardWareId == "t972" ]; then
        setprop media.eeplayer.disable 0
    elif [ $AndroidHardWareId == "T982" ] || [ $AndroidHardWareId == "TC8000" ]; then
        setprop media.nuplayer.disable false
    fi
}


# for lxos platform
function dump_mediacodec_video_es {
    chmod 777 /data/vendor/tcl
    echo " "
    setprop media.mediacodec.dump.es 1;
    echo "the data will dump to /data/vendor/tcl/, please check\n"
}
function dump_mediacodec_audio_es {
    chmod 777 /data/vendor/tcl
    echo " "
    setprop media.mediacodec.dump.es 2;
    echo "the data will dump to /data/vendor/tcl/, please check\n"
}
function dump_mediacodec_av_es {
    chmod 777 /data/vendor/tcl
    echo " "
    setprop media.mediacodec.dump.es 3;
    echo "the data will dump to /data/vendor/tcl/, please check\n"
}

function enable_socextractor {
    setprop media.tclextractor.disable true
}

function disable_socextractor {
    setprop media.tclextractor.disable false
}

function enable_videoonly {
    setprop media.nuplayer.render.videoonly 1
}

function disable_videoonly {
    setprop media.nuplayer.render.videoonly 0
}

function enable_norenderdrop {
    setprop media.nuplayer.render.nodrop 1
}

function disable_norenderdrop {
    setprop media.nuplayer.render.nodrop 0
}

function dump_videopacket {
    chmod 777 data/vendor/tcl/
    setprop vendor.media.dump.ts.packet 2
}

function dump_audiopacket {
    chmod 777 data/vendor/tcl/
    setprop vendor.media.dump.ts.packet 1
}

function getEnv() {

    #获取Android系统的版本号
    #不同的版本setprop有些不一样
    AndroidSDKVersion=$(getprop ro.system.build.version.sdk)
    AndroidBuildType=$(getprop ro.vendor.build.type)
}

#获取系统环境信息
getEnv
#注册Ctrl+C中断callback

if test "$1" != ""
then
    while [ "$1" != "" ]
    do
        if [ "$UniPlayer" == "true" ] ; then
            setprop media.uniplayer.debug.cat.level $1
        fi
        case "$1" in
            -h | --help )    help;;
            -u | --uniplayer_logprop )    setUni_logprop;;
            --disable_osd )  disable_osd;;
            --enable_osd )   enable_osd;;
            --enable_swrender )  enable_swrender;;
            --disable_swrender )   disable_swrender;;
            --enable_socplayer )  enable_socplayer;;
            --disable_socplayer )   disable_socplayer;;
            --enable_socextractor )  enable_socextractor;;
            --disable_socextractor )   disable_socextractor;;
            --dump_yuv )  dump_yuv;;
            --dump_videopacket )  dump_videopacket;;
            --dump_audiopacket )  dump_audiopacket;;
            --dump_video_es )   dump_video_es;;
            --dump_sourcedata )  dump_sourcedata;;
            --dump_pcm )   dump_pcm;;
            --dump_audio_es )  dump_audio_es;;
            --tcpdump_set )   tcpdump_set;;
            --finishdump )   finishdump;;
            --dumpsys_display )  dumpsys_display;;
            --dumpsys_performance )  dumpsys_performance;;
            --dumpsys_audio_info )  dumpsys_audio_info;;
            --dumpsys_mediaextractor )  dumpsys_mediaextractor;;
            --dumpsys_mediaplayer )  dumpsys_mediaplayer;;
            --enable_videoonly )   enable_videoonly;;
            --disable_videoonly )   disable_videoonly;;
            --enable_norenderdrop )  enable_norenderdrop;;
            --disable_norenderdrop )  disable_norenderdrop;;
            --dumpsys_heserver_media )  dumpsys_heserver_media;;
        esac
        shift
    done
else
    trap 'onCtrlC' INT
    echo "***********************************"
    echo "begin_debug:"
    echo "    1: open debug log info"
    echo "    2: open dump info"
    echo "    3: open debug log info and dump info"
    echo "    4: 根据现象 手动debug "
    echo "***********************************"
    echo -e "\nplease choose debug type:"
    read -n 1 begin_debug

    case "$begin_debug" in
        1)
        echo ""
        # catchLog module
        set_logproperty
        catchLog
        echo -e "\nThe log property is enabled, Capturing log in the background ..."
        finishcatching
        ;;
        2)
        echo ""
        echo ""
        # dump module
        echo "***********************************"
        echo "dump select:"
        echo "    1: dumpsys"
        echo "    2: SourceData"
        echo "    3: tcpdump"
        echo "    4: A/V ES"
        echo "    5: YUV/PCM"
        echo "***********************************"
        echo -e "\nplease choose dump type: "
        read -n 1 dump_select
        case "$dump_select" in
            1)
            echo ""
            echo ""
            dumpsys_set
            echo "now please reproducing the issue ..."
            echo "if you reproduced the issue, Please input y or Y(yes):"
            while true
            do
                read -n 1 input
                if [ $input == $'y' ] || [ $input == $'Y' ]; then
                    echo ""
                    echo ""
                    echo "dumpsys will be re-executed, Please select again"
                    echo ""
                    dumpsys_set
                    break
                else
                    echo ""
                    echo "The input is not yes, please re-input"
                fi
            done
            echo "the data will dump to /data/tmp/, please check\n"
            ;;
            2)
            echo ""
            echo ""
            dump_sourcedata
            echo "the data has dump to /data/vendor/tcl/ , please check\n"
            ;;
            3)
            echo ""
            echo ""
            tcpdump_set
            ;;
            4)
            echo ""
            echo ""
            esdata_dump_set
            ;;
            5)
            echo ""
            echo ""
            decoder_dump_set
            ;;
            *)
        esac
        finishdumping
        ;;
        3)
        echo ""
        #  catchLog module
        set_logproperty
        catchLog
        echo "The log property is enabled, Capturing log in the background ..."
        echo ""
        sleep 0.5

        #  dump module
        echo "then begin dump info"
        sleep 0.5
        echo "***********************************"
        echo "dump select:"
        echo "    1: dumpsys"
        echo "    2: SourceData"
        echo "    3: tcpdump"
        echo "    4: A/V ES"
        echo "    5: YUV/PCM"
        echo "***********************************"
        echo -e "\nplease choose dump type: "
        read -n 1 dump_select
        case "$dump_select" in
            1)
            echo ""
            echo ""
            dumpsys_set
            echo "now please reproducing the issue ..."
            echo "if you reproduced the issue, Please input y or Y(yes):"
            while true
            do
                read -n 1 input
                if [ $input == $'y' ] || [ $input == $'Y' ]; then
                    echo ""
                    echo ""
                    echo "dumpsys will be re-executed when you reproduced, Please select again"
                    echo ""
                    dumpsys_set
                    break
                else
                    continue
                fi
            done
            echo "the data will dump to /data/tmp/, please check\n"
            ;;
            2)
            echo ""
            echo ""
            dump_sourcedata
            echo "the data has dump to /data/vendor/tcl/ , please check\n"
            ;;
            3)
            echo ""
            echo ""
            tcpdump_set $DUMP_PATH
            echo "the data will dump to /data/tmp/, please check\n"
            ;;
            4)
            echo ""
            echo ""
            esdata_dump_set
            ;;
            5)
            echo ""
            echo ""
            decoder_dump_set
            ;;
            *)
        esac
        finishcatching
        finishdumping

        ;;
        4)
        echo ""
        echo ""
        #  debug
        echo "***********************************"
        echo "dump select:"
        echo "    1: 黑屏"
        echo "    2: 卡顿"
        echo "***********************************"
        echo -e "\nplease choose which issue that you want to reproduced:"

        read -n 1 dump_select
        case "$dump_select" in
            1)
            echo ""
            echo ""
            echo "请开始复现..."
            #1. 抓log
            set_logproperty
            catchLog
            echo ""

            while [ $dump_select -eq 1 ]
            do
                read -t 1 inputdata > /dev/null 2>&1
                echo -ne "\r"
                echo -ne "你复现到问题了吗？ y or n (yes or no)\n"
                read -n 1 input
                if [ $input == $'y' ] || [ $input == $'Y' ]; then
                    echo ""
                    echo ""
                    break
                else
                    continue
                fi
            done
            sleep 2

            #2. 开关osd
            disable_osd
            while [ $dump_select -eq 1 ]
            do
                #read -t 1 inputdata > /dev/null 2>&1
                echo -ne "\r"
                echo -ne "now has disable_osd, Is it still blackscreen？ y or n (yes or no)\n"
                read -n 1 input
                if [ $input == $'y' ] || [ $input == $'Y' ]; then
                    echo ""
                    break
                elif [ $input == $'n' ] || [ $input == $'N' ]; then
                    echo ""
                    echo ""
                    echo "enable_osd, Then dumpsys SurfaceFlinger and screencap"
                    enable_osd
                    sleep 2
                    dumpsys SurfaceFlinger >> $DUMP_PATH/SurfaceFlinger_$(date '+%m%d-%H%M%S').log
                    screencap -p /$DUMP_PATH/screenshot1.png
                    while true; do
                        echo -ne "\r"
                        echo -ne "SurfaceFlinger and screencap has saved $DUMP_PATH,  you can stop with \e[33m Ctrl+C\e[0m"
                        sleep 10
                    done
                else
                    continue
                fi
            done
            enable_osd
            echo "now enable osd..."
            sleep 3
            #3. 切换swrender
            enable_swrender
            while [ $dump_select -eq 1 ]
            do
                #echo "test enable_swrender in while"
                #read -t 1 inputdata > /dev/null 2>&1
                echo -ne "\r"
                echo -ne "now has enable_swrender, Is it still blackscreen？ y or n (yes or no)\n"
                read -n 1 input
                if [ $input == $'y' ] || [ $input == $'Y' ]; then
                    echo ""
                    echo ""
                    break
                elif [ $input == $'n' ] || [ $input == $'N' ]; then
                    echo ""
                    echo ""
                    while true; do
                        echo -ne "\r"
                        echo -ne "Please check log, Maybe this issue is related "soc HW Render", you can stop with \e[33m Ctrl+C\e[0m"
                        #read -t 10 inputdata
                        sleep 10
                    done
                else
                    continue
                fi
            done
            disable_swrender
            echo "test disable_swrender"
            sleep 2
            #4. dump YUV
            echo ""
            dump_yuv
            echo "please wait 10s, now is dumping data"
            sleep 10
            finishdump
            echo "10s has gone, now will select soc player"
            #5.切换socplayer
            enable_socplayer
            while [ $dump_select -eq 1 ]
            do
                #echo "test enable_socplayer in while"
                #read -t 1 inputdata > /dev/null 2>&1
                if [ $AndroidHardWareId == "MT9653" ]; then
                    echo "MT9653 not support enable socplayer, exit..."
                    break
                fi
                echo -ne "\r"
                echo -ne "now has enable_socplayer, Is it still blackscreen？ y or n (yes or no)\n"
                #read -t 1 inputdata > /dev/null 2>&1
                read -n 1 input
                if [ $input == $'y' ] || [ $input == $'Y' ]; then
                    echo ""
                    break
                elif [ $input == $'n' ] || [ $input == $'N' ]; then
                    echo ""
                    #切soc extrctor
                    echo "enable_socextractor..."
                    enable_socextractor
                    echo -ne "now has enable_socextractor, Is it still blackscreen？ y or n (yes or no)\n"
                    read -n 1 input
                    if [ $input == $'y' ] || [ $input == $'Y' ]; then
                        echo ""
                        break
                    elif [ $input == $'n' ] || [ $input == $'N' ]; then
                        disable_socplayer
                        disable_socextractor
                        sleep 3
                        dump_sourcedata
                        echo ""
                        echo "please wait 10s, now is dumping data..."
                        sleep 10
                        echo "10s has gone, now the data has saved /data/vendor/tcl/, please help check\n"
                        finishdump
                        break
                    fi
                else
                    continue
                fi
            done
            disable_socplayer
            disable_socextractor
            echo "now both the TCL player and extractor are restored "
            sleep 2
            echo "debug has completed, please analyze log \n"
            ;;
            2)
            echo ""
            echo ""
            echo "now please reproducing the Video Stuck issue ..."
            #1. 抓log
            set_logproperty
            catchLog
            echo ""
            while [ $dump_select -eq 2 ]
            do
                #read -t 10 inputdata > /dev/null 2>&1
                #echo -ne "\r"
                echo -ne "have you reproduced the issue？y or n (yes or no)\n"
                read -n 1 input
                if [ $input == $'y' ] || [ $input == $'Y' ]; then
                    echo ""
                    break
                else
                    echo ""
                    echo "go on to reproducing ... or  press \e[33m Ctrl+C\e[0m to exit"
                    continue
                fi
            done
            #2. 不进行丢帧
            #echo "set property to enable_norenderdrop"
            enable_norenderdrop
            sleep 2
            while [ $dump_select -eq 2 ]
            do
                #read -t 10 inputdata
                echo -ne "\r"
                echo -ne "now has set to noRenderdrop, Is the video stuck issue still exist? y or n (yes or no)\n"
                read -n 1 input
                if [ $input == $'y' ] || [ $input == $'Y' ]; then
                    echo ""
                    break
                elif [ $input == $'n' ] || [ $input == $'N' ]; then
                    echo ""
                    #echo "set property to enable video_only"
                    #3. video only 播放
                    enable_videoonly
                    while [ $dump_select -eq 2 ]
                    do
                        echo -ne "\r"
                        echo -ne "now has set to enable video_only, Is the video stuck issue still exist? y or n (yes or no)\n"
                        read -t 10 inputdata
                        read -n 1 input
                        if [ $input == $'y' ] || [ $input == $'Y' ]; then
                            echo ""
                            echo "It may be caused by video PTS jump\n"
                            break
                        elif [ $input == $'n' ] || [ $input == $'N' ]; then
                            echo ""
                            echo "It may be caused by audio clock\n"
                            break
                        else
                            continue
                        fi
                    done
                    disable_videoonly
                    while true; do
                        echo -ne "\r"
                        echo -ne "log has saved $DUMP_PATH, you can stop with \e[33m Ctrl+C\e[0m"
                        sleep 10
                    done
                else
                    continue
                fi
            done
            disable_norenderdrop
            sleep 2
            #soc 解码慢
            set_decodercmd
            iscatching=1
            while [ $dump_select -eq 2 ]
            do
                echo -ne "\r"
                echo -ne "if reproduced the issue, you can stop with \e[33m Ctrl+C\e[0m"
                sleep 10
            done
            ;;
            *)
        esac
        ;;
        *)
    esac
fi

echo "----------------[tcl_mm_dumplog.sh end]----------------"
