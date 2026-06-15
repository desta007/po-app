import apiClient from './client';
import type { User, Organization, MemberRole, TeamMember } from '@/types/auth';

export interface UpdateProfileData {
  full_name: string;
  phone?: string;
}

export interface UpdatePasswordData {
  current_password: string;
  new_password: string;
  new_password_confirmation: string;
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

  updatePassword: (data: UpdatePasswordData) =>
    apiClient.put('/api/settings/password', data),

  getOrganization: () =>
    apiClient.get<{ data: Organization }>('/api/settings/organization'),

  updateOrganization: (data: UpdateOrganizationData) =>
    apiClient.put<{ data: Organization }>('/api/settings/organization', data),

  uploadLogo: (file: File) => {
    const formData = new FormData();
    formData.append('logo', file);
    return apiClient.post<{ data: { logo_url: string } }>('/api/settings/organization/logo', formData, {
      headers: { 'Content-Type': 'multipart/form-data' },
    });
  },

  deleteLogo: () =>
    apiClient.delete('/api/settings/organization/logo'),

  getNotificationPreferences: () =>
    apiClient.get<{ data: NotificationPreferences }>('/api/settings/notifications'),

  updateNotificationPreferences: (data: NotificationPreferences) =>
    apiClient.put<{ data: NotificationPreferences }>('/api/settings/notifications', data),

  // Team Members
  listTeamMembers: () =>
    apiClient.get<{ data: TeamMember[] }>('/api/team-members'),

  inviteTeamMember: (data: { email: string; role: MemberRole }) =>
    apiClient.post<{ data: TeamMember }>('/api/team-members', data),

  updateMemberRole: (id: string, role: MemberRole) =>
    apiClient.put(`/api/team-members/${id}`, { role }),

  removeMember: (id: string) =>
    apiClient.delete(`/api/team-members/${id}`),

  // Payment Methods
  getPaymentMethods: () =>
    apiClient.get<{ data: { name: string; is_active: boolean }[] }>('/api/settings/payment-methods'),

  updatePaymentMethods: (methods: { name: string; is_active: boolean }[]) =>
    apiClient.put<{ data: { name: string; is_active: boolean }[]; message: string }>('/api/settings/payment-methods', { payment_methods: methods }),
};
