import React from 'react'
import { BrowserRouter as Router, Routes, Route, Navigate  } from 'react-router-dom';
import { ThemeProvider, createTheme } from '@mui/material';
import CssBaseline from '@mui/material/CssBaseline';
import { AuthProvider } from './context/AuthContext';
import LoginForm from './components/auth/LoginForm';
import CustomerList from "./components/customer/CustomerList";
import ProtectedRoute from './components/common/ProtectedRoute';
import Layout from './components/common/Layout';

// Material-UI のテーマ設定
const theme = createTheme({
        palette: {
            primary: { main: '#1976d2' },
            secondary: { main: '#dc0004' }
        }
});

const App: React.FC = () => {
    return (
        <ThemeProvider theme={theme}>
            {/* CSS リセット・正規化 */}
            <CssBaseline />

            {/* 認証状態を全体で管理 */}
            <AuthProvider>
                <Router>
                    <Routes>
                        {/* ログイン画面：認証不要 */}
                        <Route path="/login" element={<LoginForm />} />

                        {/* ルートパス：顧客一覧にリダイレクト */}
                        <Route path="/" element={<Navigate to="/customers" />} />

                        {/* 顧客一覧画面：認証必須 */}
                        <Route
                            path="/customers"
                            element={
                            <ProtectedRoute>
                                {/* 共通レイアウト（ヘッダー・ナビ等）で包む */}
                                <Layout>
                                    <CustomerList />
                                </Layout>
                            </ProtectedRoute>
                        } />
                    </Routes>
                </Router>
            </AuthProvider>
        </ThemeProvider>
    )
}

export default App
