#!/usr/bin/env bash
#
# 用 sbwml/packages_lang_golang 整包替换 feeds 里的 golang（和 rust.sh 一个套路）
#
# 为什么要换：feeds 里 golang 的版本跟着 OpenWrt 发布节奏走，通常比 luci-app-openlist2 /
# mosdns v5 / nikki / daed / passwall 这些 Go 插件要求的版本旧，编到一半才报
# "requires go >= 1.xx"。整包换掉最省事。
#
# 开关：build.yml 的 `golang` 输入（默认 true = 保持以前的行为）。
#       关掉就原样用 feeds 里的 golang，本脚本根本不会被调用。
#
# 必须在 openwrt 源码根目录、`feeds install -a` 之后执行（build.yml 已保证）：
# 上游 README 的用法就是 clone 回 feeds 原路径 —— package/feeds/packages/golang
# 这个软链是 feeds install 建的，目录换掉之后软链照样有效。
#
set -euo pipefail

# 想换版本/仓库只改这三行
GO_REPO="https://github.com/sbwml/packages_lang_golang.git"
GO_BRANCH="27.x"
GO_DIR="feeds/packages/lang/golang"

if [ ! -d "feeds/packages/lang" ]; then
  echo "::error::feeds 还没安装？(缺少 feeds/packages/lang)" >&2
  exit 1
fi

echo "==> 替换 golang：${GO_REPO} (${GO_BRANCH})"
rm -rf "$GO_DIR"
git clone --depth 1 -b "$GO_BRANCH" "$GO_REPO" "$GO_DIR"

# 体检：这个仓库把真正的包放在 golang/ 子目录里（Makefile 里是 PKG_NAME:=golang），
# 上层放 golang-*.mk。不写死路径，上游调整目录结构时这里还能找到。
mk="$(grep -rl --include=Makefile '^PKG_NAME:=golang' "$GO_DIR" 2>/dev/null | head -n 1 || true)"
if [ -z "$mk" ]; then
  echo "::error::${GO_DIR} 里找不到 PKG_NAME:=golang，仓库/分支结构变了？" >&2
  ls -la "$GO_DIR" >&2 || true
  exit 1
fi

ver="$(sed -n 's/^GO_VERSION_MAJOR_MINOR:=//p' "$mk" | head -n 1)"
pat="$(sed -n 's/^GO_VERSION_PATCH:=//p' "$mk" | head -n 1)"
if [ -n "$ver" ]; then
  echo "    golang ${ver}${pat:+.${pat}} 就位（${mk}）"
else
  echo "    golang 已就位（${mk}，版本号没解析出来，不影响编译）"
fi
echo "✅ golang.sh 完成"
