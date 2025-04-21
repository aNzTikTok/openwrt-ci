#!/bin/bash

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
git clone --depth=1 https://github.com/openwrt/luci.git package/feeds/luci
git clone --depth=1 https://github.com/QMODEM/telegrambot package/telegrambot
git clone --depth=1 https://github.com/QMODEM/atinout package/atinout
git clone --depth=1 https://github.com/QMODEM/luci-app-atinout-mod package/luci-app-atinout-mod
git clone --depth=1 https://github.com/QMODEM/quectel-CM-5G package/quectel-CM-5G
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
git clone --depth=1 https://github.com/aNzTikTok/luci-app-ttl package/luci-app-ttl

# Themes
git clone --depth=1 -b 18.06 https://github.com/jerrykuku/luci-theme-argon package/luci-theme-argon
git clone --depth=1 https://github.com/jerrykuku/luci-app-argon-config package/luci-app-argon-config

# Fix Makefile paths
find package/*/ -maxdepth 2 -path "*/Makefile" | xargs -i sed -i 's|../../luci.mk|$(TOPDIR)/feeds/luci/luci.mk|g' {}
find package/*/ -maxdepth 2 -path "*/Makefile" | xargs -i sed -i 's|../../lang/golang/golang-package.mk|$(TOPDIR)/feeds/packages/lang/golang/golang-package.mk|g' {}
find package/*/ -maxdepth 2 -path "*/Makefile" | xargs -i sed -i 's|PKG_SOURCE_URL:=@GHREPO|PKG_SOURCE_URL:=https://github.com|g' {}
find package/*/ -maxdepth 2 -path "*/Makefile" | xargs -i sed -i 's|PKG_SOURCE_URL:=@GHCODELOAD|PKG_SOURCE_URL:=https://codeload.github.com|g' {}

# Clone tool-up repo and move csstidy and luasrcdiet to tools/
git clone --depth=1 https://github.com/QMODEM/tool-up.git tool-up
mv tool-up/csstidy tools/csstidy
mv tool-up/luasrcdiet tools/luasrcdiet
rm -rf tool-up

# Append to tools/Makefile if not already present
grep -q 'csstidy' tools/Makefile || echo 'tools-y += csstidy' >> tools/Makefile
grep -q 'luasrcdiet' tools/Makefile || echo 'tools-y += luasrcdiet' >> tools/Makefile
