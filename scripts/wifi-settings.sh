#!/bin/bash

#默认WIFI名称
WRT_SSID="OWRT"
#默认WIFI密码
WRT_WORD="87654321"

WIFI_SH=$(find ./target/linux/{mediatek/filogic,qualcommax}/base-files/etc/uci-defaults/ -type f -name "*set-wireless.sh" 2>/dev/null)
WIFI_UC="./package/network/config/wifi-scripts/files/lib/wifi/mac80211.uc"
if [ -f "$WIFI_SH" ]; then
	#修改WIFI名称
	sed -i "s/BASE_SSID='.*'/BASE_SSID='$WRT_SSID'/g" $WIFI_SH
	#修改WIFI密码
	sed -i "s/BASE_WORD='.*'/BASE_WORD='$WRT_WORD'/g" $WIFI_SH
elif [ -f "$WIFI_UC" ]; then
	#修改WIFI名称
	sed -i "s/ssid='\${defaults?.ssid || \".*\"}'/ssid='\${defaults?.ssid || \"$WRT_SSID\"}'/g" $WIFI_UC
	#修改WIFI密码
	sed -i "s/key='\${defaults?.key || \".*\"}'/key='\${defaults?.key || \"$WRT_WORD\"}'/g" $WIFI_UC
	#修改WIFI地区
	# sed -i "s/country='.*'/country='CN'/g" $WIFI_UC
	#修改WIFI加密
	sed -i "s/encryption='\${defaults?.encryption || \".*\"}'/encryption='\${defaults?.encryption || \"psk2+ccmp\"}'/g" $WIFI_UC
fi
