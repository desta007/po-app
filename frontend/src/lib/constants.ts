import type { POStatus, PaymentStatus } from '@/types/purchase-order';

export const PO_STATUS_CONFIG: Record<POStatus, { label: string; color: string; bgColor: string }> = {
  draft: { label: 'Draft', color: '#9CA3AF', bgColor: '#F3F4F6' },
  confirmed: { label: 'Dikonfirmasi', color: '#1F4E79', bgColor: '#DBEAFE' },
  in_progress: { label: 'Diproses', color: '#D97706', bgColor: '#FEF3C7' },
  completed: { label: 'Selesai', color: '#C8A2C8', bgColor: '#F0E6F0' },
  cancelled: { label: 'Dibatalkan', color: '#C00000', bgColor: '#FEE2E2' },
};

export const PAYMENT_STATUS_CONFIG: Record<PaymentStatus, { label: string; color: string; bgColor: string }> = {
  unpaid: { label: 'Belum Bayar', color: '#C00000', bgColor: '#FEE2E2' },
  dp: { label: 'DP', color: '#D97706', bgColor: '#FEF3C7' },
  paid: { label: 'Lunas', color: '#70AD47', bgColor: '#D1FAE5' },
};

export const ROUTES = {
  LOGIN: '/login',
  REGISTER: '/register',
  FORGOT_PASSWORD: '/lupa-password',
  RESET_PASSWORD: '/reset-password',
  ONBOARDING: '/onboarding',
  DASHBOARD: '/dashboard',
  CALENDAR: '/kalender',
  PO_LIST: '/pesanan',
  PO_CREATE: '/pesanan/baru',
  PO_DETAIL: (id: string) => `/pesanan/${id}`,
  PO_EDIT: (id: string) => `/pesanan/${id}/edit`,
  CUSTOMERS: '/pelanggan',
  CUSTOMER_DETAIL: (id: string) => `/pelanggan/${id}`,
  PRODUCTS: '/produk',
  REPORTS: '/laporan',
  PROFIT_REPORT: '/laporan/laba',
  SETTINGS: '/pengaturan',
  SETTINGS_PROFILE: '/pengaturan/profil',
  SETTINGS_ORG: '/pengaturan/organisasi',
  SETTINGS_TEAM: '/pengaturan/tim',
  SETTINGS_NOTIFICATIONS: '/pengaturan/notifikasi',
  SETTINGS_INTEGRATIONS: '/pengaturan/integrasi',
  ADMIN_DASHBOARD: '/admin',
  ADMIN_USERS: '/admin/users',
  ADMIN_ORGANIZATIONS: '/admin/organizations',
} as const;

export const UNITS = [
  { value: 'pcs', label: 'Pcs' },
  { value: 'kg', label: 'Kg' },
  { value: 'gram', label: 'Gram' },
  { value: 'liter', label: 'Liter' },
  { value: 'meter', label: 'Meter' },
  { value: 'box', label: 'Box' },
  { value: 'pack', label: 'Pack' },
  { value: 'lusin', label: 'Lusin' },
  { value: 'rim', label: 'Rim' },
  { value: 'roll', label: 'Roll' },
  { value: 'set', label: 'Set' },
  { value: 'unit', label: 'Unit' },
] as const;
