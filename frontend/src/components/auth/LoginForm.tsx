// JWT認証を使ったログインフォームコンポーネント

import React, { useState, FormEvent } from 'react';
import {
    Container, Paper, TextField, Button, Typography, Alert, Box
} from '@mui/material'
import { useAuth } from "../../context/AuthContext";
import { useNavigate} from 'react-router-dom';

// ログインフォームのメインコンポーネント
const LoginForm: React.FC = () => {
    // フォームの入力状態管理
    const [email, setEmail] = useState<string>(''); // メールアドレス
    const [password, setPassword] = useState<string>(''); // パスワード
    const [error, setError] = useState<string>(''); // エラーメッセージ
    const [loading, setLoading] = useState<boolean>(false); // 送信中フラグ

    // Context から認証関数を取得
    const { login } = useAuth();
    // React Router の画面遷移関数
    const navigate = useNavigate();

    // フォーム送信処理
    const handleSubmit = async (e: FormEvent<HTMLFormElement>): Promise<void> => {
        e.preventDefault(); // デフォルトのフォーム送信を防ぐ
        setLoading(true);  // ローディング開始
        setError(''); // エラーメッセージをクリア

        // 認証APIを呼び出し
        const result = await login(email, password);

        if (result.success) {
            // ログイン成功：顧客一覧画面に遷移
            navigate('/customers');
        } else {
            // ログイン失敗：エラーメッセージを表示
            setError(result.error || 'ログインに失敗しました');
        }

        setLoading(false);
    }

    return (
        <Container maxWidth="sm">
            <Box sx={{ mt: 8, display:'flex', flexDirection: 'column', alignItems: 'center' }}>
                <Paper elevation={3} sx={{ p:4, width: "100%" }}>
                    {/* ページタイトル */}
                    <Typography component="h1" variant="h4" align="center" gutterBottom>
                        ログイン
                    </Typography>

                    {/* エラーメッセージ表示 */}
                    {error && <Alert severity="error" sx={{ mb: 2 }}>{error}</Alert>}

                    {/* ログインフォーム */}
                    <form onSubmit={handleSubmit}>
                        {/* メールアドレス入力フィールド */}
                        <TextField
                            margin="normal"
                            required
                            fullWidth
                            label="メールアドレス"
                            type="email"
                            value={email}
                            onChange={(e) => setEmail(e.target.value)} // 入力値をstateに反映
                            autoComplete="email"
                            autoFocus // ページ読み込み時にフォーカス
                        />
                        {/* パスワード入力フィールド */}
                        <TextField
                            margin="normal"
                            required
                            fullWidth
                            label="パスワード"
                            type="password"
                            value={password}
                            onChange={(e) => setPassword(e.target.value)} // 入力値をstateに反映
                            autoComplete="current-password"
                        />
                        {/* ログインボタン */}
                        <Button
                            type="submit"
                            fullWidth
                            variant="contained"
                            disabled={loading} // 送信中は無効化
                            sx={{ mt: 3, mb: 2 }}
                        >
                            {loading ? 'ログイン中...' : 'ログイン'} {/* 送信中は表示を変更 */}
                        </Button>
                    </form>
                </Paper>
            </Box>
        </Container>
    )
};

export default LoginForm;