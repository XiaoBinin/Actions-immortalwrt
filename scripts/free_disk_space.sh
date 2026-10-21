#!/usr/bin/env bash
#
# 在 GitHub 托管 runner 上腾出约 25~30GB 空间
# OpenWrt 全量编译 + 多设备镜像动辄 40GB，不清理基本必然在半路 No space left on device
#
# 注意：这里不用 set -e —— 任何一步（比如没装 firefox、没有 docker）失败都不该让整个 job 挂掉
set -uo pipefail

echo "==> 清理前："
df -h /

echo "==> 卸载用不到的大型预装包"
sudo apt-get -y purge firefox 2>/dev/null || true
sudo apt-get -y remove '^dotnet-.*' '^llvm-.*' 'php.*' '^mongodb-.*' '^mysql-.*' 2>/dev/null || true
sudo apt-get -y remove azure-cli google-cloud-sdk hhvm google-chrome-stable powershell mono-devel 2>/dev/null || true
sudo apt-get -y autoremove --purge 2>/dev/null || true
sudo apt-get -y autoclean 2>/dev/null || true
sudo apt-get -y clean 2>/dev/null || true

echo "==> 删除大目录（每个只用一次，去重了原脚本里重复的条目）"
for dir in \
  /usr/share/dotnet \
  /usr/local/graalvm \
  /usr/local/.ghcup \
  /usr/local/share/powershell \
  /usr/local/share/chromium \
  /usr/local/lib/android \
  /usr/local/lib/node_modules \
  /opt/ghc \
  /usr/local/share/boost \
  /opt/hostedtoolcache ; do
  if [ -e "$dir" ]; then
    echo "  - $dir"
    sudo rm -rf "$dir"
  fi
done

echo "==> 清理 docker 镜像/卷"
sudo docker system prune -af --volumes 2>/dev/null || true

echo "==> 清理后："
df -h /
