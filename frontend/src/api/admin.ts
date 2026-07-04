import apiClient from './client';

export const adminApi = {
  dashboard: () =>
    apiClient.get('/api/admin/dashboard'),

  users: (params?: { search?: string; page?: number; per_page?: number }) =>
    apiClient.get('/api/admin/users', { params }),

  userDetail: (id: string) =>
    apiClient.get(`/api/admin/users/${id}`),

  organizations: (params?: { search?: string; page?: number; per_page?: number }) =>
    apiClient.get('/api/admin/organizations', { params }),

  subscriptions: (params?: { search?: string; status?: string; page?: number; per_page?: number }) =>
    apiClient.get('/api/admin/subscriptions', { params }),

  approveSubscription: (id: string) =>
    apiClient.patch(`/api/admin/subscriptions/${id}/approve`),

  rejectSubscription: (id: string, data: { reject_reason: string }) =>
    apiClient.patch(`/api/admin/subscriptions/${id}/reject`, data),

  downloadSubscriptionInvoice: (id: string) =>
    apiClient.get(`/api/admin/subscriptions/${id}/invoice`, { responseType: 'blob' }),
};
