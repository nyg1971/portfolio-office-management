export interface User {
  id: number;
  email: string;
  role: 'staff' | 'manager' | 'admin';
  created_at: string;
  updated_at: string;
}

export interface Customer {
  id: number;
  name: string;
  customer_type: 'regular' | 'premium' | 'corporate';
  customer_type_display: string;
  status: 'active' | 'inactive' | 'pending';
  status_display: string;
  department: Department;
  created_at: string;
  updated_at: string;
}

export interface Department {
  id: number;
  name: string;
}

export interface PaginationInfo {
  current_page: number;
  total_pages: number;
  total_count: number;
}

export interface CustomersResponse {
  customers: Customer[];
  pagination: PaginationInfo;
}

export interface AuthResponse {
  token: string;
  user: User;
  expires_at: string;
}

export interface ApiError {
  error: string;
  errors?: string[];
}
