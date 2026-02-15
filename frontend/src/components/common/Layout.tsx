import React  from 'react';
import type { ReactNode } from 'react';
import { Box, AppBar, Toolbar, Typography, Button } from '@mui/material';
import { useAuth } from '../../hooks/useAuth';
import { useNavigate } from 'react-router-dom';

interface LayoutProps {
    children: ReactNode;
}

const Layout: React.FC<LayoutProps> = ({ children }) => {
    const { logout, user } = useAuth();
    const navigate = useNavigate();

    const handleLogout = (): void => {
        logout();
        navigate('/login');
    };

    return (
        <div className="page-container">
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

            <Box component="main" sx={{ py: 3 }}>
                {children}
            </Box>
        </div>
    );
};

export default Layout;
