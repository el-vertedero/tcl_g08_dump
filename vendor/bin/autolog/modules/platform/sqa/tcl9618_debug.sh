#!/bin/sh

ROOTDIR=""
MODE=""
LOGDIR="tcl9618_log"
DTV_OUTPUT_BASE_DIR=""
DTV_MM_DISPLAY_SHELL="/vendor/bin/autolog/modules/platform/sqa/tcl9618_display.sh"
HDMI_DISPLAY_SHELL="/vendor/bin/autolog/modules/platform/sqa/tcl9618_display.sh"
ATV_DISPLAY_SHELL="/vendor/bin/autolog/modules/platform/sqa/tcl9618_display.sh"
AUDIO_SHELL="/vendor/bin/autolog/modules/platform/sqa/tcl9618_audio.sh"
MEIDA_SHELL="/vendor/bin/autolog/modules/platform/sqa/tcl9618_media.sh"
PHOTO_SHELL="/vendor/bin/autolog/modules/platform/sqa/tcl9618_photo.sh"
#DTV_MM_DISPLAY_SHELL="./tcl9618_display.sh"


INIT_DEBUG_COMMON()
{
  case "$MODE" in
    "1")
      echo "MM/DTV Display Mode"
      $DTV_MM_DISPLAY_SHELL $ROOTDIR $MODE
      #disp_log_open
      #INIT_BSP_VIDEO_VIDEO 20001
    ;;
    "2")
      echo "HDMI_Diplay Mode"
      $HDMI_DISPLAY_SHELL $ROOTDIR $MODE
    ;;
    "3")
      echo "ATV_Diplay Mode"
      $ATV_DISPLAY_SHELL $ROOTDIR $MODE
    ;;
    "4")
      echo "Audio Mode"
      $AUDIO_SHELL $ROOTDIR
    ;;
    "5")
      echo "Media Mode"
      $MEIDA_SHELL $ROOTDIR
    ;;
    "6")
      echo "Photo Mode"
      $PHOTO_SHELL $ROOTDIR
    ;;
  esac
  #echo -e "Debug Init log Success!\n"
}

MAIN()
{
   module_arg1=$1
   module_arg2=$2
   module_arg3=$3
   if [ "$module_arg1" == "" ]; then
    echo -e "open debug fail,please set save path."
    echo -e "For example:"
    echo -e "./tcl9618_debug.sh /mnt/media_rw/storagename"
    echo -e "storagename is your usb storage name."
   exit 0
   fi
   ROOTDIR=$module_arg1
   echo "1:DTV_MM_Diplay Issue Mode"
   echo "2:HDMI_Diplay Issue Mode"
   echo "3:ATV_Diplay Issue Mode"
   echo "4:Audio Issue Mode"
   echo "5:Media Issue Mode"
   echo "6:Photo Issue Mode"   
   #wait issure reproduce
   while :
   do
    echo "Please select your test mode:"
    read -r -t 30 rst1
    if [ "${rst1}" == "1" ] || [ "${rst1}" == "2" ] || [ "${rst1}" == "3" ] || [ "${rst1}" == "4" ] || [ "${rst1}" == "5" ] || [ "${rst1}" == "6" ]; then
    MODE=${rst1}
    echo -e "You select Mode$MODE"
    INIT_DEBUG_COMMON $ROOTDIR
    break
    else
    echo -e "Your mode $rst1 is wrong.It is only 1~6."
    break
    fi
   done
}

if [ "$*" = "--source-only" ]; then
  :
else
  MAIN $*
fi
