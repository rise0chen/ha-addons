# clash

## 启动方式

### 代理IP

```bash
# 手动指定config文件
docker run -d -p 7890:7890 -p 9090:9090 --name clash rise0chen/clash

## 下载config文件
docker run -d -p 7890:7890 -p 9090:9090 -e CLASH_URL=http://xx.xx --name clash rise0chen/clash
## SSR订阅链接生成config文件
docker run -d -p 7890:7890 -p 9090:9090 -e SSR_URL=http://xx.xx --name clash rise0chen/clash
```

### 自动路由

```bash
cp scripts/clash.service /etc/systemd/system/clash.service
systemctl daemon-reload
systemctl enable clash
systemctl restart clash
```


### 构建

```bash
docker buildx build --platform linux/amd64,linux/arm64 -t rise0chen/clash --push .
```

## Web控制台

[127.0.0.1:9090/ui](127.0.0.1:9090/ui)

## 配置文件

[configuration](https://wiki.metacubex.one/config/)

## 订阅链接转配置文件

[subconverter](https://github.com/tindy2013/subconverter)
[sub-web](https://sub-web.netlify.app/)
