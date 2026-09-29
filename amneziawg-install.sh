#!/bin/sh

#set -x

PKG_MANAGER=""
PKG_EXT=""

usage() {
    cat <<EOF
用法：${0##*/} [-h] [-e] [-n]
    -h    显示此帮助信息
    -e    不询问是否安装 AmneziaWG 语言包
    -n    不配置 AmneziaWG 接口
EOF
    exit 0
}

detect_package_manager() {
    if command -v apk >/dev/null 2>&1; then
        PKG_MANAGER="apk"
        PKG_EXT="apk"
    elif command -v opkg >/dev/null 2>&1; then
        PKG_MANAGER="opkg"
        PKG_EXT="ipk"
    else
        printf "\033[32;1m未找到受支持的软件包管理器（apk/opkg）。\033[0m\n"
        exit 1
    fi
}

pkg_update() {
    if [ "$PKG_MANAGER" = "apk" ]; then
        apk update
    else
        opkg update
    fi
}

is_pkg_installed() {
    pkg_name="$1"
    if [ "$PKG_MANAGER" = "apk" ]; then
        apk info -e "$pkg_name" >/dev/null 2>&1
    else
        opkg list-installed 2>/dev/null | grep -q "^${pkg_name} "
    fi
}

install_local_pkg() {
    pkg_file="$1"
    if [ "$PKG_MANAGER" = "apk" ]; then
        apk add --allow-untrusted "$pkg_file"
    else
        opkg install "$pkg_file"
    fi
}

get_pkgarch() {
    PKGARCH_UBUS=$(ubus call system board 2>/dev/null | jsonfilter -e '@.release.arch' 2>/dev/null)
    if [ -n "$PKGARCH_UBUS" ]; then
        echo "$PKGARCH_UBUS"
        return
    fi

    if command -v opkg >/dev/null 2>&1; then
        opkg print-architecture | awk 'BEGIN {max=0} {if ($3 > max) {max = $3; arch = $2}} END {print arch}'
        return
    fi

    if [ -f /etc/openwrt_release ]; then
        PKGARCH_RELEASE=$(grep "^DISTRIB_ARCH='" /etc/openwrt_release | cut -d"'" -f2)
        if [ -n "$PKGARCH_RELEASE" ]; then
            echo "$PKGARCH_RELEASE"
            return
        fi
    fi

    if command -v apk >/dev/null 2>&1; then
        apk --print-arch
        return
    fi

    uname -m
}

download_package() {
    pkg_base_name="$1"
    pkg_postfix_base="$2"
    awg_dir="$3"
    base_url="$4"

    preferred_file="${pkg_base_name}${pkg_postfix_base}.${PKG_EXT}"
    preferred_url="${base_url}${preferred_file}"
    if wget -q -O "$awg_dir/$preferred_file" "$preferred_url" && [ -s "$awg_dir/$preferred_file" ]; then
        echo "$preferred_file"
        return 0
    fi
    rm -f "$awg_dir/$preferred_file"

    if [ "$PKG_EXT" = "apk" ]; then
        fallback_ext="ipk"
    else
        fallback_ext="apk"
    fi

    fallback_file="${pkg_base_name}${pkg_postfix_base}.${fallback_ext}"
    fallback_url="${base_url}${fallback_file}"
    if wget -q -O "$awg_dir/$fallback_file" "$fallback_url" && [ -s "$awg_dir/$fallback_file" ]; then
        echo "$fallback_file"
        return 0
    fi
    rm -f "$awg_dir/$fallback_file"

    return 1
}

# OpenWrt 软件源必须可用，以便安装 kmod-amneziawg 的依赖
check_repo() {
    printf "\033[32;1m正在检查 OpenWrt 软件源是否可用…\033[0m\n"
    if [ "$PKG_MANAGER" = "apk" ]; then
        pkg_update >/dev/null 2>&1 || \
            { printf "\033[32;1mapk 执行失败，请检查网络连接或系统时间。强制同步时间命令：ntpd -p ptbtime1.ptb.de\033[0m\n"; exit 1; }
    else
        pkg_update | grep -q "Failed to download" && \
            printf "\033[32;1mopkg 执行失败，请检查网络连接或系统时间。强制同步时间命令：ntpd -p ptbtime1.ptb.de\033[0m\n" && exit 1
    fi
}

install_awg_packages() {
    # 获取优先级最高的软件包架构
    PKGARCH=$(get_pkgarch)

    TARGET=$(ubus call system board | jsonfilter -e '@.release.target' | cut -d '/' -f 1)
    SUBTARGET=$(ubus call system board | jsonfilter -e '@.release.target' | cut -d '/' -f 2)
    VERSION=$(ubus call system board | jsonfilter -e '@.release.version')
    PKGPOSTFIX_BASE="_v${VERSION}_${PKGARCH}_${TARGET}_${SUBTARGET}"
    BASE_URL="https://github.com/Slava-Shchipunov/awg-openwrt/releases/download/"

    # 根据 OpenWrt 版本确定 AWG 协议版本
    AWG_VERSION="1.0"
    MAJOR_VERSION=$(echo "$VERSION" | cut -d '.' -f 1)
    PATCH_VERSION=$(echo "$VERSION" | cut -d '.' -f 3)

    if [ "$MAJOR_VERSION" -gt 25 ] || \
       [ "$MAJOR_VERSION" -eq 25 -a "$PATCH_VERSION" -ge 5 ] || \
       [ "$MAJOR_VERSION" -eq 24 -a "$PATCH_VERSION" -ge 8 ]; then
        AWG_VERSION="3.1"
        LUCI_PACKAGE_NAME="luci-proto-amneziawg"
    elif [ "$MAJOR_VERSION" -gt 24 ] || \
       [ "$MAJOR_VERSION" -eq 24 -a "$PATCH_VERSION" -ge 3 ] || \
       [ "$MAJOR_VERSION" -eq 23 -a "$PATCH_VERSION" -ge 6 ]; then
        AWG_VERSION="2.0"
        LUCI_PACKAGE_NAME="luci-proto-amneziawg"
    else
        LUCI_PACKAGE_NAME="luci-app-amneziawg"
    fi

    printf "\033[32;1m检测到 AWG 版本：$AWG_VERSION\033[0m\n"

    AWG_DIR="/tmp/amneziawg"
    mkdir -p "$AWG_DIR"

    if is_pkg_installed "kmod-amneziawg"; then
        echo "kmod-amneziawg 已安装"
    else
        KMOD_AMNEZIAWG_FILENAME=$(download_package "kmod-amneziawg" "$PKGPOSTFIX_BASE" "$AWG_DIR" "${BASE_URL}v${VERSION}/")
        if [ $? -eq 0 ]; then
            echo "kmod-amneziawg 文件下载成功"
        else
            echo "下载 kmod-amneziawg 失败，请手动安装后重新运行脚本"
            exit 1
        fi

        install_local_pkg "$AWG_DIR/$KMOD_AMNEZIAWG_FILENAME"

        if [ $? -eq 0 ]; then
            echo "kmod-amneziawg 安装成功"
        else
            echo "安装 kmod-amneziawg 失败，请手动安装后重新运行脚本"
            exit 1
        fi
    fi

    if is_pkg_installed "amneziawg-tools"; then
        echo "amneziawg-tools 已安装"
    else
        AMNEZIAWG_TOOLS_FILENAME=$(download_package "amneziawg-tools" "$PKGPOSTFIX_BASE" "$AWG_DIR" "${BASE_URL}v${VERSION}/")
        if [ $? -eq 0 ]; then
            echo "amneziawg-tools 文件下载成功"
        else
            echo "下载 amneziawg-tools 失败，请手动安装后重新运行脚本"
            exit 1
        fi

        install_local_pkg "$AWG_DIR/$AMNEZIAWG_TOOLS_FILENAME"

        if [ $? -eq 0 ]; then
            echo "amneziawg-tools 安装成功"
        else
            echo "安装 amneziawg-tools 失败，请手动安装后重新运行脚本"
            exit 1
        fi
    fi

    # 检查两种可能的软件包名称
    if is_pkg_installed "luci-proto-amneziawg" || is_pkg_installed "luci-app-amneziawg"; then
        echo "$LUCI_PACKAGE_NAME 已安装"
    else
        LUCI_AMNEZIAWG_FILENAME=$(download_package "$LUCI_PACKAGE_NAME" "$PKGPOSTFIX_BASE" "$AWG_DIR" "${BASE_URL}v${VERSION}/")
        if [ $? -eq 0 ]; then
            echo "$LUCI_PACKAGE_NAME 文件下载成功"
        else
            echo "下载 $LUCI_PACKAGE_NAME 失败，请手动安装后重新运行脚本"
            exit 1
        fi

        install_local_pkg "$AWG_DIR/$LUCI_AMNEZIAWG_FILENAME"

        if [ $? -eq 0 ]; then
            echo "$LUCI_PACKAGE_NAME 安装成功"
        else
            echo "安装 $LUCI_PACKAGE_NAME 失败，请手动安装后重新运行脚本"
            exit 1
        fi
    fi

    # 为 AWG 2.0 及更高版本安装所选语言包
    if [ "$AWG_VERSION" != "1.0" ] && [ "$ASK_FOR_TRANSLATION" = 1 ]; then
        printf "\033[32;1m是否安装语言包？（简体中文 zh-cn / 俄语 ru / 不安装 n）[zh-cn]：\033[0m\n"
        read INSTALL_LANG
        INSTALL_LANG=${INSTALL_LANG:-zh-cn}

        case "$INSTALL_LANG" in
            zh|zh-cn|zh_CN|zh-Hans|zh_Hans)
                LANG_CODE="zh-cn"
                LANG_NAME="简体中文"
                ;;
            ru|RU)
                LANG_CODE="ru"
                LANG_NAME="俄语"
                ;;
            *)
                LANG_CODE=""
                ;;
        esac

        if [ -n "$LANG_CODE" ]; then
            LANG_PACKAGE="luci-i18n-amneziawg-${LANG_CODE}"
            if is_pkg_installed "$LANG_PACKAGE"; then
                echo "$LANG_PACKAGE 已安装"
            else
                LUCI_I18N_AMNEZIAWG_FILENAME=$(download_package "$LANG_PACKAGE" "$PKGPOSTFIX_BASE" "$AWG_DIR" "${BASE_URL}v${VERSION}/")
                if [ $? -eq 0 ]; then
                    echo "$LANG_PACKAGE 文件下载成功"
                    install_local_pkg "$AWG_DIR/$LUCI_I18N_AMNEZIAWG_FILENAME"
                    if [ $? -eq 0 ]; then
                        echo "$LANG_PACKAGE 安装成功"
                    else
                        echo "警告：安装 $LANG_PACKAGE 失败（非致命错误）"
                    fi
                else
                    echo "警告：当前版本或平台没有可用的 $LANG_NAME 语言包（非致命错误）"
                fi
            fi
        else
            printf "\033[32;1m跳过语言包安装。\033[0m\n"
        fi
    fi

    rm -rf "$AWG_DIR"
}

configure_amneziawg_interface() {
    INTERFACE_NAME="awg1"
    CONFIG_NAME="amneziawg_awg1"
    PROTO="amneziawg"
    ZONE_NAME="awg1"

    read -r -p "请输入私钥（来自 [Interface]）："$'\n' AWG_PRIVATE_KEY_INT

    while true; do
        read -r -p "请输入带子网前缀的内部 IP 地址，例如 192.168.100.5/24（来自 [Interface]）："$'\n' AWG_IP
        if echo "$AWG_IP" | egrep -oq '^([0-9]{1,3}\.){3}[0-9]{1,3}/[0-9]+$'; then
            break
        else
            echo "IP 地址无效，请重新输入"
        fi
    done

    read -r -p "请输入 DNS 服务器（IPv4 和/或 IPv6，使用逗号或空格分隔，来自 [Interface]）[可选，留空跳过]："$'\n' AWG_DNS

    read -r -p "请输入公钥（来自 [Peer]）："$'\n' AWG_PUBLIC_KEY_INT
    read -r -p "如使用 PresharedKey，请输入预共享密钥（来自 [Peer]）；否则留空："$'\n' AWG_PRESHARED_KEY_INT
    read -r -p "请输入不含端口的端点主机（域名或 IP，来自 [Peer]）："$'\n' AWG_ENDPOINT_INT

    read -r -p "请输入端点端口（来自 [Peer]）[51820]："$'\n' AWG_ENDPOINT_PORT_INT
    AWG_ENDPOINT_PORT_INT=${AWG_ENDPOINT_PORT_INT:-51820}
    if [ "$AWG_ENDPOINT_PORT_INT" = '51820' ]; then
        echo $AWG_ENDPOINT_PORT_INT
    fi

    if [ "$AWG_VERSION" = "3.1" ]; then
        read -r -p "请输入 PersistentKeepalive 值或范围（来自 [Peer]）[可选，留空使用 25]："$'\n' AWG_PERSISTENT_KEEPALIVE
    else
        read -r -p "请输入 PersistentKeepalive 值（来自 [Peer]）[可选，留空使用 25]："$'\n' AWG_PERSISTENT_KEEPALIVE
    fi
    AWG_PERSISTENT_KEEPALIVE=${AWG_PERSISTENT_KEEPALIVE:-25}

    read -r -p "请输入 Jc 值（来自 [Interface]）："$'\n' AWG_JC
    read -r -p "请输入 Jmin 值（来自 [Interface]）："$'\n' AWG_JMIN
    read -r -p "请输入 Jmax 值（来自 [Interface]）："$'\n' AWG_JMAX
    read -r -p "请输入 S1 值（来自 [Interface]）："$'\n' AWG_S1
    read -r -p "请输入 S2 值（来自 [Interface]）："$'\n' AWG_S2
    read -r -p "请输入 H1 值（来自 [Interface]）："$'\n' AWG_H1
    read -r -p "请输入 H2 值（来自 [Interface]）："$'\n' AWG_H2
    read -r -p "请输入 H3 值（来自 [Interface]）："$'\n' AWG_H3
    read -r -p "请输入 H4 值（来自 [Interface]）："$'\n' AWG_H4

    # AWG 2.0 及更高版本的参数
    if [ "$AWG_VERSION" != "1.0" ]; then
        read -r -p "请输入 S3 值（来自 [Interface]）[可选，留空跳过]："$'\n' AWG_S3
        read -r -p "请输入 S4 值（来自 [Interface]）[可选，留空跳过]："$'\n' AWG_S4
        read -r -p "请输入 I1 值（来自 [Interface]）[可选，留空跳过]："$'\n' AWG_I1
        read -r -p "请输入 I2 值（来自 [Interface]）[可选，留空跳过]："$'\n' AWG_I2
        read -r -p "请输入 I3 值（来自 [Interface]）[可选，留空跳过]："$'\n' AWG_I3
        read -r -p "请输入 I4 值（来自 [Interface]）[可选，留空跳过]："$'\n' AWG_I4
        read -r -p "请输入 I5 值（来自 [Interface]）[可选，留空跳过]："$'\n' AWG_I5
    fi

    # AWG 3.1 参数
    if [ "$AWG_VERSION" = "3.1" ]; then
        read -r -p "请输入 HeaderProtectionKey 值（来自 [Interface]）[可选，留空跳过]："$'\n' AWG_HEADER_PROTECTION_KEY
        read -r -p "请输入 ContentPaddingAddition 值或范围（来自 [Interface]）[可选，留空跳过]："$'\n' AWG_CONTENT_PADDING_ADDITION
        read -r -p "请输入 RekeyAfterTime 值或范围（来自 [Interface]）[可选，留空跳过]："$'\n' AWG_REKEY_AFTER_TIME
        read -r -p "请输入 RekeyTimeout 值或范围（来自 [Interface]）[可选，留空跳过]："$'\n' AWG_REKEY_TIMEOUT
        read -r -p "请输入 RejectAfterTime 值或范围（来自 [Interface]）[可选，留空跳过]："$'\n' AWG_REJECT_AFTER_TIME
        read -r -p "请输入 KeepaliveTimeout 值或范围（来自 [Interface]）[可选，留空跳过]："$'\n' AWG_KEEPALIVE_TIMEOUT
        read -r -p "请输入 MaxHandshakeAttempts 值或范围（来自 [Interface]）[可选，留空跳过]："$'\n' AWG_MAX_HANDSHAKE_ATTEMPTS

        while true; do
            read -r -p "请输入 RandomTrailers 值（来自 [Interface]）[on/off，可选，留空跳过]："$'\n' AWG_RANDOM_TRAILERS
            case "$AWG_RANDOM_TRAILERS" in
                ""|0|1) break ;;
                on|On|ON|true|True|TRUE|yes|Yes|YES|y|Y) AWG_RANDOM_TRAILERS=1; break ;;
                off|Off|OFF|false|False|FALSE|no|No|NO|n|N) AWG_RANDOM_TRAILERS=0; break ;;
                *) echo "值无效，请输入 on、off 或留空" ;;
            esac
        done

        while true; do
            read -r -p "请输入 DisableCookies 值（来自 [Interface]）[on/off，可选，留空跳过]："$'\n' AWG_DISABLE_COOKIES
            case "$AWG_DISABLE_COOKIES" in
                ""|0|1) break ;;
                on|On|ON|true|True|TRUE|yes|Yes|YES|y|Y) AWG_DISABLE_COOKIES=1; break ;;
                off|Off|OFF|false|False|FALSE|no|No|NO|n|N) AWG_DISABLE_COOKIES=0; break ;;
                *) echo "值无效，请输入 on、off 或留空" ;;
            esac
        done
    fi

    uci set "network.${INTERFACE_NAME}=interface"
    uci set "network.${INTERFACE_NAME}.proto=${PROTO}"
    uci set "network.${INTERFACE_NAME}.private_key=${AWG_PRIVATE_KEY_INT}"
    uci set "network.${INTERFACE_NAME}.listen_port=51821"
    uci set "network.${INTERFACE_NAME}.addresses=${AWG_IP}"

    uci -q delete "network.${INTERFACE_NAME}.dns"
    if [ -n "$AWG_DNS" ]; then
        AWG_DNS_LIST=$(printf '%s\n' "$AWG_DNS" | tr ',' ' ')
        for AWG_DNS_SERVER in $AWG_DNS_LIST; do
            uci add_list "network.${INTERFACE_NAME}.dns=${AWG_DNS_SERVER}"
        done
    fi

    uci set "network.${INTERFACE_NAME}.awg_jc=${AWG_JC}"
    uci set "network.${INTERFACE_NAME}.awg_jmin=${AWG_JMIN}"
    uci set "network.${INTERFACE_NAME}.awg_jmax=${AWG_JMAX}"
    uci set "network.${INTERFACE_NAME}.awg_s1=${AWG_S1}"
    uci set "network.${INTERFACE_NAME}.awg_s2=${AWG_S2}"
    uci set "network.${INTERFACE_NAME}.awg_h1=${AWG_H1}"
    uci set "network.${INTERFACE_NAME}.awg_h2=${AWG_H2}"
    uci set "network.${INTERFACE_NAME}.awg_h3=${AWG_H3}"
    uci set "network.${INTERFACE_NAME}.awg_h4=${AWG_H4}"

    # 设置 AWG 2.0 及更高版本的可选参数
    if [ "$AWG_VERSION" != "1.0" ]; then
        [ -n "$AWG_S3" ] && uci set "network.${INTERFACE_NAME}.awg_s3=${AWG_S3}"
        [ -n "$AWG_S4" ] && uci set "network.${INTERFACE_NAME}.awg_s4=${AWG_S4}"
        [ -n "$AWG_I1" ] && uci set "network.${INTERFACE_NAME}.awg_i1=${AWG_I1}"
        [ -n "$AWG_I2" ] && uci set "network.${INTERFACE_NAME}.awg_i2=${AWG_I2}"
        [ -n "$AWG_I3" ] && uci set "network.${INTERFACE_NAME}.awg_i3=${AWG_I3}"
        [ -n "$AWG_I4" ] && uci set "network.${INTERFACE_NAME}.awg_i4=${AWG_I4}"
        [ -n "$AWG_I5" ] && uci set "network.${INTERFACE_NAME}.awg_i5=${AWG_I5}"
    fi

    # 设置 AWG 3.1 的可选参数
    if [ "$AWG_VERSION" = "3.1" ]; then
        [ -n "$AWG_HEADER_PROTECTION_KEY" ] && uci set "network.${INTERFACE_NAME}.awg_header_protection_key=${AWG_HEADER_PROTECTION_KEY}"
        [ -n "$AWG_CONTENT_PADDING_ADDITION" ] && uci set "network.${INTERFACE_NAME}.awg_content_padding_addition=${AWG_CONTENT_PADDING_ADDITION}"
        [ -n "$AWG_REKEY_AFTER_TIME" ] && uci set "network.${INTERFACE_NAME}.awg_rekey_after_time=${AWG_REKEY_AFTER_TIME}"
        [ -n "$AWG_REKEY_TIMEOUT" ] && uci set "network.${INTERFACE_NAME}.awg_rekey_timeout=${AWG_REKEY_TIMEOUT}"
        [ -n "$AWG_REJECT_AFTER_TIME" ] && uci set "network.${INTERFACE_NAME}.awg_reject_after_time=${AWG_REJECT_AFTER_TIME}"
        [ -n "$AWG_KEEPALIVE_TIMEOUT" ] && uci set "network.${INTERFACE_NAME}.awg_keepalive_timeout=${AWG_KEEPALIVE_TIMEOUT}"
        [ -n "$AWG_MAX_HANDSHAKE_ATTEMPTS" ] && uci set "network.${INTERFACE_NAME}.awg_max_handshake_attempts=${AWG_MAX_HANDSHAKE_ATTEMPTS}"
        [ -n "$AWG_RANDOM_TRAILERS" ] && uci set "network.${INTERFACE_NAME}.awg_random_trailers=${AWG_RANDOM_TRAILERS}"
        [ -n "$AWG_DISABLE_COOKIES" ] && uci set "network.${INTERFACE_NAME}.awg_disable_cookies=${AWG_DISABLE_COOKIES}"
    fi

    if ! uci show network | grep -Fq "$CONFIG_NAME"; then
        uci add network "$CONFIG_NAME"
    fi

    uci set "network.@${CONFIG_NAME}[0]=${CONFIG_NAME}"
    uci set "network.@${CONFIG_NAME}[0].name=${INTERFACE_NAME}_client"
    uci set "network.@${CONFIG_NAME}[0].public_key=${AWG_PUBLIC_KEY_INT}"
    uci set "network.@${CONFIG_NAME}[0].preshared_key=${AWG_PRESHARED_KEY_INT}"
    uci set "network.@${CONFIG_NAME}[0].route_allowed_ips=1"
    uci set "network.@${CONFIG_NAME}[0].persistent_keepalive=${AWG_PERSISTENT_KEEPALIVE}"
    uci set "network.@${CONFIG_NAME}[0].endpoint_host=${AWG_ENDPOINT_INT}"
    uci set "network.@${CONFIG_NAME}[0].allowed_ips=0.0.0.0/0"
    uci add_list "network.@${CONFIG_NAME}[0].allowed_ips=::/0"
    uci set "network.@${CONFIG_NAME}[0].endpoint_port=${AWG_ENDPOINT_PORT_INT}"
    uci commit network

    if ! uci show firewall | grep -q "@zone.*name='${ZONE_NAME}'"; then
        printf "\033[32;1m已创建防火墙区域\033[0m\n"
        uci add firewall zone
        uci set firewall.@zone[-1].name=$ZONE_NAME
        uci set firewall.@zone[-1].network=$INTERFACE_NAME
        uci set firewall.@zone[-1].forward='REJECT'
        uci set firewall.@zone[-1].output='ACCEPT'
        uci set firewall.@zone[-1].input='REJECT'
        uci set firewall.@zone[-1].masq='1'
        uci set firewall.@zone[-1].mtu_fix='1'
        uci set firewall.@zone[-1].family='ipv4'
        uci commit firewall
    fi

    if ! uci show firewall | grep -q "@forwarding.*name='${ZONE_NAME}-lan'"; then
        printf "\033[32;1m已配置防火墙转发\033[0m\n"
        uci add firewall forwarding
        uci set firewall.@forwarding[-1]=forwarding
        uci set firewall.@forwarding[-1].name="${ZONE_NAME}-lan"
        uci set firewall.@forwarding[-1].dest=${ZONE_NAME}
        uci set firewall.@forwarding[-1].src='lan'
        uci set firewall.@forwarding[-1].family='ipv4'
        uci commit firewall
    fi

    service network restart
}

ASK_FOR_TRANSLATION=1
ASK_FOR_INTERFACE_CONFIG=1

while getopts ":ehn" opt; do
    case "$opt" in
        h) usage ;;
        e) ASK_FOR_TRANSLATION=0 ;;
        n) ASK_FOR_INTERFACE_CONFIG=0 ;;
        \?) echo "未知选项 -$OPTARG" >&2; usage ;;
    esac
done
shift "$((OPTIND-1))"

detect_package_manager
check_repo

install_awg_packages

if [ "$ASK_FOR_INTERFACE_CONFIG" = 0 ]; then
    exit 0
fi

printf "\033[32;1m是否配置 AmneziaWG 接口？（y/n）：\033[0m\n"
read IS_SHOULD_CONFIGURE_AWG_INTERFACE

if [ "$IS_SHOULD_CONFIGURE_AWG_INTERFACE" = "y" ] || [ "$IS_SHOULD_CONFIGURE_AWG_INTERFACE" = "Y" ]; then
    configure_amneziawg_interface
else
    printf "\033[32;1m跳过 AmneziaWG 接口配置。\033[0m\n"
fi
