import apiClient from './client';
import type { WaitlistEntry, WaitlistStats, RestoTable } from '@/types/waitlist';

interface ListResponse {
  data: WaitlistEntry[];
  stats: WaitlistStats;
}

interface DisplayResponse {
  called: WaitlistEntry[];
  waiting: WaitlistEntry[];
  stats: WaitlistStats;
}

export const waitlistApi = {
  list: (params?: { status?: string; all?: boolean }) =>
    apiClient.get<ListResponse>('/api/waitlist', { params }),

  display: () => apiClient.get<DisplayResponse>('/api/waitlist/display'),

  add: (data: { guest_name: string; party_size: number; phone?: string; notes?: string }) =>
    apiClient.post<{ data: WaitlistEntry }>('/api/waitlist', data),

  update: (id: string, data: Partial<{ guest_name: string; party_size: number; phone: string; notes: string }>) =>
    apiClient.put<{ data: WaitlistEntry }>(`/api/waitlist/${id}`, data),

  call: (id: string) =>
    apiClient.post<{ data: WaitlistEntry; announcement: string; whatsapp_sent: boolean }>(`/api/waitlist/${id}/call`),

  seat: (id: string, table_id?: string) =>
    apiClient.post<{ data: WaitlistEntry }>(`/api/waitlist/${id}/seat`, { table_id }),

  cancel: (id: string, status: 'cancelled' | 'no_show') =>
    apiClient.post<{ data: WaitlistEntry }>(`/api/waitlist/${id}/cancel`, { status }),
};

export const restoTableApi = {
  list: (params?: { is_active?: boolean }) =>
    apiClient.get<{ data: RestoTable[] }>('/api/resto-tables', { params }),

  create: (data: { label: string; capacity: number; sort_order?: number }) =>
    apiClient.post<{ data: RestoTable }>('/api/resto-tables', data),

  update: (id: string, data: Partial<{ label: string; capacity: number; is_active: boolean; sort_order: number }>) =>
    apiClient.put<{ data: RestoTable }>(`/api/resto-tables/${id}`, data),

  updateStatus: (id: string, status: 'available' | 'occupied') =>
    apiClient.patch<{ data: RestoTable }>(`/api/resto-tables/${id}/status`, { status }),

  delete: (id: string) => apiClient.delete(`/api/resto-tables/${id}`),
};
