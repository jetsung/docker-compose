# asciinema

## 前置服务
1. 安装 `nginx` 和 `docker`
2. 需要使用到 `email` 账户的 `smtp` 服务，以提供登录

## [部署服务器](https://github.com/asciinema/asciinema-server)

### 服务全部使用 `Docker`

- [**`docker-compose.yml`**](docker-compose.yml)
```yaml
ervices:
  asciinema:
    image: ghcr.io/asciinema/asciinema-server:latest
    env_file:
      - ./.env
    volumes:
      - asciinema_data:/var/opt/asciinema
    ports:
      - "$SERV_PORT:4000"
    depends_on:
      postgres:
        condition: service_healthy
  postgres:
    image: docker.io/library/postgres:16
    volumes:
      - postgres_data:/var/lib/postgresql/data
    environment:
      - POSTGRES_HOST_AUTH_METHOD=trust
    healthcheck:
      test: ['CMD-SHELL', 'pg_isready -U postgres']
      interval: 2s
      timeout: 5s
      retries: 10
volumes:
  asciinema_data:
  postgres_data:
```

### 数据库使用宿主机的 `Postgres`

- 创建 `Postgres` 的用户
  - 1. 

- 查看宿主机的网络
```bash
docker network inspect bridge | grep 'Gateway' | awk -F'"' '{print $4}'
```
将下述的 `hostname` 修改为上述命令查出来的 **IP**。

- [`.env`](.env) 文件添加一行数据库的信息，[**相关文档**](https://docs.asciinema.org/manual/server/self-hosting/configuration/#external-postgresql-server)。
```ini
# Postgres
DATABASE_URL=postgresql://username:password@hostname/dbname
```

- [**`docker-compose.yml`**](docker-compose.postgres.yml)
```yaml
services:
  asciinema:
    image: ghcr.io/asciinema/asciinema-server:latest
    env_file:
      - ./.env
    volumes:
      - asciinema_data:/var/opt/asciinema
    ports:
      - "$SERV_PORT:4000"
volumes:
  asciinema_data:
```

### 数据库使用宿主机的 `Postgres` 和 `AWS S3` 对象存储
- [`.env`](.env) 文件添加 `S3` 相关的信息，[**相关文档**](https://docs.asciinema.org/manual/server/self-hosting/configuration/#cloudflare-r2)。
```ini
# S3
S3_BUCKET=<BUCKET_NAME>
S3_ENDPOINT=<https://ENDPOINT_DOMAIN>
S3_ACCESS_KEY_ID=<ACCESS_KEY>
S3_SECRET_ACCESS_KEY=<SECRET_ACCESS_KEY>
S3_REGION=<REGION>
```

- [**`docker-compose.yml`**](docker-compose.postgres-s3.yml)
```yaml
services:
  asciinema:
    image: ghcr.io/asciinema/asciinema-server:latest
    env_file:
      - ./.env
    ports:
      - "$SERV_PORT:4000"
```

## 配置信息
- [**`.env`**](.env) 参数说明
```bash
# 是否关闭注册，默认 false
SIGN_UP_DISABLED=false

# 管理员联系邮箱
CONTACT_EMAIL_ADDRESS=<CONTACT_EMAIL_ADDRESS>

# 未认领的 rec 垃圾回收时长，单位（天）
UNCLAIMED_RECORDING_TTL=30

# 密钥，使用命令生成: 
# tr -dc A-Za-z0-9 </dev/urandom | head -c 64; echo
SECRET_KEY_BASE=<SECRET_KEY_BASE>

URL_HOST=example.com # 服务器的主机名，即互联网访问域名
URL_PORT=4000 # 内部服务端口，默认 4000
URL_SCHEME=https # 访问协议，默认 http

# SMTP 基本配置
SMTP_HOST=smtp.exmail.qq.com # 必填
SMTP_PORT=587 # 必填，默认端口
SMTP_USERNAME=<SMTP_USERNAME> # 必填，邮箱用户名
SMTP_PASSWORD=<SMTP_PASSWORD> # 必填，邮箱密码

# SMTP 加密配置
SMTP_TLS=always # 加密方式
SMTP_ALLOWED_TLS_VERSIONS=tlsv1.2 # 允许的 TLS 版本

# SMTP 认证配置
SMTP_AUTH=always # 验证方式
SMTP_NO_MX_LOOKUPS=false

# 邮件头配置
MAIL_FROM_ADDRESS=<MAIL_FROM_ADDRESS> # From
MAIL_REPLY_TO_ADDRESS=<MAIL_REPLY_TO_ADDRESS> # Reply-To

# S3
S3_BUCKET=<BUCKET_NAME>
S3_ENDPOINT=<https://ENDPOINT_DOMAIN>
S3_ACCESS_KEY_ID=<ACCESS_KEY>
S3_SECRET_ACCESS_KEY=<SECRET_ACCESS_KEY>
S3_REGION=<REGION>
```

### 配置 `.env`
- [配置邮箱信息](https://docs.asciinema.org/manual/server/self-hosting/configuration/#email)
- 配置 NGINX 反代
  ```nginx
    location / {
        proxy_pass http://127.0.0.1:4000;

        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection upgrade;
        proxy_set_header Accept-Encoding gzip;
        proxy_set_header Origin https://$host;
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-For $remote_addr;

        # WebSocket support
        proxy_http_version 1.1;
        proxy_read_timeout 120s;
        proxy_next_upstream error;
        proxy_redirect off;
        proxy_buffering off;
    }  
  ```
- 添加管理邮箱
  ```bash
  docker compose exec asciinema admin_add admin@example.com
  ```
  