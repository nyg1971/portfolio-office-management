// Rails API との通信を管理する共通クライアント
import axios from 'axios';
import type { AxiosResponse, AxiosError } from 'axios';
import type { AuthResponse, User, Customer, /*ApiResponse,*/ ApiError } from "../types/api";

const API_BASE_URL = "/api/v1";

// Axios インスタンスを作成：共通設定を適用
const apiClient = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    "Content-Type": "application/json",
  },
});

// リクエストインターセプター：全てのAPIリクエストに JWT token を自動付与
apiClient.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem("token");
    if (token) {
      // Authorization ヘッダーに Bearer token を設定
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error: ApiError) => Promise.reject(error)
);

// レスポンスインターセプター：認証エラーの自動処理
apiClient.interceptors.response.use(
    (response: AxiosResponse) => response,
    (error: AxiosError<ApiError>)=>{
        if (error.response?.status === 401){
           // 401 Unauthorized の場合：認証切れとみなす
           localStorage.removeItem("token"); // トークンを削除
           window.location.href = "/login"; // ログイン画面にリダイレクト
        }
        return Promise.reject(error);
    }
)

// 認証関連のAPI呼び出し関数群
export const authService = {
    // ログイン：メールアドレスとパスワードでJWTトークンを取得
    login: (email: string, password: string): Promise<AxiosResponse<AuthResponse>> =>
        apiClient.post("/auth/login", { email, password }),
    // 認証済みユーザー情報を取得（トークン検証も兼ねる）
    me: (): Promise<AxiosResponse<{user: User}>> =>
        apiClient.get("/auth/me"),
    // 新規ユーザー登録
    signup: (userData: {email: string, password: string, password_confirmation: string}):
        Promise<AxiosResponse<AuthResponse>> =>
        apiClient.post("/auth/signup", { user: userData })
};

// 顧客管理関連のAPI呼び出し関数群
export const customerService = {
    // 顧客一覧を取得
    getAll: (): Promise<AxiosResponse<{customers: Customer[]}>> =>
        apiClient.get("/customers"),

    // 特定の顧客詳細を取得
    getById: (id: number): Promise<AxiosResponse<{customer: Customer}>> =>
        apiClient.get(`/customers/${id}`),

    // 新規顧客を作成
    create: (customer: Omit<Customer, 'id' | 'created_at' | 'customer_type_display' | 'department'>): Promise<AxiosResponse<{customer: Customer}>> =>
        apiClient.post("/customers", { customer }),

    // 既存顧客情報を更新
    update: (id: number, customer: Partial<Customer>): Promise<AxiosResponse<{customer: Customer}>> =>
        apiClient.put(`/customers/${id}`, { customer })
}

// 他のサービスでも使用可能な共通クライアントをエクスポート
export default apiClient;
