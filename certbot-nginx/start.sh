#!/bin/bash

# 检查是否以root权限运行
if [ "$EUID" -ne 0 ]
  then echo "请以root权限运行此脚本"
  exit
fi

# 设置变量
read -p "请输入您的域名: " DOMAIN

# 使用当前路径作为PROJECT_DIR
PROJECT_DIR=$(pwd)

# 创建Nginx配置目录
mkdir -p ./etc/nginx/conf.d/

# 创建初始Nginx配置
cat > ./etc/nginx/conf.d/app.conf << EOF
server {
    listen 80;
    listen [::]:80;

    server_name $DOMAIN;
    server_tokens off;

    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }

    location / {
        return 301 https://$DOMAIN\$request_uri;
    }
}
EOF

# 启动webserver
docker compose up -d webserver

# 获取SSL证书
docker compose run --rm certbot certonly --webroot --webroot-path /var/www/certbot/ -d $DOMAIN

# 更新Nginx配置以包含SSL设置
cat >> ./etc/nginx/conf.d/app.conf << EOF

server {
    listen 443 ssl;
    listen [::]:443 ssl;

    server_name $DOMAIN;

    ssl_certificate /etc/letsencrypt/live/$DOMAIN/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$DOMAIN/privkey.pem;
    
    location / {
        # 在此处添加proxy_pass或root配置
    }
}
EOF

# 重启webserver
docker compose restart webserver

# 设置自动更新cron任务
(crontab -l 2>/dev/null; echo "0 0 */5 * * cd $PROJECT_DIR && docker compose run --rm certbot renew") | crontab -

echo "部署完成！"
echo "请确保在Nginx配置中添加适当的proxy_pass或root指令。"
echo "SSL证书将每5天尝试自动更新。"