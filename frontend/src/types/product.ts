import type { DiscountType } from '@/lib/discount';

export interface Product {
  id: string;
  organization_id: string;
  name: string;
  sku: string | null;
  description: string | null;
  unit: string;
  price: number;
  cost: number | null;
  discount_enabled: boolean;
  discount_type: DiscountType | null;
  discount_value: number;
  /** Computed server: diskon aktif & organisasi Premium. */
  has_active_discount: boolean;
  discount_amount: number;
  final_price: number;
  category: string | null;
  image_url: string | null;
  images: string[];
  stock_qty: number;
  track_stock: boolean;
  is_active: boolean;
  show_in_catalog: boolean;
  created_at: string;
  updated_at: string;
}
