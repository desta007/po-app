import { useState } from 'react';
import { useQuery } from '@tanstack/react-query';
import { dashboardApi } from '@/api/dashboard';
import { PageHeader } from '@/components/layout/page-header';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Skeleton } from '@/components/ui/skeleton';
import { formatRupiah } from '@/lib/utils';
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, Legend } from 'recharts';
import { DollarSign, TrendingUp, TrendingDown, ShoppingCart } from 'lucide-react';

export default function ProfitReportPage() {
  const [period, setPeriod] = useState<'daily' | 'monthly'>('monthly');
  const [dateRange, setDateRange] = useState(() => {
    const now = new Date();
    const start = new Date(now.getFullYear(), now.getMonth() - 2, 1);
    return {
      start: start.toISOString().split('T')[0],
      end: now.toISOString().split('T')[0],
    };
  });

  const { data, isLoading } = useQuery({
    queryKey: ['profit-report', period, dateRange],
    queryFn: () => dashboardApi.profitReport({ period, start: dateRange.start, end: dateRange.end }),
  });

  const report: any = data?.data || {};
  const chartData: any[] = report.chart || [];
  const summary: any = report.summary || {};
  const topProducts: any[] = report.top_products || [];

  const totalRevenue = parseFloat(summary.total_revenue) || 0;
  const totalCost = parseFloat(summary.total_cost) || 0;
  const totalProfit = parseFloat(summary.total_profit) || 0;
  const totalOrders = summary.total_orders || 0;
  const marginPct = totalRevenue > 0 ? ((totalProfit / totalRevenue) * 100).toFixed(1) : '0';

  return (
    <div>
      <PageHeader
        title="Laporan Pendapatan & Laba"
        description="Analisis pendapatan, biaya pokok, dan laba kotor"
        actions={
          <div className="flex gap-2">
            <select
              className="px-3 py-2.5 border border-gray-300 rounded-[6px] text-[14px] bg-white focus:outline-none focus:border-primary"
              value={period}
              onChange={(e) => setPeriod(e.target.value as 'daily' | 'monthly')}
            >
              <option value="daily">Harian</option>
              <option value="monthly">Bulanan</option>
            </select>
            <input
              type="date"
              className="px-3 py-2.5 border border-gray-300 rounded-[6px] text-[14px] bg-white focus:outline-none focus:border-primary"
              value={dateRange.start}
              onChange={(e) => setDateRange(prev => ({ ...prev, start: e.target.value }))}
            />
            <input
              type="date"
              className="px-3 py-2.5 border border-gray-300 rounded-[6px] text-[14px] bg-white focus:outline-none focus:border-primary"
              value={dateRange.end}
              onChange={(e) => setDateRange(prev => ({ ...prev, end: e.target.value }))}
            />
          </div>
        }
      />

      {/* Summary Cards */}
      {isLoading ? (
        <div className="grid grid-cols-2 lg:grid-cols-4 gap-4 mb-6">
          {[1, 2, 3, 4].map(i => <Skeleton key={i} className="h-28 w-full rounded-[10px]" />)}
        </div>
      ) : (
        <div className="grid grid-cols-2 lg:grid-cols-4 gap-4 mb-6">
          <Card padding="none" className="p-4">
            <div className="w-9 h-9 rounded-[6px] flex items-center justify-center mb-2.5 bg-primary-50 text-primary">
              <DollarSign size={18} />
            </div>
            <div className="text-xs text-gray-500 font-medium">Total Pendapatan</div>
            <div className="text-[22px] font-extrabold text-gray-900 mt-1" style={{ letterSpacing: '-0.02em' }}>
              {formatRupiah(totalRevenue)}
            </div>
            <div className="text-[11px] mt-1.5 font-semibold text-gray-400">{totalOrders} pesanan</div>
          </Card>

          <Card padding="none" className="p-4">
            <div className="w-9 h-9 rounded-[6px] flex items-center justify-center mb-2.5 bg-red-50 text-red-600">
              <TrendingDown size={18} />
            </div>
            <div className="text-xs text-gray-500 font-medium">Total Biaya Pokok</div>
            <div className="text-[22px] font-extrabold text-gray-900 mt-1" style={{ letterSpacing: '-0.02em' }}>
              {formatRupiah(totalCost)}
            </div>
            <div className="text-[11px] mt-1.5 font-semibold text-red-500">
              {totalRevenue > 0 ? ((totalCost / totalRevenue) * 100).toFixed(1) : 0}% dari pendapatan
            </div>
          </Card>

          <Card padding="none" className="p-4">
            <div className="w-9 h-9 rounded-[6px] flex items-center justify-center mb-2.5 bg-accent-light text-accent">
              <TrendingUp size={18} />
            </div>
            <div className="text-xs text-gray-500 font-medium">Laba Kotor</div>
            <div className="text-[22px] font-extrabold text-gray-900 mt-1" style={{ letterSpacing: '-0.02em' }}>
              {formatRupiah(totalProfit)}
            </div>
            <div className={`text-[11px] mt-1.5 font-semibold ${totalProfit >= 0 ? 'text-accent' : 'text-danger'}`}>
              Margin {marginPct}%
            </div>
          </Card>

          <Card padding="none" className="p-4">
            <div className="w-9 h-9 rounded-[6px] flex items-center justify-center mb-2.5 bg-warning-light text-amber-700">
              <ShoppingCart size={18} />
            </div>
            <div className="text-xs text-gray-500 font-medium">Rata-rata Laba / PO</div>
            <div className="text-[22px] font-extrabold text-gray-900 mt-1" style={{ letterSpacing: '-0.02em' }}>
              {formatRupiah(totalOrders > 0 ? totalProfit / totalOrders : 0)}
            </div>
            <div className="text-[11px] mt-1.5 font-semibold text-gray-400">{totalOrders} pesanan</div>
          </Card>
        </div>
      )}

      {/* Chart */}
      <div className="grid lg:grid-cols-3 gap-5 mb-5">
        <Card className="lg:col-span-2">
          <CardHeader><CardTitle>Trend Pendapatan & Laba</CardTitle></CardHeader>
          <CardContent>
            {isLoading ? (
              <Skeleton className="h-56 w-full rounded-[10px]" />
            ) : (
              <div className="h-64">
                <ResponsiveContainer width="100%" height="100%">
                  <BarChart data={chartData}>
                    <CartesianGrid strokeDasharray="3 3" stroke="#E5E5E5" />
                    <XAxis
                      dataKey="date"
                      tick={{ fontSize: 10, fill: '#737373' }}
                      tickFormatter={(v: string) => {
                        if (period === 'monthly' && v.length === 7) {
                          const parts = v.split('-');
                          const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
                          return `${months[parseInt(parts[1] as string) - 1]} ${parts[0]}`;
                        }
                        return v;
                      }}
                    />
                    <YAxis tick={{ fontSize: 10, fill: '#737373' }} tickFormatter={(v: number) => `${(v / 1000000).toFixed(1)}jt`} />
                    <Tooltip
                      formatter={(value: number, name: string) => [
                        formatRupiah(value),
                        name === 'revenue' ? 'Pendapatan' : name === 'profit' ? 'Laba' : 'Biaya Pokok',
                      ]}
                      labelFormatter={(label: string) => {
                        if (period === 'monthly' && label.length === 7) {
                          const parts = label.split('-');
                          const months = ['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
                          return `${months[parseInt(parts[1] as string) - 1]} ${parts[0]}`;
                        }
                        return label;
                      }}
                    />
                    <Legend
                      formatter={(value: string) =>
                        value === 'revenue' ? 'Pendapatan' : value === 'profit' ? 'Laba' : 'Biaya Pokok'
                      }
                    />
                    <Bar dataKey="revenue" fill="#2E75B6" radius={[4, 4, 0, 0]} name="revenue" />
                    <Bar dataKey="profit" fill="#70AD47" radius={[4, 4, 0, 0]} name="profit" />
                  </BarChart>
                </ResponsiveContainer>
              </div>
            )}
          </CardContent>
        </Card>

        {/* Margin Summary */}
        <Card>
          <CardHeader><CardTitle>Ringkasan Margin</CardTitle></CardHeader>
          <CardContent>
            <div className="space-y-4">
              <div>
                <div className="flex justify-between text-xs mb-1">
                  <span className="text-gray-500">Pendapatan</span>
                  <strong>{formatRupiah(totalRevenue)}</strong>
                </div>
                <div className="h-2.5 bg-gray-100 rounded-full overflow-hidden">
                  <div className="h-full rounded-full bg-primary" style={{ width: '100%' }} />
                </div>
              </div>
              <div>
                <div className="flex justify-between text-xs mb-1">
                  <span className="text-gray-500">Biaya Pokok</span>
                  <strong className="text-red-600">{formatRupiah(totalCost)}</strong>
                </div>
                <div className="h-2.5 bg-gray-100 rounded-full overflow-hidden">
                  <div className="h-full rounded-full bg-red-400" style={{ width: totalRevenue > 0 ? `${(totalCost / totalRevenue) * 100}%` : '0%' }} />
                </div>
              </div>
              <div>
                <div className="flex justify-between text-xs mb-1">
                  <span className="text-gray-500">Laba Kotor</span>
                  <strong className="text-accent">{formatRupiah(totalProfit)}</strong>
                </div>
                <div className="h-2.5 bg-gray-100 rounded-full overflow-hidden">
                  <div className="h-full rounded-full bg-accent" style={{ width: totalRevenue > 0 ? `${(totalProfit / totalRevenue) * 100}%` : '0%' }} />
                </div>
              </div>
              <div className="pt-3 border-t border-gray-100">
                <div className="text-center">
                  <div className="text-xs text-gray-500 mb-1">Margin Laba Kotor</div>
                  <div className={`text-3xl font-extrabold ${totalProfit >= 0 ? 'text-accent' : 'text-danger'}`}>
                    {marginPct}%
                  </div>
                </div>
              </div>
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Top Products by Profit */}
      <Card>
        <CardHeader><CardTitle>Top Produk berdasarkan Laba</CardTitle></CardHeader>
        <CardContent>
          {isLoading ? (
            <Skeleton className="h-40 w-full rounded-[10px]" />
          ) : topProducts.length > 0 ? (
            <div className="overflow-x-auto rounded-[10px] border border-gray-200">
              <table className="w-full border-collapse">
                <thead className="bg-gray-50 border-b border-gray-200">
                  <tr>
                    <th className="px-3 py-2 text-left text-[11px] font-bold text-gray-500 uppercase">#</th>
                    <th className="px-3 py-2 text-left text-[11px] font-bold text-gray-500 uppercase">Produk</th>
                    <th className="px-3 py-2 text-right text-[11px] font-bold text-gray-500 uppercase">Qty</th>
                    <th className="px-3 py-2 text-right text-[11px] font-bold text-gray-500 uppercase">Pendapatan</th>
                    <th className="px-3 py-2 text-right text-[11px] font-bold text-gray-500 uppercase">Biaya Pokok</th>
                    <th className="px-3 py-2 text-right text-[11px] font-bold text-gray-500 uppercase">Laba</th>
                    <th className="px-3 py-2 text-right text-[11px] font-bold text-gray-500 uppercase">Margin</th>
                  </tr>
                </thead>
                <tbody>
                  {topProducts.map((p: any, i: number) => {
                    const rev = parseFloat(p.revenue) || 0;
                    const cost = parseFloat(p.cost) || 0;
                    const profit = parseFloat(p.profit) || 0;
                    const margin = rev > 0 ? ((profit / rev) * 100).toFixed(1) : '0';
                    return (
                      <tr key={i} className="border-b border-gray-100 last:border-b-0">
                        <td className="px-3 py-2.5 text-[13px] text-gray-500">{i + 1}</td>
                        <td className="px-3 py-2.5 text-[13px] font-semibold text-gray-900">{p.name}</td>
                        <td className="px-3 py-2.5 text-right text-[13px]">{parseFloat(p.total_qty)}</td>
                        <td className="px-3 py-2.5 text-right text-[13px] tabular-nums">{formatRupiah(rev)}</td>
                        <td className="px-3 py-2.5 text-right text-[13px] tabular-nums text-red-600">{formatRupiah(cost)}</td>
                        <td className="px-3 py-2.5 text-right text-[13px] font-semibold tabular-nums text-accent">{formatRupiah(profit)}</td>
                        <td className="px-3 py-2.5 text-right text-[13px] font-semibold">
                          <span className={`inline-flex items-center rounded-full px-2 py-0.5 text-[11px] font-semibold ${
                            parseFloat(margin) >= 30
                              ? 'bg-green-50 text-accent'
                              : parseFloat(margin) >= 15
                              ? 'bg-amber-50 text-amber-700'
                              : 'bg-red-50 text-red-600'
                          }`}>
                            {margin}%
                          </span>
                        </td>
                      </tr>
                    );
                  })}
                </tbody>
              </table>
            </div>
          ) : (
            <div className="text-center py-8 text-[13px] text-gray-500">
              Belum ada data. Pastikan produk memiliki harga pokok dan ada PO yang sudah selesai.
            </div>
          )}
        </CardContent>
      </Card>
    </div>
  );
}
