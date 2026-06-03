import apiClient from './client';
import type {
  TodaySummary,
  RevenueDataPoint,
  TopCustomer,
  TopProduct,
  PendingPayment,
} from '@/types/dashboard';

export interface DashboardFilters {
  period?: 'week' | 'month' | 'quarter' | 'year';
  date_from?: string;
  date_to?: string;
}

export const dashboardApi = {
  todaySummary: () =>
    apiClient.get<{ data: TodaySummary }>('/api/dashboard/today-summary'),

  revenueChart: (filters?: DashboardFilters) =>
    apiClient.get<{ data: RevenueDataPoint[] }>('/api/dashboard/revenue-chart', { params: filters }),

  topCustomers: (filters?: DashboardFilters) =>
    apiClient.get<{ data: TopCustomer[] }>('/api/dashboard/top-customers', { params: filters }),

  topProducts: (filters?: DashboardFilters) =>
    apiClient.get<{ data: TopProduct[] }>('/api/dashboard/top-products', { params: filters }),

  pendingPayments: () =>
    apiClient.get<{ data: PendingPayment }>('/api/dashboard/pending-payments'),
};
