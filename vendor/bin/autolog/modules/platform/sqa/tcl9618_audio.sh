#!/bin/sh

ROOTDIR=""
LOGDIR="tcl9618_log"
AUDIO_OUTPUT_BASE_DIR=""
TAG_VER="Test_tag_infor.txt"
AUDIO_INFOR_FILE="audio_dump_information.txt"

MAIN()
{

  ### Arguments
  # $log_fp => output log file path
  # $act_log_fp => interactive log output file path
  module_arg1=$1
  module_arg2=$2
  module_arg3=$3
  
  if [ "$module_arg1" == "" ]; then
  echo -e "please set save path,for example: ./tcl9618_audio.sh /mnt/media_rw/storagename"
  exit 0
  fi
  ROOTDIR=$module_arg1
  AUDIO_OUTPUT_BASE_DIR=$module_arg1/$LOGDIR/audio
  echo -e "AUDIO_OUTPUT_BASE_DIR=$AUDIO_OUTPUT_BASE_DIR"
  # Open log
  echo -e "Open autolog for audio\n"
  #su

  rm -rf $AUDIO_OUTPUT_BASE_DIR
  mkdir $ROOTDIR/$LOGDIR
  mkdir $ROOTDIR/$LOGDIR/audio
  #wait select audio source
  while :
  do
    echo "Please select audio source:1(Media)2(DTV/HDMI)"
    read -r -t 30 rst1
    if [ "${rst1}" == "1" ]; then
    echo "enable dsp for mediao source"
    echo dump_r2_log_start=0 9E=0x17 PATH=1 8A=0x0> /sys/devices/platform/mtk-tv-offload-platform/mtk_dbg/utopia_mdb
    fi
    if [ "${rst1}" == "2" ]; then
    echo "enable dsp for dtv/hdmi source"
    echo dump_r2_log_start=0 9E=0x16 PATH=1 8A=0x0> /sys/devices/platform/mtk-tv-offload-platform/mtk_dbg/utopia_mdb
    fi
    break
  done
  getprop|grep -i ro.vendor.mtk.pkg_version >> $AUDIO_OUTPUT_BASE_DIR/$TAG_VER
  # autolog for audio
  sh /vendor/bin/autolog/autolog.sh bsp audio audio_aow.sh 10000 -o=$AUDIO_OUTPUT_BASE_DIR
  #dmesg -C; dmesg -w > $AUDIO_OUTPUT_BASE_DIR/dmesg.log &
  #DMESG_PID=$!

  #wait issure reproduce
  while :
  do
    echo "Is finished audio reproduce, key in [Y/y] to continue:"
    read -r -t 30 rst1
    if [ "${rst1}" == "Y" ] || [ "${rst1}" == "y" ]; then
    echo "Dump audio Information"
    #  stop dsp
    echo dump_r2_log_stop=0 > /sys/devices/platform/mtk-tv-offload-platform/mtk_dbg/utopia_mdb
    #kill $DMESG_PID
    cp /data/AudioDECR2_*.log $AUDIO_OUTPUT_BASE_DIR
    echo "### HDMI audio###" >> $AUDIO_OUTPUT_BASE_DIR/$AUDIO_INFOR_FILE
    cat /sys/devices/platform/mtk_srccap0/mtk_dbg/hdmirx/audio_fs >> $AUDIO_OUTPUT_BASE_DIR/$AUDIO_INFOR_FILE
    cat /sys/devices/platform/mtk_srccap0/mtk_dbg/hdmirx/audio_fs >> $AUDIO_OUTPUT_BASE_DIR/$AUDIO_INFOR_FILE
    cat /sys/devices/platform/mtk_srccap0/mtk_dbg/hdmirx/audio_fs >> $AUDIO_OUTPUT_BASE_DIR/$AUDIO_INFOR_FILE
    break
    fi
  done
  sync
  echo -e "Please Copy $AUDIO_OUTPUT_BASE_DIR"
}


if [ "$*" = "--source-only" ]; then
  :
else
  MAIN $*
fi
