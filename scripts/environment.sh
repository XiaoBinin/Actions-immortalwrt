#!/usr/bin/env bash
#
# 安装 immortalwrt / OpenWrt 编译依赖
#
# 与原来的区别：
#   * 只做 apt update 一次、不再 full-upgrade（workflow 里也升级一次是纯浪费，每次多花 1~2 分钟）
#   * libncurses5-dev / libncursesw5-dev -> libncurses-dev（Ubuntu 24.04 上正确的包名）
#   * 去掉 ack / vim / msmtp / p7zip（编译用不到，runner 磁盘本来就紧张）
#
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

sudo apt-get -qq update
sudo apt-get -qq install -y \
  antlr3 asciidoc autoconf automake autopoint binutils bison build-essential \
  bzip2 ccache cmake cpio curl device-tree-compiler fastjar flex gawk gettext \
  gcc-multilib g++-multilib git gperf haveged help2man intltool libc6-dev-i386 \
  libelf-dev libfuse-dev libglib2.0-dev libgmp3-dev libltdl-dev libmpc-dev \
  libmpfr-dev libncurses-dev libpython3-dev libreadline-dev libssl-dev libtool \
  lrzsz mkisofs ninja-build p7zip-full patch pkgconf python3 python3-pyelftools \
  python3-setuptools qemu-utils rsync scons squashfs-tools subversion swig \
  texinfo uglifyjs upx-ucl unzip wget xmlto xxd zlib1g-dev

echo "✅ 构建依赖安装完成"
