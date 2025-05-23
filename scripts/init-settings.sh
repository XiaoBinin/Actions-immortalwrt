#!/bin/bash

#更改默认地址为192.168.8.1
sed -i 's/192.168.1.1/192.168.8.1/g' package/base-files/files/bin/config_generate

# 给config下的文件增加权限
chmod 644 files/etc/config/*


echo "init-settings executed successfully!"
