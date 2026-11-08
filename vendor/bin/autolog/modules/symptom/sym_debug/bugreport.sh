#!/usr/bin/env sh
#set -x
source "$AUTOLOG_HOME/utils/imports.sh"
ImportUtil "loggers.sh"
ImportUtil "colors.sh"
ImportUtil "sys.sh"
Import platform bluetooth bluetooth_android.sh
Import platform cec cec.sh

export DOMAIN_DUMP_LOG_DIR
export DOMAIN_SYSTEM_DUMP_LOG_DIR
export DOMAIN_DISPLAY_DUMP_LOG_DIR
export DOMAIN_AUDIO_DUMP_LOG_DIR
export DOMAIN_MULTIMEDIA_DUMP_LOG_DIR
export DOMAIN_BROADCAST_DUMP_LOG_DIR
export DOMAIN_NETWORK_DUMP_LOG_DIR
export DOMAIN_ANDROID_DUMP_LOG_DIR
export DOMAIN_CAMERA_DUMP_LOG_DIR

#========================================================
#          Import modules functions you need
# if you want to call modules/bsp/audio/audio.sh
#                  =>  Import bsp audio audio.sh
#========================================================
DO_FOLDER_CREATE()
{
  DOMAIN_DUMP_LOG_DIR=$AUTOLOG_LOG_DIR/dump
  mkdir $DOMAIN_DUMP_LOG_DIR

  DOMAIN_SYSTEM_DUMP_LOG_DIR=$DOMAIN_DUMP_LOG_DIR/system
  mkdir $DOMAIN_SYSTEM_DUMP_LOG_DIR

  DOMAIN_DISPLAY_DUMP_LOG_DIR=$DOMAIN_DUMP_LOG_DIR/display
  mkdir $DOMAIN_DISPLAY_DUMP_LOG_DIR

  DOMAIN_AUDIO_DUMP_LOG_DIR=$DOMAIN_DUMP_LOG_DIR/audio
  mkdir $DOMAIN_AUDIO_DUMP_LOG_DIR

  DOMAIN_MULTIMEDIA_DUMP_LOG_DIR=$DOMAIN_DUMP_LOG_DIR/multimedia
  mkdir $DOMAIN_MULTIMEDIA_DUMP_LOG_DIR

  DOMAIN_BROADCAST_DUMP_LOG_DIR=$DOMAIN_DUMP_LOG_DIR/broadcast
  mkdir $DOMAIN_BROADCAST_DUMP_LOG_DIR

  DOMAIN_NETWORK_DUMP_LOG_DIR=$DOMAIN_DUMP_LOG_DIR/network
  mkdir $DOMAIN_NETWORK_DUMP_LOG_DIR

  DOMAIN_ANDROID_DUMP_LOG_DIR=$DOMAIN_DUMP_LOG_DIR/android
  mkdir $DOMAIN_ANDROID_DUMP_LOG_DIR

  DOMAIN_CAMERA_DUMP_LOG_DIR=$DOMAIN_DUMP_LOG_DIR/camera
  mkdir $DOMAIN_CAMERA_DUMP_LOG_DIR

  DOMAIN_STRESS_DUMP_LOG_DIR=$DOMAIN_DUMP_LOG_DIR/stress
  mkdir $DOMAIN_STRESS_DUMP_LOG_DIR

}

DO_ANR()
{
  echo -e "${COLOR_GREEN}[AUTOLOG] Get ANR report. ${COLOR_REST}\n"
  ANR_LOG_PATH="/data/anr"
  cp -rf $ANR_LOG_PATH $DOMAIN_ANDROID_DUMP_LOG_DIR
  echo -e "${COLOR_GREEN}[AUTOLOG] Get ANR report done. ${COLOR_REST}\n"
}

DO_ANDROID_BUGREPORT()
{
  #echo "IN DO_ANDROID_BUGREPORT"
  echo -e "${COLOR_GREEN}[AUTOLOG] Doing android bugreport.${COLOR_REST}\n"
  AN_BUGREPORTZ_PATH="/data/user_de/0/com.android.shell/files/bugreports"
  if [ -d $AN_BUGREPORTZ_PATH ]; then
      rm -rf $AN_BUGREPORTZ_PATH
  fi
  bugreportz -p
  if [ $CHANGE_OUTPUT_DIR == true ]; then
      if [ ! -d $AUTOLOG_LOG_DIR ]; then
        mkdir -p $AUTOLOG_LOG_DIR
      fi
      AN_BUGREPORTZ_LOG_DIR=$AUTOLOG_LOG_DIR/../$LOG_DT/debug/dump/android
  else
      AN_BUGREPORTZ_LOG_DIR=$DOMAIN_ANDROID_DUMP_LOG_DIR
  fi
  source_file=$AN_BUGREPORTZ_PATH/*
  target_file=$AN_BUGREPORTZ_LOG_DIR
  echo "${COLOR_GREEN}[AUTOLOG] move $source_file to $target_file [start]${COLOR_REST}"
  mv $source_file $target_file
  echo "${COLOR_GREEN}[AUTOLOG] move $source_file to $target_file [end]${COLOR_REST}"
  echo -e "${COLOR_GREEN}[AUTOLOG] Did android bugreport successfully!${COLOR_REST}\n"
}

DO_SYMPTOM_BUGREPORT()
{
  #echo "IN DO_SYMPTOM_BUGREPORT"
  echo -e "${COLOR_GREEN}[AUTOLOG] Doing symptom bugreport.${COLOR_REST}\n"
  sh $AUTOLOG_MODULES_DIR/symptom/sym_debug/bugreport_common_aow.sh $LOG_DIR $LOG_DT
  echo -e "${COLOR_GREEN}[AUTOLOG] Did symptom bugreport successfully!${COLOR_REST}\n"
}

DO_BLUETOOTH_REPORT()
{
    BLUETOOTH_EN_LOG=$AUTOLOG_LOG_DEFAULT_TEMP_DIR/bluetooth_en_log
    if [ -f $BLUETOOTH_EN_LOG ]; then
        PROCFS_PLATFORM_BLUETOOTH_BLUETOOTH_ANDROID_DUMP
        rm $BLUETOOTH_EN_LOG
    fi
}

DO_CAMERA_BUGREPORT()
{
    CAMERA_END_STATUS_FP="$LOG_DIR/$LOG_DT-camera_end_status.log"
    echo "CAMERA_END_STATUS_FP: $CAMERA_END_STATUS_FP"
    ls /dev/video* -l >> $CAMERA_END_STATUS_FP
    ps -A | grep camera >> $CAMERA_END_STATUS_FP
    ls /vendor/lib/vendor.mediatek.camera.* >> $CAMERA_END_STATUS_FP
    ls /vendor/bin/hw/vendor.mediatek.hardware.camera.provider@2.4-external-service >> $CAMERA_END_STATUS_FP
    dumpsys media.camera -v2 >> $CAMERA_END_STATUS_FP
}

DO_BROADCAST_BUGREPORT()
{
    echo "[AUTOLOG][Broadcast log dump] Starting ..."
    DUMP_INFO="${DOMAIN_BROADCAST_DUMP_LOG_DIR}/apk_dump.log"
    SURFACE_DUMP_CMD="dumpsys SurfaceFlinger"
    TVINPUT_DUMP_CMD="dumpsys tv_input"
    INPUT_DUMP_CMD="dumpsys input"
    TV_DB_FILE="/data/data/com.android.providers.tv/databases/tv.db"
    AGENT_DB_FILE="/data/user_de/0/com.mediatek.tv.agent/"
    PS_DUMP="ps -ef"
    PROP_DUMP="getprop"
    TV_MEM_DUMP="dumpsys meminfo com.mediatek.tv.oneworld.tvcenter"
    WIZARD_MEM_DUMP="dumpsys meminfo com.mediatek.tv.oneworld.wizardkt"
    echo "$PS_DUMP>>>>>>>>>>>>>>>>>>>>>>" > $DUMP_INFO
    $PS_DUMP >> $DUMP_INFO
    echo "$PROP_DUMP>>>>>>>>>>>>>>>>>>>" >> $DUMP_INFO
    $PROP_DUMP >> $DUMP_INFO
    echo "$SURFACE_DUMP_CMD>>>>>>>>>>>>>>>>>>>>>>" >> $DUMP_INFO
    $SURFACE_DUMP_CMD >> $DUMP_INFO
    echo "$TVINPUT_DUMP_CMD>>>>>>>>>>>>>>>>>>>>>>" >> $DUMP_INFO
    $TVINPUT_DUMP_CMD >> $DUMP_INFO
    echo "$INPUT_DUMP_CMD>>>>>>>>>>>>>>>>>>>>>>" >> $DUMP_INFO
    $INPUT_DUMP_CMD >> $DUMP_INFO
    echo "$TV_MEM_DUMP>>>>>>>>>>>>>>>>>>>>>>" >> $DUMP_INFO
    $TV_MEM_DUMP >> $DUMP_INFO
    echo "$WIZARD_MEM_DUMP>>>>>>>>>>>>>>>>>>>>>>" >> $DUMP_INFO
    $WIZARD_MEM_DUMP >> $DUMP_INFO
    cp $TV_DB_FILE $DOMAIN_BROADCAST_DUMP_LOG_DIR && cp -rf $AGENT_DB_FILE $DOMAIN_BROADCAST_DUMP_LOG_DIR
    rm /data/tkui.print
    rm /data/mtk_dt_log
    sync
    echo "[AUTOLOG][Broadcast log dump] End"
}

DO_MMP_BUGREPORT()
{
    sh $AUTOLOG_MODULES_DIR/platform/mm/mm_aow_an.sh 39011 $DOMAIN_DISPLAY_DUMP_LOG_DIR&
}

DO_EXTIN_LSHAL_BUGREPORT()
{
    echo -e "${COLOR_GREEN}[AUTOLOG] Doing extin lshal bugreport.${COLOR_REST}\n"
    if [ "$ANDROID_VERSION" -ge 14 ]; then
      dumpsys vendor.mediatek.hardware.ExternIn.IExternIn/default >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/lshal_Extin.log&
    else
      lshal debug vendor.mediatek.hardware.ExternIn@1.0::IExternIn/ExternIn >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/lshal_Extin.log&
    fi
}

DO_EXTIN_SYSFS_BUGREPORT()
{
    FILE_APPENDIX="$1"

    cat /sys/devices/platform/mtk_srccap0/mtk_dbg/hdmirx/ALL_INFO >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_Extin_$FILE_APPENDIX.log&
    sleep 1
    cat /sys/devices/platform/mtk_srccap0/mtk_dbg/hdmirx/HDMI_INFO >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_Extin_$FILE_APPENDIX.log&
    sleep 1
    cat /sys/devices/platform/mtk_srccap0/mtk_dbg/hdmirx/TIMING_DETECT >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_Extin_$FILE_APPENDIX.log&
    sleep 1
    cat /sys/devices/platform/mtk_srccap0/mtk_dbg/hdmirx/0/dmesg >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_Extin_$FILE_APPENDIX.log&
    sleep 1
    cat /sys/devices/platform/mtk_srccap0/mtk_dbg/hdmirx/1/dmesg >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_Extin_$FILE_APPENDIX.log&
    sleep 1
    cat /sys/devices/platform/mtk_srccap0/mtk_dbg/hdmirx/2/dmesg >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_Extin_$FILE_APPENDIX.log&
    sleep 1
    cat /sys/devices/platform/mtk_srccap0/mtk_dbg/hdmirx/3/dmesg >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_Extin_$FILE_APPENDIX.log&
    sleep 1
    echo "======= SRCCAP0 =======" >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_srccap.log&
    cat /sys/devices/platform/mtk_srccap0/mtk_dbg/srccap_report_info >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_Extin_$FILE_APPENDIX.log&
    sleep 1
    echo "======= SRCCAP1 =======" >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_srccap.log&
    cat /sys/devices/platform/mtk_srccap1/mtk_dbg/srccap_report_info >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_Extin_$FILE_APPENDIX.log&
    sleep 1
}

DO_RENDER_SYSFS_BUGREPORT()
{
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/frame_sync_status >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_Render.log&
    sleep 1
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_mode_ID_Sel >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_Render.log&
    sleep 1
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_mod_status >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_Render.log&
    sleep 1
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_out_model >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_Render.log&
    sleep 1
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/path_frc >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_Render.log&
    sleep 1
    cat /sys/devices/platform/mediatek-drm-tv-kms/video_display/debug_info >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_Render.log&
    sleep 1
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/mtk_drm_debug_GOP >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_Render.log&
    sleep 1
}

DO_PANEL_SYSFS_BUGREPORT()
{
    PANEL_SYSFS_BUGREPORT_FP="$DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_panel.log"
    echo "======DO_PANEL_SYSFS_BUGREPORT: $PANEL_SYSFS_BUGREPORT_FP======"
    echo "[PANEL_START]"
    echo "[frame_sync_status]" >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_panel.log&
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/frame_sync_status >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_panel.log&
    sleep 1
    echo "[panel_mode_ID_Sel]" >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_panel.log&
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_mode_ID_Sel >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_panel.log&
    sleep 1
    echo "[panel_mode_ID_deltav]" >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_panel.log&
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_mode_ID_deltav >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_panel.log&
    sleep 1
    echo "[panel_mod_status]" >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_panel.log&
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_mod_status >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_panel.log&
    sleep 1
    echo "[ssc]" >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_panel.log&
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/ssc >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_panel.log&
    sleep 1
    echo "[swing_level]" >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_panel.log&
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/swing_level >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_panel.log&
    sleep 1
    echo "[pe_level]" >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_panel.log&
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/pe_level >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_panel.log&
    sleep 1
    echo "[output_frame_rate]" >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_panel.log&
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/output_frame_rate >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_panel.log&
    sleep 1
    echo "[panel_TgenVTT_CheckIvsOvs]" >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_panel.log&
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_TgenVTT_CheckIvsOvs >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_panel.log&
    sleep 1
    echo "[panel_mod_status]" >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_panel.log&
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_mod_status >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_panel.log&
    sleep 1
    echo "[panel_oled_status]" >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_panel.log&
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_oled_status >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_panel.log&
    sleep 1
    echo "[panel_out_model]" >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_panel.log&
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_out_model >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_panel.log&
    sleep 1
    echo "[panel_tg_ML_SupportValue_setting]" >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_panel.log&
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_tg_ML_SupportValue_setting >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_panel.log&
    sleep 1
    echo "[mtk_pq_b2r_gtgen_info]" >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_panel.log&
    cat /sys/devices/platform/mtk-pq/mtk_dbg/mtk_pq_b2r_gtgen_info >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_panel.log&
    sleep 1
    echo "[tcon_status]" >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_panel.log&
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/tcon_status >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_panel.log&
    sleep 1
    echo "[tg_param]" >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_panel.log&
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/tg_param >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_panel.log&
    sleep 1
    echo "[BK_A3A0]" >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_panel.log&
    echo 0xA3A0 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_panel.log&
    sleep 1
    echo "[BK_A3A1]" >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_panel.log&
    echo 0xA3A1 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_panel.log&
    sleep 1
    echo "[BK_A3A2]" >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_panel.log&
    echo 0xA3A2 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_panel.log&
    sleep 1
    echo "[BK_A39C]" >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_panel.log&
    echo 0xA39C > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_panel.log&
    sleep 1
    echo "[BK_A4D9]" >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_panel.log&
    echo 0xA4D9 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_panel.log&
    sleep 1
    echo "[BK_2420]" >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_panel.log&
    echo 0x2420 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_panel.log&
    sleep 1
    echo "[BK_2421]" >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_panel.log&
    echo 0x2421 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_panel.log&
    sleep 1
    echo "[BK_2422]" >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_panel.log&
    echo 0x2422 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_panel.log&
    sleep 1
    echo "[BK_2423]" >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_panel.log&
    echo 0x2423 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_panel.log&
    sleep 1
    echo "[BK_2424]" >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_panel.log&
    echo 0x2424 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_panel.log&
    sleep 1
    echo "[BK_2425]" >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_panel.log&
    echo 0x2425 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_panel.log&
    sleep 1
    echo "[BK_2426]" >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_panel.log&
    echo 0x2426 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_panel.log&
    sleep 1
    echo "[BK_2427]" >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_panel.log&
    echo 0x2427 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_panel.log&
    sleep 1
    echo "[BK_2428]" >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_panel.log&
    echo 0x2428 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_panel.log&
    sleep 1
    echo "[BK_2429]" >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_panel.log&
    echo 0x2429 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_panel.log&
    sleep 1
    echo "[BK_242A]" >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_panel.log&
    echo 0x242A > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_panel.log&
    sleep 1
    echo "[BK_242B]" >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_panel.log&
    echo 0x242B > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_panel.log&
    sleep 1
    echo "[BK_242C]" >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_panel.log&
    echo 0x242C > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_panel.log&
    sleep 1
    echo "[BK_242D]" >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_panel.log&
    echo 0x242D > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_panel.log&
    sleep 1
    echo "[BK_242E]" >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_panel.log&
    echo 0x242E > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_panel.log&
    sleep 1
    echo "[BK_242F]" >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_panel.log&
    echo 0x242F > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_panel.log&
    sleep 1
    echo "[BK_2430]" >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_panel.log&
    echo 0x2430 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_panel.log&
    sleep 1
    echo "[BK_A3A4]" >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_panel.log&
    echo 0xA3A4 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_panel.log&
    sleep 1
    echo "[BK_A3A5]" >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_panel.log&
    echo 0xA3A5 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_panel.log&
    sleep 1
    echo "[BK_A3A6]" >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_panel.log&
    echo 0xA3A6 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_panel.log&
    sleep 1
    echo "[BK_8502]" >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_panel.log&
    echo 0x8502 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_panel.log&
    sleep 1
    echo "[BK_8503]" >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_panel.log&
    echo 0x8503 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_panel.log&
    sleep 1
    echo "[BK_8504]" >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_panel.log&
    echo 0x8504 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_panel.log&
    sleep 1
    echo "[PANEL_END]"
}

DO_FRC_SYSFS_BUGREPORT()
{
    FRC_SYSFS_BUGREPORT_FP="$DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_frc.log"
    echo "======DO_FRC_SYSFS_BUGREPORT: $FRC_SYSFS_BUGREPORT_FP======"
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/path_frc >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_frc.log&
    sleep 1
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/memc_level_frc >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_frc.log&
    sleep 1
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/frc_status >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_frc.log&
    sleep 1
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/frame_sync_status >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_frc.log&
    sleep 1

    echo 0x861F > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_frc.log&
    sleep 1

    echo 0x8453 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_frc.log&
    sleep 1

    echo 0x842C > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_frc.log&
    sleep 1

    echo 0x854C > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_frc.log&
    sleep 1

    echo 0xA401 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_frc.log&
    sleep 1

    echo 0xA402 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_frc.log&
    sleep 1

    echo 0xA403 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_frc.log&
    sleep 1

    echo 0xA404 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_frc.log&
    sleep 1

    echo 0xA323 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_frc.log&
    sleep 1

    echo 0xA4F6 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_frc.log&
    sleep 1

    echo 0x851F > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_frc.log&
    sleep 1

    echo 0x8636 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_frc.log&
    sleep 1

    echo 0x8564 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_frc.log&
    sleep 1

    echo 0x8630 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_frc.log&
    sleep 1

    echo 0x8426 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_frc.log&
    sleep 1

    echo 0x8457 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_frc.log&
    sleep 1

    echo 0x84B7 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_frc.log&
    sleep 1

    echo 0x851B > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_frc.log&
    sleep 1

    echo 0x851C > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_frc.log&
    sleep 1

    echo 0xA36B > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_frc.log&
    sleep 1

    echo 0xA36C > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_frc.log&
    sleep 1

    echo 0xA326 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_frc.log&
    sleep 1

    echo 0xA3A0 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_frc.log&
    sleep 1

    echo 0xA3A1 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_frc.log&
    sleep 1

    echo 0xA43A > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_frc.log&
    sleep 1

    echo 0x8502 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_frc.log&
    sleep 1

    echo 0x8503 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_frc.log&
    sleep 1

    echo 0x8504 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_frc.log&
    sleep 1

    echo 0xA3A5 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_frc.log&
    sleep 1

    echo 0x8182 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_frc.log&
    sleep 1

    echo 0x8102 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_frc.log&
    sleep 1

    echo 0xA31F > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_frc.log&
    sleep 1

    echo 0xA347 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_frc.log&
    sleep 1

    echo 0xA347 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_frc.log&
    sleep 1

    echo 0xA345 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_frc.log&
    sleep 1

    echo 0x8650 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_frc.log&
    sleep 1

    echo 0xA3AE > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_frc.log&
    sleep 1

    echo 0xA370 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_frc.log&
    sleep 1

    echo 0xA325 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_frc.log&
    sleep 1

    echo 0xA3EA > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_frc.log&
    sleep 1
}

DO_PQU_SYSFS_BUGREPORT()
{
        echo -e "${COLOR_GREEN}$(date) [AUTOLOG] Doing pqu sysfs bugreport.${COLOR_REST}\n"
	PQU_SYSFS_BUGREPORT_FP="$DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_pqu.log"
        echo "======DO_PQU_SYSFS_BUGREPORT: $PQU_SYSFS_BUGREPORT_FP======"
	echo "mtk_pq" >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_pqu.log
	cat /sys/module/mtk_pq/parameters/pqu_enable >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_pqu.log
	echo "mtk_tvpqu" >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_pqu.log
	cat /sys/module/mtk_tvpqu/parameters/pqu_enable >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_pqu.log
	echo "mtk_tvscriptmgt" >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_pqu.log
	cat /sys/module/mtk_tvscriptmgt/parameters/pqu_enable >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_pqu.log
	echo "mediatek_drm_tv" >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_pqu.log
	cat /sys/module/mediatek_drm_tv/parameters/pqu_enable >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_pqu.log
	cat /sys/class/remoteproc/remoteproc1/state >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_pqu.log
	if [ `cat /sys/module/mtk_pq/parameters/pqu_enable` = 'N' ]
	then
		echo 0  > /sys/devices/platform/mtk-tvpqu/mtk_dbg/PQ_Debug
		cat /sys/devices/platform/mtk-tvpqu/mtk_dbg/PQ_Debug  >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_pqu.log
		echo 1  > /sys/devices/platform/mtk-tvpqu/mtk_dbg/PQ_Debug
		cat /sys/devices/platform/mtk-tvpqu/mtk_dbg/PQ_Debug  >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_pqu.log
		echo 2  > /sys/devices/platform/mtk-tvpqu/mtk_dbg/PQ_Debug
		cat /sys/devices/platform/mtk-tvpqu/mtk_dbg/PQ_Debug  >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_pqu.log
		echo 3  > /sys/devices/platform/mtk-tvpqu/mtk_dbg/PQ_Debug
		cat /sys/devices/platform/mtk-tvpqu/mtk_dbg/PQ_Debug  >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_pqu.log
		echo 4  > /sys/devices/platform/mtk-tvpqu/mtk_dbg/PQ_Debug
		cat /sys/devices/platform/mtk-tvpqu/mtk_dbg/PQ_Debug  >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_pqu.log
		echo 5  > /sys/devices/platform/mtk-tvpqu/mtk_dbg/PQ_Debug
		cat /sys/devices/platform/mtk-tvpqu/mtk_dbg/PQ_Debug  >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_pqu.log
		echo 6  > /sys/devices/platform/mtk-tvpqu/mtk_dbg/PQ_Debug
		cat /sys/devices/platform/mtk-tvpqu/mtk_dbg/PQ_Debug  >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_pqu.log
		echo 7  > /sys/devices/platform/mtk-tvpqu/mtk_dbg/PQ_Debug
		cat /sys/devices/platform/mtk-tvpqu/mtk_dbg/PQ_Debug  >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_pqu.log
		echo 8  > /sys/devices/platform/mtk-tvpqu/mtk_dbg/PQ_Debug
		cat /sys/devices/platform/mtk-tvpqu/mtk_dbg/PQ_Debug  >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_pqu.log
		echo 9  > /sys/devices/platform/mtk-tvpqu/mtk_dbg/PQ_Debug
		cat /sys/devices/platform/mtk-tvpqu/mtk_dbg/PQ_Debug  >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_pqu.log
		echo 10 > /sys/devices/platform/mtk-tvpqu/mtk_dbg/PQ_Debug
		cat /sys/devices/platform/mtk-tvpqu/mtk_dbg/PQ_Debug  >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_pqu.log
		echo 11 > /sys/devices/platform/mtk-tvpqu/mtk_dbg/PQ_Debug
		cat /sys/devices/platform/mtk-tvpqu/mtk_dbg/PQ_Debug  >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_pqu.log
		echo 12 > /sys/devices/platform/mtk-tvpqu/mtk_dbg/PQ_Debug
		cat /sys/devices/platform/mtk-tvpqu/mtk_dbg/PQ_Debug  >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_pqu.log
		echo 13 > /sys/devices/platform/mtk-tvpqu/mtk_dbg/PQ_Debug
		cat /sys/devices/platform/mtk-tvpqu/mtk_dbg/PQ_Debug  >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_pqu.log
		echo 14 > /sys/devices/platform/mtk-tvpqu/mtk_dbg/PQ_Debug
		cat /sys/devices/platform/mtk-tvpqu/mtk_dbg/PQ_Debug  >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_pqu.log
		echo 15 > /sys/devices/platform/mtk-tvpqu/mtk_dbg/PQ_Debug
		cat /sys/devices/platform/mtk-tvpqu/mtk_dbg/PQ_Debug  >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_pqu.log
	else
		cat /dev/ttyVUART-pqu-vuart >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_pqu.log&
		echo "backlight_info" > /dev/ttyVUART-pqu-vuart
		echo "PQ_Debug 0" > /dev/ttyVUART-pqu-vuart
		echo "PQ_Debug 1" > /dev/ttyVUART-pqu-vuart
		echo "PQ_Debug 2" > /dev/ttyVUART-pqu-vuart
		echo "PQ_Debug 3" > /dev/ttyVUART-pqu-vuart
	fi
}

DO_PQDD_SYSFS_BUGREPORT()
{
	PQDD_SYSFS_BUGREPORT_FP="$DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_pqdd.log"
    echo "======DO_PQDD_SYSFS_BUGREPORT: $PQDD_SYSFS_BUGREPORT_FP======"
	
	if [ -n $ANDROID_VERSION ] && [ $ANDROID_VERSION -ge 14 ]; then
		#PQHAL lshal
		echo "======PQHAL lshal 1st======" >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_pqdd.log
		dumpsys vendor.mediatek.hardware.pq@1.0::IPq/default --enable
		dumpsys vendor.mediatek.hardware.pq@1.0::IPq/default --dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_pqdd.log
		sleep 1
		echo "======PQHAL lshal 2nd======" >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_pqdd.log
		dumpsys vendor.mediatek.hardware.pq@1.0::IPq/default --dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_pqdd.log

		#Displink lshal
		echo "======Displink lshal======" >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_pqdd.log
		dumpsys vendor.mediatek.hardware.dispservice@1.0::IDispService/default --enable
		dumpsys vendor.mediatek.hardware.dispservice@1.0::IDispService/default --dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_pqdd.log
		dumpsys vendor.mediatek.hardware.dispservice@1.0::IDispService/default --dumpConfig >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_pqdd.log
		dumpsys vendor.mediatek.hardware.render@1.0::IRender/default --compose >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_pqdd.log
	else
		#PQHAL lshal
		echo "======PQHAL lshal 1st======" >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_pqdd.log
		lshal debug vendor.mediatek.hardware.pq@1.0::IPq/default --enable
		lshal debug vendor.mediatek.hardware.pq@1.0::IPq/default --dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_pqdd.log
		sleep 1
		echo "======PQHAL lshal 2nd======" >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_pqdd.log
		lshal debug vendor.mediatek.hardware.pq@1.0::IPq/default --dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_pqdd.log

		#Displink lshal
		echo "======Displink lshal======" >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_pqdd.log
		lshal debug vendor.mediatek.hardware.dispservice@1.0::IDispService/default --enable
		lshal debug vendor.mediatek.hardware.dispservice@1.0::IDispService/default --dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_pqdd.log
		lshal debug vendor.mediatek.hardware.dispservice@1.0::IDispService/default --dumpConfig >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_pqdd.log
		lshal debug vendor.mediatek.hardware.render@1.0::IRender/default --compose >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_pqdd.log
	fi
}

DO_DV_SYSFS_BUGREPORT()
{
    echo -e "${COLOR_GREEN}$(date) [AUTOLOG] Doing dv sysfs bugreport.${COLOR_REST}\n"
    DO_DV_SYSFS_BUGREPORT_start_time=$(date +%s)
    DV_SYSFS_BUGREPORT_FP="$DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_dv.log"
    echo "======DO_DV_SYSFS_BUGREPORT: $DV_SYSFS_BUGREPORT_FP======"
    echo "====== PQDD dv sysfs ======" >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_dv.log
    cat /sys/devices/platform/mtk-pq/mtk_dbg/dv >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_dv.log
    sleep 1
    echo "====== SRCCAP dv sysfs ======" >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_dv.log
    cat /sys/devices/platform/mtk_srccap0/mtk_dbg/dv >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_dv.log
    sleep 1
    DO_DV_SYSFS_BUGREPORT_cost_time=$(($(date +%s)-$DO_DV_SYSFS_BUGREPORT_start_time))
}


	echo "======PQ BANK DUMP START======" >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_pqdd.log

	echo 0xA306 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_pqdd.log

	echo 0xA307 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_pqdd.log

	echo 0xA30F > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_pqdd.log

	echo 0xA310 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_pqdd.log
	
	echo 0xA311 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_pqdd.log
	
	echo 0xA312 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_pqdd.log

	echo 0xA313 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_pqdd.log

	echo 0xA314 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_pqdd.log

	echo 0xA315 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_pqdd.log

	echo 0xA316 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_pqdd.log

	echo 0xA31F > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_pqdd.log

	echo 0xA320 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_pqdd.log

	echo 0xA321 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_pqdd.log

	echo 0xA322 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_pqdd.log

	echo 0xA323 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_pqdd.log

	echo 0xA330 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_pqdd.log

	echo 0xA331 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_pqdd.log

	echo 0xA358 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_pqdd.log

	echo 0xA359 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_pqdd.log

	echo 0xA365 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_pqdd.log

	echo 0xA38A > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_pqdd.log

	echo 0xA38B > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_pqdd.log

	echo 0xA38C > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_pqdd.log

	echo 0xA390 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_pqdd.log

	echo 0xA391 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_pqdd.log

	echo 0xA392 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_pqdd.log

	echo 0xA393 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_pqdd.log

	echo 0xA394 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_pqdd.log

	echo 0xA398 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_pqdd.log

	echo 0xA3AE > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_pqdd.log

	echo 0xA3B2 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_pqdd.log

	echo 0xA3B3 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_pqdd.log

	echo 0xA3B4 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_pqdd.log

	echo 0xA3B5 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_pqdd.log

	echo 0xA3B6 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_pqdd.log

	echo 0xA3B7 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_pqdd.log

	echo 0xA3EB > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_pqdd.log

	echo 0xA3EE > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_pqdd.log

	echo 0xA3FE > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_pqdd.log

	echo 0xA3FF > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_pqdd.log


	echo 0xA490 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_pqdd.log

	echo 0xA491 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_pqdd.log

	echo 0xA492 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_pqdd.log

	echo 0xA493 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_pqdd.log

	echo 0xA494 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_pqdd.log

	echo 0xA495 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_pqdd.log
	
	echo 0xA496 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_pqdd.log

	echo 0xA497 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_pqdd.log

	echo 0xA498 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_pqdd.log

	echo 0xA499 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_pqdd.log

	echo 0xA49A > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_pqdd.log


	echo 0x1031 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_pqdd.log

	echo 0x1032 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_pqdd.log

	echo 0x1033 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_pqdd.log

	echo 0x1034 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_pqdd.log

	echo 0x1035 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_pqdd.log

	echo 0x1036 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_pqdd.log

	echo 0x1037 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_pqdd.log

	echo 0x1038 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_pqdd.log

	echo 0x1039 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_pqdd.log

	echo 0x103A > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_pqdd.log

	echo 0x103B > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_pqdd.log

	echo 0x103C > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_pqdd.log

	echo 0x3101 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_pqdd.log

	echo "======PQ BANK DUMP END======" >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_pqdd.log
}

DO_CAPTURECMD_BUGREPORT()
{
    CAPTURECMD_DIR="$DOMAIN_DISPLAY_DUMP_LOG_DIR/CaptureCmd"
    mkdir -p $CAPTURECMD_DIR

    setprop sys.mtk.capture_hal.loglevel A
    CaptureCmd.bin -E 0 -P 1 -f 2 -T bmp -O 0,0 -d $CAPTURECMD_DIR
    CaptureCmd.bin -E 0 -P 2 -f 2 -T bmp -O 0,0 -d $CAPTURECMD_DIR
    CaptureCmd.bin -E 0 -P 3 -f 2 -T bmp -O 0,0 -d $CAPTURECMD_DIR
    CaptureCmd.bin -E 0 -P 4 -f 2 -T bmp -O 0,0 -d $CAPTURECMD_DIR
    CaptureCmd.bin -p 2 -f 2 -T bmp -O 0,0 -d $CAPTURECMD_DIR
    CaptureCmd.bin -p 3 -f 2 -T bmp -O 0,0 -d $CAPTURECMD_DIR
    CaptureCmd.bin -p 4 -f 2 -T bmp -O 0,0 -d $CAPTURECMD_DIR
    CaptureCmd.bin -p 5 -f 2 -T bmp -O 0,0 -d $CAPTURECMD_DIR
    CaptureCmd.bin -p 6 -f 2 -T bmp -O 0,0 -d $CAPTURECMD_DIR
    CaptureCmd.bin -p 7 -f 2 -T bmp -O 0,0 -d $CAPTURECMD_DIR
    CaptureCmd.bin -p 8 -f 2 -T bmp -O 0,0 -d $CAPTURECMD_DIR
    CaptureCmd.bin -p 9 -f 2 -T bmp -O 0,0 -d $CAPTURECMD_DIR
    CaptureCmd.bin -p 10 -f 2 -T bmp -O 0,0 -d $CAPTURECMD_DIR
    CaptureCmd.bin -p 11 -f 2 -T bmp -O 0,0 -d $CAPTURECMD_DIR
    CaptureCmd.bin -p 12 -f 2 -T bmp -O 0,0 -d $CAPTURECMD_DIR
    CaptureCmd.bin -p 13 -f 2 -T bmp -O 0,0 -d $CAPTURECMD_DIR
    CaptureCmd.bin -p 14 -f 2 -T bmp -O 0,0 -d $CAPTURECMD_DIR
    CaptureCmd.bin -p 15 -f 2 -T bmp -O 0,0 -d $CAPTURECMD_DIR
    setprop sys.mtk.capture_hal.loglevel E

    tar zcvf $DOMAIN_DISPLAY_DUMP_LOG_DIR/CaptureCmd.tar.gz $CAPTURECMD_DIR
    rm -rf $CAPTURECMD_DIR
}

DO_CEC_ARC_EARC_BUGREPORT()
{
    INIT_PLATFORM_CEC_CEC 20002
}
# roll back configuration to system default value
CLOSE_SYMPTOM_WIFI_ANDROID()
{
  echo "IN CLOSE_PLATFORM_NETWORK_WIFI_ANDROID"
  echo "disabled supplicant verbose"
  wpa_cli -i wlan0 -g@android:wpa_wlan0 IFNAME=wlan0 log_level INFO
  echo "disabled wifi framework verbose"
  setprop log.tag.WifiTracker I
  cmd wifi set-verbose-logging disabled
}

DO_WIFI_BUGREPORT()
{
    WIFI_EN_LOG=$AUTOLOG_LOG_DEFAULT_DIR/*logcat_wifi.log
    if [ -f $WIFI_EN_LOG ]; then
        CLOSE_SYMPTOM_WIFI_ANDROID
    fi
}

DO_SCRIPTMGT_BUGREPORT()
{
    SCRIPTMGT_INFO_LOG="$DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_scriptmgt.log"
    echo "======DO_SCRIPTMGT_SYSFS_BUGREPORT: $SCRIPTMGT_INFO_LOG======"
    echo "------ dump Triggen & TGEN setting ------" >> $SCRIPTMGT_INFO_LOG
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/tg_param >> $SCRIPTMGT_INFO_LOG
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_tg_ML_SupportValue_setting >> $SCRIPTMGT_INFO_LOG
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/frame_sync_status >> $SCRIPTMGT_INFO_LOG
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_mode_ID_Sel >> $SCRIPTMGT_INFO_LOG
    echo "------ dump Srccap report info ------" >> $SCRIPTMGT_INFO_LOG
    cat /sys/devices/platform/mtk_srccap0/mtk_dbg/srccap_report_info >> $SCRIPTMGT_INFO_LOG
    echo "------ dump menuload status ------" >> $SCRIPTMGT_INFO_LOG
    cat /sys/devices/platform/scriptmanagement/mtk_dbg/ml_dump_vstouch_status >> $SCRIPTMGT_INFO_LOG
    cat /sys/devices/platform/scriptmanagement/mtk_dbg/ml_dump_client_info >> $SCRIPTMGT_INFO_LOG
    cat  /sys/devices/platform/scriptmanagement/mtk_dbg/ml_dump_memory >> $SCRIPTMGT_INFO_LOG
    echo 0x01FF > /sys/devices/platform/scriptmanagement/mtk_dbg/ml_dump_info >> $SCRIPTMGT_INFO_LOG
    cat /sys/devices/platform/scriptmanagement/mtk_dbg/ml_dump_info >> $SCRIPTMGT_INFO_LOG
    echo "------ dump triggen bank ------" >> $SCRIPTMGT_INFO_LOG
    echo "[BK_A3A4]" >> $SCRIPTMGT_INFO_LOG
    echo 0xA3A4 >> /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $SCRIPTMGT_INFO_LOG
    echo "[BK_A3A5]" >> $SCRIPTMGT_INFO_LOG
    echo 0xA3A5 >> /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $SCRIPTMGT_INFO_LOG
    echo "------ dump 2D_MENULOAD bank ------" >> $SCRIPTMGT_INFO_LOG
    echo "[BK_A31f]" >> $SCRIPTMGT_INFO_LOG
    echo 0xA31f >> /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $SCRIPTMGT_INFO_LOG
    echo "[BK_A345]" >> $SCRIPTMGT_INFO_LOG
    echo 0xA345 >> /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $SCRIPTMGT_INFO_LOG
    sleep 1
    echo "[BK_A31f]" >> $SCRIPTMGT_INFO_LOG
    echo 0xA31f >> /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $SCRIPTMGT_INFO_LOG
    echo "[BK_A345]" >> $SCRIPTMGT_INFO_LOG
    echo 0xA345 >> /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $SCRIPTMGT_INFO_LOG
    sleep 1
    echo "[BK_A31f]" >> $SCRIPTMGT_INFO_LOG
    echo 0xA31f >> /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $SCRIPTMGT_INFO_LOG
    echo "[BK_A345]" >> $SCRIPTMGT_INFO_LOG
    echo 0xA345 >> /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $SCRIPTMGT_INFO_LOG
    echo "------ dump MW_MENULOAD bank ------" >> $SCRIPTMGT_INFO_LOG
    echo "[BK_A347]" >> $SCRIPTMGT_INFO_LOG
    echo 0xA347 >> /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $SCRIPTMGT_INFO_LOG
    echo "[BK_A348]" >> $SCRIPTMGT_INFO_LOG
    echo 0xA348 >> /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $SCRIPTMGT_INFO_LOG
    echo "------ dump CMDQ timeout status ------" >> $SCRIPTMGT_INFO_LOG
    echo 0 > /sys/devices/platform/scriptmanagement/mtk_dbg/cmdq_timeout_en
    sleep 1
    cat /sys/devices/platform/scriptmanagement/mtk_dbg/cmdq_timeout_status >> $SCRIPTMGT_INFO_LOG
    echo 1 > /sys/devices/platform/scriptmanagement/mtk_dbg/cmdq_timeout_en
    echo enable > /sys/devices/platform/mtk-tvpqu/mtk_dbg/cmdq_fps
    cat /sys/devices/platform/mtk-tvpqu/mtk_dbg/cmdq_fps >> $SCRIPTMGT_INFO_LOG
    echo disable > /sys/devices/platform/mtk-tvpqu/mtk_dbg/cmdq_fps
    echo enable > /sys/devices/platform/mtk-tvpqu/mtk_dbg/cmdq_stats
    cat /sys/devices/platform/mtk-tvpqu/mtk_dbg/cmdq_stats >> $SCRIPTMGT_INFO_LOG
    echo disable > /sys/devices/platform/mtk-tvpqu/mtk_dbg/cmdq_stats
    echo "------ dump STR_LDR status ------" >> $SCRIPTMGT_INFO_LOG
    cat /sys/devices/platform/scriptmanagement/mtk_dbg/str_ldr_debug_info >> $SCRIPTMGT_INFO_LOG
}

DO_AVD_SYSFS_BUGREPORT()
{
    AVD_SYSFS_BUGREPORT_FP="$DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_avd.log"
    echo "======DO_AVD_SYSFS_BUGREPORT: $AVD_SYSFS_BUGREPORT_FP======"

    echo 0x2500 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_avd.log&
    sleep 1

    echo 0x2500 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_avd.log&
    sleep 1

    echo 0x2501 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_avd.log&
    sleep 1

    echo 0x2502 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_avd.log&
    sleep 1

    echo 0x2503 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_avd.log&
    sleep 1

    echo 0x2504 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_avd.log&
    sleep 1

    echo 0x2505 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_avd.log&
    sleep 1

    echo 0x2506 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_avd.log&
    sleep 1

    echo 0x2507 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_avd.log&
    sleep 1

    echo 0x2508 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_avd.log&
    sleep 1

    echo 0x6011 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_avd.log&
    sleep 1

    echo 0x300F > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump >> $DOMAIN_DISPLAY_DUMP_LOG_DIR/sysfs_avd.log&
    sleep 1
}
DO_AUDIO_BUGREPORT()
{
    echo -e "${COLOR_GREEN}$(date) [AUTOLOG] Doing audio bugreport.${COLOR_REST}\n"
    echo "[AUTOLOG][Audio log dump] Starting ..."

    echo "------ dump policy ------"
    dumpsys media.audio_policy >> $DOMAIN_AUDIO_DUMP_LOG_DIR/dump_ap.txt&

    echo "------ dump flinger ------"
    dumpsys media.audio_flinger >> $DOMAIN_AUDIO_DUMP_LOG_DIR/dump_af.txt&

    echo "------ dump audio ------"
    dumpsys audio >> $DOMAIN_AUDIO_DUMP_LOG_DIR/dump_audio.txt&

    if [ -d /proc/asound/mtktvsndcard ]; then
        echo "------ dump utopia audio status ------"
        echo audio_status > /sys/devices/platform/mtk-tv-offload-platform/mtk_dbg/utopia_mdb
        dmesg | egrep -i '<UTPA_FATAL>' > $DOMAIN_AUDIO_DUMP_LOG_DIR/dump_utopia_audio_status.txt

        cp -f /data/dump_audio_hal* $DOMAIN_AUDIO_DUMP_LOG_DIR/
    fi

    echo "------ backup audio timecheck data ------"
    mv -f /mnt/vendor/tmp/apaf/*gz $DOMAIN_AUDIO_DUMP_LOG_DIR/
    mv -f /mnt/vendor/tmp/apaf/*core $DOMAIN_AUDIO_DUMP_LOG_DIR/

    echo "kill adriver_tool"
    killall -9 adriver_tool

    echo "[AUTOLOG][Audio log dump] End"
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
  #MODULE_ARG1=$1
  #MODULE_ARG2=$2
  #MODULE_ARG3=$3

  #echo "LOG_FP=$LOG_FP"
  #echo "ACT_LOG_FP=$ACT_LOG_FP"
  #echo "LOG_DIR=$LOG_DIR"
  #echo "LOG_DT=$LOG_DT"
  #echo "MODULE_ARG2=$MODULE_ARG2"
  #echo "MODULE_ARG3=$MODULE_ARG3"

  #========================================================
  #                   Main codes here
  # You can modify codes under this section
  #========================================================

  ### Import functions from other modules/scripts
  ### DO SOMETHING
  DO_FOLDER_CREATE
  DO_ANR
  DO_CAPTURECMD_BUGREPORT
  DO_BROADCAST_BUGREPORT
  DO_MMP_BUGREPORT
  DO_EXTIN_LSHAL_BUGREPORT
  DO_EXTIN_SYSFS_BUGREPORT "AFTER"
  DO_Render_SYSFS_BUGREPORT
  DO_PANEL_SYSFS_BUGREPORT
  DO_PQU_SYSFS_BUGREPORT
  DO_PQDD_SYSFS_BUGREPORT
  DO_DV_SYSFS_BUGREPORT
  DO_FRC_SYSFS_BUGREPORT
  DO_CEC_ARC_EARC_BUGREPORT
  DO_BLUETOOTH_REPORT
  DO_WIFI_BUGREPORT
  DO_CAMERA_BUGREPORT
  DO_SCRIPTMGT_BUGREPORT
  DO_AVD_SYSFS_BUGREPORT
  OpenCommandDebuger $INIT_HISTORY_FP

  temp=$(cat /data/debug_stress.txt)
  if [ "$temp" = "1" ]; then
    CloseCommandDebuger
    echo "CloseCommandDebuger IN stress"
    sh $AUTOLOG_MODULES_DIR/platform/stress/stress_test_AOW.sh end $LOG_DIR
  else
    DO_SYMPTOM_BUGREPORT $LOG_DIR
  fi

  if [ $BUGREPORTZ_DUMP == true ]; then
    DO_ANDROID_BUGREPORT
  fi

  CloseCommandDebuger
  PrintCommandDebuger $INIT_HISTORY_FP

  #echo
  #echo "================================"
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
