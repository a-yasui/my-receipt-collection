-- レシピテーブル（メインとサブレシピ両方に使用）
CREATE TABLE IF NOT EXISTS recipes (
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
CREATE TABLE IF NOT EXISTS ingredients (
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
CREATE TABLE IF NOT EXISTS steps (
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
CREATE TABLE IF NOT EXISTS tags (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- レシピタグ中間テーブル
CREATE TABLE IF NOT EXISTS recipe_tags (
    recipe_id BIGINT,
    tag_id BIGINT,
    PRIMARY KEY (recipe_id, tag_id),
    FOREIGN KEY (recipe_id) REFERENCES recipes(id) ON DELETE CASCADE,
    FOREIGN KEY (tag_id) REFERENCES tags(id) ON DELETE CASCADE
);

-- よく使う材料テーブル
CREATE TABLE IF NOT EXISTS favorite_ingredients (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    default_unit VARCHAR(50),
    usage_count INT DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);