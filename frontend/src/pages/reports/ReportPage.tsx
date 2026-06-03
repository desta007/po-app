import { useQuery } from '@tanstack/react-query';
import { dashboardApi } from '@/api/dashboard';
import { PageHeader } from '@/components/layout/page-header';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { formatRupiah } from '@/lib/utils';
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from 'recharts';
import { DollarSign, ClipboardList, Hash, TrendingUp, Download, FileText } from 'lucide-react';

const statIcons = [
  { icon: DollarSign, bgClass: 'bg-accent-light text-accent' },
  { icon: ClipboardList, bgClass: 'bg-primary-50 text-primary' },
  { icon: Hash, bgClass: 'bg-warning-light text-amber-700' },
  { icon: TrendingUp, bgClass: 'bg-danger-light text-danger' },
];

export default function ReportPage() {
  const period = '30';
  const { data } = useQuery({ queryKey: ['reports', 'revenue', period], queryFn: () => dashboardApi.revenueChart() });
  const { data: topCustomers } = useQuery({ queryKey: ['dashboard', 'topCustomers'], queryFn: () => dashboardApi.topCustomers() });
  const { data: topProducts } = useQuery({ queryKey: ['dashboard', 'topProducts'], queryFn: () => dashboardApi.topProducts() });
  const { data: todaySummary } = useQuery({ queryKey: ['dashboard', 'today'], queryFn: () => dashboardApi.todaySummary() });

  const chartData: any[] = (data as any)?.data || [];
  const customers: any[] = (topCustomers as any)?.data || [];
  const products: any[] = (topProducts as any)?.data || [];
  const t: any = (todaySummary as any)?.data || {};

  const totalOrders = t.total_orders_this_month || 0;
  const completedOrders = t.completed || 0;
  const avgOrderValue = totalOrders > 0 ? (t.total_revenue || 0) / totalOrders : 0;
  const conversionRate = totalOrders > 0 ? Math.round((completedOrders / totalOrders) * 100) : 0;

  return (
    <div>
      <PageHeader
        title="Laporan & Analitik"
        description="Analisis performa bisnis Anda"
        actions={
          <div className="flex gap-2">
            <select className="px-3 py-2.5 border border-gray-300 rounded-[6px] text-[14px] bg-white focus:outline-none focus:border-primary">
              <option>Bulan ini</option><option>Bulan lalu</option><option>3 bulan terakhir</option>
            </select>
            <Button variant="secondary"><Download size={15} /> Export Excel</Button>
            <Button><FileText size={15} /> Export PDF</Button>
          </div>
        }
      />

      {/* Stats Grid */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4 mb-6">
        {[
          { label: 'Total Revenue', value: formatRupiah(t.total_revenue || 0), change: t.revenue_change || '-', up: t.revenue_change_up ?? true, idx: 0 },
          { label: 'Total PO', value: totalOrders.toString(), change: 'Bulan ini', up: true, idx: 1 },
          { label: 'Avg Order Value', value: formatRupiah(avgOrderValue), change: 'Bulan ini', up: true, idx: 2 },
          { label: 'Conversion', value: `${conversionRate}%`, change: 'Draft → Selesai', up: true, idx: 3 },
        ].map((stat) => {
          const iconConfig = statIcons[stat.idx]!;
          const Icon = iconConfig.icon;
          return (
            <Card key={stat.label} padding="none" className="p-4">
              <div className={`w-9 h-9 rounded-[6px] flex items-center justify-center mb-2.5 ${iconConfig.bgClass}`}><Icon size={18} /></div>
              <div className="text-xs text-gray-500 font-medium">{stat.label}</div>
              <div className="text-[26px] font-extrabold text-gray-900 mt-1" style={{ letterSpacing: '-0.02em' }}>{stat.value}</div>
              <div className={`text-[11px] mt-1.5 font-semibold ${stat.up ? 'text-accent' : 'text-danger'}`}>{stat.change}</div>
            </Card>
          );
        })}
      </div>

      {/* Revenue Chart + Status Breakdown */}
      <div className="grid lg:grid-cols-3 gap-5 mb-5">
        <Card className="lg:col-span-2">
          <CardHeader><CardTitle>Trend Revenue Harian</CardTitle></CardHeader>
          <CardContent>
            <div className="h-56">
              <ResponsiveContainer width="100%" height="100%">
                <BarChart data={chartData}>
                  <CartesianGrid strokeDasharray="3 3" stroke="#E5E5E5" />
                  <XAxis dataKey="date" tick={{ fontSize: 10, fill: '#737373' }} />
                  <YAxis tick={{ fontSize: 10, fill: '#737373' }} tickFormatter={(v: number) => `${(v / 1000000).toFixed(1)}jt`} />
                  <Tooltip formatter={(v: number) => formatRupiah(v)} />
                  <Bar dataKey="revenue" fill="url(#barGradient)" radius={[6, 6, 0, 0]} />
                  <defs><linearGradient id="barGradient" x1="0" y1="0" x2="0" y2="1"><stop offset="0%" stopColor="#2E75B6" /><stop offset="100%" stopColor="#1F4E79" /></linearGradient></defs>
                </BarChart>
              </ResponsiveContainer>
            </div>
          </CardContent>
        </Card>
        <Card>
          <CardHeader><CardTitle>Status Breakdown</CardTitle></CardHeader>
          <CardContent>
            {[
              { label: 'Selesai', count: t.completed || 0, pct: totalOrders > 0 ? Math.round(((t.completed || 0) / totalOrders) * 100) : 0, color: '#70AD47', bg: 'bg-accent-light text-accent' },
              { label: 'Confirmed', count: t.confirmed || 0, pct: totalOrders > 0 ? Math.round(((t.confirmed || 0) / totalOrders) * 100) : 0, color: '#1F4E79', bg: 'bg-primary-50 text-primary' },
              { label: 'Progress', count: t.in_progress || 0, pct: totalOrders > 0 ? Math.round(((t.in_progress || 0) / totalOrders) * 100) : 0, color: '#FFC000', bg: 'bg-warning-light text-amber-700' },
              { label: 'Draft', count: t.draft || 0, pct: totalOrders > 0 ? Math.round(((t.draft || 0) / totalOrders) * 100) : 0, color: '#A3A3A3', bg: 'bg-gray-100 text-gray-700' },
            ].map((s) => (
              <div key={s.label} className="mb-3">
                <div className="flex justify-between text-xs mb-1"><span className={`inline-flex items-center gap-1 rounded-full px-2 py-0.5 text-[11px] font-semibold ${s.bg}`}><span className="h-1.5 w-1.5 rounded-full bg-current" />{s.label} ({s.count})</span><strong>{s.pct}%</strong></div>
                <div className="h-2 bg-gray-100 rounded-full overflow-hidden"><div className="h-full rounded-full" style={{ width: `${s.pct}%`, backgroundColor: s.color }} /></div>
              </div>
            ))}
          </CardContent>
        </Card>
      </div>

      {/* Top 5 Tables */}
      <div className="grid lg:grid-cols-2 gap-5">
        <Card>
          <CardHeader><CardTitle>Top 5 Customer</CardTitle></CardHeader>
          <CardContent>
            <div className="overflow-x-auto rounded-[10px] border border-gray-200">
              <table className="w-full border-collapse">
                <thead className="bg-gray-50 border-b border-gray-200"><tr><th className="px-3 py-2 text-left text-[11px] font-bold text-gray-500 uppercase">#</th><th className="px-3 py-2 text-left text-[11px] font-bold text-gray-500 uppercase">Customer</th><th className="px-3 py-2 text-right text-[11px] font-bold text-gray-500 uppercase">PO</th><th className="px-3 py-2 text-right text-[11px] font-bold text-gray-500 uppercase">Revenue</th></tr></thead>
                <tbody>{customers.slice(0, 5).map((c: any, i: number) => (<tr key={c.id} className="border-b border-gray-100 last:border-b-0"><td className="px-3 py-2.5 text-[13px]">{i + 1}</td><td className="px-3 py-2.5 text-[13px] font-semibold">{c.name}</td><td className="px-3 py-2.5 text-right text-[13px]">{c.total_orders ?? 0}</td><td className="px-3 py-2.5 text-right text-[13px] font-semibold tabular-nums">{formatRupiah(c.total_revenue)}</td></tr>))}</tbody>
              </table>
            </div>
          </CardContent>
        </Card>
        <Card>
          <CardHeader><CardTitle>Top 5 Produk</CardTitle></CardHeader>
          <CardContent>
            {products.length > 0 ? (
              <div className="overflow-x-auto rounded-[10px] border border-gray-200">
                <table className="w-full border-collapse">
                  <thead className="bg-gray-50 border-b border-gray-200"><tr><th className="px-3 py-2 text-left text-[11px] font-bold text-gray-500 uppercase">#</th><th className="px-3 py-2 text-left text-[11px] font-bold text-gray-500 uppercase">Produk</th><th className="px-3 py-2 text-right text-[11px] font-bold text-gray-500 uppercase">Terjual</th><th className="px-3 py-2 text-right text-[11px] font-bold text-gray-500 uppercase">Revenue</th></tr></thead>
                  <tbody>{products.map((p: any, i: number) => (<tr key={p.id || i} className="border-b border-gray-100 last:border-b-0"><td className="px-3 py-2.5 text-[13px]">{i + 1}</td><td className="px-3 py-2.5 text-[13px] font-semibold">{p.name}</td><td className="px-3 py-2.5 text-right text-[13px]">{p.total_qty ?? 0}</td><td className="px-3 py-2.5 text-right text-[13px] font-semibold tabular-nums">{formatRupiah(p.total_revenue)}</td></tr>))}</tbody>
                </table>
              </div>
            ) : (
              <div className="text-center py-8 text-[13px] text-gray-500">Data akan tersedia setelah ada transaksi</div>
            )}
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
