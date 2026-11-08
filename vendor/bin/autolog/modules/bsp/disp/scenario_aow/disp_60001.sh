#!/usr/bin/env sh

disp_lshal_init()
{
    lshal debug vendor.mediatek.hardware.c2.info@1.0::ICodec2InfoService/c2.info --enable
    lshal debug vendor.mediatek.hardware.dispservice@1.0::IDispService/default --enable
    lshal debug vendor.mediatek.hardware.pq@1.0::IPq/default --enable
}

