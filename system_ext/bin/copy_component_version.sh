#!/bin/bash

# Check if the source file exists
if [ -f "/product/etc/component_version.txt" ]; then
    echo "Source file exists, preparing to copy..."

    # If the destination directory does not exist, create it
    if [ ! -d "/cache/recovery/component" ]; then
        echo "Destination directory does not exist, creating it..."
        mkdir -p "/cache/recovery/component"
    fi

    # Copy the file and rename it in the destination directory
    cp "/product/etc/component_version.txt" "/cache/recovery/component/product_component_version.txt"
    echo "File copied and renamed successfully: /cache/recovery/component/product_component_version.txt"
else
    echo "Source file does not exist: /product/etc/component_version.txt"
fi

if [ -f "/preload/etc/preload_component_version.txt" ]; then
    echo "Source file exists, preparing to copy..."

    # If the destination directory does not exist, create it
    if [ ! -d "/cache/recovery/component" ]; then
        echo "Destination directory does not exist, creating it..."
        mkdir -p "/cache/recovery/component"
    fi

    # Copy the file and rename it in the destination directory
    cp "/preload/etc/preload_component_version.txt" "/cache/recovery/component/preload_component_version.txt"
    echo "File copied and renamed successfully: /cache/recovery/component/preload_component_version.txt"
else
    echo "Source file does not exist: /preload/etc/component_version.txt"
fi

# Check if the source file exists
if [ -f "/tclconfig/tvcust/aio_resources/resource/component_version.txt" ]; then
    echo "Source file exists, preparing to copy..."

    # Copy the file and rename it in the destination directory
    cp "/tclconfig/tvcust/aio_resources/resource/component_version.txt" "/cache/recovery/tclconfig/component_version.txt"
    echo "File copied and renamed successfully: /cache/recovery/tclconfig/component_version.txt"
else
    echo "Source file does not exist: /tclconfig/tvcust/aio_resources/resource/component_version.txt"
fi

if [ -f "/tclconfig/SVN_VERSION.txt" ]; then
    echo "Source file exists, preparing to copy..."

    # Copy the file and rename it in the destination directory
    cp "/tclconfig/SVN_VERSION.txt" "/cache/recovery/tclconfig/SVN_VERSION.txt"
    echo "File copied and renamed successfully: /cache/recovery/tclconfig/SVN_VERSION.txt"
else
    echo "Source file does not exist: /tclconfig/SVN_VERSION.txt"
fi