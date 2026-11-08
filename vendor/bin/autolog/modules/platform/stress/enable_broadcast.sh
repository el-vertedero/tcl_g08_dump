echo "======enable broadcast log======"
# broadcast and tuner prop
setprop vendor.mtk.broadcast.log.level D
setprop vendor.mtk.tvexoplayer.log all
setprop vendor.debug.tuner.service.log 1

#TS/PS container log //20211118 requested by Neil Hsieh
setprop vendor.mtk.ts.verbose.log 1
setprop vendor.mtk.ps.verbose.log 1

#################################################
