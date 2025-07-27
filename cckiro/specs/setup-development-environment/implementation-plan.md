# 開発環境セットアップ実装計画

## 実装順序

### Phase 1: 基本構造の準備（15分）
1. **ディレクトリ構造の作成**
   - [ ] docker/ディレクトリとサブディレクトリ作成
   - [ ] backend/ディレクトリ作成（Laravelプロジェクト用）
   - [ ] frontend/ディレクトリ作成（Vue.jsプロジェクト用）

2. **設定ファイルの作成**
   - [ ] .env.docker ファイル作成
   - [ ] .gitignore 更新（.env、vendor/、node_modules/など）

### Phase 2: Dockerファイルの作成（30分）
1. **Backend用Dockerfile作成**
   - [ ] docker/php/Dockerfile作成
   - [ ] PHP 8.3-fpm ベース
   - [ ] 必要な拡張モジュールインストール
   - [ ] Composerインストール
   - [ ] Nginx設定

2. **PHP設定ファイル作成**
   - [ ] docker/php/php.ini作成
   - [ ] メモリ制限、タイムアウト設定

3. **Nginx設定ファイル作成**
   - [ ] docker/nginx/default.conf作成
   - [ ] Laravelのルーティング設定

4. **MySQL初期化ファイル作成**
   - [ ] docker/mysql/init.sql作成
   - [ ] テーブル定義（仕様書から）

### Phase 3: Docker Compose設定（20分）
1. **docker-compose.yml作成**
   - [ ] backendサービス定義（Traefikラベル含む）
   - [ ] frontendサービス定義（Traefikラベル含む）
   - [ ] mysqlサービス定義
   - [ ] redisサービス定義
   - [ ] 外部ネットワーク設定（degg-develop-net）
   - [ ] ボリューム定義

### Phase 4: Laravel環境構築（30分）
1. **Laravelプロジェクト作成**
   - [ ] Composerでlaravel/laravelインストール
   - [ ] .env設定（データベース接続情報）
   - [ ] routes/api.php設定（/apiプレフィックス）

2. **初期マイグレーション作成**
   - [ ] recipesテーブル
   - [ ] ingredientsテーブル
   - [ ] stepsテーブル
   - [ ] tagsテーブル
   - [ ] recipe_tagsテーブル
   - [ ] favorite_ingredientsテーブル

### Phase 5: Vue.js環境構築（20分）
1. **Vue.jsプロジェクト作成**
   - [ ] npm create vue@latest実行
   - [ ] Vue Router、Pinia選択
   - [ ] TypeScript使用（任意）

2. **Vite設定**
   - [ ] vite.config.js修正
   - [ ] プロキシ設定（/api → backend）
   - [ ] HMR設定

### Phase 6: 便利スクリプト作成（10分）
1. **Makefile作成**
   - [ ] make setup: 初回セットアップ
   - [ ] make up: 起動
   - [ ] make down: 停止
   - [ ] make logs: ログ表示
   - [ ] make shell-backend: バックエンドシェル
   - [ ] make shell-frontend: フロントエンドシェル
   - [ ] make migrate: マイグレーション実行
   - [ ] make fresh: データベースリフレッシュ

### Phase 7: 動作確認（15分）
1. **起動確認**
   - [ ] docker compose up -d 実行
   - [ ] 全コンテナの起動確認

2. **アクセス確認**
   - [ ] http://my-receipt.localhost でフロントエンド表示
   - [ ] http://my-receipt.localhost/api でAPI応答確認

3. **開発機能確認**
   - [ ] ホットリロード動作確認
   - [ ] データベース接続確認

## 各ファイルの実装詳細

### docker/php/Dockerfile
```dockerfile
FROM php:8.3-fpm

# システムパッケージインストール
RUN apt-get update && apt-get install -y \
    nginx \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip

# PHP拡張インストール
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

# Composerインストール
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Nginx設定
COPY docker/nginx/default.conf /etc/nginx/sites-available/default

# 作業ディレクトリ
WORKDIR /var/www/html

# 起動スクリプト
CMD service nginx start && php-fpm
```

### docker-compose.yml（主要部分）
```yaml
version: '3.8'

networks:
  degg-develop-net:
    external: true

services:
  backend:
    build:
      context: .
      dockerfile: docker/php/Dockerfile
    container_name: my-receipt-backend
    volumes:
      - ./backend:/var/www/html
    networks:
      - degg-develop-net
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.my-receipt-backend.rule=Host(`my-receipt.localhost`)"
      - "traefik.http.services.my-receipt.loadbalancer.server.port=80"
    depends_on:
      - mysql
      - redis

  frontend:
    image: node:18-alpine
    container_name: my-receipt-frontend
    working_dir: /app
    volumes:
      - ./frontend:/app
    command: sh -c "npm install && npm run dev"
    networks:
      - degg-develop-net
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.my-receipt-frontend.rule=Host(`my-receipt.localhost`)"
      - "traefik.http.services.my-receipt-frontend.loadbalancer.server.port=5173"

  mysql:
    image: mysql:8.5
    container_name: my-receipt-mysql
    environment:
      MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}
      MYSQL_DATABASE: ${MYSQL_DATABASE}
      MYSQL_USER: ${MYSQL_USER}
      MYSQL_PASSWORD: ${MYSQL_PASSWORD}
    volumes:
      - mysql_data:/var/lib/mysql
      - ./docker/mysql/init.sql:/docker-entrypoint-initdb.d/init.sql
    networks:
      - degg-develop-net

  redis:
    image: redis:7-alpine
    container_name: my-receipt-redis
    volumes:
      - redis_data:/data
    networks:
      - degg-develop-net

volumes:
  mysql_data:
  redis_data:
```

## リスク管理

### 想定されるリスクと対策
1. **ポート競合**
   - 対策: Traefik経由のみでアクセスするため問題なし

2. **権限エラー**
   - 対策: Dockerfileでwww-dataユーザー設定

3. **ネットワーク接続エラー**
   - 対策: degg-develop-netが存在することを事前確認

4. **初期化失敗**
   - 対策: Makefileで各ステップを分離、エラー時の再実行を容易に

## 完了条件
- [ ] 全サービスが正常起動
- [ ] http://my-receipt.localhost でアクセス可能
- [ ] ホットリロードが機能
- [ ] データベース接続成功
- [ ] APIエンドポイントが応答