import apiClient from './client';
import type { Customer } from '@/types/customer';
import type { PaginatedResponse } from '@/types';

export interface CustomerFilters {
  search?: string;
  page?: number;
  per_page?: number;
  sort_by?: string;
  sort_dir?: 'asc' | 'desc';
}

export interface CreateCustomerData {
  name: string;
  phone?: string;
  email?: string;
  address?: string;
  notes?: string;
  tags?: string[];
}

export type UpdateCustomerData = Partial<CreateCustomerData>;

export const customersApi = {
  list: (filters?: CustomerFilters) =>
    apiClient.get<PaginatedResponse<Customer>>('/api/customers', { params: filters }),

  get: (id: string) =>
    apiClient.get<{ data: Customer }>(`/api/customers/${id}`),

  show: (id: string) =>
    apiClient.get<{ data: Customer }>(`/api/customers/${id}`),

  create: (data: CreateCustomerData) =>
    apiClient.post<{ data: Customer }>('/api/customers', data),

  update: (id: string, data: UpdateCustomerData) =>
    apiClient.put<{ data: Customer }>(`/api/customers/${id}`, data),

  delete: (id: string) =>
    apiClient.delete(`/api/customers/${id}`),

  search: (query: string) =>
    apiClient.get<{ data: Customer[] }>('/api/customers/search', { params: { q: query } }),
};
