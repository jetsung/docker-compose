## Docker 下 V2ray + CloudFlare

### 环境需求
- Linux (服务器平台)
- Docker (布署环境)
- V2ray (梯子工具)
- CloudFlare (代理转发加速)
- Caddy / Nginx (代理到 443 端口)

### 使用指南
**v2ray：**   
1. 创建文件夹以保存 `config.json` 和 `docker-compose.yaml` 两个文件
2. 使用 `docker compose up -d` 启动 v2ray

至此，即可直接使用 v2ray。   
案例中的配置信息为：   
```
vmess://e44fefd3-38bc-4eef-bba9-e63cbdb43e99@YOU_HOST_IP_ADDRESS:39288?tls=0&path=/cf&encryption=none&type=ws&alterId=64#YOUR_HOST_IP
```

**Caddy：**   
> 假设域名为 `example.com`   
1. 添加以下配置信息到 `Caddyfile` 文件
```
example.com {
	root * /data/wwwroot/default
	encode gzip
 	tls example@domain.com
  	reverse_proxy /cf 127.0.0.1:39288 {
		header_up Host {upstream_hostport}
		header_up X-Forwarded-Host {host}
	}
}
```

**Nginx：(比 Caddy 略麻烦)**   
> nginx 与 caddy 只选其一即可。   
> 出现这种情况主要是因为一台服务器可能跑了很多服务，比如同时跑了使用 nginx 的 WEB 服务。   
> 注意，需要自行安装 SSL 证书。
> 假设域名为 `example.com`   

1. 添加以下信息到 `vhost/example.com.conf` 文件中
```
#必须添加的
map $http_upgrade $connection_upgrade {
        default upgrade;
        '' close;
}
#监听websocket
upstream websocket {
    #ip_hash;
    #转发到服务器上相应的ws端口
    server localhost:39288;
}

server {
    listen 80;
    listen [::]:80;
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
  
    server_name example.com;
    
    ## 此处的路径与 websocket 的 path 路径需要一致
    location / {
        #转发到 http://websocket
        proxy_pass http://websocket;
        proxy_read_timeout 300s;
        proxy_send_timeout 300s;

        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        #升级http1.1到 websocket协议  
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection  $connection_upgrade;
    }

    ssl_certificate    ssl/example.com.pem;
    ssl_certificate_key    ssl/example.com.key;

    ssl_protocols TLSv1 TLSv1.1 TLSv1.2 TLSv1.3;
    ssl_ciphers TLS13-AES-256-GCM-SHA384:TLS13-CHACHA20-POLY1305-SHA256:TLS13-AES-128-GCM-SHA256:TLS13-AES-128-CCM-8-SHA256:TLS13-AES-128-CCM-SHA256:EECDH+CHACHA20:EECDH+AES128:RSA+AES128:EECDH+AES256:RSA+AES256:EECDH+3DES:RSA+3DES:!MD5;
    ssl_prefer_server_ciphers on;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;
    error_page 497  https://$host$request_uri;

}
```

2. 肯定需要重启 caddy/nginx 嘛。   
至此，即可直接使用 tls 加密方式与 443 端口。 
案例中的配置信息为：   
```
vmess://e44fefd3-38bc-4eef-bba9-e63cbdb43e99@example.com:443?tls=1&path=/cf&encryption=none&type=ws&alterId=64#example.com
```

**CloudFlare：**   
> 加速，可以看高清的油管   
1. 到 cloudflare 平台里，域名 example.com 下的 DNS 中添加“记录名称”为 proxy，IP 地址为 v2ray 的服务器 IP
2. 打开该（二级）域名的代理状态
3. 在 SSL/TLS 中将 SSL/TLS 加密模式修改为“完全”
4. 在 “边缘证书” 选项卡中添加证书，建议修改 “最低 TLS 版本” 为 “TLS 1.3”

至此，已可以使用 CloudFlare 加速 V2ray 代理。 
案例中的配置信息为（与上一节的配置信息相同）：   
```
vmess://e44fefd3-38bc-4eef-bba9-e63cbdb43e99@example.com:443?tls=1&path=/cf&encryption=none&type=ws&alterId=64#example.com
```