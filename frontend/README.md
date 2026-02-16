# Frontend - React SPA

React 19 + TypeScript によるシングルページアプリケーション

## 起動

```bash
npm install
npm run dev
```

`http://localhost:5173` でアクセス。API リクエストは Vite プロキシ経由でバックエンド（ポート 3001）に転送されます。

## スクリプト

| コマンド | 説明 |
|---------|------|
| `npm run dev` | 開発サーバー起動 |
| `npm run build` | プロダクションビルド（型チェック + Vite ビルド） |
| `npm run lint` | ESLint 実行 |
| `npm run type-check` | TypeScript 型チェックのみ |

## ディレクトリ構成

```
src/
├── components/
│   ├── auth/
│   │   └── LoginForm.tsx          # ログインフォーム
│   ├── common/
│   │   ├── Layout.tsx             # 共通レイアウト（ヘッダー・ログアウト）
│   │   └── ProtectedRoute.tsx     # 認証ガード
│   └── customer/
│       ├── CustomerList.tsx       # 顧客一覧（メイン画面）
│       ├── CustomerFilters.tsx    # 検索・フィルタリング
│       └── CustomerPagination.tsx # ページネーション UI
├── context/
│   ├── authContextDef.ts          # AuthContext 定義・型
│   └── AuthContext.tsx            # AuthProvider コンポーネント
├── hooks/
│   └── useAuth.ts                 # 認証フック
├── services/
│   └── apiClient.ts               # Axios クライアント・API サービス
├── types/
│   └── api.ts                     # API レスポンス型定義
├── App.tsx                        # ルーティング定義
└── main.tsx                       # エントリーポイント
```

## 主要な設計判断

- **AuthContext 分離**: React Fast Refresh の制約に対応し、Context 定義（`authContextDef.ts`）・Provider（`AuthContext.tsx`）・Hook（`useAuth.ts`）を分離
- **Axios interceptor**: リクエスト時の JWT トークン自動付与、401 レスポンス時の自動リダイレクトを透過的に処理
- **サーバーサイドページネーション**: Kaminari の API レスポンスと連動し、ページ切り替え・表示件数変更を実装
- **フロントエンドフィルタリング**: 取得済みデータに対するクライアントサイド検索（顧客名・種別・ステータス）
