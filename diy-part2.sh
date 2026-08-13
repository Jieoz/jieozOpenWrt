#!/bin/bash
#
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#

# Modify default IP
#sed -i 's/192.168.1.1/192.168.50.5/g' package/base-files/files/bin/config_generate

# ---------------------------------------------------------------------------
# Fix upstream feed Makefiles that pin an inter-package dependency using the
# OpenWrt-official release-suffix format `-r$(PKG_RELEASE)`.
#
# Why this is needed: official openwrt/openwrt builds package versions as
# `$(PKG_VERSION)-r$(PKG_RELEASE)` (include/package-defaults.mk), but the lede
# tree we build against uses `$(PKG_VERSION)-$(PKG_RELEASE)` — no `r`. When a
# Makefile hardcodes an `EXTRA_DEPENDS` pin in the official format, the
# dependency string can never be satisfied in this tree and opkg aborts at
# `package/install` with:
#     pkg_hash_check_unresolved: cannot find dependency libsqlite3 (= 3.53.1-r1)
# which fails the whole firmware build AFTER ~4h of compiling.
#
# Concretely this hit coolsnowwolf/packages libs/sqlite3 (commit 360859c,
# 2026-07-05) which added `libsqlite3 (=$(PKG_VERSION)-r$(PKG_RELEASE))` to
# sqlite3-cli. Rather than patch that one package by name, rewrite any such pin
# to the format this tree actually produces, and only when the tree really is
# the non-`r` variant — so if we ever switch to official OpenWrt this becomes a
# no-op instead of silently corrupting correct pins.
# ---------------------------------------------------------------------------
if grep -qF -- 'VERSION:=$(PKG_VERSION)-r$(PKG_RELEASE)' include/package-defaults.mk; then
  echo "package-defaults uses OpenWrt-style -r release suffix; upstream pins already correct, nothing to do"
else
  echo "package-defaults uses lede-style release suffix (no 'r'); normalizing upstream -r pins"
  files=$(grep -rlF --include=Makefile -- '-r$(PKG_RELEASE))' feeds package 2>/dev/null || true)
  if [ -z "$files" ]; then
    echo "no -r\$(PKG_RELEASE) pins found"
  else
    for f in $files; do
      sed -i 's/-r\$(PKG_RELEASE))/-\$(PKG_RELEASE))/g' "$f"
      echo "patched release-suffix pin: $f"
    done
  fi
fi
