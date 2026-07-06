import { useQuery } from '@tanstack/react-query';
import { useAuth } from '@/contexts/auth-context';
import apiClient from '@/api/client';

interface QuotaItem {
  current: number;
  limit: number | null;
}

interface QuotaUsage {
  is_premium: boolean;
  po_monthly: QuotaItem;
  products: QuotaItem;
  team_members: QuotaItem;
}

export function useQuota() {
  const { isAuthenticated, organizationPlan, isSuperAdmin } = useAuth();

  const { data, ...rest } = useQuery({
    queryKey: ['quota-usage'],
    queryFn: () => apiClient.get<{ data: QuotaUsage }>('/api/quota/usage'),
    enabled: isAuthenticated,
    staleTime: 30_000,
  });

  const usage = data?.data?.data;
  const isPremiumOrAdmin = organizationPlan === 'premium' || isSuperAdmin;

  return {
    usage,
    isPremiumOrAdmin,
    poUsage: usage?.po_monthly,
    productUsage: usage?.products,
    teamUsage: usage?.team_members,
    ...rest,
  };
}
