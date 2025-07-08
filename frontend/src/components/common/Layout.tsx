// 共通レイアウトのプレースホルダー（DAY 5で拡張予定）

import React, { ReactNode } from 'react';
import { Box, AppBar, Toolbar, Typography, Button } from '@mui/material';
import { useAuth } from '../../context/AuthContext';
import { useNavigate } from 'react-router-dom';

// Layout コンポーネントのプロパティ型定義
interface LayoutProps {
    children: ReactNode; // 子コンポーネント
}

const Layout: React.FC<LayoutProps> = ({ children }) => {
    const { logout, user } = useAuth(); // 認証情報とログアウト関数を取得
    const navigate = useNavigate(); // 画面遷移用

    // ログアウト処理
    const handleLogout = (): void => {
        logout(); // Context のログアウト関数を呼び出し
        navigate('/login'); // ログイン画面にリダイレクト
    };

    return (
        <Box sx={{ flexGrow: 1 }}>
            {/* ヘッダー */}
            <AppBar position="static">
                <Toolbar>
                    <Typography variant="h6" component="div" sx={{ flexGrow: 1 }}>
                        Business API Frontend
                    </Typography>
                    <Typography variant="body2" sx={{ mr: 2 }}>
                        {user?.email}
                    </Typography>
                    <Button color="inherit" onClick={handleLogout}>
                        ログアウト
                    </Button>
                </Toolbar>
            </AppBar>

            {/* メインコンテンツ */}
            <main>
                {children}
            </main>
        </Box>
    );
};

export default Layout;