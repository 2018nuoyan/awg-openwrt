---
layout: default
title: "OpenWrt 25.12.3 x86/64"
---

# AmneziaWG 软件源

当前位置：[首页](https://slava-shchipunov.github.io/awg-openwrt/) / [25.12.3](https://slava-shchipunov.github.io/awg-openwrt/25.12.3/) / [x86](https://slava-shchipunov.github.io/awg-openwrt/25.12.3/x86/)

- OpenWrt 版本：`25.12.3`
- 目标平台：`x86`
- 子目标平台：`64`
- 软件包架构：`x86_64`

## OpenWrt 上游目标平台

[https://downloads.openwrt.org/releases/25.12.3/targets/x86/64/](https://downloads.openwrt.org/releases/25.12.3/targets/x86/64/)

## 配置软件源

```sh
mkdir -p /etc/apk/keys
wget -O /etc/apk/keys/awg-openwrt-feed.pem "https://slava-shchipunov.github.io/awg-openwrt/keys/awg-openwrt-feed.pem"
echo "https://slava-shchipunov.github.io/awg-openwrt/25.12.3/x86/64/packages.adb" >> /etc/apk/repositories.d/customfeeds.list
```

## 安装软件包

```sh
apk update
apk add amneziawg-tools kmod-amneziawg luci-proto-amneziawg luci-i18n-amneziawg-zh-cn
```

<script src="https://slava-shchipunov.github.io/awg-openwrt/assets/copy-code.js?v=2"></script>

## 软件源文件

- [amneziawg-tools-1.0.20260223-r1.apk](https://slava-shchipunov.github.io/awg-openwrt/25.12.3/x86/64/amneziawg-tools-1.0.20260223-r1.apk)
- [feed.json](https://slava-shchipunov.github.io/awg-openwrt/25.12.3/x86/64/feed.json)
- [index.json](https://slava-shchipunov.github.io/awg-openwrt/25.12.3/x86/64/index.json)
- [kmod-amneziawg-6.12.85.1.0.20260329-r1.apk](https://slava-shchipunov.github.io/awg-openwrt/25.12.3/x86/64/kmod-amneziawg-6.12.85.1.0.20260329-r1.apk)
- [luci-i18n-amneziawg-ru-0.260509.08015.apk](https://slava-shchipunov.github.io/awg-openwrt/25.12.3/x86/64/luci-i18n-amneziawg-ru-0.260509.08015.apk)
- [luci-proto-amneziawg-2.0.4-r1.apk](https://slava-shchipunov.github.io/awg-openwrt/25.12.3/x86/64/luci-proto-amneziawg-2.0.4-r1.apk)
- [packages.adb](https://slava-shchipunov.github.io/awg-openwrt/25.12.3/x86/64/packages.adb)
