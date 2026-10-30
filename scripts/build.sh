#!/usr/bin/env bash
#
# 在 openwrt 源码根目录执行编译
# 用法: build.sh <single|staged> [jobs]
#
set -euo pipefail

MODE="${1:-single}"
JOBS="${2:-$(nproc)}"

# 并行失败就退回 -j1 V=s 重编，拿到可读的报错（原逻辑保留，只是抽成函数）
build() {
  if make -j"${JOBS}" "$@"; then
    return 0
  fi
  echo "::warning::make -j${JOBS} $* 失败，改用 -j1 V=s 重试以输出可读日志" >&2
  make -j1 V=s "$@"
}

echo "==> 编译方式: ${MODE}，并行度: ${JOBS}"
make defconfig

if [ "$MODE" = "staged" ]; then
  build tools/compile
  build toolchain/compile

  # 工具链编完先删中间产物，否则后面编内核/插件时空间不够
  rm -rf dl/* build_dir/host/* build_dir/toolchain-*

  build target/linux/compile
  build package/compile
  build package/install
  make package/index

  rm -rf build_dir/target-*/host

  build target/install
  make json_overview_image_info
  make checksum
else
  build
fi

echo "✅ 编译完成"
