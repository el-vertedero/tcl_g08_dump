#!/usr/bin/env sh

IsPatternQuestion()
{
    local OUTPUT_FP="$1"
    message="${COLOR_GREEN} Please check $pattern test pattern is normal and capture the screen, key in [y/n] to continue:  ${COLOR_REST}"
    ### This will call prompt function from utils/helpers.sh
    ### prompt(message, log_file_path)
    ###   => Use read command to ask user questions, and record it into log_file_path
    bug=$(prompt "$message" "$OUTPUT_FP")
    echo "$bug"  # Return answer
}

IsExtInSrcQuestion()
{
    local OUTPUT_FP="$1"
    message="${COLOR_GREEN} Is HDMI/Ypbpr/Cvbs/ATV/VGA/Svideo/Scart Source? key in [y/n] to continue:  ${COLOR_REST}"
    ### This will call prompt function from utils/helpers.sh
    ### prompt(message, log_file_path)
    ###   => Use read command to ask user questions, and record it into log_file_path
    bug=$(prompt "$message" "$OUTPUT_FP")
    echo "$bug"  # Return answer
}

MJC_Check()
{
    echo "-----------------------------------------------"
    echo "cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/isany_frc =>"
    if [[ ! $(grep "no FRC window" /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/isany_frc) == "" ]]; then
        echo "MJC is off"
        return 0
    else
        echo "MJC is enabled"
        return 1
    fi
    echo "-----------------------------------------------"
}

Pattern_Dump()
{
    echo 0xa401 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump

    echo 0xa402 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump

    echo 0xa403 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump

    echo 0xa404 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump

    echo 0xa405 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump

    echo 0xa406 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump

    echo 0xa407 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump

    echo 0xa408 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump

    echo 0xa409 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
    cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
}

disp_log_open()
{
    echo 0x0 > /sys/devices/platform/mtk-tvpqu/mtk_dbg/IsBypass_PatternTest
    pattern="GFX"
    echo "Step 1. Invoke moving pattern_gfx..."
    echo "If it's video issue not UI, or no UI in this scene, please press y to skip this step"
    echo enable=1 type=2 movable=1 speed=1 width=64 height= 64 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/pattern_gfx
    while :
    do
    rst1=$(IsPatternQuestion $ACT_LOG_FP)
    if [ "${rst1}" == "y" ]; then
        echo enable=1 type=2 movable=1 speed=1 width=64 height= 64 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/pattern_gfx
        echo "Move to next stage.... "
        break
    elif [ "${rst1}" == "n" ]; then
        Pattern_Dump
        echo enable=0 type=2 movable=1 speed=1 width=64 height= 64 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/pattern_gfx
        echo "=================================================================="
        echo "This problem might belong to GFX"
        echo "=================================================================="
        sleep 5
        exit
    fi
    done
    pattern="Multi Win"
    echo "Step 2. Invoke moving pattern_multiwin..."
    echo enable=1 type=2 movable=1 speed=1 width=64 height= 64 force_timing=1> /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/pattern_multiwin
    while :
    do
    rst1=$(IsPatternQuestion $ACT_LOG_FP)
    if [ "${rst1}" == "y" ]; then
        echo enable=0 type=2 movable=1 speed=1 width=64 height= 64> /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/pattern_multiwin
        echo "Move to next stage.... "
        break
    elif [ "${rst1}" == "n" ]; then
        Pattern_Dump
        echo enable=0 type=2 movable=1 speed=1 width=64 height= 64> /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/pattern_multiwin
        echo "=================================================================="
        echo "This problem might belong to Render"
        echo "=================================================================="
        sleep 5
        exit
    fi
    done

    pattern="vop"
    echo "Step 3-1. Invoke moving pattern_vop..."
    echo window=0 enable=1 type=2 width=64 height= 64 speed=1 movable = 1 force_timing=1 > /sys/devices/platform/mtk-pq/mtk_dbg/pattern_vop
    echo window=0 enable=1 type=2 width=64 height= 64 speed=1 movable = 1 force_timing=1 > /sys/devices/platform/mtk-pq/mtk_dbg/pattern_vop
    while :
    do
        rst1=$(IsPatternQuestion $ACT_LOG_FP)
        if [ "${rst1}" == "y" ]; then
            echo window=0 enable=0 type=2 width=64 height= 64 speed=1 movable = 1 force_timing=0 > /sys/devices/platform/mtk-pq/mtk_dbg/pattern_vop
            echo "Move to next stage.... "
            break
        elif [ "${rst1}" == "n" ]; then
            Pattern_Dump
            echo window=0 enable=0 type=2 width=64 height= 64 speed=1 movable = 1 force_timing=0 > /sys/devices/platform/mtk-pq/mtk_dbg/pattern_vop
            echo "=================================================================="
            echo "This problem might belong to PQ path."
            echo "=================================================================="
            sleep 5
            exit
        fi
    done
    pattern="ip2_post"
    echo "Step 3-2. Invoke moving pattern_ip2_post..."
    echo window=0 enable=1 type=2 width=64 height= 64 speed=1 movable = 1 force_timing=1 > /sys/devices/platform/mtk-pq/mtk_dbg/pattern_ip2_post
    while :
    do
        rst1=$(IsPatternQuestion $ACT_LOG_FP)
        if [ "${rst1}" == "y" ]; then
            echo window=0 enable=0 type=2 width=64 height= 64 speed=1 movable = 1 force_timing=0 > /sys/devices/platform/mtk-pq/mtk_dbg/pattern_ip2_post
            echo "Move to next stage.... "
            break
        elif [ "${rst1}" == "n" ]; then
            Pattern_Dump
            echo window=0 enable=0 type=2 width=64 height= 64 speed=1 movable = 1 force_timing=0 > /sys/devices/platform/mtk-pq/mtk_dbg/pattern_ip2_post
            echo "=================================================================="
            echo "This problem might belong to PQ path."
            echo "=================================================================="
            sleep 5
            exit
        fi
    done
    pattern="srs_out"
    echo "Step 3-3. Invoke moving pattern_srs_out..."
    echo window=0 enable=1 type=2 width=64 height= 64 speed=1 movable = 1 force_timing=1 > /sys/devices/platform/mtk-pq/mtk_dbg/pattern_srs_out
    while :
    do
        rst1=$(IsPatternQuestion $ACT_LOG_FP)
        if [ "${rst1}" == "y" ]; then
            echo window=0 enable=0 type=2 width=64 height= 64 speed=1 movable = 1 force_timing=0 > /sys/devices/platform/mtk-pq/mtk_dbg/pattern_srs_out
            echo "Move to next stage.... "
            break
        elif [ "${rst1}" == "n" ]; then
            Pattern_Dump
            echo window=0 enable=0 type=2 width=64 height= 64 speed=1 movable = 1 force_timing=0 > /sys/devices/platform/mtk-pq/mtk_dbg/pattern_srs_out
            echo "=================================================================="
            echo "This problem might belong to PQ path."
            echo "=================================================================="
            sleep 5
            exit
        fi
    done
    pattern="srs_in"
    echo "Step 3-4. Invoke moving pattern_srs_in..."
    echo window=0 enable=1 type=2 width=64 height= 64 speed=1 movable = 1 force_timing=1 > /sys/devices/platform/mtk-pq/mtk_dbg/pattern_srs_in
    while :
    do
        rst1=$(IsPatternQuestion $ACT_LOG_FP)
        if [ "${rst1}" == "y" ]; then
            echo window=0 enable=0 type=2 width=64 height= 64 speed=1 movable = 1 force_timing=0 > /sys/devices/platform/mtk-pq/mtk_dbg/pattern_srs_in
            echo "Move to next stage.... "
            break
        elif [ "${rst1}" == "n" ]; then
            Pattern_Dump
            echo window=0 enable=0 type=2 width=64 height= 64 speed=1 movable = 1 force_timing=0 > /sys/devices/platform/mtk-pq/mtk_dbg/pattern_srs_in
            echo "=================================================================="
            echo "This problem might belong to PQ path."
            echo "=================================================================="
            sleep 5
            exit
        fi
    done
    pattern="di"
    echo "Step 3-5. Invoke moving pattern_di..."
    echo window=0 enable=1 type=2 width=64 height= 64 speed=1 movable = 1 force_timing=1 > /sys/devices/platform/mtk-pq/mtk_dbg/pattern_di
    while :
    do
        rst1=$(IsPatternQuestion $ACT_LOG_FP)
        if [ "${rst1}" == "y" ]; then
            echo window=0 enable=0 type=2 width=64 height= 64 speed=1 movable = 1 force_timing=0 > /sys/devices/platform/mtk-pq/mtk_dbg/pattern_di
            echo "Move to next stage.... "
            break
        elif [ "${rst1}" == "n" ]; then
            Pattern_Dump
            echo window=0 enable=0 type=2 width=64 height= 64 speed=1 movable = 1 force_timing=0 > /sys/devices/platform/mtk-pq/mtk_dbg/pattern_di
            echo "=================================================================="
            echo "This problem might belong to PQ path."
            echo "=================================================================="
            sleep 5
            exit
        fi
    done
    pattern="ip2"
    echo "Step 3-10. Invoke moving pattern_ip2..."
    echo window=0 enable=1 type=2 width=64 height= 64 speed=1 movable = 1 force_timing=1 > /sys/devices/platform/mtk-pq/mtk_dbg/pattern_ip2
    while :
    do
        rst1=$(IsPatternQuestion $ACT_LOG_FP)
        if [ "${rst1}" == "y" ]; then
            echo window=0 enable=0 type=2 width=64 height= 64 speed=1 movable = 1 force_timing=0 > /sys/devices/platform/mtk-pq/mtk_dbg/pattern_ip2
            echo "Move to next stage.... "
            break
        elif [ "${rst1}" == "n" ]; then
            Pattern_Dump
            echo window=0 enable=0 type=2 width=64 height= 64 speed=1 movable = 1 force_timing=0 > /sys/devices/platform/mtk-pq/mtk_dbg/pattern_ip2
            echo "=================================================================="
            echo "This problem might belong to PQ path."
            echo "=================================================================="
            sleep 5
            exit
        fi
    done
    while :
    do
        rst1=$(IsExtInSrcQuestion $ACT_LOG_FP)
        if [ "${rst1}" == "n" ]; then
            break
        elif [ "${rst1}" == "y" ]; then
				    pattern="preIP2_post"
				    echo "Step 4-1. Invoke moving PreIP2 post pattern..."
				    echo enable=1 type=2 movable=1 speed=1 width=64 height= 64 > /sys/devices/platform/mtk_srccap0/mtk_dbg/pattern_pre_ip2_1_post
				    echo enable=1 type=2 movable=1 speed=1 width=64 height= 64 > /sys/devices/platform/mtk_srccap0/mtk_dbg/pattern_pre_ip2_0_post
				    while :
				    do
				        rst2=$(IsPatternQuestion $ACT_LOG_FP)
				         if [ "${rst2}" == "y" ]; then
				            echo enable=0 type=2 movable=1 speed=1 width=64 height= 64 > /sys/devices/platform/mtk_srccap0/mtk_dbg/pattern_pre_ip2_1_post
				            echo enable=0 type=2 movable=1 speed=1 width=64 height= 64 > /sys/devices/platform/mtk_srccap0/mtk_dbg/pattern_pre_ip2_0_post
				            echo "Move to next stage.... "
				            break
				        elif [ "${rst2}" == "n" ]; then
                            Pattern_Dump
                            echo "=================================================================="
				            echo "This problem might belong to SrcCap"
				            echo enable=0 type=2 movable=1 speed=1 width=64 height= 64 > /sys/devices/platform/mtk_srccap0/mtk_dbg/pattern_pre_ip2_1_post
				            echo enable=0 type=2 movable=1 speed=1 width=64 height= 64 > /sys/devices/platform/mtk_srccap0/mtk_dbg/pattern_pre_ip2_0_post
                            echo "=================================================================="
                            sleep 5
				            exit
				        fi
				    done
				    pattern="preIP2"
				    echo "Step 4-2. Invoke moving PreIP2 pattern..."
				    echo enable=1 type=2 movable=1 speed=1 width=64 height= 64 > /sys/devices/platform/mtk_srccap0/mtk_dbg/pattern_pre_ip2_1
				    echo enable=1 type=2 movable=1 speed=1 width=64 height= 64 > /sys/devices/platform/mtk_srccap0/mtk_dbg/pattern_pre_ip2_0
				    while :
				    do
				        rst2=$(IsPatternQuestion $ACT_LOG_FP)
				         if [ "${rst2}" == "y" ]; then
				            echo enable=0 type=2 movable=1 speed=1 width=64 height= 64 > /sys/devices/platform/mtk_srccap0/mtk_dbg/pattern_pre_ip2_1
				            echo enable=0 type=2 movable=1 speed=1 width=64 height= 64 > /sys/devices/platform/mtk_srccap0/mtk_dbg/pattern_pre_ip2_0
				            echo "Move to next stage.... "
				            break
				        elif [ "${rst2}" == "n" ]; then
                            Pattern_Dump
                            echo "=================================================================="
				            echo "This problem might belong to SrcCap"
				            echo enable=0 type=2 movable=1 speed=1 width=64 height= 64 > /sys/devices/platform/mtk_srccap0/mtk_dbg/pattern_pre_ip2_1
				            echo enable=0 type=2 movable=1 speed=1 width=64 height= 64 > /sys/devices/platform/mtk_srccap0/mtk_dbg/pattern_pre_ip2_0
                            echo "=================================================================="
                            sleep 5
				            exit
				        fi
				    done
				    pattern="ip1"
				    echo "Step 4-3. Invoke moving IP1 pattern..."
				    echo enable=1 type=2 movable=1 speed=1 width=64 height= 64 > /sys/devices/platform/mtk_srccap0/mtk_dbg/pattern_ip1
				    while :
				    do
				        rst2=$(IsPatternQuestion $ACT_LOG_FP)
				         if [ "${rst2}" == "y" ]; then
				            echo enable=0 type=2 movable=1 speed=1 width=64 height= 64 > /sys/devices/platform/mtk_srccap0/mtk_dbg/pattern_ip1
                            echo "=================================================================="
				            echo "This problem might belong to ATV/CVBS, HDMI, Ypbpr"
                            echo "=================================================================="
                            sleep 5
				            break
				        elif [ "${rst2}" == "n" ]; then
                            Pattern_Dump
                            echo "=================================================================="
				            echo "This problem might belong to SrcCap"
				            echo enable=0 type=2 movable=1 speed=1 width=64 height= 64 > /sys/devices/platform/mtk_srccap0/mtk_dbg/pattern_ip1
                            echo "=================================================================="
                            sleep 5
				            exit
				        fi
				    done
				    break
        fi
    done

}

disp_log_close()
{
    echo 0x1 > /sys/devices/platform/mtk-tvpqu/mtk_dbg/IsBypass_PatternTest
    echo "Finish to dump disp log..."
}
