#!/bin/bash

# Dir
rclone mount --daemon navin: /root/rom/
cd /root/rom/

# Variables

export MNFST="https://github.com/ArrowOS/android_manifest"
export MNFST_REV="arrow-12.1"

export DT_LINK="https://github.com/X00T-dev/device_asus_X00T"
export VT_LINK="https://github.com/X00T-dev/vendor_asus"
export KT_LINK="https://github.com/ArrowOS-Devices/android_kernel_asus_X00T"

export PLATFORM="sdm660"
export OEM="asus"
export DEVICE="X00T"

export DT_PATH=device/$OEM/$DEVICE
export VT_PATH=vendor/$OEM
export KT_PATH=kernel/$OEM/$PLATFORM

#export DT_PATH=$(echo $DT_LINK | cut -d / -f 5 | sed "s\_\/\g")
#export VT_PATH=$(echo $DT_LINK | cut -d / -f 5 | sed "s\_\/\g")
#export KT_PATH=$(echo $DT_LINK | cut -d / -f 5 | sed "s\_\/\g")

export LUNCH_COMBO="arrow_X00T-eng"

export ZIP_NAME="Arrow*.zip"

# Sync

repo init --depth=1 -u $MNFST -b $MNFST_REV || { echo "Failed to Init repo !!!" && exit 1; }
repo sync --force-sync --no-tags --no-clone-bundle --prune -j$(nproc --all)
repo sync -j1 --fail-fast || { echo "Failed to Sync !!!" && exit 1; } # Sync Again to avoid Partial Sync

git clone --single-branch --depth=1 $DT_LINK $DT_PATH || { echo "Failed to Clone Device Tree !!!" && exit 1; }
git clone --single-branch --depth=1 $VT_LINK $VT_PATH || { echo "Failed to Clone Vendor Tree !!!" && exit 1; }
git clone --single-branch --depth=1 $KT_LINK $KT_PATH || { echo "Failed to Clone Kernel Source !!!" && exit 1; }

export USE_CCACHE=1
export CCACHE_EXEC=/usr/bin/ccache
export CCACHE_DIR=/tmp/.ccache
ccache -M 32G

source b*/e*
lunch ${LUNCH_COMBO} || { echo "Failed to Lunch !!!" && exit 1; }
timeout 110m make bacon -j$(nproc --all) || { echo "Failed to make target !!!" && exit 1; }

# Upload

#cd out/target/product/${DEVICE}

#curl -T $ZIP_NAME https://oshi.at/${ZIP_NAME} > mirror.txt || { echo "Failed to Mirror Build Zip !!!" && exit 1; }

#MIRROR_LINK=$(cat mirror.txt | grep Download | cut -d\  -f1)

#echo "Mirror: ${MIRROR_LINK}"
