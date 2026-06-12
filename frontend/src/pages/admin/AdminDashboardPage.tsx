import { useQuery } from '@tanstack/react-query';
import { adminApi } from '@/api/admin';
import { PageHeader } from '@/components/layout/page-header';
import { Button } from '@/components/ui/button';
import { Card } from '@/components/ui/card';
import { Skeleton } from '@/components/ui/skeleton';
import { formatRupiah } from '@/lib/utils';
import { Users, Building2, ClipboardList, TrendingUp, UserPlus, Activity } from 'lucide-react';
import { useNavigate } from 'react-router-dom';
import { ROUTES } from '@/lib/constants';

const STAT_CARDS = [
  { key: 'total_users', label: 'Total Users', icon: Users, color: '#1F4E79', bg: '#DBEAFE' },
  { key: 'total_organizations', label: 'Total Organisasi', icon: Building2, color: '#70AD47', bg: '#D1FAE5' },
  { key: 'total_purchase_orders', label: 'Total PO', icon: ClipboardList, color: '#D97706', bg: '#FEF3C7' },
  { key: 'total_revenue', label: 'Total Revenue', icon: TrendingUp, color: '#8B5CF6', bg: '#EDE9FE', format: 'currency' },
];

const HIGHLIGHT_CARDS = [
  { key: 'new_users_this_month', label: 'User Baru (Bulan Ini)', icon: UserPlus, color: '#1F4E79' },
  { key: 'new_orgs_this_month', label: 'Org Baru (Bulan Ini)', icon: Building2, color: '#70AD47' },
  { key: 'active_users_today', label: 'User Aktif Hari Ini', icon: Activity, color: '#D97706' },
];

export default function AdminDashboardPage() {
  const navigate = useNavigate();
  const { data, isLoading } = useQuery({
    queryKey: ['admin', 'dashboard'],
    queryFn: () => adminApi.dashboard(),
  });

  const stats = data?.data;

  if (isLoading) {
    return (
      <div>
        <PageHeader title="Super Admin Dashboard" description="Ringkasan platform PO Scheduler" />
        <div className="grid grid-cols-2 lg:grid-cols-4 gap-4 mb-6">
          {[1,2,3,4].map(i => <Skeleton key={i} className="h-28 rounded-[10px]" />)}
        </div>
      </div>
    );
  }

  const monthlyGrowth = stats?.monthly_growth || [];
  const topOrgs = stats?.top_organizations || [];
  const maxRevenue = Math.max(...monthlyGrowth.map((m: any) => m.revenue), 1);

  return (
    <div>
      <PageHeader
        title="🛡️ Super Admin Dashboard"
        description="Ringkasan platform PO Scheduler — SaaS Overview"
      />

      {/* Main Stats */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4 mb-6">
        {STAT_CARDS.map(card => {
          const Icon = card.icon;
          const value = stats?.[card.key] ?? 0;
          return (
            <Card key={card.key} padding="none" className="p-4 hover:shadow-md transition-shadow">
              <div className="flex items-start justify-between">
                <div>
                  <p className="text-[11px] font-semibold text-gray-500 uppercase tracking-wider">{card.label}</p>
                  <p className="text-[26px] font-extrabold text-gray-900 mt-1">
                    {card.format === 'currency' ? formatRupiah(value) : value.toLocaleString('id-ID')}
                  </p>
                </div>
                <div className="p-2.5 rounded-[10px]" style={{ backgroundColor: card.bg }}>
                  <Icon size={20} style={{ color: card.color }} />
                </div>
              </div>
            </Card>
          );
        })}
      </div>

      {/* Highlight Cards */}
      <div className="grid grid-cols-3 gap-4 mb-6">
        {HIGHLIGHT_CARDS.map(card => {
          const Icon = card.icon;
          const value = stats?.[card.key] ?? 0;
          return (
            <Card key={card.key} padding="none" className="p-4">
              <div className="flex items-center gap-3">
                <Icon size={18} style={{ color: card.color }} />
                <div>
                  <p className="text-[20px] font-extrabold text-gray-900">{value}</p>
                  <p className="text-[11px] text-gray-500 font-medium">{card.label}</p>
                </div>
              </div>
            </Card>
          );
        })}
      </div>

      <div className="grid lg:grid-cols-2 gap-5">
        {/* Monthly Growth Chart */}
        <Card>
          <h3 className="text-[14px] font-bold text-gray-900 mb-4">📈 Pertumbuhan Bulanan (Revenue)</h3>
          <div className="space-y-3">
            {monthlyGrowth.map((m: any) => (
              <div key={m.month} className="flex items-center gap-3">
                <span className="text-[12px] text-gray-500 w-16 flex-shrink-0">{m.month_label}</span>
                <div className="flex-1 bg-gray-100 rounded-full h-6 overflow-hidden">
                  <div
                    className="h-full rounded-full flex items-center px-2 transition-all duration-500"
                    style={{
                      width: `${Math.max((m.revenue / maxRevenue) * 100, 3)}%`,
                      background: 'linear-gradient(135deg, #1F4E79 0%, #2E75B6 100%)',
                    }}
                  >
                    <span className="text-[10px] font-bold text-white whitespace-nowrap">
                      {formatRupiah(m.revenue)}
                    </span>
                  </div>
                </div>
                <span className="text-[11px] text-gray-400 w-8 text-right">{m.pos} PO</span>
              </div>
            ))}
          </div>
          {monthlyGrowth.length === 0 && (
            <p className="text-[13px] text-gray-400 text-center py-6">Belum ada data pertumbuhan.</p>
          )}
        </Card>

        {/* Top Organizations */}
        <Card>
          <h3 className="text-[14px] font-bold text-gray-900 mb-4">🏆 Top Organisasi by Revenue</h3>
          {topOrgs.length > 0 ? (
            <div className="space-y-3">
              {topOrgs.map((org: any, i: number) => (
                <div key={org.id} className="flex items-center gap-3">
                  <div className={`w-7 h-7 rounded-full flex items-center justify-center text-white font-bold text-[12px] flex-shrink-0 ${
                    i === 0 ? 'bg-yellow-500' : i === 1 ? 'bg-gray-400' : i === 2 ? 'bg-amber-700' : 'bg-gray-300'
                  }`}>
                    {i + 1}
                  </div>
                  <div className="flex-1 min-w-0">
                    <p className="text-[13px] font-semibold text-gray-900 truncate">{org.name}</p>
                    <p className="text-[11px] text-gray-500">{org.total_pos} PO</p>
                  </div>
                  <span className="text-[13px] font-bold text-primary">{formatRupiah(org.total_revenue)}</span>
                </div>
              ))}
            </div>
          ) : (
            <p className="text-[13px] text-gray-400 text-center py-6">Belum ada data organisasi.</p>
          )}
        </Card>
      </div>

      {/* Quick Links */}
      <div className="mt-6 flex gap-3">
        <Button variant="secondary" onClick={() => navigate(ROUTES.ADMIN_USERS)}>
          <Users size={15} /> Lihat Semua Users
        </Button>
        <Button variant="secondary" onClick={() => navigate(ROUTES.ADMIN_ORGANIZATIONS)}>
          <Building2 size={15} /> Lihat Semua Organisasi
        </Button>
      </div>
    </div>
  );
}
