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
# Official UnblockNeteaseMusic LuCI frontend (JavaScript/Node.js core).
clone_or_update https://github.com/UnblockNeteaseMusic/luci-app-unblockneteasemusic.git
clone_or_update https://github.com/monokoo/luci-app-syncdial.git
clone_or_update https://github.com/asvow/luci-app-tailscale.git

# LuCI themes policy: only keep stock bootstrap and argon.
# Third-party legacy themes have repeatedly broken newer LuCI dispatcher/header rendering.

cd lean
rm -rf luci-theme-argon
clone_or_update https://github.com/jerrykuku/luci-theme-argon.git luci-theme-argon

