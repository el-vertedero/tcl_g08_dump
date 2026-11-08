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
    pattern="pafrc"
    echo "Step 1 Invoke pattern_pafrc..."
    echo window=0 enable=1 type=2 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/pattern_pafrc_post
    while :
    do
        rst1=$(IsPatternQuestion $ACT_LOG_FP)
        if [ "${rst1}" == "y" ]; then
            echo window=0 enable=0 type=2 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/pattern_pafrc_post
            echo "Move to next stage.... "
            break
        elif [ "${rst1}" == "n" ]; then
            Pattern_Dump
            echo window=0 enable=0 type=2 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/pattern_pafrc_post
            echo "=================================================================="
            echo "This problem might be belong to render stage. Owner: Render DD Panel"
            echo "=================================================================="
            sleep 5
            break
        fi
    done

    pattern="multi win"
    echo "Step 2 Invoke pattern_multiwin..."
    echo enable=1 type=2 force_timing=1 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/pattern_multiwin
    while :
    do
        rst1=$(IsPatternQuestion $ACT_LOG_FP)
        if [ "${rst1}" == "y" ]; then
            echo enable=0 type=2 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/pattern_multiwin
            echo "Move to next stage.... "
            break
        elif [ "${rst1}" == "n" ]; then
            Pattern_Dump
            echo enable=0 type=2 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/pattern_multiwin
            echo "=================================================================="
            echo "This problem might be belong to render stage. Owner: Render"
            echo "=================================================================="
            sleep 5
            exit
        fi
    done

    MJC_Check
    rst1=$?
    if [ "${rst1}" == 1 ]; then
        pattern="MJC"
        echo "Step 3. Invoke pattern_frc..."
        echo enable=1 type=5 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/pattern_frc
        while :
        do
            rst1=$(IsPatternQuestion $ACT_LOG_FP)
            if [ "${rst1}" == "y" ]; then
                echo enable=0 type=5 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/pattern_frc
                echo "Move to next stage.... "
                break
            elif [ "${rst1}" == "n" ]; then
                Pattern_Dump
                echo enable=0 type=5 > /sys/devices/platform/mediatek-drm-tv-kms/mtk_dbg/pattern_frc
                echo "=================================================================="
                echo "This problem might belong to MJC."
                echo "=================================================================="
                sleep 5
                exit
            fi
        done
    fi

    pattern="vip in"
    echo "Step 4 Invoke pattern_vip_in..."
    echo window=0 enable=1 type=2 force_timing=1 > /sys/devices/platform/mtk-pq/mtk_dbg/pattern_vip_in
	echo window=0 enable=1 type=2 force_timing=1 > /sys/devices/platform/mtk-pq/mtk_dbg/pattern_vip_in
    while :
    do
        rst1=$(IsPatternQuestion $ACT_LOG_FP)
        if [ "${rst1}" == "y" ]; then
            echo window=0 enable=0 type=2 force_timing=0 > /sys/devices/platform/mtk-pq/mtk_dbg/pattern_vip_in
            echo "Move to next stage.... "
            break
        elif [ "${rst1}" == "n" ]; then
            Pattern_Dump
            echo window=0 enable=0 type=2 force_timing=0 > /sys/devices/platform/mtk-pq/mtk_dbg/pattern_vip_in
            echo "=================================================================="
            echo "This problem might belong to PQ path."
            echo "=================================================================="
            sleep 5
            exit
        fi
    done
    pattern="di"
    echo "Step 5 Invoke pattern_di"
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
    echo "Step 6 Invoke pattern_ip2..."
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
            echo "Step 7-1. Invoke pattern_b2r..."
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
            pattern="pre_ip2_0"
            echo "Step 7-2. Invoke pattern_pre_ip2_0 pattern..."
            echo window=0 enable=1 type=2 > /sys/devices/platform/mtk_srccap0/mtk_dbg/pattern_pre_ip2_0
            while :
            do
                rst2=$(IsPatternQuestion $ACT_LOG_FP)
                if [ "${rst2}" == "y" ]; then
                    echo window=0 enable=0 type=2 > /sys/devices/platform/mtk_srccap0/mtk_dbg/pattern_pre_ip2_0
                    echo "=================================================================="
                    echo "This problem might belong to Source Signal"
                    echo "=================================================================="
                    sleep 5
                    break
                elif [ "${rst2}" == "n" ]; then
                    Pattern_Dump
                    echo "=================================================================="
                    echo "This problem might belong to SrcCap"
                    echo window=0 enable=0 type=2 > /sys/devices/platform/mtk_srccap0/mtk_dbg/pattern_pre_ip2_0
                    echo "=================================================================="
                    sleep 5
                    exit
                fi
            done
            pattern="ip1"
            echo "Step 7-3. Invoke pattern_ip1 pattern..."
            echo window=0 enable=1 type=2 > /sys/devices/platform/mtk_srccap0/mtk_dbg/pattern_ip1
            while :
            do
                rst2=$(IsPatternQuestion $ACT_LOG_FP)
                if [ "${rst2}" == "y" ]; then
                    echo window=0 enable=0 type=2 > /sys/devices/platform/mtk_srccap0/mtk_dbg/pattern_ip1
                    echo "=================================================================="
                    echo "This problem might belong to Source decoder"
                    echo "=================================================================="
                    sleep 5
                    break
                elif [ "${rst2}" == "n" ]; then
                    Pattern_Dump
                    echo window=0 enable=0 type=2 > /sys/devices/platform/mtk_srccap0/mtk_dbg/pattern_ip1
                    echo "=================================================================="
                    echo "This problem might belong to SrcCap"
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
