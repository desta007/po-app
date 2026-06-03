import apiClient from './client';
import type { User, Organization } from '@/types/auth';

export interface UpdateProfileData {
  full_name: string;
  phone?: string;
}

export interface UpdatePasswordData {
  current_password: string;
  password: string;
  password_confirmation: string;
}

export interface UpdateOrganizationData {
  name: string;
  phone?: string;
  address?: string;
  settings?: Record<string, unknown>;
}

export interface NotificationPreferences {
  email_enabled: boolean;
  whatsapp_enabled: boolean;
  reminder_hours_before: number;
  daily_summary: boolean;
}

export const settingsApi = {
  updateProfile: (data: UpdateProfileData) =>
    apiClient.put<{ data: User }>('/api/settings/profile', data),

  updateAvatar: (file: File) => {
    const formData = new FormData();
    formData.append('avatar', file);
    return apiClient.post<{ data: { avatar_url: string } }>('/api/settings/avatar', formData, {
      headers: { 'Content-Type': 'multipart/form-data' },
    });
  },

  updatePassword: (data: UpdatePasswordData) =>
    apiClient.put('/api/settings/password', data),

  getOrganization: () =>
    apiClient.get<{ data: Organization }>('/api/settings/organization'),

  updateOrganization: (data: UpdateOrganizationData) =>
    apiClient.put<{ data: Organization }>('/api/settings/organization', data),

  updateOrgLogo: (file: File) => {
    const formData = new FormData();
    formData.append('logo', file);
    return apiClient.post<{ data: { logo_url: string } }>('/api/settings/organization/logo', formData, {
      headers: { 'Content-Type': 'multipart/form-data' },
    });
  },

  getNotificationPreferences: () =>
    apiClient.get<{ data: NotificationPreferences }>('/api/settings/notifications'),

  updateNotificationPreferences: (data: NotificationPreferences) =>
    apiClient.put<{ data: NotificationPreferences }>('/api/settings/notifications', data),
};
