#!/vendor/bin/sh
if [ $1 == $(getprop persist.odm.tcl.glp_copy_version) ]; then
	if [ "$(ls -A /data/vendor/mediadrm/group_license)" ]; then
		return
	fi
fi
mkdir -p /data/vendor/mediadrm/group_license
rm -rf /data/vendor/mediadrm/group_license/*
cp -af /vendor/etc/atsc3_glp/* /data/vendor/mediadrm/group_license
chmod 777 /data/vendor/mediadrm/group_license
chmod 777 /data/vendor/mediadrm/group_license/*
setprop persist.odm.tcl.glp_copy_version $1