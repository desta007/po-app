export interface Product {
  id: string;
  organization_id: string;
  name: string;
  sku: string | null;
  description: string | null;
  unit: string;
  price: number;
  cost: number | null;
  category: string | null;
  image_url: string | null;
  stock_qty: number;
  is_active: boolean;
  created_at: string;
  updated_at: string;
}
