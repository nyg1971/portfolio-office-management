import { createContext } from 'react';
import type { User } from '../types/api';

export interface AuthContextType {
    user: User | null;
    token: string | null;
    loading: boolean;
    login: (email: string, password: string) => Promise<{ success: boolean; error?: string }>;
    logout: () => void;
}

export const AuthContext = createContext<AuthContextType | undefined>(undefined);
