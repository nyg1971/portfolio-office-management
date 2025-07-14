// 顧客一覧画面
import React, { useState, useEffect } from 'react';
import {
    Table,
    TableBody,
    TableCell,
    TableContainer,
    TableHead,
    TableRow,
    Paper,
    Typography,
    Chip,
    CircularProgress,
    Box,
    Alert
} from '@mui/material';
import CustomerFilters from './CustomerFilters';
import type { FilterState } from './CustomerFilters';

// 顧客データの型定義
interface Customer {
    id: number;
    name: string;
    customer_type: string;
    customer_type_display: string;
    status: string;
    status_display: string;
    department: {
        id: number;
        name: string;
    };
    created_at: string;
    updated_at: string;
}
interface CustomersResponse {
    customers: Customer[];
    pagination: {
        current_page: number;
        total_pages: number;
        total_count: number;
    };
}

// 顧客一覧取得API関数
const fetchCustomers = async (): Promise<CustomersResponse> => {
    const token = localStorage.getItem('token');

    const response = await fetch('http://localhost:3001/api/v1/customers', {
        method: 'GET',
        headers: {
            'Authorization': `Bearer ${token}`,
            'Content-Type': 'application/json',
        },
    });

    if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
    }

    return response.json();

};

const CustomerList: React.FC = () => {
    // 基本状態管理
    const [customersData, setCustomersData] = useState<CustomersResponse | null>(null);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState<string | null>(null);
    // フィルター状態管理
    const [filters, setFilters] = useState<FilterState>({
        searchName: '',
        customerType: '',
        status: ''
    });
    const loadCustomers = async () => {
        try {
            setLoading(true);
            const data = await fetchCustomers();
            setCustomersData(data);
        } catch (err) {
            setError(err instanceof Error ? err.message : 'Unknown error');
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        loadCustomers();
    }, []);

    // フィルター処理関数
    const getFilteredCustomers = (): Customer[] => {
        if(!customersData) return [];
        return customersData.customers.filter((customer) => {
            const nameMatch = filters.searchName === '' || customer.name.toLowerCase().includes(filters.searchName.toLowerCase());
            const typeMatch = filters.customerType === '' || customer.customer_type === filters.customerType;
            const statusMatch = filters.status === '' || customer.status === filters.status;
            return nameMatch && typeMatch && statusMatch;
        });
    }

    // フィルター変更ハンドラー
    const handleFiltersChange = (newFilters: FilterState) => {
        setFilters(newFilters);
    };

    // ローディング状態
    if (loading) {
        return (
            <Box display="flex" justifyContent="center" alignItems="center" minHeight="400px">
                <CircularProgress />
                <Typography variant="body1" sx={{ ml: 2 }}>
                    顧客データを読み込み中...
                </Typography>
            </Box>
        );
    }

    // エラー状態
    if (error) {
        return (
            <Alert severity="error" sx={{ mt: 2 }}>
                エラーが発生しました: {error}
            </Alert>
        );
    }

    // データなし状態
    if (!customersData || customersData.customers.length === 0) {
        return (
            <Paper sx={{ p: 3, mt: 2 }}>
                <Typography variant="h6" align="center" color="text.secondary">
                    顧客データがありません
                </Typography>
            </Paper>
        );
    }

    const { pagination } = customersData;
    // フィルター済み顧客データ取得
    const filteredCustomers = getFilteredCustomers();

    return (
        <Box>
            {/* ヘッダー */}
            <Typography variant="h4" component="h1" gutterBottom>
                顧客一覧
            </Typography>


            {/* 検索・フィルター */}
            <CustomerFilters
                filters={filters}
                onFiltersChange={handleFiltersChange}
            />

            {/* 結果統計情報 */}
            <Box sx={{ mb: 2, display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                <Typography variant="body2" color="text.secondary">
                    {filteredCustomers.length > 0 ? (
                        <>
                            {filteredCustomers.length} 件表示
                            {filteredCustomers.length !== customersData.customers.length &&
                                ` (全 ${customersData.customers.length} 件中)`
                            }
                        </>
                    ) : (
                        <>検索条件に一致する顧客が見つかりません</>
                    )}
                </Typography>

                {/* フィルター適用中の表示 */}
                {(filters.searchName || filters.customerType || filters.status) && (
                    <Chip
                        label="フィルター適用中"
                        color="primary"
                        size="small"
                        variant="outlined"
                    />
                )}
            </Box>

            {/* 顧客一覧テーブル */}
            <TableContainer component={Paper} sx={{ mt: 2 }}>
                <Table>
                    <TableHead>
                        <TableRow sx={{ backgroundColor: '#f5f5f5' }}>
                            <TableCell><strong>顧客名</strong></TableCell>
                            <TableCell><strong>顧客種別</strong></TableCell>
                            <TableCell><strong>部署</strong></TableCell>
                            <TableCell><strong>ステータス</strong></TableCell>
                            <TableCell><strong>登録日</strong></TableCell>
                            <TableCell><strong>操作</strong></TableCell>
                        </TableRow>
                    </TableHead>
                    <TableBody>
                        {filteredCustomers.map((customer) => (
                            <TableRow key={customer.id} hover>
                                <TableCell>
                                    <Typography variant="body1" fontWeight="medium">
                                        {customer.name}
                                    </Typography>
                                </TableCell>
                                <TableCell>
                                    <Chip
                                        label={customer.customer_type_display}
                                        variant="outlined"
                                        color={customer.customer_type === 'premium' ? 'primary' : 'default'}
                                        size="small"
                                    />
                                </TableCell>
                                <TableCell>
                                    <Typography variant="body2">
                                        {customer.department.name}
                                    </Typography>
                                </TableCell>
                                <TableCell>
                                    <Chip
                                        label={customer.status_display}
                                        color={customer.status === 'active' ? 'success' : 'default'}
                                        size="small"
                                    />
                                </TableCell>
                                <TableCell>
                                    <Typography variant="body2" color="text.secondary">
                                        {new Date(customer.created_at).toLocaleDateString('ja-JP')}
                                    </Typography>
                                </TableCell>
                                <TableCell>
                                    {/* Phase 2以降で実装予定 */}
                                    <Typography variant="body2" color="text.secondary">
                                        操作ボタン
                                    </Typography>
                                </TableCell>
                            </TableRow>
                        ))}
                    </TableBody>
                </Table>
            </TableContainer>

            {/* ページネーション情報 */}
            <Box sx={{ mt: 2, display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                <Typography variant="body2" color="text.secondary">
                    ページ {pagination.current_page} / {pagination.total_pages}
                </Typography>
                <Typography variant="body2" color="text.secondary">
                    合計 {pagination.total_count} 件
                </Typography>
            </Box>
        </Box>
    );
};
export default CustomerList;
