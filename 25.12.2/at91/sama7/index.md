---
layout: default
title: "OpenWrt 25.12.2 at91/sama7"
---

# AmneziaWG 软件源

当前位置：[首页](https://slava-shchipunov.github.io/awg-openwrt/) / [25.12.2](https://slava-shchipunov.github.io/awg-openwrt/25.12.2/) / [at91](https://slava-shchipunov.github.io/awg-openwrt/25.12.2/at91/)

- OpenWrt 版本：`25.12.2`
- 目标平台：`at91`
- 子目标平台：`sama7`
- 软件包架构：`arm_cortex-a7_vfpv4`

## OpenWrt 上游目标平台

[https://downloads.openwrt.org/releases/25.12.2/targets/at91/sama7/](https://downloads.openwrt.org/releases/25.12.2/targets/at91/sama7/)

## 配置软件源

```sh
mkdir -p /etc/apk/keys
wget -O /etc/apk/keys/awg-openwrt-feed.pem "https://slava-shchipunov.github.io/awg-openwrt/keys/awg-openwrt-feed.pem"
echo "https://slava-shchipunov.github.io/awg-openwrt/25.12.2/at91/sama7/packages.adb" >> /etc/apk/repositories.d/customfeeds.list
```

## 安装软件包

```sh
apk update
apk add amneziawg-tools kmod-amneziawg luci-proto-amneziawg luci-i18n-amneziawg-zh-cn
```

<script src="https://slava-shchipunov.github.io/awg-openwrt/assets/copy-code.js?v=2"></script>

## 软件源文件

- [amneziawg-tools-1.0.20260223-r1.apk](https://slava-shchipunov.github.io/awg-openwrt/25.12.2/at91/sama7/amneziawg-tools-1.0.20260223-r1.apk)
- [feed.json](https://slava-shchipunov.github.io/awg-openwrt/25.12.2/at91/sama7/feed.json)
- [index.json](https://slava-shchipunov.github.io/awg-openwrt/25.12.2/at91/sama7/index.json)
- [kmod-amneziawg-6.12.74.1.0.20260329-r1.apk](https://slava-shchipunov.github.io/awg-openwrt/25.12.2/at91/sama7/kmod-amneziawg-6.12.74.1.0.20260329-r1.apk)
- [luci-i18n-amneziawg-ru-0.260508.67422.apk](https://slava-shchipunov.github.io/awg-openwrt/25.12.2/at91/sama7/luci-i18n-amneziawg-ru-0.260508.67422.apk)
- [luci-i18n-amneziawg-ru-0.260508.69322.apk](https://slava-shchipunov.github.io/awg-openwrt/25.12.2/at91/sama7/luci-i18n-amneziawg-ru-0.260508.69322.apk)
- [luci-proto-amneziawg-2.0.4-r1.apk](https://slava-shchipunov.github.io/awg-openwrt/25.12.2/at91/sama7/luci-proto-amneziawg-2.0.4-r1.apk)
- [packages.adb](https://slava-shchipunov.github.io/awg-openwrt/25.12.2/at91/sama7/packages.adb)
