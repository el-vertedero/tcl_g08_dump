#!/usr/bin/env sh


join()
{
  local IFS="$1"
  shift
  echo "$*"
}


Import()
{
  # CallModule path to module
  #   if you want to call modules/bsp/example/example.sh
  #                 => Import bsp example example.sh
  #   if you want to call modules/BSP/audio/example.sh
  #                 => Import BSP audio example.sh
  if [ -z $(echo $AUTOLOG_MODULES_DIR) ]; then
    echo -e "${COLOR_RED}AUTOLOG_MODULES_DIR has not been clarified.${COLOR_REST}"
    exit 1
  fi

  if [ -z $(echo $AUTOLOG_LIBRARY) ]; then
    export AUTOLOG_LIBRARY=""
  fi

  args=$*
  SCRIPT_FP="$AUTOLOG_MODULES_DIR/$(join "/" ${args[@]})"

  local IFS=";"
  SOURCES=($AUTOLOG_LIBRARY)
  local IFS=" "

  for src in ${SOURCES[@]}; do
    if [ $src = "$SCRIPT_FP" ]; then
      # To prevent import same script multiple times
      return 0
    fi
  done

  # add to AUTOLOG_LIBRARY
  export AUTOLOG_LIBRARY="$SCRIPT_FP;$AUTOLOG_LIBRARY"
  # source script
  source "$SCRIPT_FP" --source-only
  return 1
}


ImportUtil()
{
  if [ -z $(echo $AUTOLOG_UTILS_DIR) ]; then
    echo -e "${COLOR_RED}AUTOLOG_UTILS_DIR has not been clarified.${COLOR_REST}"
    exit 1
  fi

  if [ -z $(echo $AUTOLOG_UTILS) ]; then
    export AUTOLOG_UTILS=""
  fi

  args=$*
  SCRIPT_FP="$AUTOLOG_UTILS_DIR/$(join "/" ${args[@]})"

  local IFS=";"
  SOURCES=($AUTOLOG_UTILS)
  local IFS=" "

  for src in ${SOURCES[@]}; do
    if [ $src = "$SCRIPT_FP" ]; then
      # To prevent import same script multiple times
      return 0
    fi
  done

  # add to AUTOLOG_UTILS
  export AUTOLOG_UTILS="$SCRIPT_FP;$AUTOLOG_UTILS"
  # source script
  source "$SCRIPT_FP" --source-only
  return 1
}
