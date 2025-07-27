# 開発環境セットアップ設計

## 概要
Docker Composeを使用してマルチコンテナ環境を構築し、Traefikをリバースプロキシとして利用することで、統一されたホスト名でアクセス可能な開発環境を実現する。

## アーキテクチャ設計

### コンテナ構成
```
┌─────────────────────────────────────────────────────────┐
│         Traefik (Reverse Proxy) - 外部で稼働            │
│                  http://my-receipt.localhost             │
└─────────────┬───────────────────────┬───────────────────┘
              │                       │
              ▼                       ▼
┌─────────────────────────┐ ┌─────────────────────────┐
│    Frontend Container    │ │    Backend Container     │
│      (Vue.js/Vite)      │ │    (PHP/Laravel)        │
│         Port 5173       │ │       Port 9000         │
└─────────────────────────┘ └──────────┬──────────────┘
                                       │
                            ┌──────────┴──────────┐
                            ▼                     ▼
                  ┌─────────────────┐   ┌─────────────────┐
                  │  MySQL Container │   │ Redis Container  │
                  │    Port 3306     │   │   Port 6379     │
                  └─────────────────┘   └─────────────────┘
```

### ディレクトリ構造
```
my-cook-receipt/
├── docker/
│   ├── php/
│   │   ├── Dockerfile
│   │   └── php.ini
│   ├── mysql/
│   │   └── init.sql
│   └── nginx/
│       └── default.conf
├── backend/              # Laravel プロジェクト
├── frontend/             # Vue.js プロジェクト
├── docker-compose.yml
├── .env.docker
└── Makefile             # 便利コマンド集
```

## コンテナ設計詳細

### 1. Backend コンテナ (PHP-FPM + Nginx)
- **ベースイメージ**: php:8.3-fpm
- **インストール内容**:
  - Composer
  - 必要なPHP拡張 (pdo_mysql, mbstring, etc.)
  - Nginx (同一コンテナ内)
- **Traefikラベル**:
  - `traefik.http.routers.my-receipt-backend.rule=Host('my-receipt.localhost')`
  - `traefik.http.services.my-receipt.loadbalancer.server.port=80`
- **ルーティング**: Laravel側で`/api`プレフィックスを処理

### 2. Frontend コンテナ
- **ベースイメージ**: node:18-alpine
- **役割**: Vue.js開発サーバー
- **設定**:
  - Vite設定でHMR対応
  - Proxy設定で/apiをバックエンドへ転送
- **Traefikラベル**:
  - `traefik.http.routers.my-receipt-frontend.rule=Host('my-receipt.localhost')`
  - `traefik.http.services.my-receipt-frontend.loadbalancer.server.port=5173`

### 3. MySQL コンテナ
- **イメージ**: mysql:8.5
- **環境変数**:
  - MYSQL_DATABASE=recipe_db
  - MYSQL_USER=recipe_user
  - MYSQL_PASSWORD=recipe_pass
- **初期化**: init.sqlでテーブル作成

### 4. Redis コンテナ
- **イメージ**: redis:7-alpine
- **設定**: 永続化有効

## ネットワーク設計
- **外部ネットワーク**: degg-develop-net（Traefikが稼働している既存ネットワーク）
- 全コンテナが外部ネットワークに参加
- docker-compose.ymlでの設定:
  ```yaml
  networks:
    degg-develop-net:
      external: true
  ```

## ボリューム設計
```yaml
volumes:
  # ソースコード（ホットリロード用）
  - ./backend:/var/www/html
  - ./frontend:/app
  
  # データ永続化
  - mysql_data:/var/lib/mysql
  - redis_data:/data
  
  # 設定ファイル
  - ./docker/php/php.ini:/usr/local/etc/php/php.ini
  - ./docker/nginx/default.conf:/etc/nginx/conf.d/default.conf
```

## 環境変数設計

### .env.docker
```env
# MySQL
MYSQL_ROOT_PASSWORD=root_password
MYSQL_DATABASE=recipe_db
MYSQL_USER=recipe_user
MYSQL_PASSWORD=recipe_pass

# Laravel
APP_ENV=local
APP_DEBUG=true
DB_HOST=mysql
DB_PORT=3306
DB_DATABASE=recipe_db
DB_USERNAME=recipe_user
DB_PASSWORD=recipe_pass
REDIS_HOST=redis
REDIS_PORT=6379

# Frontend
VITE_API_BASE_URL=http://my-receipt.localhost/api
```

## 初期化プロセス設計

### 1. 初回起動スクリプト
Makefileに以下のタスクを定義：
- `make setup`: 初回セットアップ（全自動）
- `make up`: 通常起動
- `make down`: 停止
- `make logs`: ログ確認
- `make shell-backend`: バックエンドコンテナにログイン
- `make shell-frontend`: フロントエンドコンテナにログイン

### 2. 自動セットアップ内容
1. 必要なディレクトリ作成
2. Laravelプロジェクト作成（存在しない場合）
3. Vue.jsプロジェクト作成（存在しない場合）
4. .envファイルのコピー・設定
5. Composer依存関係インストール
6. npm依存関係インストール
7. APP_KEY生成
8. データベースマイグレーション実行

## セキュリティ考慮事項
- 開発環境専用（本番環境では使用しない）
- データベースパスワードは.env.dockerで管理
- 外部ネットワーク経由でのアクセスはTraefik経由のみ

## パフォーマンス最適化
- Docker layer cacheの活用
- node_modulesはボリュームマウントから除外
- vendorディレクトリはボリュームマウントから除外（同期後）