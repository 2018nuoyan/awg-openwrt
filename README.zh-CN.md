![发行版下载次数](https://img.shields.io/endpoint?url=https%3A%2F%2Fslava-shchipunov.github.io%2Fawg-openwrt%2Fdownloads.json)

# OpenWrt 的 AmneziaWG 软件包

[Русский / English](README.ru-en.md)

本仓库为 OpenWrt 构建 AmneziaWG 内核模块、命令行工具和 LuCI 管理界面，并提供简体中文界面翻译。

## 软件包

- `kmod-amneziawg`：内核模块
- `amneziawg-tools`：命令行工具及网络脚本
- `luci-proto-amneziawg`：LuCI 协议和状态界面
- `luci-i18n-amneziawg-zh-cn`：LuCI 简体中文语言包

## 自动安装

支持 OpenWrt 23.05.0 及更高版本。通过 SSH 登录路由器后执行：

```sh
sh <(wget -O - https://raw.githubusercontent.com/Slava-Shchipunov/awg-openwrt/refs/heads/master/amneziawg-install.sh)
```

脚本会自动识别 OpenWrt 版本、平台及软件包管理器。出现语言包提示时输入 `zh-cn` 即可安装简体中文语言包。随后可按提示创建 AmneziaWG 接口；创建的对端默认启用“路由允许的 IP”，即让全部流量通过隧道。

只安装软件包、不配置接口且不询问语言包：

```sh
sh <(wget -O - https://raw.githubusercontent.com/Slava-Shchipunov/awg-openwrt/refs/heads/master/amneziawg-install.sh) -en
```

## 手动安装

1. 在 [Releases](https://github.com/Slava-Shchipunov/awg-openwrt/releases) 中选择与路由器 OpenWrt 版本相同的发行版。
2. 确认设备的 `target`、`subtarget` 和软件包架构。
3. 下载并安装名称后缀与设备匹配的四个软件包：
   - `kmod-amneziawg`
   - `amneziawg-tools`
   - `luci-proto-amneziawg`
   - `luci-i18n-amneziawg-zh-cn`
4. 在 LuCI 的“系统 → 系统 → 语言和界面”中选择简体中文；如果页面仍显示旧文本，请清除浏览器缓存并重新登录。

OpenWrt 25.x 及更高版本还可使用本项目的 [APK 软件源](docs/custom-feed.md)。添加软件源后执行：

```sh
apk update
apk add amneziawg-tools kmod-amneziawg luci-proto-amneziawg luci-i18n-amneziawg-zh-cn
```

## LuCI 配置

在“网络 → 接口”中新建接口，并选择 **AmneziaWG VPN** 协议。界面支持：

- 导入 AmneziaWG `.conf` 配置；
- 管理对端、密钥、允许的 IP 和持续保活；
- 配置 AWG 2.0/3.1 混淆参数；
- 导出客户端配置及生成二维码；
- 查看接口、流量和最近握手状态。

AWG 3.1 新增报头保护、内容填充、重新协商时间、握手重试、随机尾部填充及 Cookie 控制等选项。相关参数必须与隧道另一端的配置保持一致。

## 从源码构建

将本仓库的软件包目录加入 OpenWrt SDK 或构建系统后，选择以下软件包：

```text
Network Support  -> kmod-amneziawg
Network          -> VPN -> amneziawg-tools
LuCI             -> Protocols -> luci-proto-amneziawg
LuCI             -> Translations -> luci-i18n-amneziawg-zh-cn
```

构建 `luci-proto-amneziawg` 时，`po/zh_Hans/` 中的翻译会自动生成 `luci-i18n-amneziawg-zh-cn` 软件包。
