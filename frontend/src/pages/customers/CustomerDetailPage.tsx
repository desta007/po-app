import { useParams, Link } from 'react-router-dom';
import { useQuery } from '@tanstack/react-query';
import { customersApi } from '@/api/customers';
import { Button } from '@/components/ui/button';
import { Card } from '@/components/ui/card';
import { Skeleton } from '@/components/ui/skeleton';
import { formatRupiah, getInitials } from '@/lib/utils';
import { MessageCircle, Edit, Plus } from 'lucide-react';
import { useNavigate } from 'react-router-dom';

export default function CustomerDetailPage() {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const { data, isLoading } = useQuery({ queryKey: ['customer', id], queryFn: () => customersApi.show(id!), enabled: !!id });

  if (isLoading) return <Skeleton className="h-64 rounded-[10px]" />;
  const c = data?.data?.data || data?.data;
  if (!c) return <p className="text-gray-500">Pelanggan tidak ditemukan.</p>;

  return (
    <div>
      <div className="mb-4"><Link to="/pelanggan" className="text-xs text-gray-500 hover:text-primary">← Kembali ke daftar customer</Link></div>

      {/* Profile Card */}
      <Card className="mb-4">
        <div className="flex gap-4 items-center flex-wrap">
          <div className="w-16 h-16 rounded-full bg-primary text-white flex items-center justify-center font-bold text-2xl flex-shrink-0">{getInitials((c as any).name || '?')}</div>
          <div className="flex-1 min-w-0">
            <div className="flex items-center gap-2 mb-1"><h2 className="text-[22px] font-bold text-gray-900">{(c as any).name}</h2></div>
            <div className="text-[13px] text-gray-500">📱 {(c as any).phone || '-'} · ✉️ {(c as any).email || '-'} · 📍 {(c as any).address || '-'}</div>
          </div>
          <div className="flex gap-2">
            <Button variant="secondary"><MessageCircle size={15} /> Kirim WA</Button>
            <Button variant="secondary"><Edit size={15} /> Edit</Button>
            <Button onClick={() => navigate('/pesanan/baru')}><Plus size={15} /> PO Baru</Button>
          </div>
        </div>
      </Card>

      {/* Stats Grid */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4 mb-5">
        {[
          { label: 'Total Order', value: (c as any).total_orders ?? 0, sub: 'Sejak bergabung', up: true },
          { label: 'Total Revenue', value: formatRupiah((c as any).total_revenue ?? 0), sub: `Avg ${formatRupiah((c as any).total_orders ? ((c as any).total_revenue / (c as any).total_orders) : 0)}/PO`, up: true },
          { label: 'Last Order', value: (c as any).last_order_date ? new Date((c as any).last_order_date).toLocaleDateString('id-ID', { day: 'numeric', month: 'short' }) : '-', sub: '', up: true },
          { label: 'Outstanding', value: formatRupiah((c as any).outstanding ?? 0), sub: `${(c as any).pending_orders ?? 0} PO pending`, up: false },
        ].map((s) => (
          <Card key={s.label} padding="none" className="p-4">
            <div className="text-xs text-gray-500 font-medium">{s.label}</div>
            <div className="text-[22px] font-extrabold text-gray-900 mt-1">{s.value}</div>
            {s.sub && <div className={`text-[11px] mt-1 font-semibold ${s.up ? 'text-accent' : 'text-danger'}`}>{s.sub}</div>}
          </Card>
        ))}
      </div>

      {/* Info Card */}
      <Card>
        <h3 className="text-[14px] font-bold mb-3">Informasi</h3>
        <div className="grid sm:grid-cols-2 gap-3 text-[13px]">
          <div><span className="text-gray-500">Email</span><p className="font-medium text-gray-900">{(c as any).email || '-'}</p></div>
          <div><span className="text-gray-500">Telepon</span><p className="font-medium text-gray-900">{(c as any).phone || '-'}</p></div>
          <div><span className="text-gray-500">Alamat</span><p className="font-medium text-gray-900">{(c as any).address || '-'}</p></div>
          <div><span className="text-gray-500">Catatan</span><p className="font-medium text-gray-900">{(c as any).notes || '-'}</p></div>
        </div>
      </Card>
    </div>
  );
}
