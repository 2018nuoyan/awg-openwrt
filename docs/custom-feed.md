# 自定义软件源（GitHub Pages）

本仓库通过 GitHub Pages 为使用 `apk` 和 APK v3 元数据的 OpenWrt 25.x 及更高版本发布完整的软件源。

OpenWrt 24.x 及更早版本不支持此软件源，请从 GitHub Releases 下载对应的 `.ipk` 软件包。

软件源由工作流 `.github/workflows/build-feed.yml` 发布到 `gh-pages` 分支，目录格式如下：

```text
/<openwrt-version>/<target>/<subtarget>/
```

例如：

```text
/25.12.3/mediatek/filogic/
```

软件源首页：

```text
https://slava-shchipunov.github.io/awg-openwrt/
```

网站按以下层级提供导航：

```text
/<openwrt-version>/
/<openwrt-version>/<target>/
/<openwrt-version>/<target>/<subtarget>/
```

软件源包含：

- `.apk` 软件包；
- `packages.adb`；
- 由 SDK 生成的 APK 软件源元数据；
- 用于验证元数据的公开签名密钥。

## OpenWrt 25.x 及更高版本

首先安装公开签名密钥：

```sh
mkdir -p /etc/apk/keys
wget -O /etc/apk/keys/awg-openwrt-feed.pem https://slava-shchipunov.github.io/awg-openwrt/keys/awg-openwrt-feed.pem
```

然后添加软件源。请将 `VERSION`、`TARGET` 和 `SUBTARGET` 替换为设备对应的值：

```sh
echo "https://slava-shchipunov.github.io/awg-openwrt/VERSION/TARGET/SUBTARGET/packages.adb" >> /etc/apk/repositories.d/customfeeds.list
apk update
apk add amneziawg-tools kmod-amneziawg luci-proto-amneziawg luci-i18n-amneziawg-zh-cn
```

最小验证命令：

```sh
apk update
apk add amneziawg-tools
```

## 公开签名密钥

签名密钥发布在以下固定地址：

```text
https://slava-shchipunov.github.io/awg-openwrt/keys/awg-openwrt-feed.pem
```

如需可信安装，请将公开密钥保存到 `/etc/apk/keys/`：

```sh
mkdir -p /etc/apk/keys
wget -O /etc/apk/keys/awg-openwrt-feed.pem https://slava-shchipunov.github.io/awg-openwrt/keys/awg-openwrt-feed.pem
apk update
```

工作流中的所有矩阵任务使用 GitHub Secrets 中同一组固定密钥签名：

- `AWG_FEED_APK_PRIVATE_KEY`
- `AWG_FEED_APK_PUBLIC_KEY`

可使用以下命令生成密钥对：

```sh
openssl ecparam -name prime256v1 -genkey -noout -out awg-openwrt-feed.pem
openssl ec -in awg-openwrt-feed.pem -pubout > awg-openwrt-feed.pub.pem
```

将 `awg-openwrt-feed.pem` 和 `awg-openwrt-feed.pub.pem` 的内容分别保存到上述 Secrets。私钥不会公开；公钥会以 `keys/awg-openwrt-feed.pem` 路径发布到 GitHub Pages。
