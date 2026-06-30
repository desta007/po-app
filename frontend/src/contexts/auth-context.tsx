import { createContext, useContext, useState, useEffect, useCallback, type ReactNode } from 'react';
import type { User, LoginCredentials, RegisterData, MemberRole, SubscriptionPlan, SubscriptionInfo } from '@/types/auth';
import { authApi } from '@/api/auth';

interface AuthContextType {
  user: User | null;
  role: MemberRole | null;
  isSuperAdmin: boolean;
  organizationPlan: SubscriptionPlan;
  subscription: SubscriptionInfo | null;
  isLoading: boolean;
  isAuthenticated: boolean;
  login: (credentials: LoginCredentials) => Promise<void>;
  register: (data: RegisterData) => Promise<void>;
  logout: () => Promise<void>;
  refreshUser: () => Promise<void>;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<User | null>(null);
  const [role, setRole] = useState<MemberRole | null>(null);
  const [isSuperAdmin, setIsSuperAdmin] = useState(false);
  const [organizationPlan, setOrganizationPlan] = useState<SubscriptionPlan>('free');
  const [subscription, setSubscription] = useState<SubscriptionInfo | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  const refreshUser = useCallback(async () => {
    try {
      const response = await authApi.me();
      setUser(response.data.user);
      setRole(response.data.role ?? null);
      setIsSuperAdmin(response.data.is_super_admin ?? false);
      setOrganizationPlan(response.data.organization_plan ?? 'free');
      setSubscription(response.data.subscription ?? null);
    } catch {
      localStorage.removeItem('auth_token');
      setUser(null);
      setRole(null);
      setIsSuperAdmin(false);
      setOrganizationPlan('free');
      setSubscription(null);
    }
  }, []);

  useEffect(() => {
    const checkAuth = async () => {
      const token = localStorage.getItem('auth_token');
      if (!token) {
        setUser(null);
        setIsLoading(false);
        return;
      }
      try {
        const response = await authApi.me();
        setUser(response.data.user);
        setRole(response.data.role ?? null);
        setIsSuperAdmin(response.data.is_super_admin ?? false);
        setOrganizationPlan(response.data.organization_plan ?? 'free');
        setSubscription(response.data.subscription ?? null);
      } catch {
        localStorage.removeItem('auth_token');
        setUser(null);
      } finally {
        setIsLoading(false);
      }
    };
    checkAuth();
  }, []);

  const login = async (credentials: LoginCredentials) => {
    const response = await authApi.login(credentials);
    localStorage.setItem('auth_token', response.data.token);
    setUser(response.data.user);
    setRole(response.data.role ?? null);
    setIsSuperAdmin(response.data.is_super_admin ?? false);
    setOrganizationPlan(response.data.organization_plan ?? 'free');
    setSubscription(response.data.subscription ?? null);
  };

  const register = async (data: RegisterData) => {
    const response = await authApi.register(data);
    localStorage.setItem('auth_token', response.data.token);
    setUser(response.data.user);
    setRole(response.data.role ?? null);
    setIsSuperAdmin(false);
    setOrganizationPlan('free');
    setSubscription(null);
  };

  const logout = async () => {
    try {
      await authApi.logout();
    } catch {
      // Still clear token even if request fails
    }
    localStorage.removeItem('auth_token');
    sessionStorage.removeItem('premium_modal_shown');
    setUser(null);
    setRole(null);
    setIsSuperAdmin(false);
    setOrganizationPlan('free');
    setSubscription(null);
  };

  return (
    <AuthContext.Provider
      value={{
        user,
        role,
        isSuperAdmin,
        organizationPlan,
        subscription,
        isLoading,
        isAuthenticated: !!user,
        login,
        register,
        logout,
        refreshUser,
      }}
    >
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error('useAuth harus digunakan di dalam AuthProvider');
  }
  return context;
}
