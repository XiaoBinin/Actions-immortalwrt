#!/bin/bash

echo "开始替换 feeds中的rust ..."
echo "========================================"

rm -rf openwrt/feeds/packages/lang/rust
cp -r patches/rust openwrt/feeds/packages/lang/

echo "===== 查看rust文件是否存在 ====="
ls -l openwrt/feeds/packages/lang/ | grep rust

# 额外验证Makefile是否存在（核心文件）
if [ -f "openwrt/feeds/packages/lang/rust/Makefile" ]; then
  echo "✅ Rust目录替换成功，Makefile存在"
else
  echo "❌ Rust目录替换失败，Makefile不存在"
fi

echo "========================================"
echo "rust 替换完成！"
