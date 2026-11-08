#!/bin/sh

ROOTDIR=""
MODE=""
LOGDIR="tcl9618_log"
DISPLAY_OUTPUT_BASE_DIR=""
DISPLAY_OUTPUT_FILE="log_display.log"
ATV_FILE="atv.log"
DISPLAY_INFOR_FILE="display_dump_information.txt"
LDM_DUMP_FILE="ldm_dump_information.txt"
VIDEO_INFOR_FILE="video_dump_information.txt"
HDMI_INFOR_FILE="hdmi_dump_information.txt"
CEC_INFOR_FILE="CEC_ARC_eARC_dump_information.txt"
TAG_VER="Test_tag_infor.txt"

MAIN()
{

  ### Arguments
  # $log_fp => output log file path
  # $act_log_fp => interactive log output file path
  module_arg1=$1
  module_arg2=$2
  module_arg3=$3
  echo -e "arg1=$module_arg1,arg2=$module_arg2"
  
  #if [ "$module_arg1" == "" ]; then
  #echo -e "please set save path,for example: ./tcl9618_display.sh /mnt/media_rw/storagename"
  #exit 0
  #fi
  
  #if [ "$module_arg2" != "1" ]|| [ "$module_arg2" != "2" ] [ "$module_arg2" == "3" ]; then
  #MODE=$module_arg2
  #else
  #echo -e "Your debug mode$module_arg2 is wrong,it is only 1~3"
  #exit 0
  #fi

  ROOTDIR=$module_arg1
  MODE=$module_arg2
  DISPLAY_OUTPUT_BASE_DIR=$module_arg1/$LOGDIR/display
  echo -e "DISPLAY_OUTPUT_BASE_DIR=$DISPLAY_OUTPUT_BASE_DIR"
  # Open log
  echo -e "Open autolog for Display\n"
  #su
  rm -rf $DISPLAY_OUTPUT_BASE_DIR
  mkdir $ROOTDIR/$LOGDIR
  mkdir $ROOTDIR/$LOGDIR/display
  
  
  echo "enable DIPLAY  debug"
  getprop|grep -i ro.vendor.mtk.pkg_version >> $DISPLAY_OUTPUT_BASE_DIR/$TAG_VER
  setprop vendor.mtk.displink.log 1
  setprop vendor.mtk.dispservice.mediator.info.log 1
  setprop vendor.mtk.c2bwm.log 3
  setprop vendor.mtk.mirender.debuglevel F0
  setprop vendor.mtk.mirender.debuginfo 417E0000
  setprop vendor.mtk.c2.enable.comp.log 2
  setprop vendor.mtk.c2.enable.vdec.log 2
  setprop vendor.mtktv.c2.enable.vdec.log 2
  setprop vendor.mtktv.c2.enable.bm.log 2
  setprop vendor.mtk.vcodecvideo.log 2
  setprop vendor.mtk.vcodecvdecimpl.log 3
  setprop vendor.mtk.c2bwmlock.log 3
  setprop vendor.mtk.c2bwm.log 3
  setprop vendor.mtk.dispservice.mediator.info.log 1
  # renderDD
  echo 0xFF > /sys/module/drm/parameters/debug
  echo 0x4000002 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/log_level
  #echo -e "enable LDM debug"
  #echo 0x800000 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/log_level
  #logcat -c
  #logcat -G 256M
  #logcat -v threadtime -f $DISPLAY_OUTPUT_BASE_DIR/$DISPLAY_OUTPUT_FILE &
  #LOGCAT_PID=$!
  #dmesg -C; dmesg -w > $LDM_OUTPUT_BASE_DIR/dmesg.log &
  #DMESG_PID=$!
  case "$MODE" in
    "1")
      echo "MM/DTV Display Mode"
      sh /vendor/bin/autolog/autolog.sh bsp disp disp_aow.sh 10001 -o=$DISPLAY_OUTPUT_BASE_DIR
      #disp_log_open
      #INIT_BSP_VIDEO_VIDEO 20001
      #dtv frontend
      setprop vendor.mtk.broadcast.log.level V 
      setprop vendor.mtk.tvexoplayer.log all
      setprop vendor.debug.tuner.service.log 1
    ;;
    "2")
      echo "HDMI_Diplay Mode"
      echo -e "enable CEC/ARC/eARC  debug"
      echo 7 > /sys/devices/platform/mtk_earc/mtk_dbg/eARC/LogLevel
      echo 1 > /sys/devices/platform/mtk_earc/RD/Info
      lshal debug vendor.mediatek.hardware.ExternIn@1.0::IExternIn/ExternIn --dbglevel 6
      setprop vendor.hal.audio.log.level VERBOSE
      sh /vendor/bin/autolog/autolog.sh bsp disp disp_aow.sh 50001 -o=$DISPLAY_OUTPUT_BASE_DIR
    ;;
    "3")
      echo "ATV_Diplay Mode"
      echo 0 > /proc/sys/kernel/printk
      echo 5 > /sys/devices/platform/mtk_srccap0/mtk_dbg/log_level
      setprop vendor.mtk.vcodecatv.log.level 3
      lshal debug vendor.mediatek.hardware.ExternIn@1.0::IExternIn/ExternIn --dbglevel 4
      setprop vendor.mtk.c2.enable.vdec.log 2
      setprop vendor.mtktv.c2.enable.vdec.log 3
      setprop vendor.mtktv.c2.enable.bm.log 2
      setprop vendor.mtk.broadcast.log.level V
      setprop media.framework.verbose.log 1
      setprop vendor.mtk.tpc.debug.log 4
      setprop vendor.mtk.displink.log 1
      setprop vendor.mtk.pqlink.log 1
      setprop vendor.mtk.pqhal.debuglevel 5
      setprop vendor.mtk.dispservice.mediator.info.log 1
      setprop vendor.debug.tuner.service.log 1
      setprop vendor.hal.c2.audio.log.level VERBOSE
      setprop log.tag.audio_hw_primary V
      echo apaf_log_level=info > /mnt/vendor/tmp/apaf/D
      echo 7 > /sys/devices/platform/1c2e5800.mtk-tv-offload-soc/mtk_dbg/log_level
      echo debug_level=3 > /sys/devices/platform/mtk-tv-offload-platform/mtk_dbg/utopia_mdb
      logcat -c
      logcat -G 256M
      logcat -v threadtime -f $DISPLAY_OUTPUT_BASE_DIR/$ATV_FILE &
      LOGCAT_PID=$!
    ;;
  esac

  #wait issure reproduce
  while :
  do
    echo "Is finished display reproduce, key in [Y/y] to continue:"
    read -r -t 30 rst1
    if [ "${rst1}" == "Y" ] || [ "${rst1}" == "y" ]; then
    echo "Dump Display Information"

    ## Render
    echo "### Render ###" >> $DISPLAY_OUTPUT_BASE_DIR/$DISPLAY_INFOR_FILE
    lshal debug vendor.mediatek.hardware.render@1.0::IRender/default --reset
    lshal debug vendor.mediatek.hardware.render@1.0::IRender/default --dump >> $DISPLAY_OUTPUT_BASE_DIR/$DISPLAY_INFOR_FILE
    sleep 1
    lshal debug vendor.mediatek.hardware.render@1.0::IRender/default --dump >> $DISPLAY_OUTPUT_BASE_DIR/$DISPLAY_INFOR_FILE
    sleep 1
    lshal debug vendor.mediatek.hardware.render@1.0::IRender/default --dump >> $DISPLAY_OUTPUT_BASE_DIR/$DISPLAY_INFOR_FILE
    sleep 1
    lshal debug vendor.mediatek.hardware.render@1.0::IRender/default --dump >> $DISPLAY_OUTPUT_BASE_DIR/$DISPLAY_INFOR_FILE
    ## C2
    echo "### C2 ###" >> $DISPLAY_OUTPUT_BASE_DIR/$DISPLAY_INFOR_FILE
    lshal debug vendor.mediatek.hardware.c2.info@1.0::ICodec2InfoService/c2.info --enable
    lshal debug vendor.mediatek.hardware.c2.info@1.0::ICodec2InfoService/c2.info --dump >> $DISPLAY_OUTPUT_BASE_DIR/$DISPLAY_INFOR_FILE
    ## Displink
    echo "### Displink ###" >> $DISPLAY_OUTPUT_BASE_DIR/$DISPLAY_INFOR_FILE
    lshal debug vendor.mediatek.hardware.dispservice@1.0::IDispService/default --enable
    lshal debug vendor.mediatek.hardware.dispservice@1.0::IDispService/default --dump >> $DISPLAY_OUTPUT_BASE_DIR/$DISPLAY_INFOR_FILE
    ## MI_PQ
    echo "### MI_PQ ###" >> $DISPLAY_OUTPUT_BASE_DIR/$DISPLAY_INFOR_FILE
    lshal debug vendor.mediatek.hardware.pq@1.0::IPq/default --enable
    lshal debug vendor.mediatek.hardware.pq@1.0::IPq/default ¨Cdump >> $DISPLAY_OUTPUT_BASE_DIR/$DISPLAY_INFOR_FILE
    ## PQ
    echo "### PQ ###" >> $DISPLAY_OUTPUT_BASE_DIR/$DISPLAY_INFOR_FILE
    lshal debug vendor.mediatek.hardware.pq@1.0::IPq/default --enable
    lshal debug vendor.mediatek.hardware.pq@1.0::IPq/default --dump >> $DISPLAY_OUTPUT_BASE_DIR/$DISPLAY_INFOR_FILE
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_mode_ID_Sel >> $DISPLAY_OUTPUT_BASE_DIR/$DISPLAY_INFOR_FILE
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/frame_sync_status >> $DISPLAY_OUTPUT_BASE_DIR/$DISPLAY_INFOR_FILE
    ## LDM
    echo "### LDM ###" >> $DISPLAY_OUTPUT_BASE_DIR/$LDM_DUMP_FILE
  	echo 0x800000 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/log_level
    cat /sys/devices/platform/mediatek-drm-tv-kms/Localdimming/ldm_dts 
    dmesg | grep LDM >> $DISPLAY_OUTPUT_BASE_DIR/$LDM_DUMP_FILE
    ## VIDEO
    echo "### VIDEO ###" >> $DISPLAY_OUTPUT_BASE_DIR/$VIDEO_INFOR_FILE
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/memc_level_frc >> $DISPLAY_OUTPUT_BASE_DIR/$VIDEO_INFOR_FILE
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/frc_algo_status >> $DISPLAY_OUTPUT_BASE_DIR/$VIDEO_INFOR_FILE
    lshal debug vendor.mediatek.hardware.render@1.0::IRender/default --reset
    lshal debug vendor.mediatek.hardware.render@1.0::IRender/default --compose >> $DISPLAY_OUTPUT_BASE_DIR/$VIDEO_INFOR_FILE
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/path_frc >> $DISPLAY_OUTPUT_BASE_DIR/$VIDEO_INFOR_FILE
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/tg_param >> $DISPLAY_OUTPUT_BASE_DIR/$VIDEO_INFOR_FILE
    
    if [ "$MODE" == "1" ]; then
    ## FRONTEND
    echo "### frontend ###" >> $DISPLAY_OUTPUT_BASE_DIR/$VIDEO_INFOR_FILE
    cat /sys/devices/platform/mtk-dvb-adapter/dvb0.frontend0/debug_info >> $DISPLAY_OUTPUT_BASE_DIR/$VIDEO_INFOR_FILE
    cat /sys/devices/platform/mtk-dvb-adapter/dvb0.frontend0/debug_info >> $DISPLAY_OUTPUT_BASE_DIR/$VIDEO_INFOR_FILE
    ## VDEC
    echo "### vdec ###" >> $DISPLAY_OUTPUT_BASE_DIR/$VIDEO_INFOR_FILE
    cat /sys/devices/platform/1c570000.vcu/mtk_dbg/decode_base_info >> $DISPLAY_OUTPUT_BASE_DIR/$VIDEO_INFOR_FILE
    cat /sys/devices/platform/1c570000.vcu/mtk_dbg/decode_base_info >> $DISPLAY_OUTPUT_BASE_DIR/$VIDEO_INFOR_FILE
    fi
    
    ## HDMI
    if [ "$MODE" == "2" ]; then
    echo 3 > /proc/sys/kernel/printk
    echo "### HDMI EDID0###" >> $DISPLAY_OUTPUT_BASE_DIR/$HDMI_INFOR_FILE
    cat /sys/devices/platform/mtk_srccap0/mtk_dbg/hdmirx/0/edid >> $DISPLAY_OUTPUT_BASE_DIR/$HDMI_INFOR_FILE
    echo "### HDMI EDID1###" >> $DISPLAY_OUTPUT_BASE_DIR/$HDMI_INFOR_FILE
    cat /sys/devices/platform/mtk_srccap0/mtk_dbg/hdmirx/1/edid >> $DISPLAY_OUTPUT_BASE_DIR/$HDMI_INFOR_FILE
    echo "### HDMI EDID2###" >> $DISPLAY_OUTPUT_BASE_DIR/$HDMI_INFOR_FILE
    cat /sys/devices/platform/mtk_srccap0/mtk_dbg/hdmirx/2/edid >> $DISPLAY_OUTPUT_BASE_DIR/$HDMI_INFOR_FILE
    echo "### HDMI EDID3###" >> $DISPLAY_OUTPUT_BASE_DIR/$HDMI_INFOR_FILE
    cat /sys/devices/platform/mtk_srccap0/mtk_dbg/hdmirx/3/edid >> $DISPLAY_OUTPUT_BASE_DIR/$HDMI_INFOR_FILE
    echo "### HDMI ALL INFOR###" >> $DISPLAY_OUTPUT_BASE_DIR/$HDMI_INFOR_FILE
    cat /sys/devices/platform/mtk_srccap0/mtk_dbg/hdmirx/ALL_INFO >> $DISPLAY_OUTPUT_BASE_DIR/$HDMI_INFOR_FILE
    echo "### HDMI INFOR###" >> $DISPLAY_OUTPUT_BASE_DIR/$HDMI_INFOR_FILE
    cat /sys/devices/platform/mtk_srccap0/mtk_dbg/hdmirx/HDMI_INFO >> $DISPLAY_OUTPUT_BASE_DIR/$HDMI_INFOR_FILE
    echo "### HDMI TIMING_DETECT###" >> $DISPLAY_OUTPUT_BASE_DIR/$HDMI_INFOR_FILE
    cat /sys/devices/platform/mtk_srccap0/mtk_dbg/hdmirx/TIMING_DETECT >> $DISPLAY_OUTPUT_BASE_DIR/$HDMI_INFOR_FILE
    echo "### HDMI srccap_report_info###" >> $DISPLAY_OUTPUT_BASE_DIR/$HDMI_INFOR_FILE
    cat /sys/devices/platform/mtk_srccap0/mtk_dbg/srccap_report_info >> $DISPLAY_OUTPUT_BASE_DIR/$HDMI_INFOR_FILE
    echo "### HDMI dmesg0###" >> $DISPLAY_OUTPUT_BASE_DIR/$HDMI_INFOR_FILE
    cat /sys/devices/platform/mtk_srccap0/mtk_dbg/hdmirx/0/dmesg >> $DISPLAY_OUTPUT_BASE_DIR/$HDMI_INFOR_FILE
    echo "### HDMI dmesg1###" >> $DISPLAY_OUTPUT_BASE_DIR/$HDMI_INFOR_FILE
    cat /sys/devices/platform/mtk_srccap0/mtk_dbg/hdmirx/1/dmesg >> $DISPLAY_OUTPUT_BASE_DIR/$HDMI_INFOR_FILE
    echo "### HDMI dmesg2###" >> $DISPLAY_OUTPUT_BASE_DIR/$HDMI_INFOR_FILE
    cat /sys/devices/platform/mtk_srccap0/mtk_dbg/hdmirx/2/dmesg >> $DISPLAY_OUTPUT_BASE_DIR/$HDMI_INFOR_FILE
    echo "### HDMI dmesg3###" >> $DISPLAY_OUTPUT_BASE_DIR/$HDMI_INFOR_FILE
    cat /sys/devices/platform/mtk_srccap0/mtk_dbg/hdmirx/3/dmesg >> $DISPLAY_OUTPUT_BASE_DIR/$HDMI_INFOR_FILE
    echo "### HDMI pkt0###" >> $DISPLAY_OUTPUT_BASE_DIR/$HDMI_INFOR_FILE
    cat /sys/devices/platform/mtk_srccap0/mtk_dbg/hdmirx/0/pkt_all >> $DISPLAY_OUTPUT_BASE_DIR/$HDMI_INFOR_FILE
    echo "### HDMI pkt1###" >> $DISPLAY_OUTPUT_BASE_DIR/$HDMI_INFOR_FILE
    cat /sys/devices/platform/mtk_srccap0/mtk_dbg/hdmirx/1/pkt_all >> $DISPLAY_OUTPUT_BASE_DIR/$HDMI_INFOR_FILE
    echo "### HDMI pkt2###" >> $DISPLAY_OUTPUT_BASE_DIR/$HDMI_INFOR_FILE
    cat /sys/devices/platform/mtk_srccap0/mtk_dbg/hdmirx/2/pkt_all >> $DISPLAY_OUTPUT_BASE_DIR/$HDMI_INFOR_FILE
    echo "### HDMI pkt3###" >> $DISPLAY_OUTPUT_BASE_DIR/$HDMI_INFOR_FILE
    cat /sys/devices/platform/mtk_srccap0/mtk_dbg/hdmirx/3/pkt_all >> $DISPLAY_OUTPUT_BASE_DIR/$HDMI_INFOR_FILE
    echo "### HDMI audio###" >> $DISPLAY_OUTPUT_BASE_DIR/$HDMI_INFOR_FILE
    cat /sys/devices/platform/mtk_srccap0/mtk_dbg/hdmirx/audio_fs >> $DISPLAY_OUTPUT_BASE_DIR/$HDMI_INFOR_FILE
    cat /sys/devices/platform/mtk_srccap0/mtk_dbg/hdmirx/audio_fs >> $DISPLAY_OUTPUT_BASE_DIR/$HDMI_INFOR_FILE
    cat /sys/devices/platform/mtk_srccap0/mtk_dbg/hdmirx/audio_fs >> $DISPLAY_OUTPUT_BASE_DIR/$HDMI_INFOR_FILE
    echo "### HDMI HDCP22 KEY###" >> $DISPLAY_OUTPUT_BASE_DIR/$HDMI_INFOR_FILE
    intertaca_manual -c HDCP22RX >> $DISPLAY_OUTPUT_BASE_DIR/$HDMI_INFOR_FILE
    echo "### HDMI HDCP14 KEY###" >> $DISPLAY_OUTPUT_BASE_DIR/$HDMI_INFOR_FILE
    intertaca_manual -c HDCP14 >> $DISPLAY_OUTPUT_BASE_DIR/$HDMI_INFOR_FILE

    ## CEC/ARC/eARC informtion
    echo -e "### CEC/ARC/eARC ###" >> $DISPLAY_OUTPUT_BASE_DIR/$CEC_INFOR_FILE
    dumpsys hdmi_control >> $DISPLAY_OUTPUT_BASE_DIR/$CEC_INFOR_FILE
    dumpsys hdmi_audio >> $DISPLAY_OUTPUT_BASE_DIR/$CEC_INFOR_FILE
    dumpsys media.audio_policy >> $DISPLAY_OUTPUT_BASE_DIR/$CEC_INFOR_FILE
    dumpsys audio >> $DISPLAY_OUTPUT_BASE_DIR/$CEC_INFOR_FILE
    cat /sys/devices/platform/mtk_earc/mtk_dbg/eARC/EarcStatus >> $DISPLAY_OUTPUT_BASE_DIR/$CEC_INFOR_FILE
    cat /sys/devices/platform/mtk_earc/RD/Info >> $DISPLAY_OUTPUT_BASE_DIR/$CEC_INFOR_FILE
    fi

    ## ATV
    if [ "$MODE" == "3" ]; then
    echo 4 > /sys/devices/platform/mtk_srccap0/mtk_dbg/log_level
    echo debug_level=2 > /sys/devices/platform/mtk-tv-offload-platform/mtk_dbg/utopia_mdb
    sync
    kill $LOGCAT_PID
    fi

    #cd /data/local/CaptureCmd
    #rm -rf /data/local/CaptureCmd
    #CaptureCmd.bin -p 13
    #CaptureCmd.bin -p 2
    #CaptureCmd.bin -p 9
    #CaptureCmd.bin -p 10
    #CaptureCmd.bin -p 11
    #CaptureCmd.bin -p 12
    #cp -R /data/local/CaptureCmd $DISPLAY_OUTPUT_BASE_DIR
    #kill $LOGCAT_PID
    #kill $DMESG_PID
    break
    fi
  done
  sync
  echo -e "Please Copy $DISPLAY_OUTPUT_BASE_DIR"
}


if [ "$*" = "--source-only" ]; then
  :
else
  MAIN $*
fi
