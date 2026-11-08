###############################################################################
# Copyright Statement:                                                         #
#                                                                              #
# This software/firmware and related documentation ("MediaTek Software") are   #
# protected under relevant copyright laws. The information contained herein is #
# confidential and proprietary to MediaTek Inc. and/or its licensors. Without  #
# the prior written permission of MediaTek inc. and/or its licensors, any      #
# reproduction, modification, use or disclosure of MediaTek Software, and      #
# information contained herein, in whole or in part, shall be strictly         #
# prohibited.                                                                  #
#                                                                              #
# Copyright  (C) [2021]  MediaTek Inc. All rights reserved.                    #
#                                                                              #
# BY OPENING THIS FILE, RECEIVER HEREBY UNEQUIVOCALLY ACKNOWLEDGES AND AGREES  #
# THAT THE SOFTWARE/FIRMWARE AND ITS DOCUMENTATIONS ("MEDIATEK SOFTWARE")      #
# RECEIVED FROM MEDIATEK AND/OR ITS REPRESENTATIVES ARE PROVIDED TO RECEIVER   #
# ON AN "AS-IS" BASIS ONLY. MEDIATEK EXPRESSLY DISCLAIMS ANY AND ALL           #
# WARRANTIES, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED     #
# WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE OR           #
# NONINFRINGEMENT. NEITHER DOES MEDIATEK PROVIDE ANY WARRANTY WHATSOEVER WITH  #
# RESPECT TO THE SOFTWARE OF ANY THIRD PARTY WHICH MAY BE USED BY,             #
# INCORPORATED IN, OR SUPPLIED WITH THE MEDIATEK SOFTWARE, AND RECEIVER AGREES #
# TO LOOK ONLY TO SUCH THIRD PARTY FOR ANY WARRANTY CLAIM RELATING THERETO.    #
# RECEIVER EXPRESSLY ACKNOWLEDGES THAT IT IS RECEIVER'S SOLE RESPONSIBILITY TO #
# OBTAIN FROM ANY THIRD PARTY ALL PROPER LICENSES CONTAINED IN MEDIATEK        #
# SOFTWARE. MEDIATEK SHALL ALSO NOT BE RESPONSIBLE FOR ANY MEDIATEK SOFTWARE   #
# RELEASES MADE TO RECEIVER'S SPECIFICATION OR TO CONFORM TO A PARTICULAR      #
# STANDARD OR OPEN FORUM. RECEIVER'S SOLE AND EXCLUSIVE REMEDY AND MEDIATEK'S  #
# ENTIRE AND CUMULATIVE LIABILITY WITH RESPECT TO THE MEDIATEK SOFTWARE        #
# RELEASED HEREUNDER WILL BE, AT MEDIATEK'S OPTION, TO REVISE OR REPLACE THE   #
# MEDIATEK SOFTWARE AT ISSUE, OR REFUND ANY SOFTWARE LICENSE FEES OR SERVICE   #
# CHARGE PAID BY RECEIVER TO MEDIATEK FOR SUCH MEDIATEK SOFTWARE AT ISSUE.     #
#                                                                              #
# The following software/firmware and/or related documentation ("MediaTek      #
# Software") have been modified by MediaTek Inc. All revisions are subject to  #
# any receiver's applicable license agreements with MediaTek Inc.              #
################################################################################

#!/usr/bin/env sh
#set -x

. "$AUTOLOG_HOME/utils/imports.sh"
ImportUtil "loggers.sh"
ImportUtil "colors.sh"
ImportUtil "sys.sh"

#========================================================
#          Import modules functions you need
# if you want to call modules/bsp/audio/audio.sh
#                  =>  Import bsp audio audio.sh
#========================================================
Import bsp optee optee.sh

INIT_PLATFORM_SECURITY_DTCPIP()
{

  #========================================================
  #                   Define Scenarios
  # In this section, you have to design log switches for
  #   each kinds of scenarios.
  # For example:
  #    Scenario A (10101) is related to log_a, log_b, log_c
  #        => Enable log_a, log_b, log_c
  #    Scenario A' (10102) is a light version of scenario A.
  #      only enable log_a, log_b
  #        => Enable log_a, log_b
  #    Scenario B (10201) is only related to log_b
  #        => Just have to enable log_b
  #========================================================
  echo "Initialize PLATFORM.SECURITY.DTCPIP log configs..."
  SCENARIO_NUM="$1"
#  set -e

  #========================================================
  #                   Common part  (CAUTION!!)
  #  Commands defined here will been executed while user
  #  call this function EVERY TIME.
  #========================================================
  DTCPIP_LOG_FP="$LOG_DIR/$LOG_DT-platform_security_dtcpip.sh_${SCENARIO_NUM}.log"
  echo "DTCPIP_LOG_FP: $DTCPIP_LOG_FP"

  case "$AUTOLOG_PLATFORM" in
    "android")
        #############################################################
        #              ( android )  Android platfrom
        #############################################################
        echo "[DTCPIP] Android"
        DTCPIP_LOG_INI_PATH="/data/vendor"
    ;;
    *)
        ######################################################
        #              ( * )  platfrom not defined
        #
        ######################################################
        echo "[DTCPIP] AUTOLOG_PLATFORM='$AUTOLOG_PLATFORM' is not defined in autolog.sh"
        exit 1
    ;;
  esac

  ### Enable logs by scenario number
  ### You can setup kinds of scenario here
  ### Scenario Number is
  case "$SCENARIO_NUM" in
    "10101")
      #############################################################
      #              ( 10101 )  Scenario A - enable normal log
      #
      # Enable dtcpip normal log
      #
      #############################################################
      echo "IN DTCPIP 10101"

#      mkdir -p $DTCPIP_LOG_INI_PATH
      touch $DTCPIP_LOG_INI_PATH/dtcpiplog.ini
      chmod o+rx $DTCPIP_LOG_INI_PATH/dtcpiplog.ini
      cat > $DTCPIP_LOG_INI_PATH/dtcpiplog.ini << EOF
ta_log_level=3
EOF
      sync
      if [ "$AUTOLOG_PLATFORM" = "android" ]; then
        chcon -R u:object_r:vendor_media_data_file:s0 $DTCPIP_LOG_INI_PATH/dtcpiplog.ini
        logcat -c
#        kill `ps -A | grep dtcpip | grep service | awk '{print $2}'`
        logcat -v threadtime > $DTCPIP_LOG_FP&
      fi

      INIT_BSP_OPTEE_OPTEE 10002
    ;;
    "10102")
      #############################################################
      #              ( 10102 )  Scenario A - enable more tee log
      #
      # Enable more log for tee issue
      #
      #############################################################
      echo "IN DTCPIP 10102"

#      mkdir -p $DTCPIP_LOG_INI_PATH
      touch $DTCPIP_LOG_INI_PATH/dtcpiplog.ini
      chmod o+rx $DTCPIP_LOG_INI_PATH/dtcpiplog.ini
      cat > $DTCPIP_LOG_INI_PATH/dtcpiplog.ini << EOF
ta_log_level=6
EOF
      sync
      if [ "$AUTOLOG_PLATFORM" = "android" ]; then
        chcon -R u:object_r:vendor_media_data_file:s0 $DTCPIP_LOG_INI_PATH/dtcpiplog.ini
        logcat -c
#        kill `ps -A | grep dtcpip | grep service | awk '{print $2}'`
        logcat -v threadtime > $DTCPIP_LOG_FP&
      fi

      INIT_BSP_OPTEE_OPTEE 10504
    ;;
    "10201")
      ###################################################################
      #              ( 10201 )  Scenario A - reset to default log level
      #
      # reset to default dtcpip log level
      #
      ###################################################################
      echo "IN DTCPIP 10201"

      rm -f $DTCPIP_LOG_INI_PATH/dtcpiplog.ini
      sync
      if [ "$AUTOLOG_PLATFORM" = "android" ]; then
        logcat -c
#        kill `ps -A | grep dtcpip | grep service | awk '{print $2}'`
        logcat -v threadtime > $DTCPIP_LOG_FP&
      fi
    ;;
    *)
      ######################################################
      #              ( * )  Scenario not defined
      #
      ######################################################
      echo "SCENARIO_NUM='$SCENARIO_NUM' is not defined in dtcpip.sh, please check or contact related RD"
      exit 1
    ;;
  esac

  echo -e "Init Platform Security dtcpip log Success!\n"
}

CLOSE_PLATFORM_SECURITY_DTCPIP()
{
  if [ "$AUTOLOG_PLATFORM" = "android" ]; then
    kill `pidof logcat`
  fi

#  set -e
  CLOSE_BSP_OPTEE_OPTEE
#  set +e
  echo -e "Close Platform Security dtcpip log Success!\n"
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
  MODULE_ARG1=$1
  MODULE_ARG2=$2
  MODULE_ARG3=$3

  echo "LOG_FP=$LOG_FP"
  echo "ACT_LOG_FP=$ACT_LOG_FP"
  echo "LOG_DIR=$LOG_DIR"
  echo "LOG_DT=$LOG_DT"
  echo "SCENARIO_NUM=$SCENARIO_NUM"
  echo "MODULE_ARG1=$MODULE_ARG1"
  echo "MODULE_ARG2=$MODULE_ARG2"
  echo "MODULE_ARG3=$MODULE_ARG3"

  #========================================================
  #                   Main codes here
  # You can modify codes under this section
  #========================================================

  ### Import functions from other modules/scripts
  ### DO SOMETHING
  OpenCommandDebuger $INIT_HISTORY_FP
  INIT_PLATFORM_SECURITY_DTCPIP $SCENARIO_NUM
  CloseCommandDebuger
  PrintCommandDebuger $INIT_HISTORY_FP

  #PrintCpuMemUsage "$ACT_LOG_FP"

  #--------------------------------------
  #Reproduce issue and finishing record.
  echo -e "!!! After dtcpip issue appears, press [enter] to finishing recording !!!"
  read "abc"

  ################################
  ### CLOSE LOGs
  #PrintCpuMemUsage "$ACT_LOG_FP"
  CLOSE_PLATFORM_SECURITY_DTCPIP

  echo
  echo "================================"
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
