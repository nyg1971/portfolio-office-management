import { useState, useEffect } from 'react';
import type { AxiosResponse } from "axios";

// フックが返す状態の型定義
interface UseApiState<T> {
    data: T | null;     // API から取得したデータ（取得前は null）
    loading: boolean;   // 通信中フラグ
    error: string | null; // エラーメッセージ（エラーなしの場合は null）
}

// 汎用的なAPI通信フック（ジェネリック型で型安全性を確保）
export const useApi = <T>(
    apiCall: () => Promise<AxiosResponse<T>> // 実行するAPI関数
): UseApiState<T> => {
    // API通信の状態管理
    const [state, setState] = useState<UseApiState<T>>({
        data: null,     // 初期状態：データなし
        loading: true,  // 初期状態：ローディング中
        error: null     // 初期状態：エラーなし
    });

    useEffect(() => {
        // 非同期でAPI通信を実行
        const fetchData = async () => {
            try {
                // ローディング開始・エラーリセット
                setState(prev => ({ ...prev, loading: true, error: null }));

                // API呼び出し実行
                const response = await apiCall();

                // 成功：データを状態に保存
                setState(() => ( { data: response.data, loading: false, error: null } ));
            } catch (error: unknown) {
                setState({
                   data: null,
                   loading: false,
                   error: error.response?.data?.error || 'エラーが発生しました'
                });
            }
        };

        fetchData();    // API通信を実行
    }, [apiCall]);   // 依存配列が変更されたら再実行
    return state;  // 現在の状態を返す
};
