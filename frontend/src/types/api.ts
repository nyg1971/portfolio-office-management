// API通信で使用する型定義を集約管理

export interface User {
  id: number;
  email: string;
  role: 'staff'|'manager'|'admin';
  created_at: string;
  updated_at: string;
}

export interface Customer {
    id: number;
     name: string;
     customer_type: 'regular'|'premium'|'corporate';
     customer_type_display: string;
     status: 'active'|'inactive'|'pending';
     department: Department;
     created_at: string;
}

export interface Department {
    id: number;
    name: string;
}

export interface ApiResponse<T> {
    data: T;
    message?: string;
}

export interface AuthResponse {
    token: string;
    user: User;
    expire_at: string;
}

export interface ApiError {
    error: string;
    errors?: string[];
}
