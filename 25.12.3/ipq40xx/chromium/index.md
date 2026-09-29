---
layout: default
title: "OpenWrt 25.12.3 ipq40xx/chromium"
---

# AmneziaWG 软件源

当前位置：[首页](https://slava-shchipunov.github.io/awg-openwrt/) / [25.12.3](https://slava-shchipunov.github.io/awg-openwrt/25.12.3/) / [ipq40xx](https://slava-shchipunov.github.io/awg-openwrt/25.12.3/ipq40xx/)

- OpenWrt 版本：`25.12.3`
- 目标平台：`ipq40xx`
- 子目标平台：`chromium`
- 软件包架构：`arm_cortex-a7_neon-vfpv4`

## OpenWrt 上游目标平台

[https://downloads.openwrt.org/releases/25.12.3/targets/ipq40xx/chromium/](https://downloads.openwrt.org/releases/25.12.3/targets/ipq40xx/chromium/)

## 配置软件源

```sh
mkdir -p /etc/apk/keys
wget -O /etc/apk/keys/awg-openwrt-feed.pem "https://slava-shchipunov.github.io/awg-openwrt/keys/awg-openwrt-feed.pem"
echo "https://slava-shchipunov.github.io/awg-openwrt/25.12.3/ipq40xx/chromium/packages.adb" >> /etc/apk/repositories.d/customfeeds.list
```

## 安装软件包

```sh
apk update
apk add amneziawg-tools kmod-amneziawg luci-proto-amneziawg luci-i18n-amneziawg-zh-cn
```

<script src="https://slava-shchipunov.github.io/awg-openwrt/assets/copy-code.js?v=2"></script>

## 软件源文件

- [amneziawg-tools-1.0.20260223-r1.apk](https://slava-shchipunov.github.io/awg-openwrt/25.12.3/ipq40xx/chromium/amneziawg-tools-1.0.20260223-r1.apk)
- [feed.json](https://slava-shchipunov.github.io/awg-openwrt/25.12.3/ipq40xx/chromium/feed.json)
- [index.json](https://slava-shchipunov.github.io/awg-openwrt/25.12.3/ipq40xx/chromium/index.json)
- [kmod-amneziawg-6.12.85.1.0.20260329-r1.apk](https://slava-shchipunov.github.io/awg-openwrt/25.12.3/ipq40xx/chromium/kmod-amneziawg-6.12.85.1.0.20260329-r1.apk)
- [luci-i18n-amneziawg-ru-0.260509.08033.apk](https://slava-shchipunov.github.io/awg-openwrt/25.12.3/ipq40xx/chromium/luci-i18n-amneziawg-ru-0.260509.08033.apk)
- [luci-proto-amneziawg-2.0.4-r1.apk](https://slava-shchipunov.github.io/awg-openwrt/25.12.3/ipq40xx/chromium/luci-proto-amneziawg-2.0.4-r1.apk)
- [packages.adb](https://slava-shchipunov.github.io/awg-openwrt/25.12.3/ipq40xx/chromium/packages.adb)
