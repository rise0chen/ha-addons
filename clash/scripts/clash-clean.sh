#!/bin/bash

echo "[INFO] 正在清理 iptables TPROXY 防火墙..."

# 斩断入口：从系统主链中移除对自定义链的引用（必须先做，否则无法删除自定义链）
while iptables -t mangle -D PREROUTING -j CLASH 2>/dev/null; do :; done
while iptables -t nat -D POSTROUTING -j MASQUERADE 2>/dev/null; do :; done

# 清空并删除自定义链 CLASH
iptables -t mangle -F CLASH 2>/dev/null
iptables -t mangle -X CLASH 2>/dev/null

# 删除策略路由规则与路由表条目
ip rule del fwmark 1 table 100 2>/dev/null
ip route del local default dev lo table 100 2>/dev/null

# 删除虚拟网卡
CLASH_INTERFACE=${CLASH_INTERFACE:-$(jq -r '.tproxy.clash_interface // empty' $CONFIG_PATH 2>/dev/null)}
if ip link show ${CLASH_INTERFACE} >/dev/null 2>&1; then
    echo "[INFO] 正在刪除虚拟网卡: ${CLASH_INTERFACE}..."
    ip link set ${CLASH_INTERFACE} down 2>/dev/null || true
    ip link del dev ${CLASH_INTERFACE} 2>/dev/null || true
fi

echo "[INFO] iptables 清理完成"

# 关闭 IP 转发（注意：如果你的机器做旁路由/网关，关闭此项会导致其他设备断网，请根据实际情况决定是否执行）
# sysctl -w net.ipv4.ip_forward=0
