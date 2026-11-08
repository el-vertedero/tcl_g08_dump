#!/sbin/sh

audioserver_pid=$(pidof audioserver)
audiosrvice_pid=$(pidof vendor.mediatek.hardware.audio.service)
system_server_pid=$(pidof system_server)
tis_pid=$(pidof com.mediatek.tis)
atsctuner_pid=$(pidof com.mediatek.dtv.tvinput.atsctuner:remoteTunerInputService)
isdbtuner_pid=$(pidof com.mediatek.dtv.tvinput.isdbtuner)
dvbtuner_pid=$(pidof com.mediatek.dtv.tvinput.dvbtuner)
sony_EU_pid=$(pidof com.sony.dtv.tvinput.framework.server:remote)
tpc_pid=$(pidof vendor.mediatek.hardware.tpc@1.0-service)
hwc_pid=$(pidof vendor.mediatek.hardware.hwcomposer.composer@2.5-service)
c2_pid=$(pidof android.hardware.media.c2@1.1-mediatek)
tvcenter_pid=$(pidof com.mediatek.tv.oneworld.tvcenter)
tunerhal_pid=$(pidof vendor.mediatek.hardware.tv.tuner@1.1-service)
tune_pid=$(pidof media.tuner)
mediator_pid=$(pidof vendor.mediatek.hardware.mediator@1.0-service)
surfaceflinger_pid=$(pidof surfaceflinger)

if [ -f /data/ps_report.txt ]; then
    rm /data/ps_report.txt
fi

tname=`date +%Y%m%d%H%M%S`
echo "$tname start test ori pid .....">>/data/ps_report.txt
echo "audioserver_pid = $audioserver_pid">>/data/ps_report.txt
echo "audiosrvice_pid = $audiosrvice_pid">>/data/ps_report.txt
echo "tis_pid = $tis_pid">>/data/ps_report.txt
echo "atsctuner_pid = $atsctuner_pid">>/data/ps_report.txt
echo "isdbtuner_pid = $isdbtuner_pid">>/data/ps_report.txt
echo "dvbtuner_pid = $dvbtuner_pid">>/data/ps_report.txt
echo "system_server_pid = $system_server_pid">>/data/ps_report.txt
echo "tpc_pid = $tpc_pid">>/data/ps_report.txt
echo "hwc_pid = $hwc_pid">>/data/ps_report.txt
echo "c2_pid = $c2_pid">>/data/ps_report.txt
echo "tvcenter_pid = $tvcenter_pid">>/data/ps_report.txt
echo "tunerhal_pid = $tunerhal_pid">>/data/ps_report.txt
echo "tune_pid = $tune_pid">>/data/ps_report.txt
echo "mediator_pid = $mediator_pid " >>/data/ps_report.txt
echo "surfaceflinger_pid = $surfaceflinger_pid " >>/data/ps_report.txt

while [ 1 ]
do
    tname=`date +%Y%m%d%H%M%S`
    #echo "$tname start check process status ............."

    audioserver_pid_new=$(pidof audioserver)
    audiosrvice_pid_new=$(pidof vendor.mediatek.hardware.audio.service)
    system_server_pid_new=$(pidof system_server)
    tis_pid_new=$(pidof com.mediatek.tis)
    atsctuner_pid_new=$(pidof com.mediatek.dtv.tvinput.atsctuner:remoteTunerInputService)
    isdbtuner_pid_new=$(pidof com.mediatek.dtv.tvinput.isdbtuner)
    dvbtuner_pid_new=$(pidof com.mediatek.dtv.tvinput.dvbtuner)
    sony_EU_pid_new=$(pidof com.sony.dtv.tvinput.framework.server:remotee)
    tpc_pid_new=$(pidof vendor.mediatek.hardware.tpc@1.0-service)
    hwc_pid_new=$(pidof vendor.mediatek.hardware.hwcomposer.composer@2.5-service)
    c2_pid_new=$(pidof android.hardware.media.c2@1.1-mediatek)
    tvcenter_pid_new=$(pidof com.mediatek.tv.oneworld.tvcenter)
    tunerhal_pid_new=$(pidof vendor.mediatek.hardware.tv.tuner@1.1-service)
    tune_pid_new=$(pidof media.tuner)
    mediator_pid_new=$(pidof vendor.mediatek.hardware.mediator@1.0-service)
    surfaceflinger_pid_new=$(pidof surfaceflinger)


    if [ $audioserver_pid != $audioserver_pid_new ]; then
        echo "$tname ..... audioserver crash and new_pid is $audioserver_pid_new">>/data/ps_report.txt
        audioserver_pid=$audioserver_pid_new
    fi

    if [ $audiosrvice_pid != $audiosrvice_pid_new ]; then
        echo "$tname ..... audiosrvice crash and new_pid is $audiosrvice_pid_new">>/data/ps_report.txt
        audiosrvice_pid=$audiosrvice_pid_new
    fi

    if [ $system_server_pid != $system_server_pid_new ]; then
        echo "$tname ..... system_server crash and new_pid is $system_server_pid_new">>/data/ps_report.txt
        system_server_pid=$system_server_pid_new
    fi

    if [ $tis_pid != $tis_pid_new ]; then
        echo "$tname ..... tis crash and new_pid is $tis_pid_new">>/data/ps_report.txt
        tis_pid=$tis_pid_new
    fi
    if [[ -n "$atsctuner_pid_new" ]]; then
        if [ $atsctuner_pid != $atsctuner_pid_new ]; then
            echo "$tname ..... atsctuner crash and new_pid is $atsctuner_pid_new">>/data/ps_report.txt
            atsctuner_pid=$atsctuner_pid_new
        fi
    fi

    if [[ -n "$isdbtuner_pid_new" ]]; then
        if [ $isdbtuner_pid != $isdbtuner_pid_new ]; then
            echo "$tname ..... isdbtuner crash and new_pid is $isdbtuner_pid_new">>/data/ps_report.txt
            isdbtuner_pid=$isdbtuner_pid_new
        fi
    fi

    if [[ -n "$dvbtuner_pid_new" ]]; then
        if [ $dvbtuner_pid != $dvbtuner_pid_new ]; then
            echo "$tname ..... dvbtuner crash and new_pid is $dvbtuner_pid_new">>/data/ps_report.txt
            dvbtuner_pid=$dvbtuner_pid_new
        fi
    fi

    if [[ -n "$sony_EU_pid_new" ]]; then
        if [ $sony_EU_pid != $sony_EU_pid_new ]; then
            echo "$tname ..... sony dtv tvinput crash and new_pid is $sony_EU_pid_new">>/data/ps_report.txt
            dtmbtuner_pid=$sony_EU_pid_new
        fi
    fi

    if [ $tpc_pid != $tpc_pid_new ]; then
        echo "$tname ..... tpc crash and new_pid is $tpc_pid_new">>/data/ps_report.txt
        tpc_pid=$tpc_pid_new
    fi

    if [ $hwc_pid != $hwc_pid_new ]; then
        echo "$tname ..... hwc crash and new_pid is $hwc_pid_new">>/data/ps_report.txt
        hwc_pid=$hwc_pid_new
    fi

    if [ $c2_pid != $c2_pid_new ]; then
        echo "$tname ..... c2 crash and new_pid is $c2_pid_new">>/data/ps_report.txt
        c2_pid=$c2_pid_new
    fi

    if [ $tvcenter_pid != $tvcenter_pid_new ]; then
        echo "$tname ..... tvcenter crash and new_pid is $tvcenter_pid_new">>/data/ps_report.txt
        tvcenter_pid=$tvcenter_pid_new
    fi

    if [ $tunerhal_pid != $tunerhal_pid_new ]; then
        echo "$tname ..... tunerhal crash and new_pid is $tunerhal_pid_new">>/data/ps_report.txt
        tunerhal_pid=$tunerhal_pid_new
        fi

    if [ $tune_pid != $tune_pid_new ]; then
        echo "$tname ..... tune crash and new_pid is $tune_pid_new">>/data/ps_report.txt
        tune_pid=$tune_pid_new
    fi

    if [ $mediator_pid != $mediator_pid_new ]; then
        echo "$tname ..... mediator crash and new_pid is $mediator_pid_new">>/data/ps_report.txt
        mediator_pid=$mediator_pid_new
    fi

    if [ $surfaceflinger_pid != $surfaceflinger_pid_new ]; then
        echo "$tname ..... surfaceflinger crash and new_pid is $surfaceflinger_pid">>/data/ps_report.txt
        surfaceflinger_pid=$surfaceflinger_pid_new
    fi

    #echo "$tname end check process status ............."
    sleep 180
done
