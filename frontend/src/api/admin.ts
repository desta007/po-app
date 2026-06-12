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
};
