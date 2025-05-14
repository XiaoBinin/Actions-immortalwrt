#!/bin/bash

echo "======================================="
echo "[*] 开始安装 5G 模块支持..."
echo "======================================="

# 1. 克隆 5G Modem 支持库
echo >> feeds.conf.default
echo 'src-git modem https://github.com/FUjr/modem_feeds.git;main' >> feeds.conf.default
./scripts/feeds update modem
./scripts/feeds install -a -p modem

if [ -d "package/Modem-Support" ]; then
    echo "⚠️ 目录 package/Modem-Support 已存在，删除旧版本..."
    rm -rf package/Modem-Support
fi

git clone --depth=1 https://github.com/Siriling/5G-Modem-Support package/Modem-Support
if [ $? -ne 0 ]; then
    echo "❌ Git 克隆失败！请检查网络连接或仓库地址"
    exit 1
fi
rm -rf package/Modem-Support/rooter/0optionalapps/bwallocate
rm -rf package/Modem-Support/rooter/0optionalapps/ext-rspeedtest
rm -rf package/Modem-Support/rooter/0optionalapps/ext-speedtest

# 2. 创建目标目录（使用 -p 防止目录已存在时报错）
mkdir -p package/network/utils/quectel-CM-5G
mkdir -p package/network/utils/sms-tool

# 3. 移动文件，检查目录是否存在再执行
if [ -d "package/Modem-Support/quectel_cm_5G" ]; then
    mv -f package/Modem-Support/quectel_cm_5G/* package/network/utils/quectel-CM-5G
else
    echo "⚠️ 警告：quectel_cm_5G 目录不存在，跳过移动"
fi

if [ -d "package/Modem-Support/sms-tool" ]; then
    mv -f package/Modem-Support/sms-tool/* package/network/utils/sms-tool
else
    echo "⚠️ 警告：sms-tool 目录不存在，跳过移动"
fi

echo "======================================="
echo "✅ 5G 模块支持安装完成！"
echo "======================================="
exit 0
