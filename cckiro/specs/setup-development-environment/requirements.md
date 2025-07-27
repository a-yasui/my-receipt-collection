# 開発環境セットアップ要件

## 目的
料理レシピ管理サイトの開発に必要な環境を構築し、開発を開始できる状態にする。

## 要件

### 1. 基本環境要件
- Docker および Docker Compose がインストールされ、起動可能な状態にする
- 開発に必要なすべてのサービスがコンテナとして動作する
- Traefik をリバースプロキシとして使用する

### 2. バックエンド環境要件
- **PHPコンテナ**
  - PHP 8.1以上
  - Laravel 10.x が動作する環境
  - Composer がインストールされている
  - 必要なPHP拡張モジュール（pdo_mysql, mbstring, openssl, tokenizer, xml, ctype, json）

- **MySQLコンテナ**
  - MySQL 8.0
  - データベース名: recipe_db
  - ユーザー名: recipe_user
  - パスワード: recipe_pass
  - 初期テーブル構造の自動セットアップ

- **Redisコンテナ**
  - Redis 7-alpine
  - キャッシュおよびセッション管理用

### 3. フロントエンド環境要件
- **Node.jsコンテナ**
  - Node.js 18以上
  - Vue.js 3 + Composition API
  - Vite による開発サーバー
  - ホットリロード機能

### 4. 開発効率化要件
- **アクセス設定**
  - Traefik経由でのアクセス: http://my-receipt.localhost
  - フロントエンドとバックエンドを同一ホスト名で提供
  - APIエンドポイント: http://my-receipt.localhost/api
  - MySQLとRedisはコンテナ間通信のみ（外部ポート公開なし）

- **ボリュームマウント**
  - ソースコードの変更が即座にコンテナに反映される
  - データベースのデータが永続化される

### 5. 初期セットアップ要件
- 1コマンドで全環境が起動する（`docker compose up -d`）
- Laravelの初期設定（.env、APP_KEY生成、マイグレーション）が自動化される
- Vue.jsの依存関係が自動インストールされる
- Traefikのルーティング設定が自動的に適用される

### 6. 開発ツール要件
- Laravelのartisanコマンドが実行可能
- npmコマンドが実行可能
- データベースマイグレーションが実行可能
- コンテナ内でのデバッグが可能

## 成功基準
1. `docker compose up -d` で全サービスが起動する
2. http://my-receipt.localhost でVue.jsのフロントエンドが表示される
3. http://my-receipt.localhost/api でLaravel APIが応答する
4. データベースに接続でき、マイグレーションが実行できる
5. ソースコードの変更が即座に反映される（ホットリロード）
6. Traefikダッシュボードで各サービスの状態が確認できる