# 料理レシピ管理サイト

効率的な入力と見やすい表示を重視した料理レシピ管理サイトです。
タレや調味料の作り方も含む入れ子構造のレシピ管理が可能です。

## 技術スタック

- **フロントエンド**: Vue.js 3 + Composition API
- **バックエンド**: PHP 8.3 (Laravel)
- **データベース**: MySQL 8.5
- **インフラ**: Docker + Docker Compose
- **リバースプロキシ**: Traefik（外部で稼働）

## セットアップ手順

### 前提条件

- Docker および Docker Compose がインストールされていること
- Traefik が degg-develop-net ネットワークで稼働していること

### 初回セットアップ

```bash
# 初回セットアップ（全自動）
make setup
```

このコマンドで以下が実行されます：
1. 環境変数ファイルの作成
2. Laravelプロジェクトの作成
3. Vue.jsプロジェクトの作成
4. Dockerコンテナのビルドと起動
5. データベースマイグレーション

### 通常の起動・停止

```bash
# コンテナ起動
make up

# コンテナ停止
make down

# ログ確認
make logs
```

### 開発用コマンド

```bash
# バックエンドコンテナにログイン
make shell-backend

# フロントエンドコンテナにログイン
make shell-frontend

# マイグレーション実行
make migrate

# データベースリフレッシュ
make fresh
```

## アクセス方法

- **フロントエンド**: http://my-receipt.localhost
- **バックエンドAPI**: http://my-receipt.localhost/api
- **ヘルスチェック**: http://my-receipt.localhost/api/health

## ディレクトリ構造

```
my-cook-receipt/
├── backend/          # Laravelプロジェクト
├── frontend/         # Vue.jsプロジェクト
├── docker/           # Docker設定ファイル
│   ├── php/         # PHP/Nginx設定
│   ├── mysql/       # MySQL初期化
│   └── nginx/       # Nginx設定
├── docker-compose.yml
├── Makefile
└── .env.docker      # 環境変数テンプレート
```

## トラブルシューティング

### コンテナが起動しない場合

1. Traefikが起動していることを確認
2. degg-develop-netネットワークが存在することを確認
3. ポートの競合がないことを確認

### APIに接続できない場合

1. バックエンドコンテナが正常に起動していることを確認
2. Laravelのルーティングが正しく設定されていることを確認
3. Nginx設定が正しいことを確認

### データベースエラーの場合

1. MySQLコンテナが正常に起動していることを確認
2. .env.dockerの設定が正しいことを確認
3. マイグレーションが実行されていることを確認