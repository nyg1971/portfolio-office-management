// 共通レイアウト

import React  from 'react';
import type { ReactNode } from 'react';
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
        <div className="page-container">
            {/* ヘッダー */}
            <AppBar position="static">
                <Toolbar>
                    <Typography variant="h6" component="div" sx={{ flexGrow: 1 }}>
                        福祉事務所 業務管理システム
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
            <Box component={"main"} sx={{ py: 3 }}>
                <main>
                    {children}
                </main>
            </Box>
        </div>
    );
};

export default Layout;