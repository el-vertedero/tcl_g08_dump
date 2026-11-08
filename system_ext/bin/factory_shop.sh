#!/bin/sh

pmode="$(getprop odm.tcl.factory.pmode)"

locale_file=/userdata/factory_locale.txt

# ifndef VENDOR_EDIT
# kangwei.liu@tcl.com, 2025.07.21.add for yuchaoxie
emmcfile=/userdata/emmcEnv.ini
if [ -f "$emmcfile" ];
then
    rm -f /userdata/emmcEnv.ini
fi
# endif  /* VENDOR_EDIT End*/

function set_system_osd_locale(){
    if [ -f "$locale_file" ];then
        sys_fty_locale="$(getprop persist.odm.tcl.fty.locale.stat)"
        echo "<fty_locale>fty_locale=$sys_fty_locale"

        ###读取factory_locale.txt 文件的值,然后比对属性中存储的语言信息
        var=$(cat /userdata/factory_locale.txt)
        echo "<fty_locale>txt_locale=$var"
        if [[ "$sys_fty_locale" != "$var" ]];then
            if [[ $var == *-* ]];then
                echo "<fty_locale>read factory locale,and set setprop..."
                setprop persist.sys.locale $var
                setprop persist.odm.tcl.fty.locale.stat "$var"
                sync
            else
                echo "<fty_locale>factory_locale data error!!..."
                ##可以考虑删除
                ##rm -rf /userdata/factory_locale.txt
            fi
        else
            echo "<fty_locale>factory_locale.txt is already read..."
        fi
    else
        echo "<fty_locale>factory_locale.txt is not exist!!!!!..."
    fi
}

if [[ "$pmode" != "1" ]];
then
    echo "<fty_locale>user mode,can set locale..."
    set_system_osd_locale
else
    echo "<fty_locale>current is P mode..."
    rm -rf /data/anr
    rm -rf /data/system/dropbox
    rm -rf /data/tombstones
fi

echo "<fty_locale>enter factory sh process ,out"
