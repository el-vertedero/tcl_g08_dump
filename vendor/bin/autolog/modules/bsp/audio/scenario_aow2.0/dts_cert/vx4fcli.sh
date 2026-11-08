#!/bin/sh

VX_TEST_PARAM_FILE=vx4_test_item.txt
VX_TEST_SUPPORT_MODULE="VX MBHL LC GEQ AEQ ILD EIL"
VX_TEST_CURRENT_UNSUPPORT_ITEM=""

INPUT_TEST_ITEM=$(echo $1 | tr a-z A-Z)   #VX MBHL LC GEQ AEQ ILD EIL
INPUT_TEST_NUM="$2"
INPUT_TEST_DEBUG=VX$(echo $3 | tr a-z A-Z)  #dbg
INPUT_INPUT_COUNT="$#"

VXCLI_HEAD="SetAdvSndProperty=DTS_VIRTUALX:CLI_CMD:"
VXCLI_TAIL=" >/sys/devices/platform/mtk-tv-offload-platform/mtk_dbg/utopia_mdb"

VX_TEST_IS_SUPPORT_ITEM=0
Check_Support()
{
    Include_zero=$(echo "$INPUT_TEST_NUM" | grep "0")
    if [ $INPUT_TEST_NUM -lt 10 ] && [ "$Include_zero" = "" ]; then
        INPUT_TEST_NUM=0$INPUT_TEST_NUM
    fi

    test_params=$(cat $VX_TEST_PARAM_FILE | grep $INPUT_TEST_ITEM"_Test"$INPUT_TEST_NUM)
    if [ $INPUT_INPUT_COUNT -lt 2 ] || [ "$test_params" = "" ]; then
        VX_TEST_IS_SUPPORT_ITEM=0
        echo -e "\033[31mnot support input $INPUT_TEST_ITEM $INPUT_TEST_NUM\033[0m"
        return
    fi

    for i in $VX_TEST_CURRENT_UNSUPPORT_ITEM
    do
        if [ "$INPUT_TEST_ITEM"_Test"$INPUT_TEST_NUM" = $i ]; then
            echo -e "\033[31mCurrent is not support $INPUT_TEST_ITEM"_Test"$INPUT_TEST_NUM\033[0m"
            VX_TEST_IS_SUPPORT_ITEM=0
            return
        fi
    done

    VX_TEST_IS_SUPPORT_ITEM=1
}

VX_Preset()
{
    #set bypass amp sound effect
    echo set Amp_Bypass > /sys/kernel/mik/MI_AOUT
    #set bypass mtksound process
    echo SetAudioDebug=MSTSOUND:debug_mode 1 >/sys/devices/platform/mtk-tv-offload-platform/mtk_dbg/utopia_mdb
    echo SetAudioDebug=MSTSOUND:spk_sndeff 0x0202 >/sys/devices/platform/mtk-tv-offload-platform/mtk_dbg/utopia_mdb
    #set pre-scal gain 0dB
    echo write_reg=0x950310[0xffff]=0x0000 >/sys/devices/platform/mtk-tv-offload-platform/mtk_dbg/utopia_mdb
    #set spk data bypass to spdif
    echo SetAudioDebug=MSTSOUND:spdif_mux 0x06 >/sys/devices/platform/mtk-tv-offload-platform/mtk_dbg/utopia_mdb
    #turn off vx fading mute
    echo SetAdvSndProperty=DTS_VIRTUALX:CLI_CMD:vx_fading_enable 0 >/sys/devices/platform/mtk-tv-offload-platform/mtk_dbg/utopia_mdb
    #reset vx 
    echo SetAdvSndProperty=DTS_VIRTUALX:CLI_CMD:reset > /sys/devices/platform/mtk-tv-offload-platform/mtk_dbg/utopia_mdb
}

#Get and set param
Apply_Param()
{
    count=0
    test_params=$(cat $VX_TEST_PARAM_FILE | grep $1 )
    test_params=$(echo $test_params | sed "s/$1=//" )
    for i in $test_params
    do
        count=$(($count+1))
        if [ $(($count % 2)) -eq 1 ]; then      #--virtualx-discard 0
            test_item=$i                        #first is param: --virtualx-discard
        else
            test_value=$i                        #second is value: 0
            VXCLI=${VXCLI_HEAD}${test_item}" "${test_value}${VXCLI_TAIL}
            if [ $INPUT_TEST_DEBUG = "VXDBG" ]; then
                echo ${test_item}" "${test_value}
            fi
            /bin/sh -c "echo $VXCLI"
        fi
    done
}

MAIN()
{
    Check_Support
    if [ $VX_TEST_IS_SUPPORT_ITEM -eq 1 ]; then

        VX_Preset
        echo "Preset vx test module ok"

        Apply_Param $INPUT_TEST_ITEM"_Params"
        Apply_Param $INPUT_TEST_ITEM"_Test"$INPUT_TEST_NUM
        echo "Apply $INPUT_TEST_ITEM Test$INPUT_TEST_NUM setting ok"
    else
        echo "Usage: sh /vendor/bin/dts_cert/vx4fcli.sh [module] [num] ..."
        echo "module: $VX_TEST_SUPPORT_MODULE"
        echo "num:    01 02..."
    fi
}

#process
MAIN
