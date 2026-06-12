import type { Customer } from './customer';

export type POStatus = 'draft' | 'confirmed' | 'in_progress' | 'completed' | 'cancelled';
export type PaymentStatus = 'unpaid' | 'dp' | 'paid';

export interface PurchaseOrderItem {
  id: string;
  po_id: string;
  product_id: string | null;
  product_name: string;
  quantity: number;
  unit_price: number;
  subtotal: number;
  notes: string | null;
  sort_order: number;
}

export interface PurchaseOrder {
  id: string;
  organization_id: string;
  po_number: string;
  customer_id: string;
  customer?: Customer;
  order_date: string;
  delivery_date: string;
  status: POStatus;
  payment_status: PaymentStatus;
  dp_amount: number;
  paid_amount: number;
  subtotal: number;
  discount: number;
  tax: number;
  shipping_cost: number;
  total: number;
  notes: string | null;
  payment_method: string | null;
  created_by: string;
  items?: PurchaseOrderItem[];
  status_history?: POStatusHistory[];
  created_at: string;
  updated_at: string;
}

export interface POStatusHistory {
  id: string;
  po_id: string;
  from_status: POStatus | null;
  to_status: POStatus;
  changed_by: string;
  reason: string | null;
  changed_at: string;
}

export interface CalendarEvent {
  id: string;
  title: string;
  start: string;
  backgroundColor: string;
  borderColor: string;
  extendedProps: {
    po_number: string;
    customer_name: string;
    status: POStatus;
    payment_status: PaymentStatus;
    total: number;
  };
}
