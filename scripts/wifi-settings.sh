#!/usr/bin/env bash
#
# 修改固件默认 WiFi 名称/密码/加密
# 必须在 openwrt 源码根目录执行（build.yml 已保证）
#
# 由 build.yml 的 with_wifi_defaults 开关控制，默认 false —— 打开前想清楚，
# 这会改变所有用它编译出来的固件的默认 SSID/密码。
#
set -euo pipefail

WRT_SSID="${WRT_SSID:-OWRT}"
WRT_WORD="${WRT_WORD:-87654321}"

# 老版本：target 自带的 uci-defaults 脚本
WIFI_SH=$(find target/linux/mediatek/filogic target/linux/qualcommax \
             -path '*uci-defaults*set-wireless.sh' -type f 2>/dev/null | head -n 1 || true)
# 新版本：wifi-scripts 的 uc 模板
WIFI_UC="package/network/config/wifi-scripts/files/lib/wifi/mac80211.uc"

if [ -n "$WIFI_SH" ] && [ -f "$WIFI_SH" ]; then
  sed -i "s/BASE_SSID='.*'/BASE_SSID='${WRT_SSID}'/" "$WIFI_SH"
  sed -i "s/BASE_WORD='.*'/BASE_WORD='${WRT_WORD}'/" "$WIFI_SH"
  echo "✅ 已把 ${WIFI_SH} 的默认 SSID 改为 ${WRT_SSID}"
elif [ -f "$WIFI_UC" ]; then
  sed -i "s/ssid='\${defaults?.ssid || \".*\"}'/ssid='\${defaults?.ssid || \"${WRT_SSID}\"}'/" "$WIFI_UC"
  sed -i "s/key='\${defaults?.key || \".*\"}'/key='\${defaults?.key || \"${WRT_WORD}\"}'/" "$WIFI_UC"
  sed -i "s/encryption='\${defaults?.encryption || \".*\"}'/encryption='\${defaults?.encryption || \"psk2+ccmp\"}'/" "$WIFI_UC"
  echo "✅ 已把 ${WIFI_UC} 的默认 SSID 改为 ${WRT_SSID}，密码改为 ${WRT_WORD}"
else
  echo "::warning::没找到可修改的默认 WiFi 配置，跳过"
fi
