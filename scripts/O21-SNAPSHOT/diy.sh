#!/bin/bash

#创建所需文件夹
mkdir -p target/linux/rockchip/files/drivers/phy/rockchip

#删除原来的uboot.patch
rm -rf package/boot/uboot-rockchip/patches/202-rockchip-rk3328-Add-support-for-OrangePi-R1-Plus-LTS.patch

#更改r8152默认驱动
#sed -i 's/kmod-usb-net-rtl8152/kmod-usb-net-rtl8152-vendor/g' target/linux/rockchip/image/armv8.mk

#添加内核配置
sed -i '$a CONFIG_PHY_ROCKCHIP_INNO_USB3=y' target/linux/rockchip/armv8/config-5.4

