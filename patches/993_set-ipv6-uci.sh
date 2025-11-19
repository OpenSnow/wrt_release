#!/bin/sh

# 只在第一次启动时运行的 uci-defaults 脚本
# 让 LAN 自动分配 IPv6（RA + DHCPv6）

# 如果网络/dhcp 配置不存在，直接退出
[ -f /etc/config/network ] || exit 0
[ -f /etc/config/dhcp ] || exit 0

# 1. 给 LAN 分配 IPv6 前缀
uci -q set network.lan.ip6assign='64'

# 加一行判断，不动现有的 ip6assign
# [ -z "$(uci -q get network.lan.ip6assign)" ] && uci set network.lan.ip6assign='64'

# 2. 为 LAN 打开 RA 和 DHCPv6
#    ra          = 'server' 表示路由器作为 RA 服务器
#    dhcpv6      = 'server' 打开 DHCPv6
#    ra_management = '1' 使用“管理型”模式（IPv6 地址由 DHCPv6 分配）
uci -q set dhcp.lan.ra='server'
uci -q set dhcp.lan.dhcpv6='server'
uci -q set dhcp.lan.ra_management='1'

# （可选）把 RA 默认路由也打开
# uci -q set dhcp.lan.ra_default='1'

uci commit network
uci commit dhcp

# 3. 尝试重载网络/服务
/etc/init.d/network reload >/dev/null 2>&1 || true
/etc/init.d/dnsmasq restart  >/dev/null 2>&1 || true
# odhcpd：
/etc/init.d/odhcpd restart >/dev/null 2>&1 || true

# 4. 自毁，保证只在第一次启动执行
rm -f "$0"

exit 0
