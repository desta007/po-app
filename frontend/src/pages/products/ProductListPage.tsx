import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { productsApi } from '@/api/products';
import { PageHeader } from '@/components/layout/page-header';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Card } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Dialog, DialogContent, DialogHeader, DialogTitle } from '@/components/ui/dialog';
import { EmptyState } from '@/components/ui/empty-state';
import { Plus, Search, Package, Download } from 'lucide-react';
import { useState } from 'react';
import { formatRupiah } from '@/lib/utils';
import { toast } from 'sonner';
import type { Product } from '@/types/product';

const CATEGORY_GRADIENTS: Record<string, string> = {
  'Kue': 'linear-gradient(135deg, #FFEEC7 0%, #F4C57B 100%)',
  'Cookies': 'linear-gradient(135deg, #FFE0E0 0%, #FFB8B8 100%)',
  'Catering': 'linear-gradient(135deg, #E8F3E0 0%, #A8D080 100%)',
  'Pastry': 'linear-gradient(135deg, #FFE8D6 0%, #F5B989 100%)',
  'default': 'linear-gradient(135deg, #E0F0FF 0%, #A8D0F4 100%)',
};

const CATEGORY_EMOJIS: Record<string, string> = {
  'Kue': '🎂',
  'Cookies': '🍪',
  'Catering': '🥗',
  'Pastry': '🥐',
  'default': '📦',
};

function getStockBadge(qty: number) {
  if (qty === 0) return <Badge variant="danger" dot>Stock 0</Badge>;
  if (qty <= 5) return <Badge variant="warning" dot>Stock {qty}</Badge>;
  return <Badge variant="success" dot>Stock {qty}</Badge>;
}

export default function ProductListPage() {
  const queryClient = useQueryClient();
  const [search, setSearch] = useState('');
  const [categoryFilter, setCategoryFilter] = useState('');
  const [dialogOpen, setDialogOpen] = useState(false);
  const [form, setForm] = useState({ name: '', sku: '', price: 0, unit: 'pcs', category: '', stock_qty: 0 });

  const { data, isLoading } = useQuery({
    queryKey: ['products', search],
    queryFn: () => productsApi.list({ search }),
  });

  const createProduct = useMutation({
    mutationFn: (data: any) => productsApi.create(data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['products'] });
      setDialogOpen(false);
      setForm({ name: '', sku: '', price: 0, unit: 'pcs', category: '', stock_qty: 0 });
      toast.success('Produk berhasil ditambahkan.');
    },
    onError: (err: any) => toast.error(err.response?.data?.message || 'Gagal.'),
  });

  const products: Product[] = data?.data?.data || [];
  const categories = [...new Set(products.map(p => p.category).filter(Boolean))];

  return (
    <div>
      <PageHeader
        title="Produk"
        description={`${products.length} produk aktif${categories.length > 0 ? ` · ${categories.length} kategori` : ''}`}
        actions={
          <div className="flex gap-2">
            <Button variant="secondary"><Download size={15} /> Import CSV</Button>
            <Button onClick={() => setDialogOpen(true)}><Plus size={15} /> Produk Baru</Button>
          </div>
        }
      />

      {/* Filter bar */}
      <div className="flex gap-2.5 mb-5 flex-wrap">
        <div className="flex-1 min-w-[240px] relative">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" size={16} />
          <input
            className="w-full pl-10 pr-3 py-2.5 border border-gray-300 rounded-[6px] text-[14px] bg-white text-gray-900 placeholder:text-gray-400 focus:outline-none focus:border-primary focus:ring-3 focus:ring-primary-50"
            placeholder="Cari produk..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
          />
        </div>
        <select
          className="px-3 py-2.5 border border-gray-300 rounded-[6px] text-[14px] bg-white text-gray-900 focus:outline-none focus:border-primary"
          value={categoryFilter || ''}
          onChange={(e) => setCategoryFilter(e.target.value)}
        >
          <option value="">Semua kategori</option>
          {categories.map(c => <option key={c || 'empty'} value={c || ''}>{c || 'Tanpa Kategori'}</option>)}
        </select>
      </div>

      {products.length === 0 && !isLoading ? (
        <EmptyState icon={<Package size={48} />} title="Belum ada produk" description="Tambahkan produk pertama Anda" />
      ) : (
        <div className="grid sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
          {products
            .filter(p => !categoryFilter || p.category === categoryFilter)
            .map((p) => {
              const cat = p.category || 'default';
              const gradient = CATEGORY_GRADIENTS[cat] || CATEGORY_GRADIENTS['default'];
              const emoji = CATEGORY_EMOJIS[cat] || CATEGORY_EMOJIS['default'];
              return (
                <Card key={p.id} padding="none" className="overflow-hidden hover:shadow-md transition-shadow cursor-pointer">
                  <div
                    className="h-[140px] flex items-center justify-center text-5xl"
                    style={{ background: gradient }}
                  >
                    {emoji}
                  </div>
                  <div className="p-3.5">
                    <div className="text-[11px] text-gray-500 uppercase font-semibold tracking-wider">
                      {p.category || 'Tanpa kategori'}
                    </div>
                    <div className="font-bold text-[14px] text-gray-900 mt-1 mb-2">{p.name}</div>
                    <div className="flex items-center justify-between">
                      <span className="font-bold text-primary">{formatRupiah(p.price)}</span>
                      {getStockBadge(p.stock_qty ?? 0)}
                    </div>
                  </div>
                </Card>
              );
            })}

          {/* Add product card */}
          <div
            onClick={() => setDialogOpen(true)}
            className="rounded-[10px] border-2 border-dashed border-gray-300 flex items-center justify-center min-h-[220px] cursor-pointer hover:border-gray-400 hover:bg-gray-50 transition-colors"
          >
            <div className="text-center text-gray-500">
              <div className="text-3xl mb-1">+</div>
              <div className="text-[13px] font-semibold">Tambah Produk</div>
            </div>
          </div>
        </div>
      )}

      <Dialog open={dialogOpen} onOpenChange={setDialogOpen}>
        <DialogContent>
          <DialogHeader><DialogTitle>Tambah Produk</DialogTitle></DialogHeader>
          <form onSubmit={(e) => { e.preventDefault(); createProduct.mutate(form); }} className="space-y-3">
            <Input label="Nama Produk *" value={form.name} onChange={(e) => setForm({...form, name: e.target.value})} required />
            <Input label="SKU" value={form.sku} onChange={(e) => setForm({...form, sku: e.target.value})} />
            <Input label="Harga *" type="number" value={form.price} onChange={(e) => setForm({...form, price: Number(e.target.value)})} required />
            <Input label="Kategori" value={form.category} onChange={(e) => setForm({...form, category: e.target.value})} />
            <Input label="Stok" type="number" value={form.stock_qty} onChange={(e) => setForm({...form, stock_qty: Number(e.target.value)})} />
            <div className="flex justify-end gap-2 pt-2">
              <Button variant="secondary" type="button" onClick={() => setDialogOpen(false)}>Batal</Button>
              <Button type="submit" loading={createProduct.isPending}>Simpan</Button>
            </div>
          </form>
        </DialogContent>
      </Dialog>
    </div>
  );
}
