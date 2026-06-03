import { useQuery } from '@tanstack/react-query';
import { dashboardApi } from '@/api/dashboard';
import { PageHeader } from '@/components/layout/page-header';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Skeleton } from '@/components/ui/skeleton';
import { formatRupiah } from '@/lib/utils';
import { PO_STATUS_CONFIG } from '@/lib/constants';
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from 'recharts';
import { ClipboardList, DollarSign, Clock, Users, Calendar } from 'lucide-react';
import { useNavigate } from 'react-router-dom';

const statIcons = [
  { icon: ClipboardList, bgClass: 'bg-primary-50 text-primary' },
  { icon: DollarSign, bgClass: 'bg-accent-light text-accent' },
  { icon: Clock, bgClass: 'bg-warning-light text-amber-700' },
  { icon: Users, bgClass: 'bg-danger-light text-danger' },
];

export default function DashboardPage() {
  const navigate = useNavigate();
  const { data: today, isLoading: loadingToday } = useQuery({ queryKey: ['dashboard', 'today'], queryFn: () => dashboardApi.todaySummary() });
  const { data: revenue } = useQuery({ queryKey: ['dashboard', 'revenue'], queryFn: () => dashboardApi.revenueChart() });
  const { data: topCustomers } = useQuery({ queryKey: ['dashboard', 'topCustomers'], queryFn: () => dashboardApi.topCustomers() });
  const { data: pending } = useQuery({ queryKey: ['dashboard', 'pending'], queryFn: () => dashboardApi.pendingPayments() });

  const t = today?.data;
  const revenueData: any[] = (revenue as any)?.data || [];
  const customers: any[] = (topCustomers as any)?.data || [];
  const p = pending?.data;

  const now = new Date();
  const dayName = now.toLocaleDateString('id-ID', { weekday: 'long' });
  const dateStr = now.toLocaleDateString('id-ID', { day: 'numeric', month: 'long', year: 'numeric' });
  const hour = now.getHours();
  const greeting = hour < 12 ? 'Selamat pagi' : hour < 15 ? 'Selamat siang' : hour < 18 ? 'Selamat sore' : 'Selamat malam';

  return (
    <div>
      <PageHeader
        title="Dashboard"
        description={`${dayName}, ${dateStr} · ${greeting} ☀️`}
        actions={
          <div className="flex gap-2">
            <Button variant="secondary" onClick={() => navigate('/kalender')}>
              <Calendar size={15} /> Lihat Kalender
            </Button>
            <Button onClick={() => navigate('/pesanan/baru')}>+ Buat PO Baru</Button>
          </div>
        }
      />

      {/* Stat Cards */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4 mb-6">
        {[
          {
            label: 'PO Hari Ini',
            value: (t as any)?.total_po ?? 0,
            change: (t as any)?.po_change ?? '0% dari kemarin',
            changeUp: (t as any)?.po_change_up ?? true,
            idx: 0,
          },
          {
            label: 'Revenue Bulan Ini',
            value: formatRupiah((t as any)?.total_revenue ?? 0),
            change: (t as any)?.revenue_change ?? '0% dari bulan lalu',
            changeUp: (t as any)?.revenue_change_up ?? true,
            idx: 1,
          },
          {
            label: 'Pending Pembayaran',
            value: formatRupiah((p as any)?.unpaid_amount ?? 0),
            change: `${(p as any)?.total_unpaid ?? 0} PO belum lunas`,
            changeUp: false,
            idx: 2,
          },
          {
            label: 'Customer Aktif',
            value: (t as any)?.active_customers ?? 0,
            change: (t as any)?.customer_change ?? '+0 bulan ini',
            changeUp: (t as any)?.customer_change_up ?? true,
            idx: 3,
          },
        ].map((stat) => {
          const iconConfig = statIcons[stat.idx]!;
          const Icon = iconConfig.icon;
          return (
            <Card key={stat.label} padding="none" className="p-4 relative overflow-hidden">
              <div className={`w-9 h-9 rounded-[6px] flex items-center justify-center mb-2.5 ${iconConfig.bgClass}`}>
                <Icon size={18} />
              </div>
              <div className="text-xs text-gray-500 font-medium">{stat.label}</div>
              <div className="text-[26px] font-extrabold text-gray-900 mt-1" style={{ letterSpacing: '-0.02em' }}>
                {loadingToday ? <Skeleton className="h-8 w-16" /> : stat.value}
              </div>
              <div className={`text-[11px] mt-1.5 font-semibold ${stat.changeUp ? 'text-accent' : 'text-danger'}`}>
                {stat.change}
              </div>
            </Card>
          );
        })}
      </div>

      {/* Status breakdown */}
      {t && (
        <div className="flex flex-wrap gap-2 mb-6">
          {(['draft', 'confirmed', 'in_progress', 'completed'] as const).map((s) => (
            <Badge key={s} dot style={{ backgroundColor: PO_STATUS_CONFIG[s].bgColor, color: PO_STATUS_CONFIG[s].color }}>
              {PO_STATUS_CONFIG[s].label}: {(t as any)[s] ?? 0}
            </Badge>
          ))}
        </div>
      )}

      <div className="grid lg:grid-cols-3 gap-5">
        {/* Revenue chart */}
        <Card className="lg:col-span-2">
          <CardHeader>
            <CardTitle>Revenue 30 Hari Terakhir</CardTitle>
            <Button variant="secondary" size="sm">30 hari ▾</Button>
          </CardHeader>
          <CardContent>
            <div className="h-52">
              <ResponsiveContainer width="100%" height="100%">
                <LineChart data={revenueData}>
                  <CartesianGrid strokeDasharray="3 3" stroke="#E5E5E5" />
                  <XAxis dataKey="date" tick={{ fontSize: 10, fill: '#737373' }} />
                  <YAxis tick={{ fontSize: 10, fill: '#737373' }} tickFormatter={(v: number) => `${(v / 1000000).toFixed(1)}jt`} />
                  <Tooltip formatter={(v: number) => formatRupiah(v)} />
                  <Line type="monotone" dataKey="revenue" stroke="#1F4E79" strokeWidth={2} dot={false} />
                </LineChart>
              </ResponsiveContainer>
            </div>
          </CardContent>
        </Card>

        {/* Top customers */}
        <Card>
          <CardHeader>
            <CardTitle>Top Customer Bulan Ini</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-3">
              {customers.map((c: any, i: number) => {
                const colors = ['#1F4E79', '#70AD47', '#FFC000', '#2E75B6', '#C00000'];
                return (
                  <div key={c.id} className="flex items-center gap-2.5">
                    <div
                      className="w-8 h-8 rounded-full flex items-center justify-center text-white text-xs font-bold flex-shrink-0"
                      style={{ backgroundColor: colors[i % colors.length] }}
                    >
                      {(c.name || '?')[0].toUpperCase()}
                    </div>
                    <div className="flex-1 min-w-0">
                      <div className="text-[13px] font-semibold text-gray-900 truncate">{c.name}</div>
                      <div className="text-[11px] text-gray-500">{c.total_orders ?? 0} PO · {formatRupiah(c.total_revenue)}</div>
                    </div>
                  </div>
                );
              })}
              {customers.length === 0 && <p className="text-[13px] text-gray-500 text-center py-4">Belum ada data</p>}
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
