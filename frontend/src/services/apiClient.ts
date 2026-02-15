import axios from 'axios';
import type { AxiosResponse, AxiosError } from 'axios';
import type { AuthResponse, User, Customer, CustomersResponse, ApiError } from "../types/api";

const apiClient = axios.create({
  baseURL: "/api/v1",
  headers: { "Content-Type": "application/json" },
});

apiClient.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem("token");
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error: ApiError) => Promise.reject(error)
);

apiClient.interceptors.response.use(
  (response: AxiosResponse) => response,
  (error: AxiosError<ApiError>) => {
    if (error.response?.status === 401) {
      localStorage.removeItem("token");
      window.location.href = "/login";
    }
    return Promise.reject(error);
  }
);

export const authService = {
  login: (email: string, password: string): Promise<AxiosResponse<AuthResponse>> =>
    apiClient.post("/auth/login", { email, password }),

  me: (): Promise<AxiosResponse<{ user: User }>> =>
    apiClient.get("/auth/me"),

  signup: (userData: { email: string; password: string; password_confirmation: string }):
    Promise<AxiosResponse<AuthResponse>> =>
    apiClient.post("/auth/signup", { user: userData })
};

export const customerService = {
  getAll: (params?: { page?: number; per_page?: number }): Promise<AxiosResponse<CustomersResponse>> =>
    apiClient.get("/customers", { params }),

  getById: (id: number): Promise<AxiosResponse<{ customer: Customer }>> =>
    apiClient.get(`/customers/${id}`),

  create: (customer: Omit<Customer, 'id' | 'created_at' | 'updated_at' | 'customer_type_display' | 'status_display' | 'department'>):
    Promise<AxiosResponse<{ customer: Customer }>> =>
    apiClient.post("/customers", { customer }),

  update: (id: number, customer: Partial<Customer>): Promise<AxiosResponse<{ customer: Customer }>> =>
    apiClient.put(`/customers/${id}`, { customer })
};

export default apiClient;
