#!/system/bin/sh

echo "tcl RC_UNCONNECTED start."
chdomain zygote "am broadcast --receiver-foreground -a \"tcl.sys.intent.action.RC_UNCONNECTED\" -f 0x01000000" &
echo "tcl RC_UNCONNECTED end."
wait
