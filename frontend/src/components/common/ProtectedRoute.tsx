// 認証が必要なページを保護するコンポーネント
import React, { ReactNode } from 'react';
import { Navigate } from "react-router-dom";
import { useAuth } from '../../context/AuthContext';
import { CircularProgress, Box } from '@mui/material';

// コンポーネントのプロパティ型定義
interface ProtectedRouteProps {
    children: ReactNode // 認証後に表示する子コンポーネント
}

// 認証ガード機能を提供するコンポーネント
const ProtectedRoute: React.FC<ProtectedRouteProps> = ({ children }) => {
    // 認証状態を取得 (userは後日使用)
    const { /* user, */ loading, token } = useAuth();

    // 認証状態の読み込み中：ローディング表示
    if (loading) {
        return (
            <Box display="flex" justifyContent="center" alignItems="center" minHeight="100vh">
                <CircularProgress />{/* Material-UI のスピナー */}
            </Box>
        )
    }

    // 未認証（トークンなし）：ログイン画面にリダイレクト
    if (!token) {
        return <Navigate to="/login" replace/>
    }

    // 認証済み：子コンポーネントを表示
    return <>{children}</>;
}

export default ProtectedRoute;

