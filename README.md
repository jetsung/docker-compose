# docker-compose

- acme
- adminer
- alist
- aliyundrive
- aliyunpan
- asciinema
- bark
- chanify
- chatgpt-web
- drone
- emqx
- etcd
- filetas
- frpc
- frps
- git
- gitea
- gitlab-runner
- hedgedoc
- joplin
- listmonk
- matomo
- mariadb
- meilisearch
- memos
- mindoc
- minio
- mrdoc
- mysql
- nginx-php
- open-webui
- pgadmin
- phpmyadmin
- postgres
- qbittorrent
- qinglong
- rap2
- rclone
- redis
- remark42
- rsshub
- rustpad
- simple-torrent
- sonic
- swagger
- syncthing
- transfer
- vaultwarden
- vaultwarden-backup
- webdav
- wechat-devtools
- wiz
- woodpecker
- xunsearch

## 提交与格式化

- 预提交工具 `pre-commit`  
  https://github.com/pre-commit/pre-commit  
  https://pre-commit.com/

  ```python
  pip install pre-commit

  # ever commit
  pre-commit install

  # format all files
  pre-commit run --all-files

  # format hook id
  pre-commit run <HOOK_ID>
  ```

- 格式化 `yml` 文件  
  https://github.com/jumanjihouse/pre-commit-hook-yamlfmt

## 仓库镜像

- https://git.jetsung.com/jetsung/docker-compose
- https://framagit.org/jetsung/docker-compose
- https://gitcode.com/jetsung/docker-compose
- https://github.com/jetsung/docker-compose
