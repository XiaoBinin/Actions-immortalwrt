#!/bin/bash
#
#预置HomeProxy数据
#
set -euo pipefail

HOMEPROXY_DIR="./feeds/luci/applications/luci-app-homeproxy"
DNS_CONFIG_FILE="${HOMEPROXY_DIR}/root/etc/config/homeproxy"
HP_RULE="surge"
HP_PATH="root/etc/homeproxy"

if [ -d "${HOMEPROXY_DIR}" ]; then
    echo "=======开始处理 homeproxy 规则和 DNS 配置======="

    rm -rf "${HOMEPROXY_DIR}/${HP_PATH}/resources/"*

    git clone -q --depth=1 --single-branch --branch "release" "https://github.com/Loyalsoldier/surge-rules.git" "./${HP_RULE}/"

    cd "./${HP_RULE}/" && RES_VER=$(git log -1 --pretty=format:'%s' | grep -o "[0-9]*")

    echo "${RES_VER}" | tee china_ip4.ver china_ip6.ver china_list.ver gfw_list.ver

    awk -F, '/^IP-CIDR,/{print $2 > "china_ip4.txt"} /^IP-CIDR6,/{print $2 > "china_ip6.txt"}' cncidr.txt

    sed 's/^\.//g' direct.txt > china_list.txt ; sed 's/^\.//g' gfw.txt > gfw_list.txt

    mv -f ./{china_*,gfw_list}.{ver,txt} "../${HOMEPROXY_DIR}/${HP_PATH}/resources/"

    cd .. && rm -rf "./${HP_RULE}/"

    echo "✅ homeproxy 规则已更新"

    sed -i 's/option dns_server '\''8.8.8.8'\''/option dns_server '\''https:\/\/94.140.14.140\/dns-query'\''/g' "${DNS_CONFIG_FILE}"

	sed -i 's/option china_dns_server '\''223.5.5.5'\''/option china_dns_server '\''https:\/\/223.5.5.5\/dns-query'\''/g' "${DNS_CONFIG_FILE}"

    echo "✅ homeproxy DNS 服务器已修改"

else
    echo "错误：luci-app-homeproxy 目录不存在！"
fi
