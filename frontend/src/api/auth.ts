import apiClient from './client';
import type { User, LoginCredentials, RegisterData, MemberRole, SubscriptionPlan, SubscriptionInfo } from '@/types/auth';

export const authApi = {
  login: (data: LoginCredentials) =>
    apiClient.post<{ user: User; token: string; role?: MemberRole; is_super_admin?: boolean; organization_plan?: SubscriptionPlan; subscription?: SubscriptionInfo | null }>('/api/auth/login', data),

  register: (data: RegisterData) =>
    apiClient.post<{ user: User; token: string; role?: MemberRole; is_super_admin?: boolean; organization_plan?: SubscriptionPlan; subscription?: SubscriptionInfo | null }>('/api/auth/register', data),

  logout: () =>
    apiClient.post('/api/auth/logout'),

  me: () =>
    apiClient.get<{ user: User; role?: MemberRole; is_super_admin?: boolean; organization_plan?: SubscriptionPlan; subscription?: SubscriptionInfo | null }>('/api/auth/me'),

  forgotPassword: (email: string) =>
    apiClient.post('/api/auth/forgot-password', { email }),

  resetPassword: (data: {
    token: string;
    email: string;
    password: string;
    password_confirmation: string;
  }) => apiClient.post('/api/auth/reset-password', data),
};
