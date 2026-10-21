#!/usr/bin/env bash
#
# 改默认 LAN IP + 修正内置配置权限
# 必须在 openwrt 源码根目录执行（build.yml 已保证）
#
set -euo pipefail

DEF_IP="192.168.8.1"

echo "==> 默认 LAN IP -> ${DEF_IP}"

# 1. LuCI「系统 -> 备份/升级」页里显示的示例地址
mapfile -t FLASH_JS < <(find feeds/luci/modules/luci-mod-system -type f -name flash.js 2>/dev/null || true)
if [ "${#FLASH_JS[@]}" -gt 0 ]; then
  sed -i "s/192\.168\.[0-9]\+\.[0-9]\+/${DEF_IP}/g" "${FLASH_JS[@]}"
else
  echo "::warning::没找到 luci-mod-system/flash.js，跳过（LuCI 版本变了？）"
fi

# 2. base-files 里生成的默认 LAN 配置
CONFIG_GENERATE="package/base-files/files/bin/config_generate"
if [ -f "$CONFIG_GENERATE" ]; then
  sed -i "s/192\.168\.[0-9]\+\.[0-9]\+/${DEF_IP}/g" "$CONFIG_GENERATE"
else
  echo "::error::$CONFIG_GENERATE 不存在，默认 IP 改不了"
  exit 1
fi

# 3. 随固件下发的 files/etc/config/* 统一 644，避免权限 600 时 LuCI 读不到
if compgen -G "files/etc/config/*" > /dev/null; then
  chmod 644 files/etc/config/*
fi

echo "✅ init-settings.sh 完成"
