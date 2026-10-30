#!/usr/bin/env bash
#
# 整理产物：清杂项 -> 按平台重命名 -> 重算校验和 -> 生成 Release 说明
# 用法: organize.sh <platform>
#
# 依赖环境变量: GITHUB_WORKSPACE / GITHUB_ENV / BRANCH / WRT_HASH / KERNEL_VERSION(可选)
#
set -euo pipefail
shopt -s nullglob

PLATFORM="${1:?用法: organize.sh <platform>}"
: "${GITHUB_ENV:?GITHUB_ENV 未设置}"
: "${GITHUB_WORKSPACE:?GITHUB_WORKSPACE 未设置}"

TARGET_DIRS=(openwrt/bin/targets/*/*/)
if [ "${#TARGET_DIRS[@]}" -ne 1 ]; then
  echo "::error::期望恰好一个产物目录，实际 ${#TARGET_DIRS[@]} 个：${TARGET_DIRS[*]}" >&2
  exit 1
fi
cd "${TARGET_DIRS[0]}"
echo "==> 产物目录: $PWD"

# 1. 不需要上传的东西
rm -f ./*.buildinfo ./*.json ./*.manifest ./sha256sums
rm -rf ./packages

# 2. 按平台决定保留哪些文件、去掉哪个文件名前缀
PREFIX=""
case "$PLATFORM" in
  x86-64)
    rm -f ./*.bin
    ;;
  allwinner)
    PREFIX="sunxi-cortexa53-"
    ;;
  rockchip|rk3568)
    rm -f ./*.bin
    PREFIX="rockchip-armv8-"
    ;;
  mt7621)
    PREFIX="ramips-mt7621-"
    ;;
  filogic)
    rm -f ./*uboot.fip ./*gpt.bin ./*preloader.bin ./*recovery.itb ./*kernel.bin ./*factory.bin
    PREFIX="mediatek-filogic-"
    ;;
  *)
    echo "::warning::未知平台 ${PLATFORM}，只做清理不做重命名"
    ;;
esac

# 3. 去掉文件名里冗余的平台前缀
if [ -n "$PREFIX" ]; then
  for f in *; do
    [ -f "$f" ] || continue
    case "$f" in
      *"$PREFIX"*)
        mv -v -- "$f" "${f//"$TARGET"/}"
        ;;
    esac
  done
fi

# 4. 重命名后原来的 sha256sums 已经对不上，重算一份
{
  for f in *; do
    [ -f "$f" ] || continue
    if [ "$f" = "sha256sums" ]; then continue; fi
    printf '%s *%s\n' "$(sha256sum -- "$f" | awk '{print $1}')" "$f"
  done
} > sha256sums

echo "FIRMWARE=$PWD" >> "$GITHUB_ENV"

# 5. Release 说明
case "$PLATFORM" in
  x86-64)    TITLE="X86-64 平台" ;;
  allwinner) TITLE="Allwinner 平台" ;;
  rockchip)  TITLE="Rockchip 平台" ;;
  rk3568)    TITLE="Rockchip RK3568 平台" ;;
  mt7621)    TITLE="ramips MT7621 平台" ;;
  filogic)   TITLE="MTK Filogic 平台" ;;
  *)         TITLE="${PLATFORM} 平台" ;;
esac

{
  echo "🎉 ${TITLE}"
  echo
  echo "- 源码分支：\`${BRANCH}\`（${WRT_HASH:-unknown}）"
  if [ -n "${KERNEL_VERSION:-}" ]; then
    echo "- 内核版本：\`${KERNEL_VERSION}\`"
  fi
  echo "- 默认 IP：\`192.168.8.1\`"
  echo "- 构建时间：$(date '+%Y-%m-%d %H:%M %Z')（run #${GITHUB_RUN_NUMBER}）"
  echo
  echo "> 产物已去掉平台前缀，校验和见 \`sha256sums\`。"
} > "$GITHUB_WORKSPACE/release.txt"

echo "==> 产物清单:"
ls -lh
echo "✅ organize.sh 完成"
