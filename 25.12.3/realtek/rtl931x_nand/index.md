---
layout: default
title: "OpenWrt 25.12.3 realtek/rtl931x_nand"
---

# AmneziaWG 软件源

当前位置：[首页](https://slava-shchipunov.github.io/awg-openwrt/) / [25.12.3](https://slava-shchipunov.github.io/awg-openwrt/25.12.3/) / [realtek](https://slava-shchipunov.github.io/awg-openwrt/25.12.3/realtek/)

- OpenWrt 版本：`25.12.3`
- 目标平台：`realtek`
- 子目标平台：`rtl931x_nand`
- 软件包架构：`mips_24kc`

## OpenWrt 上游目标平台

[https://downloads.openwrt.org/releases/25.12.3/targets/realtek/rtl931x_nand/](https://downloads.openwrt.org/releases/25.12.3/targets/realtek/rtl931x_nand/)

## 配置软件源

```sh
mkdir -p /etc/apk/keys
wget -O /etc/apk/keys/awg-openwrt-feed.pem "https://slava-shchipunov.github.io/awg-openwrt/keys/awg-openwrt-feed.pem"
echo "https://slava-shchipunov.github.io/awg-openwrt/25.12.3/realtek/rtl931x_nand/packages.adb" >> /etc/apk/repositories.d/customfeeds.list
```

## 安装软件包

```sh
apk update
apk add amneziawg-tools kmod-amneziawg luci-proto-amneziawg luci-i18n-amneziawg-zh-cn
```

<script src="https://slava-shchipunov.github.io/awg-openwrt/assets/copy-code.js?v=2"></script>

## 软件源文件

- [amneziawg-tools-1.0.20260223-r1.apk](https://slava-shchipunov.github.io/awg-openwrt/25.12.3/realtek/rtl931x_nand/amneziawg-tools-1.0.20260223-r1.apk)
- [feed.json](https://slava-shchipunov.github.io/awg-openwrt/25.12.3/realtek/rtl931x_nand/feed.json)
- [index.json](https://slava-shchipunov.github.io/awg-openwrt/25.12.3/realtek/rtl931x_nand/index.json)
- [kmod-amneziawg-6.12.85.1.0.20260329-r1.apk](https://slava-shchipunov.github.io/awg-openwrt/25.12.3/realtek/rtl931x_nand/kmod-amneziawg-6.12.85.1.0.20260329-r1.apk)
- [luci-i18n-amneziawg-ru-0.260509.08274.apk](https://slava-shchipunov.github.io/awg-openwrt/25.12.3/realtek/rtl931x_nand/luci-i18n-amneziawg-ru-0.260509.08274.apk)
- [luci-proto-amneziawg-2.0.4-r1.apk](https://slava-shchipunov.github.io/awg-openwrt/25.12.3/realtek/rtl931x_nand/luci-proto-amneziawg-2.0.4-r1.apk)
- [packages.adb](https://slava-shchipunov.github.io/awg-openwrt/25.12.3/realtek/rtl931x_nand/packages.adb)
