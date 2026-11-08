#!/usr/bin/env sh

disp_lshal_dump()
{
    LOG_PATH="$1"

    LSHAL_CODEC2_LOG_FP="$LOG_PATH/lshal_CODEC2.log"
    echo "lshal c2 dump => $LSHAL_CODEC2_LOG_FP"
    lshal debug vendor.mediatek.hardware.c2.info@1.0::ICodec2InfoService/c2.info --dump >> $LSHAL_CODEC2_LOG_FP&
    sleep 5
    lshal debug vendor.mediatek.hardware.c2.info@1.0::ICodec2InfoService/c2.info --dump >> $LSHAL_CODEC2_LOG_FP&
    LSHAL_DISP_LOG_FP="$LOG_PATH/lshal_HwDispService.log"
    echo "lshal hardware.dispservice reset and dump => $LSHAL_DISP_LOG_FP"
    lshal debug vendor.mediatek.hardware.dispservice@1.0::IDispService/default --dump >> $LSHAL_DISP_LOG_FP&
    sleep 5
    lshal debug vendor.mediatek.hardware.dispservice@1.0::IDispService/default --dump >> $LSHAL_DISP_LOG_FP&
    LSHAL_PQHAL_LOG_FP="$LOG_PATH/lshal_PQHAL.log"
    echo "lshal pqhal dump => $LSHAL_PQHAL_LOG_FP"
    lshal debug vendor.mediatek.hardware.pq@1.0::IPq/default --dump >> $LSHAL_PQHAL_LOG_FP&
    sleep 5
    lshal debug vendor.mediatek.hardware.pq@1.0::IPq/default --dump >> $LSHAL_PQHAL_LOG_FP&
    LSHAL_RENDER_LOG_FP="$LOG_PATH/lshal_HwRender.log"
    echo "lshal hardware.render reset and dump => $LSHAL_RENDER_LOG_FP"
    lshal debug vendor.mediatek.hardware.render@1.0::IRender/default --reset >> $LSHAL_RENDER_LOG_FP&
    sleep 5
    lshal debug vendor.mediatek.hardware.render@1.0::IRender/default --dump >> $LSHAL_RENDER_LOG_FP&
}

