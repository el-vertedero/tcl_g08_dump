#!/system/bin/sh

pid=$(awk -F' = ' '/^gProjectID/ {gsub(/[";:]/,"",$2); print $2}' /mnt/vendor/project_id/project_id.ini)
setprop ro.vendor.project_id $pid
