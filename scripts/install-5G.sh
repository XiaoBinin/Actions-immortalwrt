#!/usr/bin/env bash
#
# 添加 QModem（5G 模块管理）feed 并安装
# 必须在 openwrt 源码根目录执行（build.yml 已保证）
#
set -euo pipefail

FEED_LINE='src-git qmodem https://github.com/FUjr/QModem.git;main'

if grep -qxF "$FEED_LINE" feeds.conf.default 2>/dev/null; then
  echo "qmodem feed 已存在，跳过追加"
else
  echo "$FEED_LINE" >> feeds.conf.default
fi

./scripts/feeds update qmodem
./scripts/feeds install -a -f -p qmodem

echo "✅ 5G (QModem) 安装完成"
