#!/bin/bash

set -e

echo "======================================"
echo "  VPS 一键部署（Halo + Siyuan + Caddy + RustDesk）"
echo "======================================"
echo

cd ~/docker || mkdir -p ~/docker && cd ~/docker

# ======================
# 输入信息
# ======================
read -p "Halo域名: " HALO_DOMAIN
read -p "思源域名: " SIYUAN_DOMAIN
read -p "RustDesk域名(标识用): " RUST_DOMAIN

read -s -p "Postgres密码: " DB_PASS
echo
read -s -p "Halo数据库密码: " HALO_PASS
echo
read -s -p "思源访问码: " SIYUAN_CODE
echo

# ======================
# 创建目录
# ======================
mkdir -p caddy halo/db siyuan rustdesk/hbbs rustdesk/hbbr

# ======================
# .env（备用扩展）
# ======================
cat > .env <<EOF
POSTGRES_PASSWORD=$DB_PASS
HALO_DB_PASSWORD=$HALO_PASS
SIYUAN_CODE=$SIYUAN_CODE
HALO_DOMAIN=$HALO_DOMAIN
SIYUAN_DOMAIN=$SIYUAN_DOMAIN
RUST_DOMAIN=$RUST_DOMAIN
EOF

echo "✔ .env 已生成"

# ======================
# Caddyfile
# ======================
cat > caddy/Caddyfile <<EOF
$HALO_DOMAIN {
    reverse_proxy halo:8090
}

$SIYUAN_DOMAIN {
    reverse_proxy siyuan:6806
}

# RustDesk只是标识域名（不做反代）
$RUST_DOMAIN {
    respond "RustDesk server running"
}
EOF

echo "✔ Caddyfile 已生成"

# ======================
# docker-compose.yml
# ======================
cat > docker-compose.yml <<EOF
services:

  # ======================
  # Caddy
  # ======================
  caddy:
    image: caddy:latest
    container_name: caddy
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./caddy/Caddyfile:/etc/caddy/Caddyfile
      - ./caddy/data:/data
      - ./caddy/config:/config
    networks:
      - web

  # ======================
  # Halo
  # ======================
  halo:
    image: halohub/halo-pro:2
    container_name: halo
    restart: unless-stopped
    depends_on:
      - halodb
    environment:
      - JVM_OPTS=-Xmx512m -Xms256m
    command:
      - --spring.r2dbc.url=r2dbc:pool:postgresql://halodb:5432/halo
      - --spring.r2dbc.username=halo
      - --spring.r2dbc.password=${HALO_DB_PASSWORD}
      - --halo.external-url=https://${HALO_DOMAIN}
    volumes:
      - ./halo:/root/.halo2
    ports:
      - "8090:8090"
    networks:
      - web

  # ======================
  # Halo PostgreSQL
  # ======================
  halodb:
    image: postgres:17
    container_name: halodb
    restart: unless-stopped
    environment:
      - POSTGRES_DB=halo
      - POSTGRES_USER=halo
      - POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
    volumes:
      - ./halo/db:/var/lib/postgresql/data
    networks:
      - web

  # ======================
  # Siyuan
  # ======================
  siyuan:
    image: b3log/siyuan:latest
    container_name: siyuan
    restart: unless-stopped
    user: root
    command:
      - --workspace=/workspace
      - --accessAuthCode=${SIYUAN_CODE}
    environment:
      - TZ=Asia/Shanghai
    volumes:
      - ./siyuan:/workspace
    ports:
      - "6806:6806"
    networks:
      - web

  # ======================
  # RustDesk hbbs
  # ======================
  hbbs:
    image: rustdesk/rustdesk-server:latest
    container_name: hbbs
    command: hbbs
    restart: unless-stopped
    volumes:
      - ./rustdesk/hbbs:/root
    ports:
      - "21115:21115"
      - "21116:21116"
      - "21116:21116/udp"
      - "21118:21118"
    networks:
      - web

  # ======================
  # RustDesk hbbr
  # ======================
  hbbr:
    image: rustdesk/rustdesk-server:latest
    container_name: hbbr
    command: hbbr
    restart: unless-stopped
    volumes:
      - ./rustdesk/hbbr:/root
    ports:
      - "21117:21117"
      - "21119:21119"
    networks:
      - web

networks:
  web:
EOF

echo "✔ docker-compose.yml 已生成"

# ======================
# 启动
# ======================
echo
echo "🚀 启动所有服务..."
docker compose up -d

echo
echo "======================================"
echo "✔ 部署完成"
echo "======================================"
echo "Halo:     https://$HALO_DOMAIN"
echo "思源:     https://$SIYUAN_DOMAIN"
echo "RustDesk: $RUST_DOMAIN"
echo "======================================"