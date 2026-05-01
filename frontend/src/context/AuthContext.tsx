import { useState, useEffect } from 'react';
import type { ReactNode } from 'react';
import { authService } from '../services/apiClient';
import { AuthContext } from './authContextDef';
import type { AuthContextType } from './authContextDef';

interface AuthProviderProps {
    children: ReactNode;
}

export const AuthProvider = ({ children }: AuthProviderProps) => {
    const [user, setUser] = useState<AuthContextType['user']>(null);
    const [loading, setLoading] = useState<boolean>(true);
    const [token, setToken] = useState<string | null>(localStorage.getItem('token'));

    useEffect(() => {
        const initializeAuth = () => {
            const storedToken = localStorage.getItem('token');
            if (storedToken) {
                setToken(storedToken);
            }
            setLoading(false);
        };

        initializeAuth();
    }, []);

    const login = async (email: string, password: string): Promise<{ success: boolean; error?: string }> => {
        try {
            const response = await authService.login(email, password);
            const { token: newToken, user: newUser } = response.data;

            localStorage.setItem('token', newToken);
            setToken(newToken);
            setUser(newUser);
            return { success: true };
        } catch (error: unknown) {
            const message =
                error instanceof Error ? error.message : 'ログインに失敗しました';
            return { success: false, error: message };
        }
    };

    const logout = () => {
        localStorage.removeItem('token');
        setToken(null);
        setUser(null);
    };

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
};
