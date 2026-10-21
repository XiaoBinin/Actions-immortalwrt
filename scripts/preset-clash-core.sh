#!/usr/bin/env bash
#
# 预置 OpenClash 需要的 mihomo(Meta) 内核和规则库
# 用法: preset-clash-core.sh <amd64|arm64>
# 必须在 openwrt 源码根目录执行（build.yml 已保证），产物写进 files/ 随固件打包
#
# 原来有 3 份几乎一样的脚本（amd64 / arm64 / arm64-L），其中 arm64 那份根本没被任何
# workflow 用到；这里合并成一份，按架构传参。
#
# 关键修复：原脚本是 `wget -qO- $URL | gunzip -c > 文件`，
# 一旦 GitHub API 限流（匿名 60 次/小时）拿到空 URL，就会静默生成 0 字节内核，
# chmod +x 还照样成功 —— 固件里带一个坏内核，刷完才发现。
# 现在下载后校验非空，失败直接退出。
#
set -euo pipefail

ARCH="${1:?用法: preset-clash-core.sh <amd64|arm64>}"

case "$ARCH" in
  amd64) MIHOMO_PATTERN='mihomo-linux-amd64-compatible-alpha-.*\.gz' ;;
  arm64) MIHOMO_PATTERN='mihomo-linux-arm64-alpha-.*\.gz' ;;
  *)
    echo "::error::不支持的架构: ${ARCH}（只支持 amd64 / arm64）" >&2
    exit 1
    ;;
esac

CORE_DIR="files/etc/openclash/core"
mkdir -p "$CORE_DIR"

# fetch <url> <输出文件>：下载并校验非空
fetch() {
  local url="$1" out="$2"
  echo "==> 下载 $(basename "$out")"
  wget -q --tries=3 --timeout=300 -O "${out}.part" "$url"
  if [ ! -s "${out}.part" ]; then
    echo "::error::下载失败或内容为空: ${url}" >&2
    rm -f "${out}.part"
    exit 1
  fi
  mv -f "${out}.part" "$out"
}

echo "==> 获取 mihomo 最新 alpha 版本下载地址"
API_URL="https://api.github.com/repos/MetaCubeX/mihomo/releases/tags/Prerelease-Alpha"
AUTH_HEADER=()
if [ -n "${GH_TOKEN:-}" ]; then
  AUTH_HEADER=(-H "Authorization: Bearer ${GH_TOKEN}")
fi

API_JSON=$(curl -fsSL "${AUTH_HEADER[@]}" "$API_URL") || true
META_URL=$(printf '%s' "$API_JSON" \
  | grep -o "\"browser_download_url\": *\"[^\"]*${MIHOMO_PATTERN}\"" \
  | head -n 1 | cut -d'"' -f4 || true)

if [ -z "${META_URL}" ]; then
  echo "::error::没拿到 mihomo 下载地址（API 限流或 release 结构变了）" >&2
  exit 1
fi
echo "     ${META_URL}"

echo "==> 下载并解压内核"
wget -q --tries=3 --timeout=300 -O "${CORE_DIR}/clash_meta.gz" "$META_URL"
gunzip -c "${CORE_DIR}/clash_meta.gz" > "${CORE_DIR}/clash_meta"
rm -f "${CORE_DIR}/clash_meta.gz"

if [ ! -s "${CORE_DIR}/clash_meta" ]; then
  echo "::error::clash_meta 解压后为空" >&2
  exit 1
fi
chmod +x "${CORE_DIR}/clash_meta"
echo "     大小: $(du -h "${CORE_DIR}/clash_meta" | cut -f1)"

echo "==> 下载规则库"
GEO_BASE="https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest"
fetch "${GEO_BASE}/geoip.dat"         files/etc/openclash/GeoIP.dat
fetch "${GEO_BASE}/geosite.dat"       files/etc/openclash/GeoSite.dat
fetch "${GEO_BASE}/country.mmdb"      files/etc/openclash/Country.mmdb
fetch "${GEO_BASE}/GeoLite2-ASN.mmdb" files/etc/openclash/GeoLite2-ASN.mmdb

echo "✅ OpenClash 内核与规则库预置完成"
