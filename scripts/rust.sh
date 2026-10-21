#!/usr/bin/env bash
#
# 用 patches/rust 整个替换 feeds/packages/lang/rust
# 必须在 openwrt 源码根目录执行（build.yml 已保证）
#
# 说明：patches/rust 里包含 Makefile(1.98.1) + Config.in + rust-values.mk +
#      rust-package.mk + rust-host-build.mk + 1 个补丁，是 feed 包的完整副本。
#      源码分支切换（25.12 <-> master）后如果 rust 编译报错，先对比 core 的
#      include/rust-*.mk 是否已经改名/改参数。
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
