#!/vendor/bin/sh

echo "run tclfactoryos start"

#export env variable
#export F1_CONFIG=/tclconfig/json_sys.ini
export F1_OS_SYSTEM=/vendor/bin/sh

#run tclfactoryos
/vendor/bin/tclfactoryos &

echo "run tclfactoryos end"

logcat -G 5M

while true; do
        sleep 1
done

