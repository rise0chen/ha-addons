#!/bin/bash
set -e
cd "$(dirname "$0")"

TPROXY=${TPROXY:-$(jq -r '.tproxy.enable // false' $CONFIG_PATH 2>/dev/null)}
if [ "$TPROXY" != "true" ]; then
    exit 0
fi
HOST_INTERFACE=${HOST_INTERFACE:-$(jq -r '.tproxy.host_interface // empty' $CONFIG_PATH 2>/dev/null)}
CLASH_INTERFACE=${CLASH_INTERFACE:-$(jq -r '.tproxy.clash_interface // empty' $CONFIG_PATH 2>/dev/null)}
CLASH_IP=${CLASH_IP:-$(jq -r '.tproxy.clash_ip // empty' $CONFIG_PATH 2>/dev/null)}
GATEWAY_IP=${GATEWAY_IP:-$(jq -r '.tproxy.gateway_ip // empty' $CONFIG_PATH 2>/dev/null)}
SUBNET=${SUBNET_MASK:-$(jq -r '.tproxy.subnet_mask // empty' $CONFIG_PATH 2>/dev/null)}
if [ -z "$HOST_INTERFACE" ] || [ -z "$CLASH_INTERFACE" ] || [ -z "$CLASH_IP" ] || [ -z "$GATEWAY_IP" ]; then
    exit 1
fi

echo "[INFO] 正在初始化 Macvlan 网络接口: ${CLASH_INTERFACE} to ${HOST_INTERFACE}..."
if ! ip link show ${CLASH_INTERFACE} >/dev/null 2>&1; then
    ip link add ${CLASH_INTERFACE} link ${HOST_INTERFACE} type macvlan mode bridge
    ip addr add ${CLASH_IP}/${SUBNET} dev ${CLASH_INTERFACE}
    ip link set ${CLASH_INTERFACE} up
fi
echo "[INFO] Macvlan 配置成功，IP: ${CLASH_IP}，网关: ${GATEWAY_IP}"
