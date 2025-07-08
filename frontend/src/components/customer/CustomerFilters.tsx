// src/components/customer/CustomerFilters.tsx
import React from 'react';
import {
    Paper,
    Grid,
    TextField,
    FormControl,
    InputLabel,
    Select,
    MenuItem,
    Typography,
    Box
} from '@mui/material';
import type { SelectChangeEvent } from '@mui/material';

// フィルター状態の型定義
interface FilterState {
    searchName: string;
    customerType: string;
    status: string;
}

// コンポーネントのProps型定義
interface CustomerFiltersProps {
    filters: FilterState;
    onFiltersChange: (filters: FilterState) => void;
}

const CustomerFilters: React.FC<CustomerFiltersProps> = ({ filters, onFiltersChange }) => {
    // 検索名の変更ハンドラー
    const handleSearchNameChange = (event: React.ChangeEvent<HTMLInputElement>) => {
        onFiltersChange({
            ...filters,
            searchName: event.target.value
        });
    };

    // 顧客種別の変更ハンドラー
    const handleCustomerTypeChange = (event: SelectChangeEvent<{ value: unknown }>) => {
        onFiltersChange({
            ...filters,
            customerType: event.target.value
        });
    };

    // ステータスの変更ハンドラー
    const handleStatusChange = (event: SelectChangeEvent<{ value: unknown }>) => {
        onFiltersChange({
            ...filters,
            status: event.target.value
        });
    };

    return (
        <Paper sx={{ p: 3, mb: 3 }}>
            {/* フィルターヘッダー */}
            <Typography variant="h6" gutterBottom>
                検索・フィルター
            </Typography>

            <Grid container spacing={3}>
                {/* 顧客名検索 */}
                <Grid item xs={12} md={4}>
                    <TextField
                        fullWidth
                        label="顧客名で検索"
                        placeholder="例：田中"
                        value={filters.searchName}
                        onChange={handleSearchNameChange}
                        variant="outlined"
                        size="small"
                    />
                </Grid>

                {/* 顧客種別フィルター */}
                <Grid item xs={12} md={4}>
                    <FormControl fullWidth size="small">
                        <InputLabel>顧客種別</InputLabel>
                        <Select
                            value={filters.customerType}
                            label="顧客種別"
                            onChange={handleCustomerTypeChange}
                        >
                            <MenuItem value="">
                                <em>全て</em>
                            </MenuItem>
                            <MenuItem value="regular">一般顧客</MenuItem>
                            <MenuItem value="premium">プレミアム顧客</MenuItem>
                            <MenuItem value="corporate">法人顧客</MenuItem>
                        </Select>
                    </FormControl>
                </Grid>

                {/* ステータスフィルター */}
                <Grid item xs={12} md={4}>
                    <FormControl fullWidth size="small">
                        <InputLabel>ステータス</InputLabel>
                        <Select
                            value={filters.status}
                            label="ステータス"
                            onChange={handleStatusChange}
                        >
                            <MenuItem value="">
                                <em>全て</em>
                            </MenuItem>
                            <MenuItem value="active">アクティブ</MenuItem>
                            <MenuItem value="inactive">非アクティブ</MenuItem>
                            <MenuItem value="pending">保留中</MenuItem>
                        </Select>
                    </FormControl>
                </Grid>
            </Grid>

            {/* 現在のフィルター状況表示 */}
            {(filters.searchName || filters.customerType || filters.status) && (
                <Box sx={{ mt: 2, p: 2, backgroundColor: '#f5f5f5', borderRadius: 1 }}>
                    <Typography variant="body2" color="text.secondary">
                        現在のフィルター:
                        {filters.searchName && ` 名前「${filters.searchName}」`}
                        {filters.customerType && ` 種別「${getCustomerTypeDisplay(filters.customerType)}」`}
                        {filters.status && ` ステータス「${getStatusDisplay(filters.status)}」`}
                    </Typography>
                </Box>
            )}
        </Paper>
    );
};

// 顧客種別の表示名取得関数
const getCustomerTypeDisplay = (type: string): string => {
    const typeMap: { [key: string]: string } = {
        regular: '一般顧客',
        premium: 'プレミアム顧客',
        corporate: '法人顧客'
    };
    return typeMap[type] || type;
};

// ステータスの表示名取得関数
const getStatusDisplay = (status: string): string => {
    const statusMap: { [key: string]: string } = {
        active: 'アクティブ',
        inactive: '非アクティブ',
        pending: '保留中'
    };
    return statusMap[status] || status;
};

export default CustomerFilters;
export type { FilterState };