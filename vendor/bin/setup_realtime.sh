#!/sbin/sh

rm -rf /data/vendor/realtime/*
exec -- /vendor/bin/rtconsumer
