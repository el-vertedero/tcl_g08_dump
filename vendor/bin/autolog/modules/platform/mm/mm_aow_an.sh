#!/usr/bin/env sh
#set -x

. "$AUTOLOG_HOME/utils/imports.sh"
ImportUtil "loggers.sh"
ImportUtil "colors.sh"
#ImportUtil "helpers.sh"
ImportUtil "sys.sh"

#========================================================
#          Import modules functions you need
# if you want to call modules/bsp/audio/audio.sh
#                  =>  Import bsp audio audio.sh
#========================================================
#Import bsp video common.sh
#Import bsp audio audio_demo.sh

#TODO
#Import bsp audio audio.sh
Import bsp video video.sh
#Import bsp disp disp.sh
Import platform security widevine_an.sh
Import bsp disp disp_aow.sh
ARGV=0
DefaultMmOutputPath="/mnt/vendor/tmp"

Wait_finish()
{
    message="${COLOR_RED}After issue appears, press keyin any words to finishing recording!${COLOR_REST}"
    bug=$(prompt "$message")
    echo "$bug"
    sleep 1s
}

INIT_PLATFORM_MM_MM()
{

  #========================================================
  #                   Define Scenarios
  # In this section, you have to design log switches for
  #   each kinds of scenarios.
  # For example:
  #    Scenario A (10101) is related to log_a, log_b, log_c
  #        => Enable log_a, log_b, log_c
  #    Scenario A' (10102) is a light version of scenario A.
  #      only enable log_a, log_b
  #        => Enable log_a, log_b
  #    Scenario B (10201) is only related to log_b
  #        => Just have to enable log_b
  #========================================================
  echo "Initialize PLATFORM.MM.MM log configs..."
  SCENARIO_NUM="$1"
  ARGV="$2"

  echo "Temp Folder: "$DefaultMmOutputPath

#  set -e

  #========================================================
  #                   Common part  (CAUTION!!)
  #  Commands defined here will been executed while user
  #  call this function EVERY TIME.
  #========================================================
  #echo debug_level=4 > /proc/utopia_mdb/audio

  ### Enable logs by scenario number
  ### You can setup kinds of scenario here
  ### Scenario Number is
  case "$SCENARIO_NUM" in
    "10001")
      ######################################################
      #              ( 10001 )  Scenario A - Normal
      #
      # <MM logcat+kernel>
      #
      ######################################################
      echo "IN 10001"

      MM_LOG_FP="$LOG_DIR/$LOG_DT-platform_mm_mm_aow_an.sh_10001-mm.log"
      echo "MM_LOG_FP: $MM_LOG_FP"
      echo "Enable MM log"
      logcat -G 256M
      setprop vendor.mstar.vsync_bridge.log 1
      setprop vendor.mstar.vdec.log 2
      setprop vendor.mtk.displink.bm.profile 1
      setprop vendor.mtk.c2.enable.comp.log 2
      setprop vendor.mtk.c2.enable.vdec.log 2
      setprop vendor.mtktv.c2.enable.vdec.log 2
      setprop vendor.mtktv.c2.enable.bm.log 2
      setprop vendor.mtk.codec2.log 2
      setprop mtk.exoplayer.debug.level 11
      setprop vendor.mtk.vcodecvideo.log 2
      setprop vendor.mtk.vcodecvdecimpl.log 3
      setprop vendor.mtk.tpchwc.log 1
      setprop vendor.mtk.vsyncbridge.log 1
      setprop vendor.mtk.displink.log 1
      setprop vendor.mtk.subhalvideo.log 0x40
      setprop vendor.hal.c2.audio.log.level VERBOSE
      setprop vendor.hal.audio.log.level VERBOSE
      setprop vendor.mtk.mipq.debuglevel F0
      setprop vendor.mtk.tpc.debug.log 4
      setprop vendor.mtk.pqlink.log 1
      setprop vendor.mtk.pqlink.performance.profile 1

      #Render //20211104 request by Adam-tt
      setprop vendor.mtk.mirender.debuglevel F0
      setprop vendor.mtk.mirender.debuginfo 417E0000

      #TS/PS container log //20211118 requested by Neil Hsieh
      setprop vendor.mtk.ts.verbose.log 1
      setprop vendor.mtk.ps.verbose.log 1

      #C2 BWM
      setprop vendor.mtk.c2bwm.log 3
      #dispservice mediator
      setprop vendor.mtk.dispservice.mediator.info.log 1
      #DTV passthrough mode
      setprop vendor.mtk.tunerlink.log 2
      #################################################
      #TODO
      echo "Enable Kernel log"
      echo "Enable VDEC LOG"
      INIT_BSP_VIDEO_VIDEO 10101
      echo "Enable DISPLAY LOG"
      #INIT_BSP_DISP_DISP 10501 #mi_disp log
      echo 0 > /proc/sys/kernel/printk
      echo 0xdff > /sys/devices/platform/mtk-pq/mtk_dbg/log_level
      echo 0xFF > /sys/module/drm/parameters/debug
      echo 0x400FFFF > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/log_level
      echo 8 > /sys/module/mtk_vcodec_dec/parameters/mtk_v4l2_dbg_level
      logcat -c
      logcat -v threadtime > $MM_LOG_FP&

      #################################################
      #TODO - for DRM WV log
      if [ "$ARGV" = "wv" ]; then
      echo "Enable DRM WV LOG"
      INIT_PLATFORM_SECURITY_WIDEVINE 10101
      INIT_PLATFORM_SECURITY_WIDEVINE 10301
      fi
    ;;
    "10002")
      ######################################################
      #              ( 10002 )  Scenario B - Light
      #
      # <MM logcat>
      #
      ######################################################
      echo "IN 10002"

      MM_LOG_FP="$LOG_DIR/$LOG_DT-platform_mm_mm_aow_an.sh_10002-mm.log"
      echo "MM_LOG_FP: $MM_LOG_FP"
      echo "Enable MM log"
      logcat -G 256M
      setprop vendor.mstar.vsync_bridge.log 1
      setprop vendor.mstar.vdec.log 2
      setprop vendor.mtk.displink.bm.profile 1
      setprop vendor.mtk.c2.enable.comp.log 2
      setprop vendor.mtk.c2.enable.vdec.log 2
      setprop vendor.mtktv.c2.enable.vdec.log 2
      setprop vendor.mtktv.c2.enable.bm.log 2
      setprop vendor.mtk.codec2.log 2
      setprop mtk.exoplayer.debug.level 11
      setprop vendor.mtk.vcodecvideo.log 2
      setprop vendor.mtk.vcodecvdecimpl.log 3
      setprop vendor.mtk.tpchwc.log 1
      setprop vendor.mtk.vsyncbridge.log 1
      setprop vendor.mtk.displink.log 1
      setprop vendor.mtk.subhalvideo.log 0x40
      setprop vendor.hal.c2.audio.log.level VERBOSE
      setprop vendor.hal.audio.log.level VERBOSE
      setprop vendor.mtk.mipq.debuglevel 40
      setprop vendor.mtk.tpc.debug.log 4
      setprop vendor.mtk.pqlink.log 1
      setprop vendor.mtk.pqlink.performance.profile 1
      setprop vendor.mtk.pqhal.debuglevel 2
      #C2 BWM
      setprop vendor.mtk.c2bwm.log 2
      #dispservice mediator
      setprop vendor.mtk.dispservice.mediator.info.log 1
      #DTV passthrough mode
      setprop vendor.mtk.tunerlink.log 2
      #################################################
      #TODO
      #echo "Enable Kernel log"
      #echo "Enable VDEC LOG"
      echo 8 > /sys/module/mtk_vcodec_dec/parameters/mtk_v4l2_dbg_level
      #INIT_BSP_VIDEO_VIDEO 10101 #vdec log
      #echo "Enable DISPLAY LOG"
      #INIT_BSP_DISP_DISP 10501 #mi_disp log
      logcat -c
      logcat -v threadtime > $MM_LOG_FP&

    ;;
    "10003")
      ######################################################
      #              ( 10003 )  Scenario AV SYNC
      #
      #  10003 : common log
      #  10003 1 : common log + pq kernel
      #
      ######################################################
      echo "IN 10003"

      MM_LOG_FP="$LOG_DIR/$LOG_DT-platform_mm_mm_aow_an.sh_10003-mm.log"
      echo "MM_LOG_FP: $MM_LOG_FP"
      echo "Enable MM log"
      logcat -G 256M

      #Exoplayer
      setprop mtk.exoplayer.debug.level 11

      #TPC
      setprop vendor.mtk.sharemem.debug.log 2
      setprop vendor.mtk.tpc.sync.log 1
      setprop vendor.mtk.tpc.debug.log 4

      #Render
      setprop vendor.mtk.mirender.debuglevel F0
      setprop vendor.mtk.mirender.debuginfo 417E0000

      #c2/HWC
      setprop vendor.mtk.displink.bm.profile 1
      setprop vendor.mtk.c2.enable.comp.log 2
      setprop vendor.mtk.c2.enable.vdec.log 2
      setprop vendor.mtktv.c2.enable.vdec.log 2
      setprop vendor.mtktv.c2.enable.tpcvideo.log 2
      setprop vendor.mtktv.c2.enable.bm.log 2
      setprop vendor.mtk.vcodecvdecimpl.log 3
      setprop vendor.mtk.vcodecvideo.log 3
      setprop vendor.mtk.tpchwc.log 1
      setprop vendor.mtk.displink.log 1
      setprop vendor.mtk.pqlink.log 1
      setprop vendor.mtk.pqlink.performance.profile 1
      #C2 BWM
      setprop vendor.mtk.c2bwm.log 3
      #dispservice mediator
      setprop vendor.mtk.dispservice.mediator.info.log 1
      #DTV passthrough mode
      setprop vendor.mtk.tunerlink.log 2
      #Audio
      setprop vendor.hal.audio.log.level VERBOSE
      cd $DefaultMmOutputPath/apaf/
      echo apaf_log_level=sync >D
      cd -

      if [ "$ARGV" = "1" ]; then
      echo "Add DISPLAY (PQ) LOG"
      #PQ kernel log
          echo 0 > /proc/sys/kernel/printk
          echo 0xdff > /sys/devices/platform/mtk-pq/mtk_dbg/log_level
          echo 0x006 > /sys/devices/platform/mtk-tvpqu/mtk_dbg/log_level
          setprop vendor.mtk.mipq.debuglevel F0
          setprop vendor.mtk.pqhal.debuglevel 5
      fi

      echo 8 > /sys/module/mtk_vcodec_dec/parameters/mtk_v4l2_dbg_level

      logcat -c
      logcat -v threadtime > $MM_LOG_FP&
    ;;
    "10004")
      ######################################################
      #              ( 10004 )  Scenario Extractor
      #
      # <MM logcat+kernel+mi disp>
      #
      ######################################################
      echo "IN 10004"

      MM_LOG_FP="$LOG_DIR/$LOG_DT-platform_mm_mm_aow_an.sh_10004-mm.log"
      echo "MM_LOG_FP: $MM_LOG_FP"
      echo "Enable MM log"
      logcat -G 256M
      setprop mtk.exoplayer.debug.level 11
      setprop vendor.hal.audio.log.level VERBOSE
      setprop vendor.hal.c2.audio.log.level VERBOSE
      setprop vendor.mstar.vdec.log 2
      setprop vendor.mstar.vsync_bridge.log 1
      setprop vendor.mtk.c2.enable.comp.log 2
      setprop vendor.mtk.c2.enable.vdec.log 2
      setprop vendor.mtk.codec2.log 2
      setprop vendor.mtk.displink.bm.profile 1
      setprop vendor.mtk.displink.log 1
      setprop vendor.mtk.displink.wrapper.log 1
      setprop vendor.mtk.mi.video.log 80
      setprop vendor.mtk.pqlink.performance.profile 1
      setprop vendor.mtk.subhalvideo.log 0x40
      setprop vendor.mtk.tpc.debug.log 4
      setprop vendor.mtk.tpchwc.log 1
      setprop vendor.mtk.vcodecvdecimpl.log 3
      setprop vendor.mtk.vcodecvideo.log 2
      setprop vendor.mtk.vsyncbridge.log 1
      setprop vendor.mtktv.c2.enable.bm.log 2
      setprop vendor.mtktv.c2.enable.tpcvideo.log 2
      setprop vendor.mtktv.c2.enable.vdec.log 2
      setprop vendor.mtk.displink.bm.profile 1
      setprop vendor.mtk.pqlink.setwin.info 1
      setprop vendor.mtktv.c2.enable.bm.log 2

      #Render //20211104 request by Adam-tt
      setprop vendor.mtk.mirender.debuglevel F0
      setprop vendor.mtk.mirender.debuginfo 417E0000

      #TS/PS container log //20211118 requested by Neil Hsieh
      setprop vendor.mtk.ts.verbose.log 1
      setprop vendor.mtk.ps.verbose.log 1
      #C2 BWM
      setprop vendor.mtk.c2bwm.log 3
      #dispservice mediator
      setprop vendor.mtk.dispservice.mediator.info.log 1
      #DTV passthrough mode
      setprop vendor.mtk.tunerlink.log 2
      #################################################
      #TODO
      echo "Enable Kernel log"
      echo "Enable VDEC LOG"
      INIT_BSP_VIDEO_VIDEO 10101
      echo "Enable DISPLAY LOG"
      #INIT_BSP_DISP_DISP 10501 #mi_disp log
      echo 0 > /proc/sys/kernel/printk
      echo 0xdff > /sys/devices/platform/mtk-pq/mtk_dbg/log_level
      echo 0xFF > /sys/module/drm/parameters/debug
      echo 0x400FFFF > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/log_level
      echo 8 > /sys/module/mtk_vcodec_dec/parameters/mtk_v4l2_dbg_level
      logcat -c
      logcat -v threadtime > $MM_LOG_FP&
    ;;
    "10101")
      ######################################################
      #              ( 10101 )  Scenario C
      #
      # <Dump Video Raw Data>
      #
      ######################################################
      echo "IN 10101"

      mkdir -p $ES_FRAME_DUMP_DIR
      TEMP_DIR="$ES_FRAME_DUMP_DIR"
      while [ "$TEMP_DIR" != "" -a "$TEMP_DIR" != "/" ]
      do
            echo "chmod 777 $TEMP_DIR"
            chmod 777 $TEMP_DIR
            TEMP_DIR=$(echo $TEMP_DIR|sed 's#/[^/]*$##')
      done

      MM_LOG_FP="$LOG_DIR/$LOG_DT-platform_mm_mm_aow_an.sh_10101-mm.log"
      echo "MM_LOG_FP: $MM_LOG_FP"
      echo "Enable MM log"
      logcat -G 256M
      setprop vendor.mstar.vsync_bridge.log 1
      setprop vendor.mstar.vdec.log 2
      setprop vendor.mtk.displink.bm.profile 1
      setprop vendor.mtk.c2.enable.comp.log 2
      setprop vendor.mtk.c2.enable.vdec.log 2
      setprop vendor.mtktv.c2.enable.vdec.log 2
      setprop vendor.mtktv.c2.enable.bm.log 2
      setprop vendor.mtk.codec2.log 2
      setprop mtk.exoplayer.debug.level 11
      setprop vendor.mtk.vcodecvideo.log 2
      setprop vendor.mtk.vcodecvdecimpl.log 3
      setprop vendor.mtk.tpchwc.log 1
      setprop vendor.mtk.vsyncbridge.log 1
      setprop vendor.mtk.displink.log 1
      setprop vendor.mtk.subhalvideo.log 0x40
      setprop vendor.hal.c2.audio.log.level VERBOSE
      setprop vendor.hal.audio.log.level VERBOSE
      setprop vendor.mtk.mipq.debuglevel F0
      setprop vendor.mtk.tpc.debug.log 4
      #DTV passthrough mode
      setprop vendor.mtk.tunerlink.log 2
      echo 8 > /sys/module/mtk_vcodec_dec/parameters/mtk_v4l2_dbg_level
      #C2 BWM
      setprop vendor.mtk.c2bwm.log 3
      #dispservice mediator
      setprop vendor.mtk.dispservice.mediator.info.log 1
      #################################################
      #TODO
      #echo "Enable VDEC LOG"
      #INIT_BSP_VIDEO_VIDEO 10101 #vdec log
      #echo "Enable DISPLAY LOG"
      #INIT_BSP_DISP_DISP 10501 #mi_disp log
      logcat -c
      logcat -v threadtime > $MM_LOG_FP&

      #################################################
      #TODO - Frame Dump
      #Wiki: https://wiki.mediatek.inc/display/DTVMainPage/C2+Debug+Dump
      #
      #VDEC_IN_BIT = 1,          // bit for vdec input
      #VDEC_OUT_BIT = 2,         // bit for vdec output
      #CAP_OUT_BIT = 4,          // bit for capture output
      #PQ_OUT_BIT = 8,           // bit for PQ output
      #SWDETILE_OUT_BIT = 16,    // bit for sw detile output
      #MALI_OUT_BIT = 32,        // bit for mali output
      echo "Enable Frame data dump : $ES_FRAME_DUMP_DIR"
      setprop vendor.mtk.force.panel.timing.fhd 1
      setprop vendor.mtk-codec2.dump "$ARGV"

    ;;
    "10201")
      ######################################################
      #              ( 10201 )  Scenario D
      #
      # <Photo logcat>
      #
      ######################################################
      echo "IN 10201"
      MM_LOG_FP="$LOG_DIR/$LOG_DT-platform_mm_mm_aow_an.sh_10201-mm.log"
      echo "MM_LOG_FP: $MM_LOG_FP"
      echo "Enable Photo log"
      logcat -G 256M
      setprop vendor.mstar.vsync_bridge.log 1
      setprop vendor.mtk.displink.bm.profile 1
      setprop vendor.mtk.c2.enable.comp.log 2
      setprop vendor.mtk.c2.enable.vdec.log 2
      setprop vendor.mtktv.c2.enable.vdec.log 2
      setprop vendor.mtktv.c2.enable.bm.log 2
      setprop vendor.mtk.vcodecvideo.log 2
      setprop vendor.mtk.vcodecvdecimpl.log 3
      setprop vendor.mtk.tpchwc.log 1
      setprop vendor.mtk.vsyncbridge.log 1
      setprop vendor.mtk.displink.log 1
      setprop vendor.mtk.mtkimagedecode.debug.log 1
      setprop vendor.mtk.c2.enable.cap.hw 1
      setprop vendor.mtk.codec2.log 2
      setprop vendor.mstar.vdec.log 2
      setprop vendor.mtk.pqlink.log 1
      setprop vendor.mtk.mp4.extract.log 1
      setprop vendor.mtk.pqhal.debuglevel 5
      setprop vendor.mtk.mipq.debuglevel F0
      setprop vendor.mtk.capture_hal.loglevel A
      #DispLink render
      setprop vendor.mtk.displink.render.log 1
      #C2 BWM
      setprop vendor.mtk.c2bwm.log 3
      #dispservice mediator
      setprop vendor.mtk.dispservice.mediator.info.log 1
      #DTV passthrough mode
      setprop vendor.mtk.tunerlink.log 2
      #photo service dump
      setprop vendor.mtk.mtk_photoservice.dumpdata 1
      setprop persist.mtk.cap.dump_yc_img true
      #C2 data dump
      mount -o rw,remount /vendor
      mount -o rw,remount /
      mount -o remount /data
      rm -rf $DefaultMmOutputPath/dump
      mkdir -p $DefaultMmOutputPath/dump
      chmod 777 /data
      chmod 777 $DefaultMmOutputPath/dump
      setprop vendor.mtk-codec2.dump 63
      logcat -c
      logcat -v threadtime > $MM_LOG_FP&
    ;;
    "10202")
      ######################################################
      #              ( 10202 )  Scenario E = color abnormal
      #
      # <Photo logcat>
      #
      ######################################################
      echo "IN 10202"
      MM_LOG_FP="$LOG_DIR/$LOG_DT-platform_mm_mm_aow_an.sh_10202-mm.log"
      echo "MM_LOG_FP: $MM_LOG_FP"
      echo "Enable Photo log - check color abnormal"
      logcat -G 256M
      setprop vendor.mstar.vsync_bridge.log 1
      setprop vendor.mtk.displink.bm.profile 1
      setprop vendor.mtk.c2.enable.comp.log 2
      setprop vendor.mtk.c2.enable.vdec.log 2
      setprop vendor.mtktv.c2.enable.vdec.log 2
      setprop vendor.mtktv.c2.enable.bm.log 2
      setprop vendor.mtk.vcodecvideo.log 2
      setprop vendor.mtk.vcodecvdecimpl.log 3
      setprop vendor.mtk.tpchwc.log 1
      setprop vendor.mtk.vsyncbridge.log 1
      setprop vendor.mtk.displink.log 1
      setprop vendor.mtk.mtkimagedecode.debug.log 1
      setprop vendor.mtk.c2.enable.cap.hw 1
      setprop vendor.mtk.subhalvideo.log 0x40
      setprop vendor.mtk.subhalvdec.log 0x40
      setprop vendor.mtk.vcodecvideo.log 2
      setprop vendor.mtk.vcodecvdecimpl.log 3
      #C2 BWM
      setprop vendor.mtk.c2bwm.log 3
      #dispservice mediator
      setprop vendor.mtk.dispservice.mediator.info.log 1
      #DTV passthrough mode
      setprop vendor.mtk.tunerlink.log 2
      #################################################
      #TODO
      echo "Enable Kernel log"
      echo "Enable VDEC LOG"
      INIT_BSP_VIDEO_VIDEO 10101
      logcat -c
      logcat -v threadtime > $MM_LOG_FP&
    ;;
    "10901")
      ######################################################
      #              ( 10901 )  Scenario X
      #
      # <Please describe this Scenario in this block>
      #
      ######################################################
      echo "IN 10901"
      INIT_XXX_XXXXXX_XXXX 50301
    ;;
    "20001")
      ######################################################
      #              ( 20001 )  Scenario Personal 0001
      #
      # <Personal Video logcat>
      #
      ######################################################
      echo "IN 20001"
      MM_LOG_FP="$LOG_DIR/$LOG_DT-platform_mm_mm_aow_an.sh_20001-mm.log"
      echo "MM_LOG_FP: $MM_LOG_FP"
      echo "Enable Personal Script 0001"
      logcat -G 256M
      setprop vendor.mtk.c2.enable.comp.log 2
      setprop vendor.mtk.c2.enable.vdec.log 2
      setprop vendor.mtktv.c2.enable.vdec.log 2
      setprop vendor.mtktv.c2.enable.bm.log 2
      setprop vendor.mtk.vcodecvideo.log 2
      setprop vendor.mtk.vcodecvdecimpl.log 3
      echo 8 > /sys/module/mtk_vcodec_dec/parameters/mtk_v4l2_dbg_level
      setprop vendor.mtk.displink.log 1
      setprop vendor.mtk.vsyncbridge.log 1
      setprop vendor.mtk.tpchwc.log 1
      setprop vendor.mtk.pqlink.log 1
      #C2 BWM
      setprop vendor.mtk.c2bwm.log 3
      #dispservice mediator
      setprop vendor.mtk.dispservice.mediator.info.log 1
      #DTV passthrough mode
      setprop vendor.mtk.tunerlink.log 2
      logcat -c
      logcat -v threadtime > $MM_LOG_FP&
    ;;
    "20002")
      ######################################################
      #              (20002 )  Scenario Personal 0002
      #
      # <Personal Video logcat>
      #
      ######################################################
      echo "IN 20002"
      MM_LOG_FP="$LOG_DIR/$LOG_DT-platform_mm_mm_aow_an.sh_20002-mm.log"
      echo "MM_LOG_FP: $MM_LOG_FP"
      echo "Enable Personal Script 0002"
      logcat -G 256M
      setprop vendor.mtk.displink.bm.profile 1
      setprop vendor.mtk.c2.enable.comp.log 2
      setprop vendor.mtk.c2.enable.vdec.log 2
      setprop vendor.mtktv.c2.enable.vdec.log 2
      setprop vendor.mtktv.c2.enable.bm.log 2
      setprop vendor.mtk.codec2.log 2
      setprop vendor.mstar.vdec.log 2
      setprop vendor.mtk.vcodecvideo.log 2
      setprop vendor.mtk.vcodecvdecimpl.log 3
      setprop vendor.mtk.tpchwc.log 1
      setprop vendor.mtk.displink.log 1
      setprop vendor.mtk.displink.wrapper.log 1
      setprop vendor.mtk.pqlink.log 1
      setprop vendor.mtk.pqlink.performance.profile 1
      setprop vendor.mtk.debug.hwcomposer20 17
      setprop vendor.mtk.pqhal.debuglevel 5
      setprop vendor.hal.audio.log.level VERBOSE
      #C2 BWM
      setprop vendor.mtk.c2bwm.log 3
      #dispservice mediator
      setprop vendor.mtk.dispservice.mediator.info.log 1
      #DTV passthrough mode
      setprop vendor.mtk.tunerlink.log 2
      logcat -c
      logcat -v threadtime > $MM_LOG_FP&
    ;;
    "30001")
      ######################################################
      #              (30001 )  Scenario Customer Video
      #
      # <Video Decoder logcat>
      #
      ######################################################
      echo "IN 30001"
      MM_LOG_FP="$LOG_DIR/$LOG_DT-platform_mm_mm_aow_an.sh_30001-mm.log"
      echo "MM_LOG_FP: $MM_LOG_FP"
      echo "Enable Customer Video Decoder Debug Script"
      logcat -G 256M
      setprop vendor.mtk.c2.enable.comp.log 2
      setprop vendor.mtk.c2.enable.vdec.log 2
      setprop vendor.mtktv.c2.enable.vdec.log 2
      setprop vendor.mtktv.c2.enable.bm.log 2
      setprop vendor.mtk.vcodecvideo.log 2
      setprop vendor.mtk.vcodecvdecimpl.log 3
      echo 8 > /sys/module/mtk_vcodec_dec/parameters/mtk_v4l2_dbg_level
      setprop vendor.mtk.displink.log 1
      setprop vendor.mtk.tpchwc.log 1
      setprop vendor.mtk.pqlink.log 1
      setprop vendor.mtk.tpc.sync.log 1
      setprop vendor.mtk.tpc.debug.log 4
      #C2 BWM
      setprop vendor.mtk.c2bwm.log 3
      #dispservice mediator
      setprop vendor.mtk.dispservice.mediator.info.log 1
      #DTV passthrough mode
      setprop vendor.mtk.tunerlink.log 2
      logcat -c
      logcat -v threadtime > $MM_LOG_FP&
    ;;
    "30002")
      ######################################################
      #              ( 30002 )  Scenario Customer Video
      #
      # <Video Encoder logcat>
      #
      ######################################################
      echo "IN 30002"
      MM_LOG_FP="$LOG_DIR/$LOG_DT-platform_mm_mm_aow_an.sh_30002-mm.log"
      echo "MM_LOG_FP: $MM_LOG_FP"
      echo "Enable Customer Video Encoder Debug Script"
      logcat -G 256M
      setprop vendor.mtktv.c2.enable.venc.log 1
      #C2 BWM
      setprop vendor.mtk.c2bwm.log 3
      #dispservice mediator
      setprop vendor.mtk.dispservice.mediator.info.log 1
      #DTV passthrough mode
      setprop vendor.mtk.tunerlink.log 2
      logcat -c
      logcat -v threadtime > $MM_LOG_FP&
    ;;
    "30003")
      ######################################################
      #              ( 30003 )  Scenario Customer Video
      #
      # <Video Decoder+Encoder logcat>
      #
      ######################################################
      echo "IN 30003"
      MM_LOG_FP="$LOG_DIR/$LOG_DT-platform_mm_mm_aow_an.sh_30003-mm.log"
      echo "MM_LOG_FP: $MM_LOG_FP"
      echo "Enable Customer Video Decoder+Encoder Debug Script"
      logcat -G 256M
      setprop vendor.mtk.c2.enable.comp.log 2
      setprop vendor.mtk.c2.enable.vdec.log 2
      setprop vendor.mtktv.c2.enable.vdec.log 2
      setprop vendor.mtktv.c2.enable.bm.log 2
      setprop vendor.mtk.vcodecvideo.log 2
      setprop vendor.mtk.vcodecvdecimpl.log 3
      echo 8 > /sys/module/mtk_vcodec_dec/parameters/mtk_v4l2_dbg_level
      setprop vendor.mtk.displink.log 1
      setprop vendor.mtk.tpchwc.log 1
      setprop vendor.mtk.pqlink.log 1
      setprop vendor.mtk.tpc.sync.log 1
      setprop vendor.mtk.tpc.debug.log 4
      setprop vendor.mtktv.c2.enable.venc.log 1
      #C2 BWM
      setprop vendor.mtk.c2bwm.log 3
      #dispservice mediator
      setprop vendor.mtk.dispservice.mediator.info.log 1
      #DTV passthrough mode
      setprop vendor.mtk.tunerlink.log 2
      logcat -c
      logcat -v threadtime > $MM_LOG_FP&
    ;;
    "30004")
      ######################################################
      #              ( 30004 )  Scenario Customer Photo
      #
      # <Photo logcat>
      #
      ######################################################
      echo "IN 30004"
      MM_LOG_FP="$LOG_DIR/$LOG_DT-platform_mm_mm_aow_an.sh_30004-mm.log"
      echo "MM_LOG_FP: $MM_LOG_FP"
      echo "Enable Customer Photo Debug Script"
      logcat -G 256M
      setprop vendor.mtk.c2.enable.comp.log 2
      setprop vendor.mtk.c2.enable.vdec.log 2
      setprop vendor.mtktv.c2.enable.vdec.log 2
      setprop vendor.mtktv.c2.enable.bm.log 2
      setprop vendor.mtk.vcodecvideo.log 2
      setprop vendor.mtk.vcodecvdecimpl.log 3
      setprop vendor.mtk.vcodecimage.log 2
      #C2 BWM
      setprop vendor.mtk.c2bwm.log 3
      #dispservice mediator
      setprop vendor.mtk.dispservice.mediator.info.log 1
      #DTV passthrough mode
      setprop vendor.mtk.tunerlink.log 2
      echo 255 > /sys/module/mtk_v4l2_jpd/parameters/jpd_core_debug
      echo 255 > /sys/module/mtk_v4l2_jpd/parameters/platform_jpd_debug
      echo 255 > /sys/module/mtk_v4l2_jpd/parameters/jpd_api_debug
      setprop vendor.mtk.pqlink.log 1
      setprop vendor.mtk.mtkimagedecode.debug.log true
      logcat -c
      logcat -v threadtime > $MM_LOG_FP&
    ;;
    "30005")
      ######################################################
      #              ( 30005 )  Scenario Customer Photo + data dump
      #
      # <Photo logcat> + <Photo data dump>
      #
      ######################################################
      echo "IN 30005"
      MM_LOG_FP="$LOG_DIR/$LOG_DT-platform_mm_mm_aow_an.sh_30005-mm.log"
      echo "MM_LOG_FP: $MM_LOG_FP"
      echo "Enable Customer Photo Debug Script + data dump"
      logcat -G 256M
      setprop vendor.mtk.c2.enable.comp.log 2
      setprop vendor.mtk.c2.enable.vdec.log 2
      setprop vendor.mtktv.c2.enable.vdec.log 2
      setprop vendor.mtktv.c2.enable.bm.log 2
      setprop vendor.mtk.vcodecvideo.log 2
      setprop vendor.mtk.vcodecvdecimpl.log 3
      setprop vendor.mtk.vcodecimage.log 2
      #C2 BWM
      setprop vendor.mtk.c2bwm.log 3
      #dispservice mediator
      setprop vendor.mtk.dispservice.mediator.info.log 1
      #DTV passthrough mode
      setprop vendor.mtk.tunerlink.log 2
      #photo service dump
      setprop vendor.mtk.mtk_photoservice.dumpdata 1
      setprop persist.mtk.cap.dump_yc_img true
      echo 255 > /sys/module/mtk_v4l2_jpd/parameters/jpd_core_debug
      echo 255 > /sys/module/mtk_v4l2_jpd/parameters/platform_jpd_debug
      echo 255 > /sys/module/mtk_v4l2_jpd/parameters/jpd_api_debug
      setprop vendor.mtk.pqlink.log 1
      setprop vendor.mtk.mtkimagedecode.debug.log true
      setprop vendor.mtk.displink.log 1
      #DispLink render
      setprop vendor.mtk.displink.render.log 1
      setprop vendor.mtk-codec2.dump 63
      setprop vendor.mtk.capture_hal.loglevel A
      mount -o rw,remount /vendor
      mount -o rw,remount /
      mount -o remount /data
      rm -rf $DefaultMmOutputPath/dump
      mkdir -p $DefaultMmOutputPath/dump
      chmod 777 /data
      chmod 777 $DefaultMmOutputPath/dump
      logcat -c
      logcat -v threadtime > $MM_LOG_FP&
    ;;
    "39003")
      ######################################################
      #              ( 39003 )  Scenario AV SYNC
      #
      #  39003 : common log
      #  39003 1 : common log + pq kernel
      #
      ######################################################
      echo "IN 39003"

      echo "Enable MM log"
      logcat -G 256M

      #Exoplayer
      setprop mtk.exoplayer.debug.level 11

      #TPC
      setprop vendor.mtk.sharemem.debug.log 2
      setprop vendor.mtk.tpc.sync.log 1
      setprop vendor.mtk.tpc.debug.log 4

      #Render
      setprop vendor.mtk.mirender.debuglevel F0
      setprop vendor.mtk.mirender.debuginfo 417E0000

      #c2/HWC
      setprop vendor.mtk.displink.bm.profile 1
      setprop vendor.mtk.c2.enable.comp.log 2
      setprop vendor.mtk.c2.enable.vdec.log 2
      setprop vendor.mtktv.c2.enable.vdec.log 2
      setprop vendor.mtktv.c2.enable.tpcvideo.log 2
      setprop vendor.mtktv.c2.enable.bm.log 2
      setprop vendor.mtk.vcodecvdecimpl.log 3
      setprop vendor.mtk.vcodecvideo.log 3
      setprop vendor.mtk.tpchwc.log 1
      setprop vendor.mtk.displink.log 1
      setprop vendor.mtk.pqlink.log 1
      setprop vendor.mtk.pqlink.performance.profile 1
      #C2 BWM
      setprop vendor.mtk.c2bwm.log 3
      #dispservice mediator
      setprop vendor.mtk.dispservice.mediator.info.log 1
      #DTV passthrough mode
      setprop vendor.mtk.tunerlink.log 2

      #Audio
      setprop vendor.hal.audio.log.level VERBOSE
      cd $DefaultMmOutputPath/apaf/
      echo apaf_log_level=sync >D
      cd -

      if [ "$ARGV" = "1" ]; then
      echo "Add DISPLAY (PQ) LOG"
      #PQ kernel log
          echo 0 > /proc/sys/kernel/printk
          echo 0xdff > /sys/devices/platform/mtk-pq/mtk_dbg/log_level
          echo 0x006 > /sys/devices/platform/mtk-tvpqu/mtk_dbg/log_level
          setprop vendor.mtk.mipq.debuglevel F0
          setprop vendor.mtk.pqhal.debuglevel 5
      fi
    ;;
    "39010")
      ######################################################
      #  ( 39010 )  Scenario ABNORMAL_FUNC for Auto Log V2
      #
      #  39010 : <Video Decoder> + <Video Encoder> + <Photo logcat> + <Photo data dump>
      #  + <AV sync> + <pq kernel>
      #
      ######################################################
      echo "IN 39010"

      echo "Enable MM log"
      logcat -G 256M

      #Encoder
      setprop vendor.mtktv.c2.enable.venc.log 1

      #Exoplayer
      setprop mtk.exoplayer.debug.level 11

      #TPC
      setprop vendor.mtk.sharemem.debug.log 2
      setprop vendor.mtk.tpc.debug.log 4

      #Render
      setprop vendor.mtk.mirender.debuglevel F0
      setprop vendor.mtk.mirender.debuginfo 417E0000

      #c2/HWC
      setprop vendor.mtk.displink.bm.profile 1
      setprop vendor.mtk.c2.enable.comp.log 2
      setprop vendor.mtk.c2.enable.vdec.log 2
      setprop vendor.mtktv.c2.enable.vdec.log 2
      setprop vendor.mtktv.c2.enable.tpcvideo.log 2
      setprop vendor.mtktv.c2.enable.bm.log 2
      setprop vendor.mtk.vcodecimage.log 2
      setprop vendor.mtk.vcodecvdecimpl.log 3
      setprop vendor.mtk.vcodecvideo.log 3
      setprop vendor.mtk.tpchwc.log 1
      setprop vendor.mtk.displink.log 1
      setprop vendor.mtk.pqlink.log 1
      setprop vendor.mtk.pqlink.performance.profile 1
      setprop vendor.mtk.codec2.log 2
      setprop vendor.mstar.vdec.log 2
      setprop vendor.mtk.displink.wrapper.log 1
      #C2 BWM
      setprop vendor.mtk.c2bwm.log 3
      #dispservice mediator
      setprop vendor.mtk.dispservice.mediator.info.log 1
      #DTV passthrough mode
      setprop vendor.mtk.tunerlink.log 2
      #VDEC default log
      echo 9 > /sys/module/mtk_vcu_vdec/parameters/mtk_vcu_wrap
      echo 7 > /sys/module/mtk_vcu_vdec/parameters/comhal_debug
      echo 0x24F > /sys/module/mtk_vcu_vdec/parameters/u4LogLevel
      echo 5 > /sys/module/mtk_vcu_vdec/parameters/mtk_vcu_vdec_debug
      echo 7 > /sys/module/mtk_vcodec_dec/parameters/mtk_v4l2_dbg_level
      #DTV passthrough mode
      echo 255 > /sys/module/mtk_v4l2_jpd/parameters/jpd_core_debug
      echo 255 > /sys/module/mtk_v4l2_jpd/parameters/platform_jpd_debug
      echo 255 > /sys/module/mtk_v4l2_jpd/parameters/jpd_api_debug
      setprop vendor.mtk.mtkimagedecode.debug.log true

      #Audio
      setprop vendor.hal.audio.log.level VERBOSE
      cd $DefaultMmOutputPath/apaf/
      echo apaf_log_level=sync >D
      cd -

      echo "Add DISPLAY (PQ) LOG"
      #PQ kernel log
      echo 0 > /proc/sys/kernel/printk
      echo 0xdff > /sys/devices/platform/mtk-pq/mtk_dbg/log_level
      echo 0x006 > /sys/devices/platform/mtk-tvpqu/mtk_dbg/log_level
      setprop vendor.mtk.mipq.debuglevel F0
      setprop vendor.mtk.pqhal.debuglevel 5
      setprop vendor.mtk.tpc.runtime.syncmode.enable 1


    ;;
    "39011")
      ######################################################
      #              ( 39011 )  Scenario for disp lshal dump in bugreport.sh
      #
      # <lshal dump>
      #
      ######################################################
      echo "IN 39011"
      INIT_BSP_DISP_DUMP 60002 "$ARGV"
    ;;
    "39012")
      ######################################################
      #  ( 39012 )  Scenario ABNORMAL_PERF for Auto Log V2
      #
      #  39012 : special setting for performance issue (stress test)
      #
      ######################################################
      echo "IN 39012"

      echo "Enable MM log"
      logcat -G 256M

      #Render
      setprop vendor.mtk.mirender.debuglevel F0
      setprop vendor.mtk.mirender.debuginfo 417E0000

      #c2/HWC
      setprop vendor.mtk.displink.bm.profile 1
      setprop vendor.mtk.c2.enable.comp.log 2
      setprop vendor.mtk.c2.enable.vdec.log 2
      setprop vendor.mtktv.c2.enable.vdec.log 2
      setprop vendor.mtktv.c2.enable.tpcvideo.log 2
      setprop vendor.mtktv.c2.enable.bm.log 2
      setprop vendor.mtk.vcodecimage.log 2
      setprop vendor.mtk.vcodecvdecimpl.log 3
      setprop vendor.mtk.vcodecvideo.log 3
      setprop vendor.mtk.tpchwc.log 1
      setprop vendor.mtk.displink.log 1
      setprop vendor.mtk.pqlink.log 1
      setprop vendor.mtk.pqlink.performance.profile 1
    ;;
    "39999")
      ######################################################
      #              ( 39999 )  Scenario Customer All
      #
      # <Video Decoder> + <Video Encoder> + <Photo logcat> + <Photo data dump>
      #
      ######################################################
      echo "IN 39999"
      echo "Enable Customer Debug Script"
      logcat -G 256M
      setprop vendor.mtktv.c2.enable.venc.log 1
      setprop vendor.mtk.c2.enable.comp.log 2
      setprop vendor.mtk.c2.enable.vdec.log 2
      setprop vendor.mtktv.c2.enable.vdec.log 2
      setprop vendor.mtktv.c2.enable.bm.log 2
      setprop vendor.mtk.vcodecvideo.log 2
      setprop vendor.mtk.vcodecvdecimpl.log 3
      setprop vendor.mtk.vcodecimage.log 2
      #C2 BWM
      setprop vendor.mtk.c2bwm.log 3
      #dispservice mediator
      setprop vendor.mtk.dispservice.mediator.info.log 1
      #DTV passthrough mode
      setprop vendor.mtk.tunerlink.log 2
      echo 8 > /sys/module/mtk_vcodec_dec/parameters/mtk_v4l2_dbg_level
      setprop vendor.mtk.displink.log 1
      setprop vendor.mtk.tpchwc.log 1
      echo 255 > /sys/module/mtk_v4l2_jpd/parameters/jpd_core_debug
      echo 255 > /sys/module/mtk_v4l2_jpd/parameters/platform_jpd_debug
      echo 255 > /sys/module/mtk_v4l2_jpd/parameters/jpd_api_debug
      setprop vendor.mtk.pqlink.log 1
      setprop vendor.mtk.tpc.sync.log 1
      setprop vendor.mtk.tpc.debug.log 4
      setprop vendor.mtk.mtkimagedecode.debug.log true
      setprop vendor.mtk-codec2.dump 63
    ;;

    *)
      ######################################################
      #              ( * )  Scenario not defined
      #
      ######################################################
      echo "SCENARIO_NUM='$SCENARIO_NUM' is not defined in mm.sh, please check or contact related RD"
      exit 1
    ;;
  esac

#  set +e
  echo -e "Init Platform MM MM log Success!\n"
}


CLOSE_PLATFORM_MM_MM()
{
  if [ "$SCENARIO_NUM" = "10101" ]; then
  setprop vendor.mtk.force.panel.timing.fhd 0
  setprop vendor.mtk-codec2.dump 0
  mv -f $ES_FRAME_DUMP_DIR/*.dump $LOG_DIR
  fi

  if [ "$SCENARIO_NUM" = "10201" ] || [ "$SCENARIO_NUM" = "30005" ]; then
      mv -f $DefaultMmOutputPath/dump/* $LOG_DIR
      mv -f $DefaultMmOutputPath/image/* $LOG_DIR
  fi

  cp /data/anr/* $LOG_DIR/
  sync
  sync
  kill `pidof logcat`
  kill `pidof cat`
  echo "Disable MM log "
  sync
  sync

#  set -e
  #TODO
  CLOSE_BSP_VIDEO_VIDEO
  #CLOSE_BSP_DISP_DISP
  echo 0x0 > /sys/devices/platform/mtk-pq/mtk_dbg/log_level
  echo 0x0 > /sys/module/drm/parameters/debug
  echo 0x0 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/log_level
#  set +e

  #Close DRM WV Log
  if [ "$ARGV" = "wv" ]; then
  CLOSE_PLATFORM_SECURITY_WIDEVINE
  fi

  echo -e "Close Platform MM MM log Success!\n"
}


question1()
{
  local OUTPUT_FP="$1"
  message="${COLOR_RED} Please describe your question here [Y/N]? ${COLOR_REST}"
  ### This will call prompt function from utils/helpers.sh
  ### prompt(message, log_file_path)
  ###   => Use read command to ask user questions, and record it into log_file_path
  bug=$(prompt "$message" "$OUTPUT_FP")
  echo "$bug"  # Return answer
}


question2()
{
  local OUTPUT_FP="$1"
  message="${COLOR_RED} You can ask more when answer from question1 is 'y' [Y/N]? ${COLOR_REST}"
  bug=$(prompt "$message" "$OUTPUT_FP")
  echo "$bug" # Return answer
}


MAIN()
{
  PID=$$
  version="v1.0"
  #========================================================
  #                 Pre-process functions
  #                  (Don't remove this)
  #========================================================
  echo "=========== (PID=$PID) from $0 ============="
  . "$AUTOLOG_HOME/utils/preprocess.sh"

  #========================================================
  #                       Arguments
  # Defined in utils/preprocess.sh
  #   $LOG_FP     => output log file path
  #   $ACT_LOG_FP => interactive log output file path
  #   $LOG_DIR    => output directory of log
  #   $LOG_DT     => datetime from log file name
  #   $SCENARIO_NUM => scenario number
  #
  # The number of arguments for this script are not limited.
  # You can use $n to add & declare the argument you need
  #   $module_arg<n> = Arguments passed from main script
  #========================================================
  #all these args are given from autolog.sh
  MODULE_ARG1=$1
  MODULE_ARG2=$2
  MODULE_ARG3=$3
  ES_FRAME_DUMP_DIR="$DefaultMmOutputPath/dump"

  echo "LOG_FP=$LOG_FP"
  echo "ACT_LOG_FP=$ACT_LOG_FP"
  #LOG_DIR=$2
  echo "LOG_DIR=$LOG_DIR"
  echo "LOG_DT=$LOG_DT"

  echo "SCENARIO_NUM=$SCENARIO_NUM"
  echo "MODULE_ARG1=$MODULE_ARG1"
  echo "MODULE_ARG2=$MODULE_ARG2"
  echo "MODULE_ARG3=$MODULE_ARG3"

  #========================================================
  #                   Main codes here
  # You can modify codes under this section
  #========================================================

  ### Import functions from other modules/scripts
  ### DO SOMETHING
  OpenCommandDebuger $INIT_HISTORY_FP
  INIT_PLATFORM_MM_MM $SCENARIO_NUM $MODULE_ARG1 $MODULE_ARG2

  Wait_finish

  CloseCommandDebuger
  PrintCommandDebuger $INIT_HISTORY_FP

  PrintCpuMemUsage "$ACT_LOG_FP"


  ################################
  ### Demo interactive flow
  #echo "-------- Interactive demo --------"
  ### Questions flow control
  #rst1=$(question1 $ACT_LOG_FP)
  #if [ "$rst1" = "Y" ] || [ "$rst1" = "y" ]; then
  #  rst2=$(question2 $ACT_LOG_FP)
  #fi

  ################################
  ### CLOSE LOGs
  PrintCpuMemUsage "$ACT_LOG_FP"
  CLOSE_PLATFORM_MM_MM

  echo
  echo "================================"
  ################## ENDs HERE ##################
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
