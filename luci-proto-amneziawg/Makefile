include $(TOPDIR)/rules.mk

LUCI_NAME:=luci-proto-amneziawg
PKG_NAME:=luci-proto-amneziawg

LUCI_TITLE:=AmneziaWG VPN 支持
LUCI_DESCRIPTION:=提供 AmneziaWG VPN 协议支持和 Web 管理界面
PKG_VERSION:=3.1.0
LUCI_DEPENDS:=+amneziawg-tools +ucode +luci-lib-uqr +resolveip
LUCI_PKGARCH:=all
PKGARCH:=all

PKG_LICENSE:=Apache-2.0

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature
