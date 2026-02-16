# Backend - Rails API

Rails 7.2 API モードによるバックエンドサーバー

## 起動

```bash
docker-compose up
```

初回のみ：

```bash
docker-compose run --rm app rails db:create db:migrate db:seed
```

## テスト・静的解析

```bash
# RSpec
docker-compose run --rm app rspec

# RuboCop
docker-compose run --rm app rubocop

# Brakeman
docker-compose run --rm app brakeman --no-pager
```

## ディレクトリ構成

```
app/
├── controllers/api/v1/   # API コントローラー
│   ├── base_controller.rb    # 認証・認可・ページネーション
│   ├── auth_controller.rb    # ログイン / サインアップ
│   ├── customers_controller.rb
│   └── users_controller.rb
├── models/
│   ├── concerns/validatable/  # カスタムバリデーション基盤
│   ├── department.rb
│   ├── customer.rb
│   ├── user.rb
│   └── work_record.rb
└── lib/
    └── json_web_token.rb      # JWT エンコード / デコード

config/
├── validations/          # モデル別バリデーション設定 (YAML)
└── validation_messages.yml   # エラーメッセージ定義

spec/
├── models/               # モデルスペック
├── requests/api/v1/      # リクエストスペック
└── factories/            # FactoryBot 定義
```

## 主要な設計判断

- **API モード**: フロントエンドと完全分離。ビュー・セッション関連のミドルウェアを除外
- **Validatable concern**: バリデーションロジックとエラーメッセージを YAML で外部管理し、モデルの肥大化を防止
- **JWT 認証**: Devise のユーザー管理 + 独自の JWT トークン発行。`BaseController` で全エンドポイントに認証を適用
- **ロール階層**: `staff(0) < manager(1) < admin(2)` の整数比較による認可チェック

## Docker サービス

| サービス | ポート | 用途 |
|---------|-------|------|
| app | 3001 | Rails API サーバー |
| postgres | 5432 | PostgreSQL 15 |
| redis | 6379 | Redis 7 |
| pgadmin | 8080 | DB 管理 UI |
