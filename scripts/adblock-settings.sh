#!/usr/bin/env bash
#
# 让 adblock 的"出厂默认"是关闭：首次刷机开机不会自动跑
#
# 只改固件里那份默认配置（feeds 里 adblock 包的 files/adblock.conf），不动任何运行时状态：
#
#   * 首次刷机：/etc/config/adblock 来自固件，adb_enabled='0' → 开机不启动、不下载规则，
#     想用的话去 LuCI「网络 → Adblock」打开（打开后就是正常启用，和以前一样）
#
#   * 升级固件：/etc/config/adblock 是 opkg conffile，sysupgrade 只备份"被改过"的 conffile
#     （/sbin/sysupgrade 的 list_changed_conffiles），刷完再恢复回来。所以用户自己打开过的
#     设置不会因为这次改动被打回关闭，升级后行为不变
#
# 原理备注（省得以后有人以为改错了）：
#   adblock 的 init 脚本只看 /etc/rc.d/S30adblock 在不在，真正的开关是 adblock.sh 里
#   f_dns() 的 "if [ \"${adb_enabled}\" = \"0\" ] ... exit 0"，所以出厂配置里把它设成 0
#   就够了，不需要去动 init 脚本（动 init 反而会让 LuCI 的"启用"按钮语义变乱）。
#
# 必须在 openwrt 源码根目录执行（build.yml 已保证）
#
set -euo pipefail

CONF="feeds/packages/net/adblock/files/adblock.conf"

if [ ! -f .config ]; then
  echo "::error::.config 不存在（本脚本要在 openwrt 源码根目录、配置叠加之后跑）" >&2
  exit 1
fi

# 没选 adblock 的平台（比如 Packages-L.txt）不用处理，跳过即可
if ! grep -qE '^CONFIG_PACKAGE_(luci-app-adblock|adblock)=y' .config; then
  echo "==> 本次没选 adblock / luci-app-adblock，跳过（出厂默认保持上游）"
  exit 0
fi

if [ ! -f "$CONF" ]; then
  echo "::error::$CONF 不存在，adblock 包目录结构可能变了" >&2
  exit 1
fi

# 上游如果哪天把 adb_enabled 从默认配置里删了，adblock.sh 内建的默认值就是 0，
# 效果跟我们要的一样，跳过即可（不要在这里报错挡住编译）
if ! grep -qE '^[[:space:]]*option[[:space:]]+adb_enabled' "$CONF"; then
  echo "::warning::上游默认配置里没有 adb_enabled（内建默认已是 0），跳过"
  exit 0
fi

# 只改 adb_enabled 这一行，其它默认值保持上游原样（不复制整份配置，避免以后跟上游漂移）
sed -i -E "s/^([[:space:]]*option[[:space:]]+adb_enabled[[:space:]]+)'?1'?[[:space:]]*$/\1'0'/" "$CONF"

if ! grep -qE "^[[:space:]]*option[[:space:]]+adb_enabled[[:space:]]+'0'" "$CONF"; then
  echo "::error::没能把 $CONF 里的 adb_enabled 改成 0（上游改了写法？）" >&2
  grep -n 'adb_enabled' "$CONF" >&2 || true
  exit 1
fi

echo "==> adblock 出厂默认已关闭（首次刷机不自动启动，升级保留用户设置）:"
grep -n 'adb_enabled' "$CONF"
