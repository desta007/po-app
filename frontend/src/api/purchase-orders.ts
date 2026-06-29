import apiClient from './client';
import type { PurchaseOrder, POStatus, PaymentStatus, PurchaseOrderItem } from '@/types/purchase-order';
import type { PaginatedResponse } from '@/types';

export interface POFilters {
  search?: string;
  status?: POStatus;
  payment_status?: PaymentStatus;
  customer_id?: string;
  date_from?: string;
  date_to?: string;
  page?: number;
  per_page?: number;
  sort_by?: string;
  sort_dir?: 'asc' | 'desc';
}

export interface CreatePOItemData {
  product_id?: string;
  product_name: string;
  quantity: number;
  unit_price: number;
  notes?: string;
}

export interface CreatePOData {
  customer_id: string;
  order_date: string;
  delivery_date: string;
  notes?: string;
  discount?: number;
  tax?: number;
  shipping_cost?: number;
  dp_amount?: number;
  items: CreatePOItemData[];
}

export interface UpdatePOData {
  customer_id?: string;
  order_date?: string;
  delivery_date?: string;
  notes?: string;
  discount?: number;
  tax?: number;
  shipping_cost?: number;
  dp_amount?: number;
  items?: CreatePOItemData[];
}

export interface UpdateStatusData {
  status: POStatus;
  reason?: string;
}

export interface UpdatePaymentData {
  payment_status: PaymentStatus;
  paid_amount: number;
  payment_method?: string | null;
}

export const purchaseOrdersApi = {
  list: (filters?: POFilters) =>
    apiClient.get<PaginatedResponse<PurchaseOrder>>('/api/purchase-orders', { params: filters }),

  show: (id: string) =>
    apiClient.get<{ data: PurchaseOrder }>(`/api/purchase-orders/${id}`),

  create: (data: CreatePOData) =>
    apiClient.post<{ data: PurchaseOrder }>('/api/purchase-orders', data),

  update: (id: string, data: UpdatePOData) =>
    apiClient.put<{ data: PurchaseOrder }>(`/api/purchase-orders/${id}`, data),

  delete: (id: string) =>
    apiClient.delete(`/api/purchase-orders/${id}`),

  updateStatus: (id: string, status: string, reason?: string) =>
    apiClient.patch<{ data: PurchaseOrder }>(`/api/purchase-orders/${id}/status`, { status, reason }),

  updatePayment: (id: string, data: UpdatePaymentData) =>
    apiClient.patch<{ data: PurchaseOrder }>(`/api/purchase-orders/${id}/payment`, data),

  duplicate: (id: string) =>
    apiClient.post<{ data: PurchaseOrder }>(`/api/purchase-orders/${id}/duplicate`),

  exportPdf: (id: string) =>
    apiClient.get(`/api/purchase-orders/${id}/export-pdf`, { responseType: 'blob' }),

  exportCorporatePdf: (id: string) =>
    apiClient.get(`/api/purchase-orders/${id}/export-corporate-pdf`, { responseType: 'blob' }),

  exportImage: (id: string) =>
    apiClient.get(`/api/purchase-orders/${id}/export-image`, { responseType: 'blob' }),

  exportHtml: (id: string) =>
    apiClient.get(`/api/purchase-orders/${id}/export-html`, { responseType: 'text' }),

  getItems: (id: string) =>
    apiClient.get<{ data: PurchaseOrderItem[] }>(`/api/purchase-orders/${id}/items`),
};
