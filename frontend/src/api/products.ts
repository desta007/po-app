import apiClient from './client';
import type { Product } from '@/types/product';
import type { PaginatedResponse } from '@/types';

export interface ProductFilters {
  search?: string;
  category?: string;
  is_active?: boolean;
  page?: number;
  per_page?: number;
  sort_by?: string;
  sort_dir?: 'asc' | 'desc';
}

export interface CreateProductData {
  name: string;
  sku?: string;
  description?: string;
  unit: string;
  price: number;
  cost?: number;
  category?: string;
  stock_qty?: number;
  is_active?: boolean;
}

export type UpdateProductData = Partial<CreateProductData>;

export const productsApi = {
  list: (filters?: ProductFilters) =>
    apiClient.get<PaginatedResponse<Product>>('/api/products', { params: filters }),

  get: (id: string) =>
    apiClient.get<{ data: Product }>(`/api/products/${id}`),

  create: (data: CreateProductData) =>
    apiClient.post<{ data: Product }>('/api/products', data),

  update: (id: string, data: UpdateProductData) =>
    apiClient.put<{ data: Product }>(`/api/products/${id}`, data),

  delete: (id: string) =>
    apiClient.delete(`/api/products/${id}`),

  search: (query: string) =>
    apiClient.get<{ data: Product[] }>('/api/products/search', { params: { q: query } }),

  categories: () =>
    apiClient.get<{ data: string[] }>('/api/products/categories'),
};
