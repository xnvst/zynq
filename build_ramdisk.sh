#!/bin/sh

###########################################################
#
# This script will build the root file system to be used on
# the OmniTek oz745 Development platform
#
# Contact: support@omnitek.tv
#
###########################################################

# Check that we are running as root
#./check_user.sh
#if [ $? = 1 ]; then exit 1; fi

##########################################################################################
## Build Functions

function build_ramdisk(){
  #Clean up old files
  rm uramdisk.image.gz
  rm ramdisk.img.gz
  sudo rm -rf ramdisk

  # Create the ramdisk
  #dd if=/dev/zero of=ramdisk.img bs=1024 count=32768
  dd if=/dev/zero of=ramdisk.img bs=1M count=128
  mke2fs -F ramdisk.img -L"ramdisk" -b 1024 -m 0
  tune2fs ramdisk.img -i 0
  chmod 777 ramdisk.img

  # Mount the ram disk and copy in the contents
  mkdir ramdisk
  sudo mount -o loop ramdisk.img ramdisk
  if [ $? -ne 0 ]; then
    echo "Mount failed, cannot create ram disk"
    exit 1
  fi

  cp -aR ./rootfs_APPOM/* ramdisk
  #cp -aR ./rootfs/* ramdisk
  du -h -c -s ramdisk
  ls ramdisk
  sudo chown -R root:root ramdisk/*
  sudo umount ramdisk

  # Compress the image
  gzip ramdisk.img

  # Use the previously built U-Boot tool to build the ramdisk
  ./mkimage -A arm -T ramdisk -C gzip -d ramdisk.img.gz uramdisk.image.gz
  if [ $? = 1 ]; then 
	echo Failed to build uramdisk.image.gz
	exit 1
  fi

  du -h -c -s uramdisk.image.gz
}

########################################################################################

(
  # Make the Ramdisk
  build_ramdisk
  if [ $? = 1 ]; then exit 1; fi
)
exit

