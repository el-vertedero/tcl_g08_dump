#!/bin/bash

# 读取 dsn.bin 内容，获取 serialno 值
# serialno=$(tr -d '\r\n' < /impdata/dsn.bin)
serialno=$(head -c 16 /impdata/dsn.bin | tr -d '\r\n')

# 设置属性
setprop ro.boot.serialno "$serialno"
setprop ro.serialno "$serialno"

# 执行 wcl 生成
/vendor/bin/amzn_dha_tool --sign-csr
ret1=$?

/vendor/bin/amzn_dha_tool -t
ret2=$?

# 两个命令都返回0才创建标志文件
if [ $ret1 -eq 0 ] && [ $ret2 -eq 0 ]; then
    touch /impdata/wcl_finished
    sync
fi

sync


