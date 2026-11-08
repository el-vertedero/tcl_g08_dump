#!/usr/bin/env sh

MAIN()
{
    ### Import functions from other modules/scripts
    ### DO SOMETHING
    echo "\033[1m \033[4m"
    echo "In debug_abnormal_video_input_src.sh\033[0m"

    echo "Apply abnormal video(input_src) log settings..."

    echo "Cat HDMI info in begining"
    cat /sys/devices/platform/mtk_srccap0/mtk_dbg/hdmirx/ALL_INFO >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/cathdmi_in_begining.log&
    sleep 1
    cat /sys/devices/platform/mtk_srccap0/mtk_dbg/hdmirx/HDMI_INFO >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/cathdmi_in_begining.log&
    sleep 1
    cat /sys/devices/platform/mtk_srccap0/mtk_dbg/hdmirx/TIMING_DETECT >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/cathdmi_in_begining.log&
    sleep 1

    #Analog
    setprop vendor.mtk.vcodeccomponent.log.level 3
    setprop vendor.mtk.vcodecatv.log.level 3
    setprop vendor.mtk.vcodeccomposite.log.level 3

    #HDMI
    if [ "$ANDROID_VERSION" -ge 14 ]; then
      dumpsys vendor.mediatek.hardware.ExternIn.IExternIn/default --dbglevel 5
    else
      lshal debug vendor.mediatek.hardware.ExternIn@1.0::IExternIn/ExternIn --dbglevel 5
    fi
    setprop vendor.mtk.vcodechdmi.log.level 3
    echo 7 > /sys/devices/platform/mtk_srccap0/mtk_dbg/hdmirx/log_level

    sh $AUTOLOG_MODULES_DIR/symptom/sym_debug/debug_abnormal_disp.sh

    echo "\033[1m \033[4m"
    echo "Out debug_abnormal_video_input_src.sh\033[0m"
}

#========================================================
#                 Script entrance control
#                  (Don't remove this)
#  If call this script through 'sh' command:
#      => Execute script, e.g MAIN function
#  If call this script through 'source <script_path> --source-only'
#      => import functions inside this script and this will
#         not execute MAIN()
#========================================================
if [ "$*" = "--source-only" ]; then
  :
else
  MAIN $*
fi
