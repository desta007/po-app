import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { customersApi } from '@/api/customers';
import { PageHeader } from '@/components/layout/page-header';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Dialog, DialogContent, DialogHeader, DialogTitle } from '@/components/ui/dialog';
import { EmptyState } from '@/components/ui/empty-state';
import { Skeleton } from '@/components/ui/skeleton';
import { Plus, Search, Users, ChevronLeft, ChevronRight } from 'lucide-react';
import { useState } from 'react';
import { useNavigate, useSearchParams } from 'react-router-dom';
import { formatRupiah, getInitials } from '@/lib/utils';
import { toast } from 'sonner';
import type { Customer } from '@/types/customer';

const AVATAR_COLORS = ['#1F4E79', '#70AD47', '#FFC000', '#8E44AD', '#E74C3C', '#2E75B6', '#C00000'];

export default function CustomerListPage() {
  const navigate = useNavigate();
  const queryClient = useQueryClient();
  const [searchParams, setSearchParams] = useSearchParams();
  const [search, setSearch] = useState('');
  const [dialogOpen, setDialogOpen] = useState(false);
  const [form, setForm] = useState({ name: '', phone: '', email: '', address: '', notes: '' });

  const page = Number(searchParams.get('page') || '1');

  const { data, isLoading } = useQuery({
    queryKey: ['customers', { search, page }],
    queryFn: () => customersApi.list({ search, page, per_page: 20 }),
  });

  const goToPage = (p: number) => {
    const params = new URLSearchParams(searchParams);
    params.set('page', String(p));
    setSearchParams(params);
  };

  const createCustomer = useMutation({
    mutationFn: (data: any) => customersApi.create(data),
    onSuccess: async () => {
      await queryClient.invalidateQueries({ queryKey: ['customers'], refetchType: 'all' });
      setDialogOpen(false);
      setForm({ name: '', phone: '', email: '', address: '', notes: '' });
      toast.success('Pelanggan berhasil ditambahkan.');
    },
    onError: (err: any) => toast.error(err.response?.data?.message || 'Gagal.'),
  });

  const customers: Customer[] = data?.data?.data || [];
  const meta: any = data?.data?.meta;

  // Build pagination page numbers with ellipsis
  const buildPageNumbers = () => {
    if (!meta || meta.last_page <= 1) return [];
    const pages: (number | 'ellipsis')[] = [];
    const total = meta.last_page;
    const current = meta.current_page;

    pages.push(1);
    if (current > 3) pages.push('ellipsis');
    for (let i = Math.max(2, current - 1); i <= Math.min(total - 1, current + 1); i++) {
      pages.push(i);
    }
    if (current < total - 2) pages.push('ellipsis');
    if (total > 1) pages.push(total);

    return pages;
  };

  return (
    <div>
      <PageHeader title="Customer" description={meta ? `${meta.total} customer terdaftar` : 'Kelola data customer'} actions={<Button onClick={() => setDialogOpen(true)}><Plus size={15} /> Tambah Customer</Button>} />

      <div className="relative max-w-sm mb-4">
        <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" size={16} />
        <input className="w-full pl-10 pr-3 py-2.5 border border-gray-300 rounded-[6px] text-[14px] bg-white placeholder:text-gray-400 focus:outline-none focus:border-primary focus:ring-3 focus:ring-primary-50" placeholder="Cari customer..." value={search} onChange={(e) => { setSearch(e.target.value); goToPage(1); }} />
      </div>

      {isLoading ? (
        <div className="space-y-2">
          {[1, 2, 3, 4, 5].map((i) => <Skeleton key={i} className="h-[68px] w-full rounded-[10px]" />)}
        </div>
      ) : customers.length === 0 ? (
        <EmptyState icon={<Users size={48} />} title="Belum ada customer" description="Tambahkan customer pertama Anda" />
      ) : (
        <>
          <div className="space-y-2">
            {customers.map((c, i) => (
              <div key={c.id} onClick={() => navigate(`/pelanggan/${c.id}`)} className="bg-white px-4 py-3.5 rounded-[10px] flex items-center gap-3 cursor-pointer hover:shadow-md transition-shadow border border-gray-100">
                <div className="w-10 h-10 rounded-[6px] flex items-center justify-center text-white font-bold text-sm flex-shrink-0" style={{ backgroundColor: AVATAR_COLORS[i % AVATAR_COLORS.length] }}>
                  {getInitials(c.name)}
                </div>
                <div className="flex-1 min-w-0">
                  <div className="font-semibold text-[14px] text-gray-900">{c.name}</div>
                  <div className="text-[11px] text-gray-500">{c.phone || '-'} · {c.total_orders} PO · {formatRupiah(c.total_revenue)}</div>
                </div>
                <span className="text-gray-400 text-lg">›</span>
              </div>
            ))}
          </div>

          {/* Pagination */}
          {meta && meta.last_page > 1 && (
            <div className="flex items-center justify-between mt-4">
              <div className="text-xs text-gray-500">
                Menampilkan {meta.from}–{meta.to} dari {meta.total} customer
              </div>
              <div className="flex items-center gap-1">
                <button
                  onClick={() => goToPage(Math.max(1, page - 1))}
                  disabled={page <= 1}
                  className="px-2 py-1.5 rounded-[6px] text-xs font-semibold bg-white text-gray-700 border border-gray-300 hover:bg-gray-50 disabled:opacity-40 disabled:cursor-not-allowed flex items-center"
                >
                  <ChevronLeft size={14} />
                </button>

                {buildPageNumbers().map((p, idx) =>
                  p === 'ellipsis' ? (
                    <span key={`e-${idx}`} className="px-1.5 text-xs text-gray-400">…</span>
                  ) : (
                    <button
                      key={p}
                      onClick={() => goToPage(p)}
                      className={`px-2.5 py-1.5 rounded-[6px] text-xs font-semibold ${
                        meta.current_page === p
                          ? 'bg-primary text-white'
                          : 'bg-white text-gray-700 border border-gray-300 hover:bg-gray-50'
                      }`}
                    >
                      {p}
                    </button>
                  )
                )}

                <button
                  onClick={() => goToPage(Math.min(meta.last_page, page + 1))}
                  disabled={page >= meta.last_page}
                  className="px-2 py-1.5 rounded-[6px] text-xs font-semibold bg-white text-gray-700 border border-gray-300 hover:bg-gray-50 disabled:opacity-40 disabled:cursor-not-allowed flex items-center"
                >
                  <ChevronRight size={14} />
                </button>
              </div>
            </div>
          )}
        </>
      )}

      <Dialog open={dialogOpen} onOpenChange={setDialogOpen}>
        <DialogContent>
          <DialogHeader><DialogTitle>Tambah Customer</DialogTitle></DialogHeader>
          <form onSubmit={(e) => { e.preventDefault(); createCustomer.mutate(form); }} className="space-y-3">
            <Input label="Nama *" value={form.name} onChange={(e) => setForm({...form, name: e.target.value})} required />
            <Input label="No. WhatsApp" value={form.phone} onChange={(e) => setForm({...form, phone: e.target.value})} />
            <Input label="Email" type="email" value={form.email} onChange={(e) => setForm({...form, email: e.target.value})} />
            <Input label="Alamat" value={form.address} onChange={(e) => setForm({...form, address: e.target.value})} />
            <div className="flex justify-end gap-2 pt-2">
              <Button variant="secondary" type="button" onClick={() => setDialogOpen(false)}>Batal</Button>
              <Button type="submit" loading={createCustomer.isPending}>Simpan</Button>
            </div>
          </form>
        </DialogContent>
      </Dialog>
    </div>
  );
}
