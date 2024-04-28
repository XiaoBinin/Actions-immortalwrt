#!/bin/bash

#删除feeds自带插件
rm -rf ./feeds/packages/net/mosdns
rm -rf ./feeds/packages/net/v2ray-geodata
rm -rf ./feeds/packages/net/chinadns-ng

#删除自带u-boot.dts
rm -rf package/boot/uboot-rockchip/src/arch/arm/dts/rk3328-orangepi-r1-plus-lts-u-boot.dtsi

#更改默认地址为192.168.8.1
sed -i 's/192.168.1.1/192.168.8.1/g' package/base-files/files/bin/config_generate

#更改r8152默认驱动
#sed -i 's/kmod-usb-net-rtl8152/kmod-usb-net-rtl8152-vendor/g' target/linux/rockchip/image/armv8.mk

#添加内核配置
sed -i '$a CONFIG_PHY_ROCKCHIP_INNO_USB3=y' target/linux/rockchip/armv8/config-5.15

#克隆passwall环境插件
git clone https://github.com/xiaorouji/openwrt-passwall-packages.git package/pwpage

#克隆的源码放在small文件夹
mkdir package/small
pushd package/small

#克隆源码
#adguardhome
git clone -b main --depth 1 https://github.com/XiaoBinin/luci-app-adguardhome.git
#passwall2
git clone -b main --depth 1 https://github.com/xiaorouji/openwrt-passwall2.git
#mosdns
git clone -b v5 --depth 1 https://github.com/sbwml/luci-app-mosdns.git
#v2ray-geodata
git clone https://github.com/sbwml/v2ray-geodata
#lucky
git clone -b main --depth 1 https://github.com/sirpdboy/luci-app-lucky.git

popd
