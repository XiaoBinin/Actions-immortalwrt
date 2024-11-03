#!/bin/bash

#删除feeds中的插件
# rm -rf ./feeds/packages/net/mosdns
# rm -rf ./feeds/packages/net/v2ray-geodata
rm -rf ./feeds/packages/net/shadowsocks-libev
rm -rf ./feeds/packages/net/chinadns-ng


#克隆依赖插件
git clone https://github.com/xiaorouji/openwrt-passwall-packages.git package/pwpage


#克隆的源码放在small文件夹
mkdir package/small
pushd package/small


#adguardhome
git clone -b 2023.10 --depth 1 https://github.com/XiaoBinin/luci-app-adguardhome.git
#lucky
git clone -b main --depth 1 https://github.com/sirpdboy/luci-app-lucky.git
# #smartdns
# git clone -b lede --depth 1 https://github.com/pymumu/luci-app-smartdns.git
# git clone -b master --depth 1 https://github.com/pymumu/smartdns.git
# #ssrp
# git clone -b master --depth 1 https://github.com/fw876/helloworld.git
# #passwall
# git clone -b main --depth 1 https://github.com/xiaorouji/openwrt-passwall.git
#passwall2
git clone -b main --depth 1 https://github.com/xiaorouji/openwrt-passwall2.git
# #mosdns
# git clone -b v5 --depth 1 https://github.com/sbwml/luci-app-mosdns.git
# #openclash
# git clone -b master --depth 1 https://github.com/vernesong/OpenClash.git

popd

echo "packages executed successfully!"
