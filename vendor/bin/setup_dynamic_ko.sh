dynamic_insmod() {
	local dt_node=$1
	local compat_target=$2
	local ko_name=$3
	local compat_str=$(</sys/firmware/devicetree/base/${dt_node}/compatible)
	local ko_path="/vendor/lib/modules/${ko_name}"

	# compatible string and target string mismatch
	if [ $compat_str != $compat_target ]; then return 1; fi

	# check if ko exist
	if ! test -f "$ko_path"; then
		echo $ko_path " not found."
		return 1
	fi

	insmod $ko_path
}

##############    dt node name     target compatible string     kernel module name
dynamic_insmod    gpu0@1c5e0000    mtk,mali-mt5896              mali_kbase_mt5896.ko
dynamic_insmod    gpu0@1c5e0000    mtk,mali-mt5897              mali_kbase_mt5897.ko
