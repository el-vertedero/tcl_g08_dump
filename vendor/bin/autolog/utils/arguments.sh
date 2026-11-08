

log_fp=$1
log_ts=$2
log_dir="$(dirname "$log_fp")"
act_log_fp="$(echo "$log_fp" | sed -e 's/kernel\.log/interactive\.log/')"

shift 2

