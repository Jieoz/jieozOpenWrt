#!/bin/bash
#
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part1.sh
# Description: OpenWrt DIY script part 1 (Before Update feeds)
#

# Uncomment a feed source
#sed -i 's/^#\(.*helloworld\)/\1/' feeds.conf.default

# Add a feed source
#echo 'src-git helloworld https://github.com/fw876/helloworld' >>feeds.conf.default
#echo 'src-git passwall https://github.com/xiaorouji/openwrt-passwall' >>feeds.conf.default
cd package
clone_or_update() {
  local repo="$1"
  local dir="${2:-$(basename "$repo" .git)}"
  if [ -d "$dir/.git" ]; then
    git -C "$dir" pull --ff-only || true
  else
    git clone --depth 1 "$repo" "$dir"
  fi
}

clone_or_update https://github.com/rufengsuixing/luci-app-adguardhome.git
clone_or_update https://github.com/fw876/helloworld.git
clone_or_update https://github.com/UnblockNeteaseMusic/luci-app-unblockneteasemusic.git
clone_or_update https://github.com/monokoo/luci-app-syncdial.git
clone_or_update https://github.com/asvow/luci-app-tailscale.git

# 主流美观 LuCI 主题（中文环境可用）
clone_or_update https://github.com/kiddin9/luci-theme-edge.git
clone_or_update https://github.com/thinktip/luci-theme-neobird.git
clone_or_update https://github.com/Leo-Jo-My/luci-theme-opentomcat.git
clone_or_update https://github.com/sirpdboy/luci-theme-opentopd.git
clone_or_update https://github.com/0x676e67/luci-theme-design.git

cd lean
rm -rf luci-theme-argon
clone_or_update https://github.com/jerrykuku/luci-theme-argon.git luci-theme-argon

