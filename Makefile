.PHONY: help setup up down logs shell migrate fresh build

# デフォルトターゲット
help:
	@echo "Available commands:"
	@echo "  make setup          - 初回セットアップ"
	@echo "  make up             - コンテナ起動"
	@echo "  make down           - コンテナ停止"
	@echo "  make logs           - ログ表示"
	@echo "  make shell          - アプリケーションコンテナにログイン"
	@echo "  make migrate        - マイグレーション実行"
	@echo "  make fresh          - データベースリフレッシュ"
	@echo "  make build          - コンテナ再ビルド"

# 初回セットアップ
setup:
	@echo "=== 初回セットアップを開始します ==="
	
	# .env.dockerから.envを作成
	@if [ ! -f .env ]; then \
		cp .env.docker .env; \
		echo "✓ .envファイルを作成しました"; \
	fi
	
	# Laravelプロジェクトの作成
	@if [ ! -f backend/composer.json ]; then \
		echo "Laravelプロジェクトを作成中..."; \
		docker run --rm -v $(PWD)/backend:/app composer create-project laravel/laravel . --prefer-dist; \
		echo "✓ Laravelプロジェクトを作成しました"; \
	fi
	
	# Laravel .env設定
	@if [ -f backend/.env.example ]; then \
		cp backend/.env.example backend/.env; \
		sed -i '' 's/DB_HOST=.*/DB_HOST=mysql/' backend/.env; \
		sed -i '' 's/DB_DATABASE=.*/DB_DATABASE=recipe_db/' backend/.env; \
		sed -i '' 's/DB_USERNAME=.*/DB_USERNAME=recipe_user/' backend/.env; \
		sed -i '' 's/DB_PASSWORD=.*/DB_PASSWORD=recipe_pass/' backend/.env; \
		sed -i '' 's/REDIS_HOST=.*/REDIS_HOST=redis/' backend/.env; \
		echo "✓ Laravel .envを設定しました"; \
	fi
	
	
	# コンテナビルドと起動
	@echo "コンテナをビルド中..."
	@docker compose build
	@docker compose up -d
	
	# APP_KEY生成
	@echo "Laravel APP_KEYを生成中..."
	@docker compose exec backend php artisan key:generate
	
	# マイグレーション実行
	@echo "マイグレーションを実行中..."
	@sleep 10  # MySQLの起動を待つ
	@docker compose exec backend php artisan migrate --force
	
	@echo ""
	@echo "=== セットアップが完了しました！ ==="
	@echo "アプリケーション: http://my-receipt.localhost"
	@echo ""

# コンテナ起動
up:
	docker compose up -d
	@echo "コンテナを起動しました"

# コンテナ停止
down:
	docker compose down
	@echo "コンテナを停止しました"

# ログ表示
logs:
	docker compose logs -f

# アプリケーションコンテナにログイン
shell:
	docker compose exec backend bash

# マイグレーション実行
migrate:
	docker compose exec backend php artisan migrate

# データベースリフレッシュ
fresh:
	docker compose exec backend php artisan migrate:fresh --seed

# コンテナ再ビルド
build:
	docker compose build
	docker compose up -d