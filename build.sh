#!/bin/bash

#清除编译文件
make ARCH=arm CROSS_COMPILE=arm-none-linux-gnueabihf- distclean

#配置defconfig文件
make ARCH=arm CROSS_COMPILE=arm-none-linux-gnueabihf- stm32mp1_atk_defconfig

#开始编译内核和设备树
make ARCH=arm CROSS_COMPILE=arm-none-linux-gnueabihf- uImage dtbs LOADADDR=0XC2000040 vmlinux -j16

#编译内核模块
make ARCH=arm CROSS_COMPILE=arm-none-linux-gnueabihf- modules -j16

#在当前目录下亲新建一个tmp目录，用于存放编译后的目标文件
if [ ! -e "./tmp" ]; then
    mkdir tmp
fi
rm -rf tmp/*

make ARCH=arm CROSS_COMPILE=arm-none-linux-gnueabihf- modules_install INSTALL_MOD_PATH=tmp

#删除source目录
rm -rf tmp/lib/modules/5.4.31/source

#删除build目录
rm -rf tmp/lib/modules/5.4.31/build

#裁剪模块的调试信息
find ./tmp -name "*.ko" | xargs $STRIP --strip-debug --remove-section=.comment --remove-section=.note --preserve-dates

cd tmp/lib/modules
tar -jcvf ../../modules.tar.bz2 .
cd -
rm -rf tmp/lib

#拷贝zImage到tmp目录下
cp arch/arm/boot/uImage tmp

#拷贝所有编译的设备树文件到当前的tmp目录下
cp arch/arm/boot/dts/stm32mp157d-atk*.dtb tmp
echo "编译完成，请查看当前目录下的tmp文件夹查看编译好的目标文件"
