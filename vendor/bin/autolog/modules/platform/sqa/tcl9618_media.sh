#!/bin/sh

ROOTDIR=""
LOGDIR="tcl9618_log"
CSI_OUTPUT_BASE_DIR=""
CSI_OUTPUT_FILE="log_media.log"
TAG_VER="Test_tag_infor.txt"

MAIN()
{

  ### Arguments
  # $log_fp => output log file path
  # $act_log_fp => interactive log output file path
  module_arg1=$1
  module_arg2=$2
  module_arg3=$3
  if [ "$module_arg1" == "" ]; then
  echo -e "please set save path,for example: ./tcl9618_media.sh /mnt/media_rw/storagename"
  exit 0
  fi
  ROOTDIR=$module_arg1
  CSI_OUTPUT_BASE_DIR=$module_arg1/$LOGDIR/media
  echo -e "CSI_OUTPUT_BASE_DIR=$CSI_OUTPUT_BASE_DIR"

  # Open log
  echo -e "Open autolog for MediaCdec\n"
  #su
  rm -rf $CSI_OUTPUT_BASE_DIR
  mkdir $ROOTDIR/$LOGDIR
  mkdir $ROOTDIR/$LOGDIR/media
  getprop|grep -i ro.vendor.mtk.pkg_version >> $CSI_OUTPUT_BASE_DIR/$TAG_VER
  logcat -G 256M
  setprop mtk.exoplayer.debug.level 11
  setprop vendor.mtk.displink.bm.profile 1
  setprop vendor.mtk.c2.enable.comp.log 2
  setprop vendor.mtk.c2.enable.vdec.log 2
  setprop vendor.mtktv.c2.enable.vdec.log 2
  setprop vendor.mtktv.c2.enable.bm.log 2
  setprop vendor.mtk.vcodecvideo.log 2
  setprop vendor.mtk.vcodecvdecimpl.log 3
  #echo 8 > /sys/module/mtk_vcodec_dec/parameters/mtk_v4l2_dbg_level
  #setprop vendor.mtk.mi.video.log 80
  #setprop vendor.mtk.mi.vdec.log 80
  setprop vendor.mtk.tpchwc.log 1
  #setprop vendor.mtk.tpc.debug.log 4
  #setprop vendor.mtktv.c2.enable.tpcvideo.log 2
  #setprop vendor.mtk.sharemem.debug.log 3
  setprop vendor.mtk.displink.log 1
  setprop vendor.mtk.displink.wrapper.log 1
  setprop vendor.mtk.debug.hwcomposer20 17
  setprop vendor.mtk.pqlink.setwin.info 1
  setprop vendor.mtk.pqlink.performance.profile 1
  setprop log.tag.audio_hw_primary V
  setprop vendor.hal.audio.log.level VERBOSE
  setprop vendor.mtk.pqlink.log 1
  #setprop vendor.mtk.pqhal.debuglevel 5
  #setprop vendor.mtk.mipq.debuglevel 40
  setprop vendor.mtk.c2bwm.log 3
  setprop vendor.mtk.dispservice.mediator.info.log 1
  #mount -o remount /data
  logcat -v threadtime -f $CSI_OUTPUT_BASE_DIR/$CSI_OUTPUT_FILE &
  LOGCAT_PID=$!

	#wait issure reproduce
  while :
  do
    echo "Is finished MediaCdec reproduce, key in [Y/y] to continue:"
    read -r -t 30 rst1
    if [ "${rst1}" == "Y" ] || [ "${rst1}" == "y" ]; then
    kill $LOGCAT_PID
    break
    fi
  done
  sync
  echo -e "Please Copy $CSI_OUTPUT_BASE_DIR"
}


if [ "$*" = "--source-only" ]; then
  :
else
  MAIN $*
fi
