// JWT認証の状態管理とログイン・ログアウト処理を提供
import React, { createContext, useContext, useState, useEffect, ReactNode } from 'react';
import { authService } from '../services/apiClient';
import type { User } from '../types/api';

// Context で提供する値の型定義
interface AuthContextType {
    user: User | null;
    token: string | null;
    loading: boolean;
    login: (email: string, password: string) => Promise<{ success: boolean; error?: string }>;
    logout: () => void;
}

// React Context を作成（初期値は undefined）
const AuthContext = createContext<AuthContextType | undefined>(undefined);

// カスタムフック：認証Contextを安全に取得
export const useAuth = (): AuthContextType => {
    const context = useContext(AuthContext);
    // Provider外で使用された場合のエラー
    if (!context) {
        throw new Error('useAuth must be used within an AuthProvider');
    }
    return context;
}

// AuthProvider のプロパティ型定義
interface AuthProviderProps {
    children: ReactNode;
}

// 認証情報を管理・提供するProvider コンポーネント
export const AuthProvider: React.FC<AuthProviderProps> = ({ children }) => {
    const [user, setUser] = useState<User | null>(null);
    const [loading, setLoading] = useState<boolean>(true);
    const [token, setToken] = useState<string | null>(localStorage.getItem('token'));

    useEffect(() => {
        // アプリ起動時の認証状態確認
        const initializeAuth = () => {
            const token = localStorage.getItem('token');
            if (token) {
                setToken(token);
                // 必要に応じてAPIでトークン検証
            }
            setLoading(false); // ← ここで loading を false にする
        };

        initializeAuth();
    }, []); // 空の依存配列で初回のみ実行

    // ログイン処理：メールアドレスとパスワードで認証
    const login = async (email: string, password: string): Promise<{ success: boolean; error?: string }> => {
        try {
            // Rails API に認証リクエスト送信
            const response = await authService.login(email,password);
            const { token, user } = response.data;

            // 認証成功：トークンを保存し、状態を更新
            localStorage.setItem('token', token);
            setToken(token);
            setUser(user);
            return { success: true };
        } catch (error) {
            return {
                success: false,
                error: error.response?.data?.error || 'ログインに失敗しました'
            };
        }
    }

    // ログアウト処理：認証情報をクリア
    const logout = () => {
        localStorage.removeItem('token');
        setToken(null);
        setUser(null);
    }

    // Context に提供する値
    const value: AuthContextType = {
        user,
        token,
        login,
        logout,
        loading,
    };

    return (
        <AuthContext.Provider value={value}>
            {children}
        </AuthContext.Provider>
    );
}