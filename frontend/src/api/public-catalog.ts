import apiClient from './client';

export interface PublicOrderItem {
  product_name: string;
  quantity: number;
  unit_price: number;
  subtotal: number;
}

export interface PublicOrder {
  po_number: string;
  status: string;
  status_label: string;
  payment_status: string;
  payment_status_label: string;
  subtotal: number;
  shipping_cost: number;
  shipping_method: string | null;
  tracking_number: string | null;
  total: number;
  notes: string | null;
  created_at: string;
  customer_name: string | null;
  items: PublicOrderItem[];
  organization: { name: string; phone: string | null };
  online_payment_available: boolean;
}

export interface CheckoutItem {
  product_id: string;
  product_name: string;
  quantity: number;
  unit_price: number;
}

export interface CheckoutPayload {
  customer_name: string;
  customer_phone: string;
  customer_address: string;
  shipping_method?: string | null;
  payment_preference?: 'online' | 'whatsapp';
  items: CheckoutItem[];
}

export interface CheckoutResponse {
  message: string;
  po_number: string;
  total: number;
  shipping_cost: number;
  online_payment_available: boolean;
}

export interface PayResponse {
  snap_token: string;
  client_key: string;
  is_production: boolean;
}

export const publicCatalogApi = {
  checkout: (slug: string, payload: CheckoutPayload) =>
    apiClient.post<CheckoutResponse>(`/api/catalog/${slug}/checkout`, payload),

  pay: (slug: string, poNumber: string, phone: string) =>
    apiClient.post<PayResponse>(`/api/catalog/${slug}/orders/${encodeURIComponent(poNumber)}/pay`, { phone }),

  orderStatus: (slug: string, poNumber: string, phone: string) =>
    apiClient.get<{ data: PublicOrder }>(`/api/catalog/${slug}/orders/${encodeURIComponent(poNumber)}`, {
      params: { phone },
    }),
};
