import apiClient from './client';
import type { Notification } from '@/types/notification';
import type { PaginatedResponse } from '@/types';

export const notificationsApi = {
  list: (params?: { page?: number; per_page?: number }) =>
    apiClient.get<PaginatedResponse<Notification>>('/api/notifications', { params }),

  unreadCount: () =>
    apiClient.get<{ data: { count: number } }>('/api/notifications/unread-count'),

  markAsRead: (id: string) =>
    apiClient.patch(`/api/notifications/${id}/read`),

  markAllAsRead: () =>
    apiClient.patch('/api/notifications/read-all'),

  markAllRead: () =>
    apiClient.patch('/api/notifications/read-all'),

  delete: (id: string) =>
    apiClient.delete(`/api/notifications/${id}`),
};
