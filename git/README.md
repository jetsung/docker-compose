# Git

同一 git 代码托管平台的账号，在同一台电脑上共存的解决方案

### 依赖环境
- [Docker](https://www.docker.com/)
- [docker compose](https://github.com/docker/compose) v2

### 文件说明
`docker-compose.yaml` 文件   
```
version: '3'
services:
  git:
    container_name: git-alpine
    image: devcto/git:latest
    environment:
      - GIT_USER=example
      - GIT_EMAIL=dev@example.com
    volumes:
      - ./init.sh:/root/init.sh
      - ./.ssh:/root/.ssh
      - /work_code:/srv
    restart: unless-stopped
```

- `image` 为基础镜像。即 `alpine` 镜像，该镜像比较小，最适合此项目。
- `container_name` 为 `该容器` 名称。
- `GIT_USER` 为 git 用户的账号
- `GIT_EMAIL` 为 git 用户的邮箱
- 文件 `./init.sh` 为初始化命令脚本，可自行修改。
- 文件夹 `./.ssh` 为该账号在平台的 `SSH 密钥`。必须设置，否则删除 `该容器` 再重建后，会遗失相关密钥。
- 文件夹 `/work_code` 为代码存放目录，即项目存放目录。多个项目比较分散的话，可自行在 `volumes` 添加。
- `restart` 为 `该容器` 重启的条件，防止意外终止。`unless-stopped` 的意思为 “除非本人执行停止的操作”

### 使用说明
1. 首次使用需要执行 `docker compose up -d` 。
   
2. 在终端窗口下执行 `docker exec -it git-alpine /bin/sh` 进入该容器。

3. 首次进入容器都需要先执行 `~/init.sh` 安装信赖组件和配置信息。若 `./.ssh` 目录未存在 `SSH 密钥`，则也需要自行生成。

4. 在对应的项目工程目录下执行相关的 git 命令行，即可。
  