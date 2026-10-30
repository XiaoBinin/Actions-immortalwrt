#!/usr/bin/env bash
#
# 用 patches/rust 整个替换 feeds/packages/lang/rust
# 必须在 openwrt 源码根目录执行（build.yml 已保证）
#
set -euo pipefail

SRC="${GITHUB_WORKSPACE:?GITHUB_WORKSPACE 未设置}/patches/rust"
DST="feeds/packages/lang/rust"

if [ ! -d "$SRC" ]; then
  echo "::error::找不到 ${SRC}" >&2
  exit 1
fi
if [ ! -d "feeds/packages/lang" ]; then
  echo "::error::feeds 还没安装？(缺少 feeds/packages/lang)" >&2
  exit 1
fi

echo "==> 替换 feeds/packages/lang/rust"
rm -rf "$DST"
cp -r "$SRC" "$DST"

if [ ! -f "$DST/Makefile" ]; then
  echo "::error::rust 替换失败（Makefile 不存在）" >&2
  exit 1
fi

echo "    rust $(sed -n 's/^PKG_VERSION:=//p' "$DST/Makefile") 就位"
echo "✅ rust.sh 完成"
