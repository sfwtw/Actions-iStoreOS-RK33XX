#!/bin/bash
#===============================================
# Description: DIY script
# File name: diy-script.sh
# Lisence: MIT
# Author: P3TERX
# Blog: https://p3terx.com
#===============================================

# Git稀疏克隆，只克隆指定目录到本地
function git_sparse_clone() {
  branch="$1" repourl="$2" && shift 2
  git clone --depth=1 -b $branch --single-branch --filter=blob:none --sparse $repourl
  repodir=$(echo $repourl | awk -F '/' '{print $(NF)}')
  cd $repodir && git sparse-checkout set $@
  mv -f $@ ../package
  cd .. && rm -rf $repodir
}


# update ubus git HEAD
cp -f $GITHUB_WORKSPACE/configfiles/ubus_Makefile package/system/ubus/Makefile


# 近期istoreos网站文件服务器不稳定，临时增加一个自定义下载网址
sed -i "s/push @mirrors, 'https:\/\/mirror2.openwrt.org\/sources';/&\\npush @mirrors, 'https:\/\/github.com\/xiaomeng9597\/files\/releases\/download\/iStoreosFile';/g" scripts/download.pl


#修改uhttpd配置文件，启用nginx
# sed -i "/.*uhttpd.*/d" .config
# sed -i '/.*\/etc\/init.d.*/d' package/network/services/uhttpd/Makefile
# sed -i '/.*.\/files\/uhttpd.init.*/d' package/network/services/uhttpd/Makefile
sed -i "s/:80/:81/g" package/network/services/uhttpd/files/uhttpd.config
sed -i "s/:443/:4443/g" package/network/services/uhttpd/files/uhttpd.config
cp -a $GITHUB_WORKSPACE/configfiles/etc/* package/base-files/files/etc/
# ls package/base-files/files/etc/

# 更改默认 Shell 为 zsh
# sed -i 's/\/bin\/ash/\/usr\/bin\/zsh/g' package/base-files/files/etc/passwd

# Modify default IP（FROM 192.168.1.1 CHANGE TO 192.168.31.4）
# sed -i 's/192.168.100.1/192.168.1.1/g' package/base-files/files/bin/config_generate

# TTYD 免登录
sed -i 's|/bin/login|/bin/login -f root|g' feeds/packages/utils/ttyd/files/ttyd.config

# 移除不需要的包
rm -rf feeds/packages/utils/gl-mifi-mcu
rm -rf package/kernel/rtw88-oot
rm -rf package/kernel/rtw89-oot
rm -rf package/kernel/rtl8812au-ct
rm -rf package/kernel/ath10k-ct
rm -rf package/kernel/rkwifi
rm -rf package/kernel/mt76
rm -rf feeds/routing/batman-adv
rm -rf package/kernel/mac80211
rm -rf package/network/utils/iwinfo
rm -rf package/firmware/wireless-regdb
rm -rf feeds/third/ddns-scripts_aliyun
rm -rf package/firmware/b43legacy-firmware
rm -rf package/firmware/rkwifi-firmware
rm -rf package/kernel/r8126
rm -rf package/kernel/r8125
rm -rf package/kernel/trelay
rm -rf package/firmware/prism54-firmware
rm -rf package/firmware/cypress-firmware
rm -rf feeds/packages/net/ddns-scripts
rm -rf package/network/services/relayd
rm -rf feeds/packages/net/coova-chilli
rm -rf feeds/third/ddns-scripts_aliyun
rm -rf package/kernel/button-hotplug
rm -rf feeds/packages/kernel/v4l2loopback
rm -rf feeds/telephony/net/rtpengine
rm -rf package/network/services/hostapd
rm -rf package/feeds/packages/prometheus-node-exporter-lua
rm -rf package/feeds/luci/luci-app-ddns
rm -rf package/feeds/packages/dawn
rm -rf package/firmware/ath10k-ct-firmware
rm -rf package/kernel/acx-mac80211
rm -rf package/feeds/routing/bmx7
rm -rf package/feeds/packages/bmx7-dnsupdate
rm -rf package/feeds/luci/luci-app-dawn

rm -rf package/feeds/packages/collectd
rm -rf package/feeds/luci/luci-mod-battstatus
rm -rf package/feeds/third_party/luci-app-LingTiGameAcc
rm -rf package/feeds/luci/luci-proto-relay
rm -rf package/kernel/mwlwifi
rm -rf package/feeds/packages/prometheus-node-exporter-lua
rm -rf package/feeds/luci/luci-app-bmx7
rm -rf package/feeds/luci/luci-app-statistics

rm -rf package/network/utils/rssileds
rm -rf package/kernel/rtl8812au-ac
rm -rf package/feeds/packages/travelmate

git_sparse_clone main https://github.com/Siriling/5G-Modem-Support luci-app-modem quectel_MHI quectel_cm_5G meig-cm quectel_Gobinet

# git clone https://github.com/Siriling/5G-Modem-Support.git tmp_modem
# mv -f tmp_modem/luci-app-modem package/
# mv -f tmp_modem/luci-app-sms-tool package/
# mv -f tmp_modem/quectel_MHI package/
# mv -f tmp_modem/quectel_cm_5G package/
# mv -f tmp_modem/meig-cm package/
# mv -f tmp_modem/meig_QMI_WWAN package/
# rm -rf tmp_modem

# 移植以下机型
# RK3399 R08
# RK3399 TPM312

echo -e "\\ndefine Device/rk3399_tpm312
  DEVICE_VENDOR := RK3399
  DEVICE_MODEL := TPM312
  SOC := rk3399
  SUPPORTED_DEVICES := rk3399,tpm312
  UBOOT_DEVICE_NAME := tpm312-rk3399
  IMAGE/sysupgrade.img.gz := boot-common | boot-script | pine64-img | gzip | append-metadata
endef
TARGET_DEVICES += rk3399_tpm312" >> target/linux/rockchip/image/armv8.mk


# cp -f $GITHUB_WORKSPACE/configfiles/r08-rk3399_defconfig package/boot/uboot-rockchip/src/configs/r08-rk3399_defconfig
cp -f $GITHUB_WORKSPACE/configfiles/tpm312-rk3399_defconfig package/boot/uboot-rockchip/src/configs/tpm312-rk3399_defconfig


# 网口配置为旁路由模式，注释下面两个网口模式替换命令后，网口模式会变成主路由模式，不知道什么原因理论应该全部变成旁路由模式的，但对于RK3399 R08机型网口模式还是主路由模式，没深度研究过，你们自己测试吧。
# sed -i "s/armsom,p2pro)/armsom,p2pro|\\\\\n	rk3399,tpm312)/g" target/linux/rockchip/armv8/base-files/etc/board.d/02_network


# 复制和修改u-boot压缩包SHA256校验码，编译失败时注意看是不是这个引起的。
cp -f $GITHUB_WORKSPACE/configfiles/uboot_Makefile package/boot/uboot-rockchip/Makefile
sha256_value=$(wget -qO- "https://github.com/xiaomeng9597/files/releases/download/u-boot-2021.07/u-boot-2021.07.tar.bz2.sha" | awk '{print $1}')
if [ -n "$sha256_value" ]; then
sed -i "s/.*PKG_HASH:=.*/PKG_HASH:=$sha256_value/g" package/boot/uboot-rockchip/Makefile
fi
cp -f $GITHUB_WORKSPACE/configfiles/u-boot.mk include/u-boot.mk


# 复制对应的dts设备树文件到指定目录和u-boot目录里面
cp -f $GITHUB_WORKSPACE/configfiles/rk3399.dtsi target/linux/rockchip/armv8/files/arch/arm64/boot/dts/rockchip/rk3399.dtsi
cp -f $GITHUB_WORKSPACE/configfiles/rk3399-opp.dtsi target/linux/rockchip/armv8/files/arch/arm64/boot/dts/rockchip/rk3399-opp.dtsi
cp -f $GITHUB_WORKSPACE/configfiles/rk3399-tpm312.dts target/linux/rockchip/armv8/files/arch/arm64/boot/dts/rockchip/rk3399-tpm312.dts


cp -f $GITHUB_WORKSPACE/configfiles/rk3399.dtsi package/boot/uboot-rockchip/src/arch/arm/dts/rk3399.dtsi
cp -f $GITHUB_WORKSPACE/configfiles/rk3399-opp.dtsi package/boot/uboot-rockchip/src/arch/arm/dts/rk3399-opp.dtsi
cp -f $GITHUB_WORKSPACE/configfiles/rk3399-tpm312.dts package/boot/uboot-rockchip/src/arch/arm/dts/rk3399-tpm312.dts


#不开启无线功能，已移除Realtek相关无线驱动，这个暂时不可用，原因兼容性不好，会异常掉线
# cp -f $GITHUB_WORKSPACE/configfiles/opwifi package/base-files/files/etc/init.d/opwifi
# chmod 755 package/base-files/files/etc/init.d/opwifi
# sed -i "s/wireless.radio\${devidx}.disabled=1/wireless.radio\${devidx}.disabled=0/g" package/kernel/mac80211/files/lib/wifi/mac80211.sh


#集成CPU性能跑分脚本
cp -a $GITHUB_WORKSPACE/configfiles/coremark/* package/base-files/files/bin/
chmod 755 package/base-files/files/bin/coremark
chmod 755 package/base-files/files/bin/coremark.sh
