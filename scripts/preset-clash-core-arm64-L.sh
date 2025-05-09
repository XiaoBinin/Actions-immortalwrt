#!/bin/bash
#=================================================
# File name: preset-clash-core.sh
# Usage: <preset-clash-core.sh $platform> | example: <preset-clash-core.sh armv8>
# System Required: Linux
# Version: 1.0
# Lisence: MIT
# Author: SuLingGG
# Blog: https://mlapp.cn
# 参考网址：https://github.com/zzcabc/OpenWrt_Action/blob/11208c3d5160128d22d14318772ec48f1918deb9/script/immortalwrt/diy2.sh
#=================================================


# 预置openclash内核
mkdir -p files/etc/openclash/core


# openclash 的 Meta内核版本
# CLASH_META_URL="https://github.com/vernesong/OpenClash/raw/core/master/meta/clash-linux-amd64.tar.gz"

# Meta内核版本
CLASH_META_URL=$(curl -sL https://api.github.com/repos/MetaCubeX/Clash.Meta/releases/tags/Prerelease-Alpha | grep -o '"browser_download_url": *"[^"]*mihomo-linux-arm64-alpha-[^"]*\.gz"' | awk -F '"' '{print $4}' | head -n 1)

# 给内核解压
wget -qO- $CLASH_META_URL | gunzip -c > files/etc/openclash/core/clash_meta

# 给内核权限
chmod +x files/etc/openclash/core/clash*


# 下载mihomo core需要的文件？
# GeoIP.dat
GEOIP_URL=https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/geoip.dat
# GeoSite.dat
GEOSITE_URL=https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/geosite.dat
# Country.mmdb
COUNTRY_FULL_URL=https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/country.mmdb

wget -qO- $GEOIP_URL > files/etc/openclash/GeoIP.dat
wget -qO- $GEOSITE_URL > files/etc/openclash/GeoSite.dat
wget -qO- $COUNTRY_FULL_URL > files/etc/openclash/Country.mmdb

echo "preset-clash-core-L executed successfully!"
