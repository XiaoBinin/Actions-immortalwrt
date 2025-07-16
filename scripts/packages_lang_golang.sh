#!/bin/bash

#删除feeds中的插件
# rm -rf ./feeds/packages/net/v2ray-geodata
rm -rf feeds/packages/lang/golang

#克隆依赖插件
git clone https://github.com/sbwml/packages_lang_golang -b 24.x feeds/packages/lang/golang


echo "packages_golang executed successfully!"
