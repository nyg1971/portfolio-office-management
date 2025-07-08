import React from "react";
import {
    Box,
    Pagination,
    FormControl,
    InputLabel,
    Select,
    MenuItem,
    Typography,
    Paper
} from '@mui/material';
import type { SelectChangeEvent } from '@mui/material';

// ページネーション状態の型定義
interface PaginationInfo {
    current_page: number;
    total_pages: number;
    total_count: number;
    per_page: number;
    has_next: boolean;
    has_prev: boolean;
}
// Props の型定義
interface CustomerPaginationProps {
    pagination: PaginationInfo;
    onPageChange: (page: number) => void;
    onPerPageChange: (perPage: number) => void;
    isLoading?: boolean;
}

const CustomerPagination: React.FC<CustomerPaginationProps> = ({
    pagination,
    onPageChange,
    onPerPageChange,
    isLoading = false
}) => {

    // ページ変更ハンドラー
    const handlePageChange = (_event: React.ChangeEvent<unknown>, page: number) => {
        onPageChange(page);
    };
    // 表示件数変更ハンドラー
    const handlePerPageChange = (event: SelectChangeEvent) => {
        const newPerPage = parseInt(event.target.value, 10);
        onPerPageChange(newPerPage);
    };
    // 表示範囲の計算
    const getDisplayRange = () => {
        const start = (pagination.current_page - 1) * pagination.per_page + 1;
        const end = Math.min(pagination.current_page * pagination.per_page, pagination.total_count);
        return { start, end };
    };

    const { start, end } = getDisplayRange();

    // データがない場合は表示しない
    if (pagination.total_count === 0) {
        return null;
    }

    return (
        <Paper sx={{ p: 2, mt: 2 }}>
            <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2 }}>
                {/* 統計情報表示 */}
                <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                    <Typography variant="body2" color="text.secondary">
                        {start}-{end}件表示 (全{pagination.total_count}件中)
                    </Typography>

                    {/* 表示件数選択 */}
                    <FormControl size="small" sx={{ minWidth: 120 }}>
                        <InputLabel>表示件数</InputLabel>
                        <Select
                            value={pagination.per_page.toString()}
                            label="表示件数"
                            onChange={handlePerPageChange}
                            disabled={isLoading}
                        >
                            <MenuItem value="10">10件</MenuItem>
                            <MenuItem value="20">20件</MenuItem>
                            <MenuItem value="50">50件</MenuItem>
                            <MenuItem value="100">100件</MenuItem>
                        </Select>
                    </FormControl>
                </Box>

                {/* ページネーション */}
                {pagination.total_pages > 1 && (
                    <Box sx={{ display: 'flex', justifyContent: 'center' }}>
                        <Pagination
                            count={pagination.total_pages}
                            page={pagination.current_page}
                            onChange={handlePageChange}
                            color="primary"
                            shape="rounded"
                            showFirstButton
                            showLastButton
                            disabled={isLoading}
                            size="medium"
                        />
                    </Box>
                )}
            </Box>
        </Paper>
    );

}

export default CustomerPagination;
