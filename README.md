# Portfolio Office Management

（ポートフォリオ）
仮想の事業所における利用者管理業務を効率化するWebアプリケーション

## プロジェクト概要

このプロジェクトは、仮想の事業所での実務に近い業務フローを想定した業務管理システムです。
利用者情報の管理、作業記録の追跡、部署間での情報共有を効率化することを目的としています。

### 主要機能
- **利用者管理**: 顧客情報の登録・検索・更新
- **認証システム**: JWT認証による安全なアクセス制御
- **検索・フィルタリング**: 顧客名、種別、ステータスでの絞り込み
- **ページネーション**: 大量データの効率的な表示
- **レスポンシブデザイン**: PC・タブレット・スマートフォン対応

## 技術スタック

### バックエンド
- **Ruby on Rails** 7.2 - RESTful API
- **PostgreSQL** - データベース
- **JWT** - 認証システム
- **Docker** - 開発環境
- **RSpec** - テストフレームワーク

### フロントエンド
- **React** 18 - UIライブラリ
- **TypeScript** - 型安全な開発
- **Material-UI** - UIコンポーネント
- **Vite** - 高速ビルドツール
- **ESLint** - コード品質管理

## デモ
（準備中）

### 本番環境
- **フロントエンド**: [デプロイ予定]
- **バックエンドAPI**: [デプロイ予定]

### 機能スクリーンショット
[スクリーンショット予定]

## プロジェクト構成

```
portfolio-office-management/
├── backend/          # Rails API
│   ├── app/
│   ├── config/
│   ├── db/
│   └── spec/
├── frontend/         # React SPA
│   ├── src/
│   ├── public/
│   └── package.json
├── docs/            # 設計書・仕様書
└── README.md
```

## セットアップ

### 前提条件
- Docker & Docker Compose
- Node.js 18+
- Git

### バックエンド起動
```bash
cd backend/
docker-compose up
```

### フロントエンド起動
```bash
cd frontend/
npm install
npm run dev
```

詳細なセットアップ手順は各ディレクトリのREADMEを参照してください。

## システム設計

### データベース設計
- **Users**: 認証・ユーザー管理
- **Customers**: 利用者情報
- **Departments**: 部署管理
- **WorkRecords**: 作業記録

### API設計
- RESTful API設計
- JWT認証
- ページネーション対応
- エラーハンドリング

## テスト

### バックエンド
```bash
cd backend/
docker-compose run --rm app rspec
```

### フロントエンド
```bash
cd frontend/
npm run test
```

## 開発ロードマップ

### 完了済み
- [x] 認証システム（JWT）
- [x] 利用者管理基本機能
- [x] 検索・フィルタリング
- [x] レスポンシブデザイン

### 開発中
- [ ] ページネーション
- [ ] 作業記録管理
- [ ] レポート機能
- [ ] 詳細画面の充実

### 今後の予定
- [ ] 通知機能
- [ ] データエクスポート
- [ ] 管理者画面
