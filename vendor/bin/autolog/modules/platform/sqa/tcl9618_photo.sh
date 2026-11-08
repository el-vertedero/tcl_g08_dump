#!/bin/sh

ROOTDIR=""
LOGDIR="tcl9618_log"
PHOTO_OUTPUT_BASE_DIR=""
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
  echo -e "please set save path,for example: ./tcl9618_photo.sh /mnt/media_rw/storagename"
  exit 0
  fi
  ROOTDIR=$module_arg1
  PHOTO_OUTPUT_BASE_DIR=$module_arg1/$LOGDIR/photo
  echo -e "PHOTO_OUTPUT_BASE_DIR=$PHOTO_OUTPUT_BASE_DIR"

  # Open log
  echo -e "Open autolog for photo\n"
  #su
  rm -rf $PHOTO_OUTPUT_BASE_DIR
  mkdir $ROOTDIR/$LOGDIR
  mkdir $ROOTDIR/$LOGDIR/photo
  sh /vendor/bin/autolog/autolog.sh debug.sh mmp photo -o=$PHOTO_OUTPUT_BASE_DIR
  

  #wait issure reproduce
  while :
  do
    echo "Is finished photo reproduce, key in [Y/y] to continue:"
    read -r -t 30 rst1
    if [ "${rst1}" == "Y" ] || [ "${rst1}" == "y" ]; then
    
    break
    fi
  done
  echo -e "dumping information,please wait 10S!!!"
  sleep 10
  cp /data/vendor/tmp/dump $PHOTO_OUTPUT_BASE_DIR
  sync
  echo -e "finished dump,Please Copy $PHOTO_OUTPUT_BASE_DIR"
}


if [ "$*" = "--source-only" ]; then
  :
else
  MAIN $*
fi
