export type MemberRole = 'owner' | 'admin' | 'staff' | 'viewer';
export type SubscriptionPlan = 'free' | 'premium';

export interface User {
  id: string;
  email: string;
  full_name: string;
  phone: string | null;
  avatar_url: string | null;
  current_org_id: string | null;
  is_super_admin?: boolean;
  role?: MemberRole;
  last_login_at: string | null;
  created_at: string;
}

export interface Organization {
  id: string;
  name: string;
  slug: string;
  phone: string | null;
  address: string | null;
  logo_url: string | null;
  settings: Record<string, unknown>;
  plan?: SubscriptionPlan;
}

export interface TeamMember {
  id: string;
  user_id: string;
  user_name: string;
  user_email: string;
  user_phone: string | null;
  user_avatar: string | null;
  last_login_at: string | null;
  role: MemberRole;
  role_label: string;
  joined_at: string;
}

export interface SubscriptionInfo {
  status: 'active' | 'expired' | 'pending' | 'rejected';
  status_label: string;
  starts_at: string | null;
  expires_at: string | null;
}

export interface LoginCredentials {
  email: string;
  password: string;
}

export interface RegisterData {
  email: string;
  password: string;
  password_confirmation: string;
  full_name: string;
  phone: string;
  business_name: string;
}
