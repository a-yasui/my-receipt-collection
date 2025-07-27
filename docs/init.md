# 料理メモサイト開発仕様書

## プロジェクト概要

効率的な入力と見やすい表示を重視した料理レシピ管理サイト。
タレや調味料の作り方も含む入れ子構造のレシピ管理が可能。

## 技術スタック

- **フロントエンド**: Vue.js 3 + Composition API
- **バックエンド**: PHP (Laravel)
- **データベース**: MySQL
- **インフラ**: Docker + Docker Compose
- **スタイリング**: Tailwind CSS または Bootstrap

## 主要機能

### 基本機能
- レシピの登録・編集・削除・表示
- 材料管理（入れ子構造対応）
- 手順管理
- レシピ検索・フィルタリング

### 効率化機能
- 材料のオートコンプリート
- よく使う材料のお気に入り登録
- ドラッグ&ドロップでの手順並び替え
- タイマー機能
- 進捗管理（チェックリスト）

## データベース設計

### テーブル構造

```sql
-- レシピテーブル（メインとサブレシピ両方に使用）
CREATE TABLE recipes (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    servings INT DEFAULT 1,
    prep_time INT, -- 準備時間（分）
    cook_time INT, -- 調理時間（分）
    parent_recipe_id BIGINT NULL, -- 親レシピID（サブレシピの場合）
    recipe_type ENUM('main', 'sauce', 'marinade', 'side', 'base') DEFAULT 'main',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (parent_recipe_id) REFERENCES recipes(id) ON DELETE CASCADE
);

-- 材料テーブル
CREATE TABLE ingredients (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    recipe_id BIGINT NOT NULL,
    name VARCHAR(255) NOT NULL,
    amount DECIMAL(8,2),
    unit VARCHAR(50),
    order_index INT DEFAULT 0,
    sub_recipe_id BIGINT NULL, -- サブレシピ参照
    notes TEXT, -- 「○○のタレを使用」など
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (recipe_id) REFERENCES recipes(id) ON DELETE CASCADE,
    FOREIGN KEY (sub_recipe_id) REFERENCES recipes(id) ON DELETE SET NULL
);

-- 手順テーブル
CREATE TABLE steps (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    recipe_id BIGINT NOT NULL,
    step_number INT NOT NULL,
    instruction TEXT NOT NULL,
    time_minutes INT, -- この手順にかかる時間
    image_path VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (recipe_id) REFERENCES recipes(id) ON DELETE CASCADE
);

-- タグテーブル
CREATE TABLE tags (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- レシピタグ中間テーブル
CREATE TABLE recipe_tags (
    recipe_id BIGINT,
    tag_id BIGINT,
    PRIMARY KEY (recipe_id, tag_id),
    FOREIGN KEY (recipe_id) REFERENCES recipes(id) ON DELETE CASCADE,
    FOREIGN KEY (tag_id) REFERENCES tags(id) ON DELETE CASCADE
);

-- よく使う材料テーブル
CREATE TABLE favorite_ingredients (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    default_unit VARCHAR(50),
    usage_count INT DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

## API設計

### エンドポイント一覧

```
GET    /api/recipes              - レシピ一覧取得
POST   /api/recipes              - レシピ作成
GET    /api/recipes/{id}         - レシピ詳細取得
PUT    /api/recipes/{id}         - レシピ更新
DELETE /api/recipes/{id}         - レシピ削除

GET    /api/ingredients/favorites - よく使う材料一覧
POST   /api/ingredients/favorites - よく使う材料追加

GET    /api/tags                 - タグ一覧
POST   /api/tags                 - タグ作成

GET    /api/search               - レシピ検索
```

### レスポンス例

```json
{
  "id": 1,
  "title": "鶏の照り焼き",
  "description": "簡単で美味しい照り焼き",
  "servings": 2,
  "prep_time": 10,
  "cook_time": 15,
  "recipe_type": "main",
  "ingredients": [
    {
      "id": 1,
      "name": "鶏もも肉",
      "amount": 300,
      "unit": "g",
      "order_index": 1,
      "sub_recipe": null
    },
    {
      "id": 2,
      "name": "照り焼きのタレ",
      "amount": 1,
      "unit": "人分",
      "order_index": 2,
      "sub_recipe": {
        "id": 2,
        "title": "照り焼きのタレ",
        "recipe_type": "sauce",
        "ingredients": [
          {
            "name": "しょうゆ",
            "amount": 3,
            "unit": "大さじ"
          },
          {
            "name": "みりん",
            "amount": 2,
            "unit": "大さじ"
          }
        ],
        "steps": [
          {
            "step_number": 1,
            "instruction": "材料を全て混ぜ合わせる",
            "time_minutes": 2
          }
        ]
      }
    }
  ],
  "steps": [
    {
      "step_number": 1,
      "instruction": "照り焼きのタレを作る",
      "time_minutes": 2
    },
    {
      "step_number": 2,
      "instruction": "鶏肉を一口大に切る",
      "time_minutes": 5
    }
  ],
  "tags": ["和食", "メイン", "簡単"]
}
```

## フロントエンド構成

### コンポーネント構造

```
src/
├── components/
│   ├── Recipe/
│   │   ├── RecipeForm.vue          # レシピ登録・編集フォーム
│   │   ├── RecipeList.vue          # レシピ一覧
│   │   ├── RecipeCard.vue          # レシピカード
│   │   └── RecipeDetail.vue        # レシピ詳細表示
│   ├── Ingredient/
│   │   ├── IngredientList.vue      # 材料リスト
│   │   ├── IngredientItem.vue      # 材料入力項目
│   │   └── SubRecipeModal.vue      # サブレシピ編集モーダル
│   ├── Step/
│   │   ├── StepList.vue            # 手順リスト
│   │   └── StepItem.vue            # 手順項目
│   ├── Common/
│   │   ├── SearchBar.vue           # 検索バー
│   │   ├── TagInput.vue            # タグ入力
│   │   └── Timer.vue               # タイマー機能
│   └── Layout/
│       ├── Header.vue
│       ├── Sidebar.vue
│       └── Footer.vue
├── views/
│   ├── Home.vue
│   ├── RecipeCreate.vue
│   ├── RecipeEdit.vue
│   └── RecipeView.vue
├── stores/
│   ├── recipe.js
│   ├── ingredient.js
│   └── tag.js
└── router/
    └── index.js
```

### 主要コンポーネント仕様

#### RecipeForm.vue
```vue
<template>
  <div class="recipe-form">
    <!-- 基本情報 -->
    <div class="basic-info">
      <input v-model="recipe.title" placeholder="レシピ名" />
      <textarea v-model="recipe.description" placeholder="説明" />
      <input v-model="recipe.servings" type="number" placeholder="人分" />
      <input v-model="recipe.prep_time" type="number" placeholder="準備時間(分)" />
      <input v-model="recipe.cook_time" type="number" placeholder="調理時間(分)" />
    </div>

    <!-- 材料リスト -->
    <IngredientList 
      v-model="recipe.ingredients"
      :sub-recipes="recipe.subRecipes"
      @create-sub-recipe="createSubRecipe"
    />

    <!-- 手順リスト -->
    <StepList v-model="recipe.steps" />

    <!-- タグ -->
    <TagInput v-model="recipe.tags" />

    <!-- 保存ボタン -->
    <button @click="saveRecipe">保存</button>
  </div>
</template>
```

#### IngredientItem.vue
```vue
<template>
  <div class="ingredient-item">
    <input 
      v-model="ingredient.name" 
      placeholder="材料名"
      @input="searchIngredients"
      list="ingredient-suggestions"
    />
    <datalist id="ingredient-suggestions">
      <option v-for="suggestion in suggestions" :value="suggestion.name" />
    </datalist>
    
    <input v-model="ingredient.amount" type="number" step="0.1" placeholder="量" />
    
    <select v-model="ingredient.unit">
      <option value="g">g</option>
      <option value="ml">ml</option>
      <option value="個">個</option>
      <option value="大さじ">大さじ</option>
      <option value="小さじ">小さじ</option>
      <option value="カップ">カップ</option>
    </select>

    <!-- サブレシピ関連 -->
    <div v-if="ingredient.sub_recipe_id" class="sub-recipe-controls">
      <button @click="editSubRecipe" class="edit-btn">
        📝 {{ getSubRecipeName() }}
      </button>
      <button @click="toggleSubRecipeView" class="view-btn">
        👁️ 詳細表示
      </button>
      <button @click="removeSubRecipe" class="remove-btn">
        ❌ 削除
      </button>
    </div>
    
    <button v-else @click="createSubRecipe" class="create-sub-recipe-btn">
      ➕ 作り方を追加
    </button>

    <!-- サブレシピ詳細表示 -->
    <div v-if="showSubRecipeDetail" class="sub-recipe-detail">
      <SubRecipeView :recipe="subRecipe" />
    </div>
  </div>
</template>
```

## バックエンド仕様

### Laravel Controller例

```php
<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Recipe;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class RecipeController extends Controller
{
    public function index(Request $request)
    {
        $query = Recipe::with(['ingredients.subRecipe', 'tags'])
            ->where('parent_recipe_id', null); // メインレシピのみ

        // 検索機能
        if ($request->search) {
            $query->where('title', 'like', "%{$request->search}%");
        }

        // タグフィルタ
        if ($request->tags) {
            $query->whereHas('tags', function($q) use ($request) {
                $q->whereIn('name', $request->tags);
            });
        }

        return $query->paginate(20);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'title' => 'required|string|max:255',
            'description' => 'nullable|string',
            'servings' => 'integer|min:1',
            'prep_time' => 'nullable|integer|min:0',
            'cook_time' => 'nullable|integer|min:0',
            'ingredients' => 'required|array',
            'ingredients.*.name' => 'required|string',
            'ingredients.*.amount' => 'nullable|numeric',
            'ingredients.*.unit' => 'nullable|string',
            'steps' => 'required|array',
            'steps.*.instruction' => 'required|string',
            'steps.*.time_minutes' => 'nullable|integer',
            'tags' => 'nullable|array'
        ]);

        return DB::transaction(function () use ($validated) {
            $recipe = Recipe::create($validated);

            // 材料の保存
            foreach ($validated['ingredients'] as $index => $ingredientData) {
                $ingredient = $recipe->ingredients()->create([
                    ...$ingredientData,
                    'order_index' => $index + 1
                ]);

                // サブレシピがある場合
                if (isset($ingredientData['sub_recipe'])) {
                    $subRecipe = $this->createSubRecipe(
                        $ingredientData['sub_recipe'], 
                        $recipe->id
                    );
                    $ingredient->update(['sub_recipe_id' => $subRecipe->id]);
                }
            }

            // 手順の保存
            foreach ($validated['steps'] as $index => $stepData) {
                $recipe->steps()->create([
                    ...$stepData,
                    'step_number' => $index + 1
                ]);
            }

            // タグの保存
            if (isset($validated['tags'])) {
                $this->syncTags($recipe, $validated['tags']);
            }

            return $recipe->load(['ingredients.subRecipe', 'steps', 'tags']);
        });
    }

    private function createSubRecipe(array $subRecipeData, int $parentId)
    {
        $subRecipe = Recipe::create([
            'title' => $subRecipeData['title'],
            'parent_recipe_id' => $parentId,
            'recipe_type' => $subRecipeData['type'] ?? 'sauce'
        ]);

        // サブレシピの材料・手順も保存
        if (isset($subRecipeData['ingredients'])) {
            foreach ($subRecipeData['ingredients'] as $index => $ingredient) {
                $subRecipe->ingredients()->create([
                    ...$ingredient,
                    'order_index' => $index + 1
                ]);
            }
        }

        if (isset($subRecipeData['steps'])) {
            foreach ($subRecipeData['steps'] as $index => $step) {
                $subRecipe->steps()->create([
                    ...$step,
                    'step_number' => $index + 1
                ]);
            }
        }

        return $subRecipe;
    }
}
```

## Docker構成

### docker-compose.yml

```yaml
version: '3.8'

services:
  app:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: recipe_app
    ports:
      - "8000:8000"
    volumes:
      - .:/var/www/html
      - ./storage:/var/www/html/storage
    depends_on:
      - db
      - redis
    environment:
      - DB_HOST=db
      - DB_DATABASE=recipe_db
      - DB_USERNAME=recipe_user
      - DB_PASSWORD=recipe_pass
      - REDIS_HOST=redis

  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile
    container_name: recipe_frontend
    ports:
      - "3000:3000"
    volumes:
      - ./frontend:/app
      - /app/node_modules
    command: npm run dev

  db:
    image: mysql:8.0
    container_name: recipe_db
    ports:
      - "3306:3306"
    environment:
      MYSQL_DATABASE: recipe_db
      MYSQL_USER: recipe_user
      MYSQL_PASSWORD: recipe_pass
      MYSQL_ROOT_PASSWORD: root_password
    volumes:
      - mysql_data:/var/lib/mysql
      - ./database/init.sql:/docker-entrypoint-initdb.d/init.sql

  redis:
    image: redis:7-alpine
    container_name: recipe_redis
    ports:
      - "6379:6379"

volumes:
  mysql_data:
```

## 実装優先順位

### Phase 1: 基本機能
1. データベース設計・マイグレーション
2. 基本的なレシピCRUD API
3. シンプルなフロントエンド（レシピ一覧・詳細・作成）

### Phase 2: 入れ子構造対応
1. サブレシピ機能の実装
2. 材料の階層表示
3. サブレシピ編集UI

### Phase 3: 効率化機能
1. 材料オートコンプリート
2. ドラッグ&ドロップ並び替え
3. タイマー機能

### Phase 4: 高度な機能
1. 検索・フィルタリング強化
2. レシピインポート・エクスポート
3. 印刷機能

## 開発開始手順

1. プロジェクトディレクトリ作成
2. Docker環境構築
3. Laravel プロジェクト初期化
4. Vue.js プロジェクト初期化
5. データベースマイグレーション実行
6. 基本的なAPI・フロントエンド実装

この仕様書を基に、Claude Codeで段階的に実装を進めてください。
