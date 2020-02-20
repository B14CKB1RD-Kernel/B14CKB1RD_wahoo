#!/bin/bash
rm .version
# Bash Color
green='\033[01;32m'
red='\033[01;31m'
blink_red='\033[05;31m'
restore='\033[0m'

clear

# Resources
THREAD="-j$(grep -c ^processor /proc/cpuinfo)"
export CROSS_COMPILE=~/B14CKB1RD/toolchain/aarch64/aarch64-linux-android-4.9/bin/aarch64-linux-android-
export CROSS_COMPILE_ARM32=${HOME}/B14CKB1RD/toolchain/arm/arm-linux-androideabi-4.9/bin/arm-linux-androideabi-
KBUILD_COMPILER_STRING="$(get_clang_version clang)"
DEFCONFIG="B14CKB1RD_defconfig"

# Paths
KERNEL_DIR=`pwd`
REPACK_DIR="${HOME}/B14CKB1RD/AnyKernel3"
ZIP_MOVE="${HOME}/B14CKB1RD/releases"

# Vars
KERNEL_VER="$(grep -r "EXTRAVERSION = -" ${HOME}/B14CKB1RD/B14CKB1RD_wahoo/Makefile | sed 's/EXTRAVERSION = -//')-$(date +%m.%d.%y)"
export ARCH=arm64
export SUBARCH=arm64
export KBUILD_BUILD_USER=REV3NT3CH
export KBUILD_BUILD_HOST=Desolation

# Functions
function clean_all {
		rm -rf out
		git reset --hard > /dev/null 2>&1
		git clean -f -d > /dev/null 2>&1
		cd $KERNEL_DIR
		git submodule init
		git submodule update
		echo
		make clean && make mrproper
}

function make_kernel {
		echo
		rm -rf ~${REPACK_DIR}/dtbo.img
		rm -rf ~${REPACK_DIR}/Image.lz4-dtb
		make O=out CC=~/B14CKB1RD/toolchain/clang/proton-clang/bin/clang-12  CLANG_TRIPLE=aarch64-linux-gnu- $DEFCONFIG
		make O=out CC=~/B14CKB1RD/toolchain/clang/proton-clang/bin/clang-12  CLANG_TRIPLE=aarch64-linux-gnu- -j10

}

function move_images {
                cp -f "${KERNEL_DIR}/out/arch/arm64/boot/Image.lz4-dtb" "${REPACK_DIR}/Image.lz4-dtb"
                cp -f "${KERNEL_DIR}/out/arch/arm64/boot/dtbo.img" "${REPACK_DIR}/dtbo.img"
}

function make_zip {
		cd $REPACK_DIR
		zip -r9 `echo $KERNEL_VER`.zip *
		mv  `echo $KERNEL_VER`.zip $ZIP_MOVE
		cd $KERNEL_DIR
}


DATE_START=$(date +"%s")


echo -e "${green}"
echo "-----------------"
echo "Making B14CKB1RD:"
echo "-----------------"
echo -e "${restore}"

echo

while read -p "Do you want to clean stuffs (y/n)? " cchoice
do
case "$cchoice" in
	y|Y )
		clean_all
		echo
		echo "All Cleaned now."
		break
		;;
	n|N )
		break
		;;
	* )
		echo
		echo "Invalid try again!"
		echo
		;;
esac
done

echo

while read -p "Do you want to build?" dchoice
do
case "$dchoice" in
	y|Y )
		make_kernel
		move_images
		make_zip
		break
		;;
	n|N )
		break
		;;
	* )
		echo
		echo "Invalid try again!"
		echo
		;;
esac
done


echo -e "${green}"
echo "-------------------"
echo "Build Completed in:"
echo "-------------------"
echo -e "${restore}"

DATE_END=$(date +"%s")
DIFF=$(($DATE_END - $DATE_START))
echo "Time: $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds."
echo

