#!/usr/bin/env bash
#
# 平台相关的小改动（删补丁 / 打补丁），集中在这里，避免又散回各个 workflow
# 用法: target-patches.sh <platform>
# 必须在 openwrt 源码根目录执行（build.yml 已保证）
#
# 目前只有 rockchip 家族：lede 里 991-arm64-dts-rockchip-add-more-cpu-operating-points-for.patch
# 会把 CPU 拉到不稳定频率，原 workflow 是直接删掉它（rockchip 和 r1pluslts 两个都删）。
#
set -euo pipefail

PLATFORM="${1:?用法: target-patches.sh <platform>}"

case "$PLATFORM" in
  rockchip|r1pluslts)
    PATCH=$(ls target/linux/rockchip/patches-*/991-arm64-dts-rockchip-add-more-cpu-operating-points-for.patch 2>/dev/null | head -n 1 || true)
    if [ -n "$PATCH" ]; then
      echo "==> 删除 ${PATCH}（R1 系列上 CPU 频率不稳）"
      rm -f "$PATCH"
    else
      echo "==> 没有 991-cpu-operating-points 补丁，跳过（源码分支变了？）"
    fi
    ;;
  *)
    echo "==> 平台 ${PLATFORM} 没有需要处理的补丁"
    ;;
esac

echo "✅ target-patches.sh 完成"
