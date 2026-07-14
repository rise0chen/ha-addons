#!/bin/bash
set -e

# 创建策略路由表（设置标记 1 的流量走本地环回）
echo "[INFO] 正在配置 iptables TPROXY 防火墙..."
ip rule add fwmark 1 table 100
ip route add local default dev lo table 100

# 在 iptables 中创建 CLASH 自定义链
iptables -t mangle -N CLASH

# 绕过局域网和私有 IP 流量
iptables -t mangle -A CLASH -d 0.0.0.0/8 -j RETURN
iptables -t mangle -A CLASH -d 10.0.0.0/8 -j RETURN
iptables -t mangle -A CLASH -d 127.0.0.0/8 -j RETURN
iptables -t mangle -A CLASH -d 169.254.0.0/16 -j RETURN
iptables -t mangle -A CLASH -d 172.16.0.0/12 -j RETURN
iptables -t mangle -A CLASH -d 192.168.0.0/16 -j RETURN
iptables -t mangle -A CLASH -d 224.0.0.0/4 -j RETURN
iptables -t mangle -A CLASH -d 240.0.0.0/4 -j RETURN

# 绕过特定端口
iptables -t mangle -A CLASH -p tcp --dport 9090 -j RETURN
iptables -t mangle -A CLASH -p tcp --dport 22 -j RETURN
iptables -t mangle -A CLASH -p tcp --sport 22 -j RETURN

# 将剩余的 TCP/UDP 流量通过 TProxy 转发给 Clash
iptables -t mangle -A CLASH -p tcp -j TPROXY --on-port 7893 --tproxy-mark 1
iptables -t mangle -A CLASH -p udp -j TPROXY --on-port 7893 --tproxy-mark 1

# 应用规则：将局域网其他设备发来的流量导入 CLASH 链
if [ -n "$CLASH_INTERFACE" ]; then
    iptables -t mangle -A PREROUTING -i $CLASH_INTERFACE -j CLASH
else
    iptables -t mangle -A PREROUTING -j CLASH
fi
echo "[INFO] iptables 配置完成"
