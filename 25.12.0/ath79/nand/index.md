---
layout: default
title: "OpenWrt 25.12.0 ath79/nand"
---

# AmneziaWG 软件源

当前位置：[首页](https://slava-shchipunov.github.io/awg-openwrt/) / [25.12.0](https://slava-shchipunov.github.io/awg-openwrt/25.12.0/) / [ath79](https://slava-shchipunov.github.io/awg-openwrt/25.12.0/ath79/)

- OpenWrt 版本：`25.12.0`
- 目标平台：`ath79`
- 子目标平台：`nand`
- 软件包架构：`mips_24kc`

## OpenWrt 上游目标平台

[https://downloads.openwrt.org/releases/25.12.0/targets/ath79/nand/](https://downloads.openwrt.org/releases/25.12.0/targets/ath79/nand/)

## 配置软件源

```sh
mkdir -p /etc/apk/keys
wget -O /etc/apk/keys/awg-openwrt-feed.pem "https://slava-shchipunov.github.io/awg-openwrt/keys/awg-openwrt-feed.pem"
echo "https://slava-shchipunov.github.io/awg-openwrt/25.12.0/ath79/nand/packages.adb" >> /etc/apk/repositories.d/customfeeds.list
```

## 安装软件包

```sh
apk update
apk add amneziawg-tools kmod-amneziawg luci-proto-amneziawg luci-i18n-amneziawg-zh-cn
```

<script src="https://slava-shchipunov.github.io/awg-openwrt/assets/copy-code.js?v=2"></script>

## 软件源文件

- [amneziawg-tools-1.0.20260223-r1.apk](https://slava-shchipunov.github.io/awg-openwrt/25.12.0/ath79/nand/amneziawg-tools-1.0.20260223-r1.apk)
- [feed.json](https://slava-shchipunov.github.io/awg-openwrt/25.12.0/ath79/nand/feed.json)
- [index.json](https://slava-shchipunov.github.io/awg-openwrt/25.12.0/ath79/nand/index.json)
- [kmod-amneziawg-6.12.71.1.0.20260329-r1.apk](https://slava-shchipunov.github.io/awg-openwrt/25.12.0/ath79/nand/kmod-amneziawg-6.12.71.1.0.20260329-r1.apk)
- [luci-i18n-amneziawg-ru-0.260508.62574.apk](https://slava-shchipunov.github.io/awg-openwrt/25.12.0/ath79/nand/luci-i18n-amneziawg-ru-0.260508.62574.apk)
- [luci-i18n-amneziawg-ru-0.apk](https://slava-shchipunov.github.io/awg-openwrt/25.12.0/ath79/nand/luci-i18n-amneziawg-ru-0.apk)
- [luci-proto-amneziawg-2.0.4-r1.apk](https://slava-shchipunov.github.io/awg-openwrt/25.12.0/ath79/nand/luci-proto-amneziawg-2.0.4-r1.apk)
- [packages.adb](https://slava-shchipunov.github.io/awg-openwrt/25.12.0/ath79/nand/packages.adb)
