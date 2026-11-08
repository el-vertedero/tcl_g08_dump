#!/bin/sh

AUTOLOG_VERSION="v1.1.2"


INIT_DISP_DUMP_FOLDER()
{
  DOMAIN_DUMP_LOG_DIR=$AUTOLOG_LOG_DIR/dump
  mkdir $DOMAIN_DUMP_LOG_DIR

  DOMAIN_DISPLAY_DUMP_LOG_DIR=$DOMAIN_DUMP_LOG_DIR/display
  mkdir $DOMAIN_DISPLAY_DUMP_LOG_DIR
  export DOMAIN_DISPLAY_DUMP_LOG_DIR
}

GetScriptPath()
{
     script_fp="$0"
     # While $script_fp is a symlink
     while [ -h "$script_fp" ]; do
          temp_dir="$( cd -P "$( dirname "$script_fp" )" && pwd )"
          script_fp="$( readlink "$script_fp" )"
          # If $script_fp was a relative symlink (so no "/" as prefix, need to find base dir
          [[ $script_fp != /* ]] && script_fp="$temp_dir/$script_fp"
     done
     temp_dir="$( cd -P "$( dirname "$script_fp" )" && pwd )"

     echo "$temp_dir";
     return
}

##support short command redirect
EXEC_FILE_PATH="$(GetScriptPath "$0")"

if [ -f "$EXEC_FILE_PATH/autolog/autolog.sh" ]; then
  echo "current in $EXEC_FILE_PATH, redirect into ./autolog/ ......"
  sh $EXEC_FILE_PATH/autolog/autolog.sh "$@"
else

if [ -z $AUTOLOG_HOME ]; then
  AUTOLOG_HOME="$(GetScriptPath "$0")"
  export AUTOLOG_HOME="$AUTOLOG_HOME"
fi

### System parameters (DO NOT MODIFY ANYTHING!!)
PID=$$

# set required parameters
AUTOLOG_MODULES_DIR="$AUTOLOG_HOME/modules"
export AUTOLOG_MODULES_DIR
AUTOLOG_UTILS_DIR="$AUTOLOG_HOME/utils"
export AUTOLOG_UTILS_DIR

# Detect system info
if [ "$(echo $OSTYPE)" ]; then
  AUTOLOG_PLATFORM="linux"
elif [ "$(echo $KSH_VERSION)" ]; then
  AUTOLOG_PLATFORM="android"
else
  AUTOLOG_PLATFORM="unknown"
fi
export AUTOLOG_PLATFORM

# import modules
. "$AUTOLOG_HOME/utils/imports.sh"
. "$AUTOLOG_HOME/utils/colors.sh"
. "$AUTOLOG_HOME/utils/sys.sh"
. "$AUTOLOG_HOME/utils/loggers.sh"


#=======================================================
#                  Help functions
#=======================================================
helpFunction()
{
   echo ""
   echo "Autolog Framework. Version: $AUTOLOG_VERSION"
   echo " Usage: $0 FunctionName ModuleName ScriptName ScenarioNum [script_arg1 script_arg2 ...] [optional-arguments]"
   echo -e "        Pass arguments for script needs."
   echo -e ""
   echo -e "    Options:"
   echo -e "        -h|--help\tShow help messages"
   echo -e "        -o|--output_dir\tSpecify the output path"
   echo -e "        -s|--screen\tRecord terminal session and output as file"
   echo -e "        -l|--level\tCustomize printk level before open dmesg, defualt is \"0\". ex: -l \"0\" or -l=\"0 4 4 7\""
   exit 1 # Exit script after printing help
}

#=======================================================
#                  Define arguments
#=======================================================
INTERACTIVE_ASK_NOT_SUPPORT=false
# set default parameters
OUTPUT_BASE_DIR="/data/local/tmp"
CHANGE_OUTPUT_DIR=false
AUTOLOG_LOG_DEFAULT_DIR="$OUTPUT_BASE_DIR/debug"
AUTOLOG_LOG_DIR="$AUTOLOG_LOG_DEFAULT_DIR"
AUTOLOG_LOG_DEFAULT_TEMP_DIR="$OUTPUT_BASE_DIR/debug_tmp"
SCREEN=false
BUGREPORTZ_DUMP=false
PRINTK_LEVEL="0"

# Handle positional/optional arguments from command line
POSITIONAL=()
while [[ $# -gt 0 ]]
do
  KEY="$1"

  case $KEY in
    # Help function
    -h|--help)
      helpFunction
    ;;
    # Output directory
    -o|--output_dir)
      OUTPUT_BASE_DIR="$2"
      CHANGE_OUTPUT_DIR=true
      AUTOLOG_LOG_DIR="$OUTPUT_BASE_DIR/debug"
      shift # past argument
      shift # past value
    ;;
    -o=*|--output_dir=*)
      OUTPUT_BASE_DIR="${KEY#*=}"
      CHANGE_OUTPUT_DIR=true
      AUTOLOG_LOG_DIR="$OUTPUT_BASE_DIR/debug"
      shift
    ;;
    -g|--google_bugreport)
      BUGREPORTZ_DUMP=true
      shift # past argument
    ;;
    -s|--screen)
      SCREEN=true
      shift # past argument
    ;;
    # printk level
    -l|--level)
      PRINTK_LEVEL="$2"
      shift # past argument
      shift # past value
    ;;
    -l=*|--level=*)
      PRINTK_LEVEL="${KEY#*=}"
      shift
    ;;
    *)    # unknown option
      POSITIONAL+=("$1") # save it in an array for later
      shift # past argument
    ;;
  esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

export CHANGE_OUTPUT_DIR
export AUTOLOG_LOG_DEFAULT_DIR
export AUTOLOG_LOG_DIR
export AUTOLOG_LOG_DEFAULT_TEMP_DIR
export BUGREPORTZ_DUMP

INIT_DISP_DUMP_FOLDER

SHORT_INSTR_SCRIPT="$1"
FULL_COMMAND="$*"
if [ ! -f "$AUTOLOG_MODULES_DIR/symptom/sym_debug/$SHORT_INSTR_SCRIPT" ]; then
  FUNCTION_NAME="$1"
  MODULE_NAME="$2"
  SCRIPT_NAME="$3"
  SCENARIO_NUM="$4"
  if [ ! -z "$5" ]; then
  shift 4
  fi
else
  echo -e "${COLOR_GREEN}short instruction default symptom/sys_debug/${COLOR_REST}"
  FUNCTION_NAME="symptom"
  MODULE_NAME="sym_debug"
  SCRIPT_NAME="$1"
  SCENARIO_NUM="$2"
  if [ ! -z "$3" ]; then
  shift 2
  fi
fi

if [ "$FUNCTION_NAME" = "symptom" ]; then
   INTERACTIVE_ASK_NOT_SUPPORT="true"
fi
SCRIPT_ARGS="$@"
ARGS_FOR_LOGNAME=$(join _ ${FULL_COMMAND[@]})


#=======================================================
#                  Check arguments
#=======================================================
if [ -z "$FUNCTION_NAME" ] || [ -z "$MODULE_NAME" ] || [ -z "$SCRIPT_NAME" ]; then
  multiprint "${COLOR_RED}Please assign a function and a module and a script name for further actions.${COLOR_REST}"
  helpFunction
fi

### Check module exists
if [ ! -d "$AUTOLOG_MODULES_DIR/$FUNCTION_NAME" ]; then
  multiprint "${COLOR_RED}Function '$FUNCTION_NAME' do not exists in '$AUTOLOG_MODULES_DIR/', please contact related RD.${COLOR_REST}"
  helpFunction
fi

### Check module exists
if [ ! -d "$AUTOLOG_MODULES_DIR/$FUNCTION_NAME/$MODULE_NAME" ]; then
  multiprint "${COLOR_RED}Module '$MODULE_NAME' do not exists in '$AUTOLOG_MODULES_DIR/$FUNCTION_NAME', please contact related RD.${COLOR_REST}"
  helpFunction
fi

### Check script exists
if [ ! -f "$AUTOLOG_MODULES_DIR/$FUNCTION_NAME/$MODULE_NAME/$SCRIPT_NAME" ]; then
  multiprint "${COLOR_RED}Script '$SCRIPT_NAME' do not exist in '$AUTOLOG_MODULES_DIR/$FUNCTION_NAME/$MODULE_NAME', please contact related RD.${COLOR_REST}"
  helpFunction
fi

### Scenario number check
#if [ -z "$SCENARIO_NUM" ]; then
#  multiprint "${COLOR_RED}Please assign a scenario number for further actions.${COLOR_REST}"
#  helpFunction
#fi


#=======================================================
#                  Detect USB devices
# This function will automatically detect usb device paths
# For Linux platform:
#   => check /proc/mounts and pick '/usb/' devices
# For Android platform:
#   => check /proc/mounts and pick '/media_rw/' devices
#=======================================================
if [ "$CHANGE_OUTPUT_DIR" = "false" ]; then
  if [ "$AUTOLOG_PLATFORM" = "linux" ]; then
    USB_PATHS=($(grep -e "/usb/" /proc/mounts | awk '{print $2}'))
  elif [ "$AUTOLOG_PLATFORM" = "android" ]; then
    USB_PATHS=($(grep -e "/media_rw/" /proc/mounts | awk '{print $2}'))
  else
    echo -e "${COLOR_GREEN}Unknown platform${COLOR_REST}"
    USB_PATHS=($(grep -e "/usb/" -e "/media_rw/" /proc/mounts | awk '{print $2}'))
  fi
else
  USB_PATHS=""
fi

if [ "$INTERACTIVE_ASK_NOT_SUPPORT" = "false" ]; then
if [ -n "$USB_PATHS" ]; then
  USB_LEN=${#USB_PATHS[@]}
  while true; do
    COUNTER=10
    while [ $COUNTER -gt 0 ]; do
      echo -e "${COLOR_GREEN}\nFollowing USB devices has been detected.${COLOR_REST}"
      #echo -e "${COLOR_GREEN}Please enter the ${COLOR_RED}NUMBER${COLOR_GREEN} to change output directory or 'q' use default${COLOR_REST}"
      for index in ${!USB_PATHS[@]}; do
        SHOW_INDEX=0
        let SHOW_INDEX=index+1
        echo -e "${COLOR_RED}    $SHOW_INDEX${COLOR_REST}.) ${COLOR_GREEN}${USB_PATHS[$index]}${COLOR_REST}" > /dev/tty
      done
      echo -e "\n"
      let COUNTER--
    done

    read -r -t 30 USB_INDEX
    if [ "$USB_INDEX" ]; then
      case $USB_INDEX in
        0)
          continue
          ;;
        [0-9]*)
          if [ $USB_INDEX -le $USB_LEN ]; then
            PATH_PTR=0
            let PATH_PTR=USB_INDEX-1
            OUTPUT_BASE_DIR="${USB_PATHS[$PATH_PTR]}"
            multiprint "${COLOR_GREEN}OUTPUT_DIR change to $OUTPUT_BASE_DIR${COLOR_REST}"
            break
          else
            multiprint "${COLOR_RED}The USB No '$USB_INDEX' is not shown above. Please try again.${COLOR_REST}"
            continue
          fi
          ;;
        [qQ])
          multiprint "${COLOR_GREEN}Use original output directory '$OUTPUT_BASE_DIR'${COLOR_REST}"
          break
          ;;
        *)
          continue
          ;;
      esac
    else
      OUTPUT_BASE_DIR="${USB_PATHS[0]}"
      multiprint "${COLOR_GREEN}Doesn't detect input. Use first option '$OUTPUT_BASE_DIR' as default${COLOR_REST}"
      break
    fi
  done
fi
fi


#=======================================================
#                Define pre-proccesses
#
# Create output folder if folder is not exists otherwise
#   remove *.log inside it.
# Output path is defined as "OUTPUT_BASE_DIR/FUNCTION_NAME/MODULE_NAME".
#
# For example:
#   when OUTPUT_BASE_DIR = /data
#   then output_folder   = /data/bsp/audio
#                          or /data/bsp/display
#                          or /data/bsp/video
#=======================================================
OUTPUT_DIR="$OUTPUT_BASE_DIR/$FUNCTION_NAME/$MODULE_NAME"

if [ ! -d "$OUTPUT_DIR" ]; then
  # Create dir if dir is not exists
  mkdir -p "$OUTPUT_DIR"
#else
#  # Remove log file if dir was exists
#  logfiles=$(ls $OUTPUT_DIR | grep -G .*\.log$)
#  for fp in $logfiles; do
#    rm -rf "$OUTPUT_DIR/$fp"
#  done
fi


#=======================================================
#              Call RD-defined modules
#
# Your script will receive some arguments:
#   ) arg1 = Assigned log file path.
#   ) arg<n> = Other arguments you want to pass into
#              script.
#=======================================================
DT_NOW=$(date +"%Y-%m-%d-%H%M%S")
if [ "$FUNCTION_NAME" = "symptom" ]; then
  LOG_FP="$AUTOLOG_LOG_DIR/$DT_NOW-$ARGS_FOR_LOGNAME-kernel.log"
else
  LOG_FP="$OUTPUT_DIR/$DT_NOW-$ARGS_FOR_LOGNAME-kernel.log"
fi

### Handle Kernel log for open dmesg
# Get original printk level from this device
ORG_PRINTK=$(cat "/proc/sys/kernel/printk")
# Set printk log level
echo "$PRINTK_LEVEL" > "/proc/sys/kernel/printk" || echo -e "${COLOR_RED}Change printk error! Permission Denied${COLOR_REST}"
# Open dmesg
if [ ! -d $AUTOLOG_LOG_DIR ]; then
   mkdir -p $AUTOLOG_LOG_DIR
fi
OpenKernelLog "$LOG_FP"

# Execute script
SCRIPT_PATH="$AUTOLOG_MODULES_DIR/$FUNCTION_NAME/$MODULE_NAME/$SCRIPT_NAME"
if [ "$SCREEN" = "false" ]; then
  sh "$SCRIPT_PATH" "$LOG_FP" "$DT_NOW" "$SCENARIO_NUM" $SCRIPT_ARGS
elif [  "$SCREEN" = "true" ]; then
  echo "Enable --screen"
  SCREEN_FP="$(echo "$LOG_FP" | sed -e 's/kernel\.log/screen\.log/')"
  script "$SCREEN_FP" --quiet --command "sh \"$SCRIPT_PATH\" \"$LOG_FP\" \"$DT_NOW\" \"$SCENARIO_NUM\" $SCRIPT_ARGS"
else
  echo "Something went wrong. Please check"
  exit 1
fi
CHILD_STATUS=$?

### Handle Kernel log for closing dmesg
# Kill dmesg --follow
KillKernelLog
# Recover printk level
echo "$ORG_PRINTK" > "/proc/sys/kernel/printk" || echo -e "${COLOR_RED}Change printk error! Permission Denied${COLOR_REST}"

echo -e "${COLOR_GREEN}Script return status code = $CHILD_STATUS${COLOR_REST}"

#=======================================================
#              Define post-processes
#=======================================================
KillOrphanDmesg

if [ $CHILD_STATUS -eq 0 ]; then
  if [ "$INTERACTIVE_ASK_NOT_SUPPORT" = "false" ]; then
  multiprint "${COLOR_GREEN}Log Success! Please copy files in the path (in '$(dirname $LOG_FP)/$DT_NOW-*')!${COLOR_REST}"
  else
  oneprint "${COLOR_GREEN}Log Success! Please copy files in the path ${COLOR_REST} ${COLOR_YELLOW}(in '$(dirname $LOG_FP)/')${COLOR_REST}"
  fi
  exit 0
else
  multiprint "${COLOR_RED}There are some issues happened, please contact related RD.${COLOR_REST}"
  exit 1
fi

fi ##end of short command redirect


