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

IsIssueExistQuestion()
{
    local OUTPUT_FP="$1"
    message="${COLOR_GREEN} Is issue 'EXIST'? key in [y/n] to continue:  ${COLOR_REST}"
    ### This will call prompt function from utils/helpers.sh
    ### prompt(message, log_file_path)
    ###   => Use read command to ask user questions, and record it into log_file_path
    bug=$(prompt "$message" "$OUTPUT_FP")
    echo "$bug"  # Return answer
}

disp_log_open()
{
    echo 0x0 > /sys/devices/platform/mtk-tvpqu/mtk_dbg/IsBypass_PatternTest
    pattern="TCON"
    echo "Step 1. Invoke pattern_tcon..."
    echo enable=1 type=8 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/pattern_tcon
    while :
    do
    rst1=$(IsPatternQuestion $ACT_LOG_FP)
    if [ "${rst1}" == "y" ]; then
        echo "Step1.1 Disable pattern_tcon..."
        echo enable=0 type=8 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/pattern_tcon

        echo "Step1.2 Check issue is exist or not..."
        while :
        do
        rst1=$(IsIssueExistQuestion $ACT_LOG_FP)
        if [ "${rst1}" == "y" ]; then
            echo "Step1.3 Check issue is UI(Graphic)(GFX) or Video path first..."
            echo "Disable graphic blending..."
            echo 0 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/mtk_drm_GOP_BlendingEn
            while :
            do
            rst1=$(IsIssueExistQuestion $ACT_LOG_FP)
            if [ "${rst1}" == "y" ]; then
                echo "enable graphic blending..."
                echo 1 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/mtk_drm_GOP_BlendingEn
                echo "=================================================================="
                echo "It's belong to Video problem..."
                echo "=================================================================="
                sleep 5
                break
            elif [ "${rst1}" == "n" ]; then
                echo "enable graphic blending..."
                echo 1 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/mtk_drm_GOP_BlendingEn
                echo "=================================================================="
                echo "It's belong to UI(Graphic)(GFX) problem..."
                echo "please refer to this link to dispatch"
                echo "https://wiki.mediatek.inc/display/DTVMainPage/General+Graphic+OSD+Dispatch+Steps"
                echo "=================================================================="
                sleep 5
                exit
            fi
            done
            break
        elif [ "${rst1}" == "n" ]; then
            echo "Move to Step 2. Invoke pattern_gfx.... "
            break
        fi
        done
        break
    elif [ "${rst1}" == "n" ]; then
        Pattern_Dump
        echo enable=0 type=8 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/pattern_tcon
        echo "This problem might belong to Panel"
        echo "Dump the register"
        echo 0xA3A0 >> /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
        cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
        echo 0xA3A1 >> /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
        cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
        echo 0xA3A2 >> /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
        cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
        echo 0xA3A3 >> /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
        cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
        echo 0xA3A4 >> /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
        cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
        echo 0xA3A5 >> /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
        cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
        echo 0xA3A6 >> /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
        cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
        echo 0x2427 >> /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
        cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
        echo 0x2428 >> /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
        cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_reg_dump
        # cat sysfs
        echo "Frame Sync Status"
        cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/frame_sync_status
        echo "Panel Mode ID Sel Status"
        cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_mode_ID_Sel
        echo "Panel MOD Status"
        cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_mod_status
        pattern="GFX"
        echo "Step 1-1 GFX Pattern..."
        echo enable=1 type=2 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/pattern_gfx
        while :
        do
            rst1=$(IsPatternQuestion $ACT_LOG_FP)
            if [ "${rst1}" == "y" ]; then
                echo "GFX Okay "
                break
            elif [ "${rst1}" == "n" ]; then
                echo "GFX Failed"
                break
        fi
        done

        pattern="Multi Win"
        echo "1-2 Multi Win...."
        echo 0 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/mtk_drm_GOP_BlendingEn
        echo enable=1 type=2 force_timing=1 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/pattern_multiwin
        while :
        do
            rst1=$(IsPatternQuestion $ACT_LOG_FP)
            if [ "${rst1}" == "y" ]; then
                echo enable=0 type=2 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/pattern_multiwin
                echo "Move to next stage.... "
                break
            elif [ "${rst1}" == "n" ]; then
                echo enable=0 type=2 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/pattern_multiwin
                echo "=================================================================="
                echo "This problem might be belong to render stage. Owner: Render DD Panel"
                echo "=================================================================="
                sleep 5
                break
            fi
            echo 1 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/mtk_drm_GOP_BlendingEn
        done
        pattern="Back Light"
        echo "Step 1-4 Back Light Test"
        cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_Backlight_off
        while :
        do
            rst1=$(IsPatternQuestion $ACT_LOG_FP)
            if [ "${rst1}" == "y" ]; then
                echo "Back Light control pass"
                break
            elif [ "${rst1}" == "n" ]; then
                echo "Back Light control failed"
                cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_Backlight_on
                exit
            fi
        done
        cat /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/panel_Backlight_on
        exit
    fi
    done
    pattern="GFX"
    echo "Step 2. Invoke pattern_gfx..."
    echo enable=1 type=2 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/pattern_gfx
    while :
    do
    rst1=$(IsPatternQuestion $ACT_LOG_FP)
    if [ "${rst1}" == "y" ]; then
        echo enable=0 type=2 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/pattern_gfx
        echo "Move to next stage.... "
        break
    elif [ "${rst1}" == "n" ]; then
        Pattern_Dump
        echo enable=0 type=2 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/pattern_gfx
        echo "=================================================================="
        echo "This problem might belong to GFX"
        echo "=================================================================="
        sleep 5
        exit
    fi
    done
    pattern="Multi Win"
    echo "Step 3. Invoke pattern_multiwin..."
    echo 0 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/mtk_drm_GOP_BlendingEn
    echo enable=1 type=2 force_timing=1 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/pattern_multiwin
    while :
    do
    rst1=$(IsPatternQuestion $ACT_LOG_FP)
    if [ "${rst1}" == "y" ]; then
        echo enable=0 type=2 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/pattern_multiwin
        echo 1 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/mtk_drm_GOP_BlendingEn
        echo "Move to next stage.... "
        break
    elif [ "${rst1}" == "n" ]; then
        Pattern_Dump
        echo enable=0 type=2 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/pattern_multiwin
        echo 1 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/mtk_drm_GOP_BlendingEn
        echo "=================================================================="
        echo "This problem might belong to Render"
        echo "=================================================================="
        sleep 5
        exit
    fi
    done

    pattern="MJC/OPDRAM"
    echo "Step 4. Invoke both pattern_frc and pattern_opdram..."
    echo enable=1 type=5 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/pattern_frc
    echo enable=1 type=0 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/pattern_opdram
    while :
    do
    rst1=$(IsPatternQuestion $ACT_LOG_FP)
    if [ "${rst1}" == "y" ]; then
        echo enable=0 type=5 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/pattern_frc
        echo enable=0 type=0 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/pattern_opdram
        echo "Move to next stage.... "
        break
    elif [ "${rst1}" == "n" ]; then
        Pattern_Dump
        echo enable=0 type=5 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/pattern_frc
        echo enable=0 type=0 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/pattern_opdram
        MJC_Check
        rst1=$?
        if [ "${rst1}" == "1" ]; then
            echo "=================================================================="
            echo "This problem might belong to MJC."
            echo "=================================================================="
            sleep 5
            exit
        elif [ "${rst1}" == 0 ]; then
            echo "=================================================================="
            echo "This problem might belong to Render"
            echo "=================================================================="
            sleep 5
            exit
        fi
        exit
    fi
    done

    pattern="vop"
    echo "Step 5-1. Invoke pattern_vop..."
    echo window=0 enable=1 type=2 force_timing=1 > /sys/devices/platform/mtk-pq/mtk_dbg/pattern_vop
    echo window=0 enable=1 type=2 force_timing=1 > /sys/devices/platform/mtk-pq/mtk_dbg/pattern_vop
    while :
    do
        rst1=$(IsPatternQuestion $ACT_LOG_FP)
        if [ "${rst1}" == "y" ]; then
            echo window=0 enable=0 type=2 force_timing=0 > /sys/devices/platform/mtk-pq/mtk_dbg/pattern_vop
            echo "Move to next stage.... "
            break
        elif [ "${rst1}" == "n" ]; then
            Pattern_Dump
            echo window=0 enable=0 type=2 force_timing=0 > /sys/devices/platform/mtk-pq/mtk_dbg/pattern_vop
            echo "=================================================================="
            echo "This problem might belong to PQ path."
            echo "=================================================================="
            sleep 5
            exit
        fi
    done
    pattern="di"
    echo "Step 5-2. Invoke pattern_di..."
    echo window=0 enable=1 type=2 force_timing=1 > /sys/devices/platform/mtk-pq/mtk_dbg/pattern_di
    while :
    do
        rst1=$(IsPatternQuestion $ACT_LOG_FP)
        if [ "${rst1}" == "y" ]; then
            echo window=0 enable=0 type=2 force_timing=0 > /sys/devices/platform/mtk-pq/mtk_dbg/pattern_di
            echo "Move to next stage.... "
            break
        elif [ "${rst1}" == "n" ]; then
            Pattern_Dump
            echo window=0 enable=0 type=2 force_timing=0 > /sys/devices/platform/mtk-pq/mtk_dbg/pattern_di
            echo "=================================================================="
            echo "This problem might belong to PQ path."
            echo "=================================================================="
            sleep 5
            exit
        fi
    done
    pattern="ip2"
    echo "Step 5-3. Invoke pattern_ip2..."
    echo window=0 enable=1 type=2 force_timing=1 > /sys/devices/platform/mtk-pq/mtk_dbg/pattern_ip2
    while :
    do
        rst1=$(IsPatternQuestion $ACT_LOG_FP)
        if [ "${rst1}" == "y" ]; then
            echo window=0 enable=0 type=2 force_timing=0 > /sys/devices/platform/mtk-pq/mtk_dbg/pattern_ip2
            echo "Move to next stage.... "
            break
        elif [ "${rst1}" == "n" ]; then
            Pattern_Dump
            echo window=0 enable=0 type=2 force_timing=0 > /sys/devices/platform/mtk-pq/mtk_dbg/pattern_ip2
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
            pattern="b2r"
            echo "Step 6. Invoke pattern_b2r..."
            echo 0x0 > /sys/devices/platform/mtk-tvpqu/mtk_dbg/IsBypass_PatternTest
            echo window=0 enable=1 type=0 r=77 g=14 b=108 > /sys/devices/platform/mtk-pq/mtk_dbg/pattern_b2r_dma
            while :
            do
                rst2=$(IsPatternQuestion $ACT_LOG_FP)
                if [ "${rst2}" == "y" ]; then
                    echo 0x0 > /sys/devices/platform/mtk-tvpqu/mtk_dbg/IsBypass_PatternTest
                    echo window=0 enable=0 type=0 r=77 g=14 b=108 > /sys/devices/platform/mtk-pq/mtk_dbg/pattern_b2r_dma
                    echo "=================================================================="
                    echo "This problem might not belong to disp team, please check with VDEC"
                    echo "https://wiki.mediatek.inc/display/DTVMainPage/Codec+Mapping"
                    echo "=================================================================="
                    sleep 5
                    break
                elif [ "${rst2}" == "n" ]; then
                    Pattern_Dump
                    echo 0x0 > /sys/devices/platform/mtk-tvpqu/mtk_dbg/IsBypass_PatternTest
                    echo window=0 enable=0 type=0 r=77 g=14 b=108 > /sys/devices/platform/mtk-pq/mtk_dbg/pattern_b2r_dma
                    echo "=================================================================="
                    echo "This problem might belong to B2R."
                    echo "=================================================================="
                    sleep 5
                    exit
                fi
            done
            break
        elif [ "${rst1}" == "y" ]; then
                    pattern="preIP2_post"
                    echo "Step 6-1. Invoke PreIP2 post pattern..."
                    echo enable=1 type=2 > /sys/devices/platform/mtk_srccap1/mtk_dbg/pattern_pre_ip2_1_post
                    echo enable=1 type=2 > /sys/devices/platform/mtk_srccap0/mtk_dbg/pattern_pre_ip2_0_post
                    while :
                    do
                        rst2=$(IsPatternQuestion $ACT_LOG_FP)
                         if [ "${rst2}" == "y" ]; then
                            echo enable=0 type=2 > /sys/devices/platform/mtk_srccap1/mtk_dbg/pattern_pre_ip2_1_post
                            echo enable=0 type=2 > /sys/devices/platform/mtk_srccap0/mtk_dbg/pattern_pre_ip2_0_post
                            echo "Move to next stage.... "
                            break
                        elif [ "${rst2}" == "n" ]; then
                            Pattern_Dump
                            echo "=================================================================="
                            echo "This problem might belong to SrcCap"
                            echo enable=0 type=2 > /sys/devices/platform/mtk_srccap1/mtk_dbg/pattern_pre_ip2_1_post
                            echo enable=0 type=2 > /sys/devices/platform/mtk_srccap0/mtk_dbg/pattern_pre_ip2_0_post
                            echo "=================================================================="
                            sleep 5
                            exit
                        fi
                    done
                    pattern="preIP2"
                    echo "Step 6-2. Invoke PreIP2 pattern..."
                    echo enable=1 type=2 > /sys/devices/platform/mtk_srccap1/mtk_dbg/pattern_pre_ip2_1
                    echo enable=1 type=2 > /sys/devices/platform/mtk_srccap0/mtk_dbg/pattern_pre_ip2_0
                    while :
                    do
                        rst2=$(IsPatternQuestion $ACT_LOG_FP)
                         if [ "${rst2}" == "y" ]; then
                            echo enable=0 type=2 > /sys/devices/platform/mtk_srccap1/mtk_dbg/pattern_pre_ip2_1
                            echo enable=0 type=2 > /sys/devices/platform/mtk_srccap0/mtk_dbg/pattern_pre_ip2_0
                            echo "Move to next stage.... "
                            break
                        elif [ "${rst2}" == "n" ]; then
                            Pattern_Dump
                            echo "=================================================================="
                            echo "This problem might belong to SrcCap"
                            echo enable=0 type=2 > /sys/devices/platform/mtk_srccap1/mtk_dbg/pattern_pre_ip2_1
                            echo enable=0 type=2 > /sys/devices/platform/mtk_srccap0/mtk_dbg/pattern_pre_ip2_0
                            echo "=================================================================="
                            sleep 5
                            exit
                        fi
                    done
                    pattern="ip1"
                    echo "Step 6-3. Invoke IP1 pattern..."
                    echo enable=1 type=2 > /sys/devices/platform/mtk_srccap0/mtk_dbg/pattern_ip1
                    while :
                    do
                        rst2=$(IsPatternQuestion $ACT_LOG_FP)
                         if [ "${rst2}" == "y" ]; then
                            echo enable=0 type=2 > /sys/devices/platform/mtk_srccap0/mtk_dbg/pattern_ip1
                            echo "=================================================================="
                            echo "This problem might belong to ATV/CVBS, HDMI, Ypbpr"
                            echo "=================================================================="
                            sleep 5
                            break
                        elif [ "${rst2}" == "n" ]; then
                            Pattern_Dump
                            echo "=================================================================="
                            echo "This problem might belong to SrcCap"
                            echo enable=0 type=2 > /sys/devices/platform/mtk_srccap0/mtk_dbg/pattern_ip1
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
    echo 1 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/mtk_drm_GOP_BlendingEn
    echo "Finish to dump disp log..."
}
