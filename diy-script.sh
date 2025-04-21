#!/bin/bash

# TTYD No Login
# Uncomment below to allow ttyd auto-login as root
# sed -i 's|/bin/login|/bin/login -f root|g' feeds/packages/utils/ttyd/files/ttyd.config


# Function: Sparse clone specific subdirectories from a repo
function git_sparse_clone() {
  branch="$1" repourl="$2" && shift 2
  git clone --depth=1 -b $branch --single-branch --filter=blob:none --sparse $repourl
  repodir=$(echo $repourl | awk -F '/' '{print $(NF)}')
  cd $repodir && git sparse-checkout set $@
  mv -f $@ ../package
  cd .. && rm -rf $repodir
}

# Add extra plugins 
git clone --depth=1 https://github.com/iFHax/luci-app-3ginfo-lite package/luci-app-3ginfo-lite
git clone --depth=1 https://github.com/iFHax/luci-app-modem package/luci-app-modem
git clone --depth=1 https://github.com/iFHax/luci-app-modemband package/luci-app-modemband
git clone --depth=1 https://github.com/iFHax/luci-app-modeminfo package/luci-app-modeminfo
git clone --depth=1 https://github.com/iFHax/luci-app-atcommands package/luci-app-atcommands
git clone --depth=1 https://github.com/iFHax/modemband package/modemband
git clone --depth=1 https://github.com/iFHax/modeminfo package/modeminfo
git clone --depth=1 https://github.com/iFHax/sms-tool package/sms-tool
git clone --depth=1 https://github.com/iFHax/internet-detector package/internet-detector
git clone --depth=1 https://github.com/iFHax/luci-app-internet-detector package/luci-app-internet-detector
git clone --depth=1 https://github.com/iFHaxx/luci-app-irqbalance package/luci-app-irqbalance

# Themes
git clone --depth=1 -b 18.06 https://github.com/jerrykuku/luci-theme-argon package/luci-theme-argon
git clone --depth=1 https://github.com/jerrykuku/luci-app-argon-config package/luci-app-argon-config

# Change Argon background image
cp -f $GITHUB_WORKSPACE/images/bg1.jpg package/luci-theme-argon/htdocs/luci-static/argon/img/bg1.jpg

# SmartDNS
git clone --depth=1 -b lede https://github.com/pymumu/luci-app-smartdns package/luci-app-smartdns
git clone --depth=1 https://github.com/pymumu/openwrt-smartdns package/smartdns

# msd_lite
git clone --depth=1 https://github.com/ximiTech/luci-app-msd_lite package/luci-app-msd_lite
git clone --depth=1 https://github.com/ximiTech/msd_lite package/msd_lite

# MosDNS
git clone --depth=1 https://github.com/sbwml/luci-app-mosdns package/luci-app-mosdns

# Alist
git clone --depth=1 https://github.com/sbwml/luci-app-alist package/luci-app-alist

# DDNS.to
git_sparse_clone main https://github.com/linkease/nas-packages-luci luci/luci-app-ddnsto
git_sparse_clone master https://github.com/linkease/nas-packages network/services/ddnsto

# iStore
git_sparse_clone main https://github.com/linkease/istore-ui app-store-ui
git_sparse_clone main https://github.com/linkease/istore luci

# Online User Plugin
git_sparse_clone main https://github.com/haiibo/packages luci-app-onliner
sed -i '$i uci set nlbwmon.@nlbwmon[0].refresh_interval=2s' package/lean/default-settings/files/zzz-default-settings
sed -i '$i uci commit nlbwmon' package/lean/default-settings/files/zzz-default-settings
chmod 755 package/luci-app-onliner/root/usr/share/onliner/setnlbw.sh

# Change local time display format
sed -i 's/os.date()/os.date("%a %Y-%m-%d %H:%M:%S")/g' package/lean/autocore/files/*/index.htm

# Change version to build date
date_version=$(date +"%y.%m.%d")
orig_version=$(cat "package/lean/default-settings/files/zzz-default-settings" | grep DISTRIB_REVISION= | awk -F "'" '{print $2}')
sed -i "s/${orig_version}/R${date_version} by Haiibo/g" package/lean/default-settings/files/zzz-default-settings

# Fix hostapd build error
cp -f $GITHUB_WORKSPACE/scripts/011-fix-mbo-modules-build.patch package/network/services/hostapd/patches/011-fix-mbo-modules-build.patch

# Fix xfsprogs error on armv8
sed -i 's/TARGET_CFLAGS.*/TARGET_CFLAGS += -DHAVE_MAP_SYNC -D_LARGEFILE64_SOURCE/g' feeds/packages/utils/xfsprogs/Makefile

# Fix Makefile paths
find package/*/ -maxdepth 2 -path "*/Makefile" | xargs -i sed -i 's|../../luci.mk|$(TOPDIR)/feeds/luci/luci.mk|g' {}
find package/*/ -maxdepth 2 -path "*/Makefile" | xargs -i sed -i 's|../../lang/golang/golang-package.mk|$(TOPDIR)/feeds/packages/lang/golang/golang-package.mk|g' {}
find package/*/ -maxdepth 2 -path "*/Makefile" | xargs -i sed -i 's|PKG_SOURCE_URL:=@GHREPO|PKG_SOURCE_URL:=https://github.com|g' {}
find package/*/ -maxdepth 2 -path "*/Makefile" | xargs -i sed -i 's|PKG_SOURCE_URL:=@GHCODELOAD|PKG_SOURCE_URL:=https://codeload.github.com|g' {}

# Remove theme default settings
find package/luci-theme-*/* -type f -name '*luci-theme-*' -print -exec sed -i '/set luci.main.mediaurlbase/d' {} \;

# Update & install all feeds
./scripts/feeds update -a
./scripts/feeds install -a
