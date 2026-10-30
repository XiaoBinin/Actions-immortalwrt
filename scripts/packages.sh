#!/usr/bin/env bash
#
# 处理 feeds 里的插件，并克隆需要覆盖/新增的第三方插件
# 必须在 openwrt 源码根目录执行（build.yml 已保证）
#
set -euo pipefail

clone() {
  local url="$1" dir="$2"
  shift 2
  echo "==> clone ${url} -> ${dir}"
  git clone --depth 1 "$@" "$url" "$dir"
}

echo "==> 删除 feeds 中要被覆盖的插件"
rm -rf feeds/packages/lang/golang
rm -rf feeds/packages/net/mosdns
rm -rf feeds/packages/net/{xray-core,v2ray-geodata,sing-box,chinadns-ng,dns2socks,hysteria,ipt2socks,microsocks,naiveproxy,shadowsocks-rust,shadowsocksr-libev,simple-obfs,tcping,v2ray-plugin,xray-plugin,geoview,shadow-tls,smartdns}
rm -rf feeds/luci/applications/{luci-app-mosdns,luci-app-passwall,luci-app-smartdns}

echo "==> 克隆依赖插件"
# passwall 的依赖包（xray-core / sing-box / hysteria / geoview ...）
clone https://github.com/Openwrt-Passwall/openwrt-passwall-packages.git package/pwpage

# golang：feed 里被删掉的目录用新版本补回来。
clone https://github.com/sbwml/packages_lang_golang feeds/packages/lang/golang -b 27.x

mkdir -p package/small
pushd package/small > /dev/null

clone https://github.com/eamonxg/luci-theme-aurora.git luci-theme-aurora -b master
clone https://github.com/gaobin89/luci-app-timecontrol.git luci-app-timecontrol -b js
clone https://github.com/gdy666/luci-app-lucky.git luci-app-lucky -b main
# smartdns
clone https://github.com/pymumu/luci-app-smartdns.git luci-app-smartdns -b master
# clone https://github.com/VIKINGYFY/packages.git VIKINGYFY-packages -b main
clone https://github.com/Openwrt-Passwall/openwrt-passwall.git luci-app-passwall -b main
clone https://github.com/Openwrt-Passwall/openwrt-passwall2.git luci-app-passwall2 -b main
clone https://github.com/sbwml/luci-app-mosdns.git luci-app-mosdns -b v5
clone https://github.com/muink/luci-app-netspeedtest.git luci-app-netspeedtest -b master
clone https://github.com/nikkinikki-org/OpenWrt-nikki.git luci-app-nikki -b main
clone https://github.com/nikkinikki-org/OpenWrt-momo.git luci-app-momo -b main
clone https://github.com/QiuSimons/luci-app-daed.git luci-app-daed -b master
# 流量监控（luci 前端 + bandix 核心包；核心是预编译二进制，按架构从 release 下载）
clone https://github.com/timsaya/luci-app-bandix.git luci-app-bandix -b main
clone https://github.com/timsaya/openwrt-bandix.git openwrt-bandix -b main
# 网盘（alist 的继任者，取代已失效的 aliyundrive-webdav）
clone https://github.com/sbwml/luci-app-openlist2.git luci-app-openlist2 -b main

popd > /dev/null

echo "==> 清理悬空软链（feeds 目录已删除、又没有补回来的那些包）"
if [ -d package/feeds ]; then
  find package/feeds -xtype l -delete
fi
echo "悬空软链数量: $(find package/feeds -xtype l 2>/dev/null | wc -l)"

echo "✅ packages.sh 完成"
