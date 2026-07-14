#!/usr/bin/bash

SSR_URL=${SSR_URL:-$(jq -r '.ssr_url // empty' $CONFIG_PATH 2>/dev/null)}
CLASH_URL=${CLASH_URL:-$(jq -r '.clash_url // empty' $CONFIG_PATH 2>/dev/null)}
TPROXY=${TPROXY:-$(jq -r '.tproxy.enable // false' $CONFIG_PATH 2>/dev/null)}
TUN=${TUN:-$(jq -r '.tun.enable // false' $CONFIG_PATH 2>/dev/null)}

if [ "$SSR_URL" != '' ] ; then
	/clash/subconverter/subconverter &
	sleep 3
	wget -O /clash/config/sub.yaml "http://127.0.0.1:25500/sub?target=clash&url=${SSR_URL}"
	pkill subconverter
fi
if [ "$CLASH_URL" != '' ] ; then
	wget -O /clash/config/sub.yaml -U "clash-verge/v2.5.1;mihomo/${CLASH_VERSION}" ${CLASH_URL}
fi

cd /clash/config
yq '. *= load("GeneralClashConfig.yaml")' sub.yaml > config.yaml
if [ "$TPROXY" = "true" ]; then
	yq -i '. *= load("ClashDnsConfig.yaml")' config.yaml
	yq -i '. *= load("ClashTproxyConfig.yaml")' config.yaml
	/clash/scripts/net-forward.sh
	/clash/scripts/clash-network.sh
fi
if [ "$TUN" = "true" ]; then
	yq -i '. *= load("ClashDnsConfig.yaml")' config.yaml
	yq -i '. *= load("ClashTunConfig.yaml")' config.yaml
	/clash/scripts/net-forward.sh
fi

_term() { 
	echo "Caught SIGTERM signal! Stopping Clash..."
	if [ "$TPROXY" = "true" ]; then
		/clash/scripts/clash-clean.sh
	fi

	if [ -n "$CLASH_PID" ]; then
		kill -TERM "$CLASH_PID" 2>/dev/null
		wait "$CLASH_PID" 2>/dev/null
	fi
	exit 0
}
trap _term SIGTERM SIGINT

clash -d /clash/config "$@" &
CLASH_PID=$!
wait $CLASH_PID
