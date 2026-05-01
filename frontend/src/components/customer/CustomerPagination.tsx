import type { ChangeEvent } from "react";
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
import type { PaginationInfo } from '../../types/api';

interface CustomerPaginationProps {
    pagination: PaginationInfo;
    perPage: number;
    onPageChange: (page: number) => void;
    onPerPageChange: (perPage: number) => void;
    isLoading?: boolean;
}

const CustomerPagination = ({
    pagination,
    perPage,
    onPageChange,
    onPerPageChange,
    isLoading = false
}: CustomerPaginationProps) => {
    const handlePageChange = (_event: ChangeEvent<unknown>, page: number) => {
        onPageChange(page);
    };

    const handlePerPageChange = (event: SelectChangeEvent<string>) => {
        onPerPageChange(parseInt(event.target.value, 10));
    };

    if (pagination.total_count === 0) {
        return null;
    }

    const start = (pagination.current_page - 1) * perPage + 1;
    const end = Math.min(pagination.current_page * perPage, pagination.total_count);

    return (
        <Paper sx={{ p: 2, mt: 2 }}>
            <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2 }}>
                <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                    <Typography variant="body2" color="text.secondary">
                        {start}-{end}件表示 (全{pagination.total_count}件中)
                    </Typography>

                    <FormControl size="small" sx={{ minWidth: 120 }}>
                        <InputLabel>表示件数</InputLabel>
                        <Select
                            value={perPage.toString()}
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
                        />
                    </Box>
                )}
            </Box>
        </Paper>
    );
};

export default CustomerPagination;
