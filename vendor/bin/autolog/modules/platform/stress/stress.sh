#!/usr/bin/env sh
#set -x
source "$AUTOLOG_HOME/utils/imports.sh"
ImportUtil "loggers.sh"
ImportUtil "colors.sh"
ImportUtil "sys.sh"

#========================================================
#          Import modules functions you need
# if you want to call modules/bsp/audio/audio.sh
#                  =>  Import bsp audio audio.sh
#========================================================

#========================================================


question_doAction()
{
  local OUTPUT_FP="$1"
  local sub_message="$2"
  message="${COLOR_RED} Please do ${sub_message} now. After ${sub_message} is finished, input Y [Y/N]? ${COLOR_REST}"
  ### This will call prompt function from utils/helpers.sh
  ### prompt(message, log_file_path)
  ###   => Use read command to ask user questions, and record it into log_file_path
  bug=$(prompt "$message" "$OUTPUT_FP")
  echo "$bug"  # Return answer
}


INIT_PLATFORM_STRESS_STRESS()
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
  echo "Initialize PLATFORM.STRESS.STRESS log configs..."
  SCENARIO_NUM="$1"

  #cancel autolog kernel log recording, using stress_test.sh
  #to record kernel log.
  KillKernelLog
  KillOrphanDmesg
#  set -e

  #========================================================
  #                   Common part  (CAUTION!!)
  #  Commands defined here will been executed while user
  #  call this function EVERY TIME.
  #========================================================


  ### Enable logs by scenario number
  ### You can setup kinds of scenario here
  ### Scenario Number is
  case "$SCENARIO_NUM" in
    "10001")
      ######################################################
      #              ( 10001 )  Scenario A - Record logging stress log
      #
      # Record stress log.
      #
      ######################################################
      echo "IN 10001"
      sh $AUTOLOG_MODULES_DIR/platform/stress/stress_test_AOW.sh start SQA $LOG_DIR &
    ;;
    "10101")
      ######################################################
      #              ( 10101 )  Scenario A - Record logging stress log
      #
      # Record stress log with broadcast and displinkvdec log.
      #
      ######################################################
      echo "IN 10101"
      sh $AUTOLOG_MODULES_DIR/platform/stress/enable_broadcast.sh
      sh $AUTOLOG_MODULES_DIR/platform/stress/enable_displinkvdec.sh
      sh $AUTOLOG_MODULES_DIR/platform/stress/stress_test_AOW.sh start SQA $LOG_DIR &
    ;;
    "10111")
      ######################################################
      #              ( 10111 )  Scenario A - Record logging stress log
      #
      # Record stress log with broadcast, disp_mm and displinkvdec log.
      #
      ######################################################
      echo "IN 10111"
      sh $AUTOLOG_MODULES_DIR/platform/stress/enable_broadcast.sh
      sh $AUTOLOG_MODULES_DIR/platform/stress/enable_displinkvdec.sh
      sh $AUTOLOG_MODULES_DIR/platform/stress/enable_mm_disp.sh
      sh $AUTOLOG_MODULES_DIR/platform/stress/stress_test_AOW.sh start SQA $LOG_DIR &
    ;;

    "10201")
      ######################################################
      #              ( 10201 )  Scenario A - Record logging stress log
      #
      # Record stress log with broadcast log.
      #
      ######################################################
      echo "IN 10201"
      sh $AUTOLOG_MODULES_DIR/platform/stress/enable_broadcast.sh
      sh $AUTOLOG_MODULES_DIR/platform/stress/stress_test_AOW.sh start SQA $LOG_DIR &
    ;;
    "10301")
      ######################################################
      #              ( 10301 )  Scenario A - Record logging stress log
      #
      # Record stress log with disp_mm log.
      #
      ######################################################
      echo "IN 10301"
      sh $AUTOLOG_MODULES_DIR/platform/stress/enable_mm_disp.sh
      sh $AUTOLOG_MODULES_DIR/platform/stress/stress_test_AOW.sh start SQA $LOG_DIR &
    ;;
    "10401")
      ######################################################
      #              ( 10401 )  Scenario A - Record logging stress log
      #
      # Record stress log with displinkvdec log.
      #
      ######################################################
      echo "IN 10401"
      sh $AUTOLOG_MODULES_DIR/platform/stress/enable_displinkvdec.sh
      sh $AUTOLOG_MODULES_DIR/platform/stress/stress_test_AOW.sh start SQA $LOG_DIR &
    ;;
    "10102")
      ######################################################
      #              ( 10102 )  Scenario A - collect stress log
      #
      # Collect stress log.
      #
      ######################################################
      echo "IN 10102"
      sh $AUTOLOG_MODULES_DIR/platform/stress/stress_test_AOW.sh end $LOG_DIR
    ;;

    *)
      ######################################################
      #              ( * )  Scenario not defined
      #
      ######################################################
      echo "SCENARIO_NUM='$SCENARIO_NUM' is not defined in stress.sh, please check or contact related RD"
      exit 1
    ;;
  esac

#  set +e
  echo -e "Init Platform Stress Stress log Success!\n"
}


CLOSE_PLATFORM_STRESS_STRESS()
{
#  set -e

#  set +e
  echo -e "Close Platform Stress Stress log Success!\n"
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

  echo "LOG_FP=$LOG_FP"
  echo "ACT_LOG_FP=$ACT_LOG_FP"
  echo "LOG_DIR=$LOG_DIR"
  echo "LOG_DT=$LOG_DT"
  echo "SCENARIO_NUM=$SCENARIO_NUM"
  #echo "MODULE_ARG1=$MODULE_ARG1"
  #echo "MODULE_ARG2=$MODULE_ARG2"
  #echo "MODULE_ARG3=$MODULE_ARG3"

  #========================================================
  #                   Main codes here
  # You can modify codes under this section
  #========================================================

  ### Import functions from other modules/scripts
  ### DO SOMETHING
  INIT_PLATFORM_STRESS_STRESS $SCENARIO_NUM


  ### Generate Extra Log Path that follow the naming rule of Autolog


  ################################
  ### Demo interactive flow
  # echo "-------- Interactive demo --------"
  ### Questions flow control
  #rst1=$(question1 $ACT_LOG_FP)
  #if [ "$rst1" = "Y" ] || [ "$rst1" = "y" ]; then
  #  rst2=$(question2 $ACT_LOG_FP)
  #fi

  ################################
  ### CLOSE LOGs
  CLOSE_PLATFORM_STRESS_STRESS

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
