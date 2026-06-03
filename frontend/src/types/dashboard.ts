export interface TodaySummary {
  total_po: number;
  draft: number;
  confirmed: number;
  in_progress: number;
  completed: number;
  total_revenue: number;
}

export interface RevenueDataPoint {
  date: string;
  revenue: number;
  count: number;
}

export interface TopCustomer {
  id: string;
  name: string;
  total_revenue: number;
  total_orders: number;
}

export interface TopProduct {
  id: string;
  name: string;
  total_qty: number;
  total_revenue: number;
}

export interface PendingPayment {
  total_unpaid: number;
  total_dp: number;
  unpaid_amount: number;
  dp_remaining_amount: number;
}
