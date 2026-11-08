#!/usr/bin/env sh

VIDEO_DUMP_TEMP_DIR=/mnt/vendor/tmp/dump
VIDEO_DUMP_DIR=$AUTOLOG_LOG_DIR/dump

tar_video_dump_and_move_to_dir()
{
    directory=$1
    target_file=$2

    echo "start tar $VIDEO_DUMP_TEMP_DIR into $directory/$target_file!"
    tar zcf $directory/$target_file $VIDEO_DUMP_TEMP_DIR
    rm -fr $VIDEO_DUMP_TEMP_DIR
    echo "Finish tar_video_dump_and_move_to_dir"
}

video_dump()
{
    if [ ! -d $VIDEO_DUMP_DIR ]; then
        mkdir $VIDEO_DUMP_DIR
    else
        rm -fr $VIDEO_DUMP_DIR
        mkdir $VIDEO_DUMP_DIR
    fi

    sleep 10
    sync

    tar_video_dump_and_move_to_dir $VIDEO_DUMP_DIR abnormal_video_dump.tar.gz
}

MAIN()
{
    ### Import functions from other modules/scripts
    ### DO SOMETHING
    echo "\033[1m \033[4m"
    echo "In debug_abnormal_video.sh\033[0m"

    sh $AUTOLOG_MODULES_DIR/symptom/sym_debug/debug_abnormal_disp.sh

    #MEMORY_LOG_PID=$!
    #echo "MEMORY_LOG_PID: $MEMORY_LOG_PID"
    echo "\033[1m \033[4m"
    echo "Out debug_abnormal_video.sh\033[0m"
}

#========================================================
#                 Script entrance control
#                  (Don't remove this)
#  If call this script through 'sh' command:
#      => Execute script, e.g MAIN function
#  If call this script through 'source <script_path> --source-only'
#      => import functions inside this script and this will
#         not execute MAIN()
#========================================================
if [ "$*" = "--source-only" ]; then
  :
else
  MAIN $*
fi