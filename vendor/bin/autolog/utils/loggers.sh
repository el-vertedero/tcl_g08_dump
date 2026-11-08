#!/usr/bin/env sh

multiprint()
{
  MESSAGE="$1"
  COUNTER=10
  while [ $COUNTER -gt 0 ]; do
    echo -e "\n$MESSAGE\n" > /dev/tty
    let COUNTER--
  done
}

oneprint()
{
  MESSAGE="$1"
  echo -e "\n$MESSAGE\n" > /dev/tty
}

prompt()
{
  # prompt(message, log_file_path=None)
  #   => User read command to ask user questions, and record it into log_file_path
  MESSAGE="$1"
  OUTPUT_FP="$2"

  while true; do
    ### Print MESSAGE 10 times to prevent user don't see the prompt messages
    multiprint "$MESSAGE"
    read -r -t 10 ANSWER

    if [ -z "$ANSWER" ]; then
      continue
    else
      break
    fi
  done

  if [ -n "$OUTPUT_FP" ]; then
    # Record it into $log_fp
    write_interactive "$OUTPUT_FP" "$MESSAGE" "$ANSWER"
  fi

  echo "$ANSWER"  # Return $bug
}


write_interactive()
{
  # Arguments: (log_path, message, result)
  log_path="$1"
  message="$2"
  result="$3"
  message=$(echo "$message" | sed 's/\\e\[[0-9]\{0,2\}m \{0,1\}//g')  # remove color_string
  echo "$(date +"%Y-%m-%d %H:%M:%S"),question=\"$message\",result=\"$result\"" >> "$log_path"
}

