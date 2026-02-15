import React from 'react'
import { BrowserRouter as Router, Routes, Route, Navigate  } from 'react-router-dom';
import { ThemeProvider, createTheme } from '@mui/material';
import CssBaseline from '@mui/material/CssBaseline';
import { AuthProvider } from './context/AuthContext';
import LoginForm from './components/auth/LoginForm';
import CustomerList from "./components/customer/CustomerList";
import ProtectedRoute from './components/common/ProtectedRoute';
import Layout from './components/common/Layout';

const theme = createTheme({
    palette: {
        primary: { main: '#1976d2' },
        secondary: { main: '#dc0004' }
    }
});

const App: React.FC = () => {
    return (
        <ThemeProvider theme={theme}>
            <CssBaseline />
            <AuthProvider>
                <Router>
                    <Routes>
                        <Route path="/login" element={<LoginForm />} />
                        <Route path="/" element={<Navigate to="/customers" />} />
                        <Route
                            path="/customers"
                            element={
                            <ProtectedRoute>
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
