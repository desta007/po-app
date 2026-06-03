export type { User, Organization, LoginCredentials, RegisterData } from './auth';
export type { Customer } from './customer';
export type { Product } from './product';
export type {
  POStatus,
  PaymentStatus,
  PurchaseOrder,
  PurchaseOrderItem,
  POStatusHistory,
  CalendarEvent,
} from './purchase-order';
export type { Notification } from './notification';
export type {
  TodaySummary,
  RevenueDataPoint,
  TopCustomer,
  TopProduct,
  PendingPayment,
} from './dashboard';

// Common API types
export interface PaginatedResponse<T> {
  data: T[];
  meta: {
    current_page: number;
    last_page: number;
    per_page: number;
    total: number;
  };
}

export interface ApiError {
  message: string;
  errors?: Record<string, string[]>;
}
