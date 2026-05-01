import { useState } from 'react';
import type { FormEvent } from 'react';
import {
    Container, Paper, TextField, Button, Typography, Alert, Box
} from '@mui/material'
import { useAuth } from "../../hooks/useAuth";
import { useNavigate} from 'react-router-dom';

const LoginForm = () => {
    const [email, setEmail] = useState<string>('');
    const [password, setPassword] = useState<string>('');
    const [error, setError] = useState<string>('');
    const [loading, setLoading] = useState<boolean>(false);

    const { login } = useAuth();
    const navigate = useNavigate();

    const handleSubmit = async (e: FormEvent<HTMLFormElement>): Promise<void> => {
        e.preventDefault();
        setLoading(true);
        setError('');

        const result = await login(email, password);

        if (result.success) {
            navigate('/customers');
        } else {
            setError(result.error || 'ログインに失敗しました');
        }

        setLoading(false);
    }

    return (
        <div className="login-container">
            <Container maxWidth="sm">
                <Box sx={{ mt: 8, display:'flex', flexDirection: 'column', alignItems: 'center' }}>
                    <Paper elevation={3} sx={{ p:4, width: "100%" }}>
                        <Typography
                            component="h1"
                            variant="h5"
                            align="center"
                            gutterBottom
                        >
                        ログイン
                        </Typography>

                        {error && <Alert severity="error" sx={{ mb: 2 }}>{error}</Alert>}

                        <form onSubmit={handleSubmit}>
                            <TextField
                                margin="normal"
                                required
                                fullWidth
                                label="メールアドレス"
                                type="email"
                                value={email}
                                onChange={(e) => setEmail(e.target.value)}
                                autoComplete="email"
                                autoFocus
                            />
                            <TextField
                                margin="normal"
                                required
                                fullWidth
                                label="パスワード"
                                type="password"
                                value={password}
                                onChange={(e) => setPassword(e.target.value)}
                                autoComplete="current-password"
                            />
                            <Button
                                type="submit"
                                fullWidth
                                variant="contained"
                                disabled={loading}
                                sx={{ mt: 3, mb: 2 }}
                            >
                                {loading ? 'ログイン中...' : 'ログイン'}
                            </Button>
                        </form>
                    </Paper>
                </Box>
            </Container>
        </div>
    )
};

export default LoginForm;
