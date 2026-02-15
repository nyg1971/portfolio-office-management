import React, { useState, useEffect, useCallback } from 'react';
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
import { customerService } from '../../services/apiClient';
import type { Customer, CustomersResponse } from '../../types/api';
import CustomerFilters from './CustomerFilters';
import type { FilterState } from './CustomerFilters';
import CustomerPagination from './CustomerPagination';

const CustomerList: React.FC = () => {
    const [customersData, setCustomersData] = useState<CustomersResponse | null>(null);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState<string | null>(null);
    const [page, setPage] = useState(1);
    const [perPage, setPerPage] = useState(20);
    const [filters, setFilters] = useState<FilterState>({
        searchName: '',
        customerType: '',
        status: ''
    });

    const loadCustomers = useCallback(async () => {
        try {
            setLoading(true);
            const response = await customerService.getAll({ page, per_page: perPage });
            setCustomersData(response.data);
        } catch (err: unknown) {
            const message = err instanceof Error ? err.message : '顧客データの取得に失敗しました';
            setError(message);
        } finally {
            setLoading(false);
        }
    }, [page, perPage]);

    useEffect(() => {
        loadCustomers();
    }, [loadCustomers]);

    const handlePageChange = (newPage: number) => {
        setPage(newPage);
    };

    const handlePerPageChange = (newPerPage: number) => {
        setPerPage(newPerPage);
        setPage(1);
    };

    const getFilteredCustomers = (): Customer[] => {
        if (!customersData) return [];
        return customersData.customers.filter((customer) => {
            const nameMatch = filters.searchName === '' ||
                customer.name.toLowerCase().includes(filters.searchName.toLowerCase());
            const typeMatch = filters.customerType === '' ||
                customer.customer_type === filters.customerType;
            const statusMatch = filters.status === '' ||
                customer.status === filters.status;
            return nameMatch && typeMatch && statusMatch;
        });
    };

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

    if (error) {
        return (
            <Alert severity="error" sx={{ mt: 2 }}>
                エラーが発生しました: {error}
            </Alert>
        );
    }

    if (!customersData || customersData.customers.length === 0) {
        return (
            <Paper sx={{ p: 3, mt: 2 }}>
                <Typography variant="h6" align="center" color="text.secondary">
                    顧客データがありません
                </Typography>
            </Paper>
        );
    }

    const filteredCustomers = getFilteredCustomers();

    return (
        <Box>
            <Typography variant="h4" component="h1" gutterBottom>
                顧客一覧
            </Typography>

            <CustomerFilters
                filters={filters}
                onFiltersChange={setFilters}
            />

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

                {(filters.searchName || filters.customerType || filters.status) && (
                    <Chip
                        label="フィルター適用中"
                        color="primary"
                        size="small"
                        variant="outlined"
                    />
                )}
            </Box>

            <TableContainer component={Paper} sx={{ mt: 2 }}>
                <Table>
                    <TableHead>
                        <TableRow sx={{ backgroundColor: '#f5f5f5' }}>
                            <TableCell><strong>顧客名</strong></TableCell>
                            <TableCell><strong>顧客種別</strong></TableCell>
                            <TableCell><strong>部署</strong></TableCell>
                            <TableCell><strong>ステータス</strong></TableCell>
                            <TableCell><strong>登録日</strong></TableCell>
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
                            </TableRow>
                        ))}
                    </TableBody>
                </Table>
            </TableContainer>

            <CustomerPagination
                pagination={customersData.pagination}
                perPage={perPage}
                onPageChange={handlePageChange}
                onPerPageChange={handlePerPageChange}
                isLoading={loading}
            />
        </Box>
    );
};

export default CustomerList;
