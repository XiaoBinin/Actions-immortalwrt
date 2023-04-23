#!/bin/bash

#删除自带u-boot.dts
rm -rf package/boot/uboot-rockchip/src/arch/arm/dts/rk3328-orangepi-r1-plus-lts-u-boot.dtsi

#更改默认地址为192.168.8.1
sed -i 's/192.168.1.1/192.168.8.1/g' package/base-files/files/bin/config_generate

#更改r8152默认驱动
sed -i 's/kmod-usb-net-rtl8152/kmod-usb-net-rtl8152-vendor/g' target/linux/rockchip/image/armv8.mk

#添加内核配置
sed -i '$a CONFIG_PHY_ROCKCHIP_INNO_USB3=y' target/linux/rockchip/armv8/config-5.15


#克隆的源码放在small文件夹
#mkdir package/small
#pushd package/small

#克隆源码
#openwrt-packages
git clone https://github.com/kenzok8/openwrt-packages.git package/opackages
rm -rf package/opackages/luci-app-mosdns
rm -rf package/opackages/luci-app-argon-config
rm -rf package/opackages/luci-theme-argon
rm -rf package/opackages/luci-app-argonne-config
rm -rf package/opackages/luci-theme-argonne 

#wall
git clone https://github.com/kenzok8/wall.git package/wall
rm -rf package/wall/mosdns
rm -rf package/wall/upx

#mosdns
git clone -b v5 https://github.com/sbwml/luci-app-mosdns.git package/mosdns


#git clone -b main https://github.com/xiaorouji/openwrt-passwall2.git

#popd
