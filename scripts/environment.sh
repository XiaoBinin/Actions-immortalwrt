#!/usr/bin/env bash
#
# 安装 immortalwrt / OpenWrt 编译依赖
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
