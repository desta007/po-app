export interface Customer {
  id: string;
  organization_id: string;
  name: string;
  phone: string | null;
  email: string | null;
  address: string | null;
  notes: string | null;
  tags: string[];
  total_orders: number;
  total_revenue: number;
  created_at: string;
  updated_at: string;
}
