import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { productsApi } from '@/api/products';
import { PageHeader } from '@/components/layout/page-header';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Card } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Dialog, DialogContent, DialogHeader, DialogTitle } from '@/components/ui/dialog';
import { EmptyState } from '@/components/ui/empty-state';
import { Plus, Search, Package, Download, Trash2, Image as ImageIcon, Upload, Globe, X, Boxes } from 'lucide-react';
import { useState, useRef } from 'react';
import { formatRupiah, storageUrl } from '@/lib/utils';
import { toast } from 'sonner';
import { useQuota } from '@/hooks/use-quota';
import { Crown } from 'lucide-react';
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

const EMPTY_FORM = { name: '', sku: '', description: '', price: 0, cost: 0, unit: 'pcs', category: '', stock_qty: 0, track_stock: true, show_in_catalog: true };

export default function ProductListPage() {
  const queryClient = useQueryClient();
  const { productUsage, isPremiumOrAdmin } = useQuota();
  const [search, setSearch] = useState('');
  const [categoryFilter, setCategoryFilter] = useState('');
  const [dialogOpen, setDialogOpen] = useState(false);
  const [editingProduct, setEditingProduct] = useState<Product | null>(null);
  const [form, setForm] = useState(EMPTY_FORM);
  const [uploadingImage, setUploadingImage] = useState(false);
  const [pendingImageFiles, setPendingImageFiles] = useState<File[]>([]);
  const [pendingImagePreviews, setPendingImagePreviews] = useState<string[]>([]);
  const fileInputRef = useRef<HTMLInputElement>(null);

  const { data, isLoading } = useQuery({
    queryKey: ['products', search],
    queryFn: () => productsApi.list({ search }),
  });

  const createProduct = useMutation({
    mutationFn: (data: any) => productsApi.create(data),
    onSuccess: async (res) => {
      const newProduct = res.data?.data;
      if (pendingImageFiles.length > 0 && newProduct?.id) {
        try {
          await productsApi.uploadImages(newProduct.id, pendingImageFiles);
        } catch {
          toast.error('Produk dibuat, tapi gagal upload gambar.');
        }
      }
      queryClient.invalidateQueries({ queryKey: ['products'] });
      queryClient.invalidateQueries({ queryKey: ['quota-usage'] });
      closeDialog();
      toast.success('Produk berhasil ditambahkan.');
    },
    onError: (err: any) => toast.error(err.response?.data?.message || 'Gagal menambahkan produk.'),
  });

  const updateProduct = useMutation({
    mutationFn: ({ id, data }: { id: string; data: any }) => productsApi.update(id, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['products'] });
      closeDialog();
      toast.success('Produk berhasil diperbarui.');
    },
    onError: (err: any) => toast.error(err.response?.data?.message || 'Gagal memperbarui produk.'),
  });

  const deleteProduct = useMutation({
    mutationFn: (id: string) => productsApi.delete(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['products'] });
      closeDialog();
      toast.success('Produk berhasil dihapus.');
    },
    onError: (err: any) => toast.error(err.response?.data?.message || 'Gagal menghapus produk.'),
  });

  const handleImageUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const files = Array.from(e.target.files ?? []);
    if (files.length === 0) return;

    if (editingProduct) {
      // Edit mode: upload langsung ke server
      setUploadingImage(true);
      try {
        const res = await productsApi.uploadImages(editingProduct.id, files);
        queryClient.invalidateQueries({ queryKey: ['products'] });
        setEditingProduct({
          ...editingProduct,
          image_url: res.data.data.image_url,
          images: res.data.data.images,
        });
        toast.success(files.length > 1 ? `${files.length} gambar berhasil diupload.` : 'Gambar berhasil diupload.');
      } catch (err: any) {
        toast.error(err.response?.data?.message || 'Gagal upload gambar.');
      } finally {
        setUploadingImage(false);
        if (fileInputRef.current) fileInputRef.current.value = '';
      }
    } else {
      // Create mode: simpan file, upload setelah produk dibuat
      setPendingImageFiles(prev => [...prev, ...files]);
      setPendingImagePreviews(prev => [...prev, ...files.map(f => URL.createObjectURL(f))]);
      if (fileInputRef.current) fileInputRef.current.value = '';
    }
  };

  const handleRemoveExistingImage = async (imageUrl: string) => {
    if (!editingProduct) return;
    try {
      const res = await productsApi.deleteImage(editingProduct.id, imageUrl);
      queryClient.invalidateQueries({ queryKey: ['products'] });
      setEditingProduct({
        ...editingProduct,
        image_url: res.data.data.image_url,
        images: res.data.data.images,
      });
      toast.success('Gambar berhasil dihapus.');
    } catch (err: any) {
      toast.error(err.response?.data?.message || 'Gagal menghapus gambar.');
    }
  };

  const handleRemovePendingImage = (index: number) => {
    setPendingImagePreviews(prev => {
      const preview = prev[index];
      if (preview) URL.revokeObjectURL(preview);
      return prev.filter((_, i) => i !== index);
    });
    setPendingImageFiles(prev => prev.filter((_, i) => i !== index));
  };

  function openCreate() {
    setEditingProduct(null);
    setForm(EMPTY_FORM);
    setDialogOpen(true);
  }

  function openEdit(product: Product) {
    setEditingProduct(product);
    setForm({
      name: product.name,
      sku: product.sku || '',
      description: product.description || '',
      price: product.price,
      cost: product.cost ?? 0,
      unit: product.unit || 'pcs',
      category: product.category || '',
      stock_qty: product.stock_qty ?? 0,
      track_stock: product.track_stock ?? true,
      show_in_catalog: product.show_in_catalog ?? true,
    });
    setDialogOpen(true);
  }

  function closeDialog() {
    setDialogOpen(false);
    setEditingProduct(null);
    setForm(EMPTY_FORM);
    pendingImagePreviews.forEach(url => URL.revokeObjectURL(url));
    setPendingImageFiles([]);
    setPendingImagePreviews([]);
  }

  function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (editingProduct) {
      updateProduct.mutate({ id: editingProduct.id, data: form });
    } else {
      createProduct.mutate(form);
    }
  }

  function handleDelete() {
    if (!editingProduct) return;
    if (window.confirm(`Hapus produk "${editingProduct.name}"? Tindakan ini tidak dapat dibatalkan.`)) {
      deleteProduct.mutate(editingProduct.id);
    }
  }

  const products: Product[] = data?.data?.data || [];
  const categories = [...new Set(products.map(p => p.category).filter(Boolean))];
  const isSubmitting = createProduct.isPending || updateProduct.isPending;

  return (
    <div>
      <PageHeader
        title="Produk"
        description={`${products.length} produk aktif${categories.length > 0 ? ` · ${categories.length} kategori` : ''}`}
        actions={
          <div className="flex gap-2">
            <Button variant="secondary"><Download size={15} /> Import CSV</Button>
            <Button onClick={openCreate}><Plus size={15} /> Produk Baru</Button>
          </div>
        }
      />

      {/* Quota banner for free users */}
      {!isPremiumOrAdmin && productUsage && (
        <div className="mb-4 flex items-center justify-between bg-amber-50 border border-amber-200 rounded-xl px-4 py-2.5">
          <span className="text-sm text-amber-800">
            Produk: <strong>{productUsage.current}/{productUsage.limit}</strong>
          </span>
          {productUsage.current >= (productUsage.limit ?? Infinity) && (
            <span className="inline-flex items-center gap-1 text-xs font-semibold text-primary">
              <Crown size={12} /> Upgrade Premium
            </span>
          )}
        </div>
      )}

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
                <Card key={p.id} padding="none" className="group overflow-hidden hover:shadow-md transition-shadow cursor-pointer" onClick={() => openEdit(p)}>
                  <div
                    className="aspect-square flex items-center justify-center relative overflow-hidden"
                    style={{ background: gradient }}
                  >
                    {p.image_url ? (
                      <img src={storageUrl(p.image_url)} alt={p.name} className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300" />
                    ) : (
                      <span className="text-5xl">{emoji}</span>
                    )}
                    {!p.show_in_catalog && (
                      <div className="absolute top-2 right-2 bg-gray-800/75 text-white text-[10px] font-semibold px-1.5 py-0.5 rounded flex items-center gap-1">
                        <Globe size={10} /> Tidak di katalog
                      </div>
                    )}
                    {p.images && p.images.length > 1 && (
                      <div className="absolute bottom-2 right-2 bg-black/60 text-white text-[10px] font-semibold px-1.5 py-0.5 rounded flex items-center gap-1">
                        <ImageIcon size={10} /> {p.images.length}
                      </div>
                    )}
                  </div>
                  <div className="p-3.5">
                    <div className="text-[11px] text-gray-500 uppercase font-semibold tracking-wider">
                      {p.category || 'Tanpa kategori'}
                    </div>
                    <div className="font-bold text-[14px] text-gray-900 mt-1 mb-2 break-words whitespace-normal">{p.name}</div>
                    <div className="flex items-center justify-between">
                      <div>
                        <div className="text-[10px] text-gray-400 font-medium">Harga Jual</div>
                        <span className="font-bold text-primary">{formatRupiah(p.price)}</span>
                      </div>
                      {getStockBadge(p.stock_qty ?? 0)}
                    </div>
                  </div>
                </Card>
              );
            })}

          {/* Add product card */}
          <div
            onClick={openCreate}
            className="rounded-[10px] border-2 border-dashed border-gray-300 flex items-center justify-center min-h-[220px] cursor-pointer hover:border-gray-400 hover:bg-gray-50 transition-colors"
          >
            <div className="text-center text-gray-500">
              <div className="text-3xl mb-1">+</div>
              <div className="text-[13px] font-semibold">Tambah Produk</div>
            </div>
          </div>
        </div>
      )}

      <Dialog open={dialogOpen} onOpenChange={(open) => { if (!open) closeDialog(); }}>
        <DialogContent>
          <DialogHeader><DialogTitle>{editingProduct ? 'Edit Produk' : 'Tambah Produk'}</DialogTitle></DialogHeader>
          <form onSubmit={handleSubmit} className="space-y-3">
            <Input label="Nama Produk *" value={form.name} onChange={(e) => setForm({...form, name: e.target.value})} required />
            <Input label="SKU" value={form.sku} onChange={(e) => setForm({...form, sku: e.target.value})} />
            <div>
              <label className="block text-xs font-semibold text-gray-700 mb-1.5">Keterangan</label>
              <textarea
                className="w-full border border-gray-300 rounded-[6px] px-3 py-2.5 text-[14px] min-h-[72px] focus:outline-none focus:border-primary focus:ring-3 focus:ring-primary-50"
                placeholder="Cth: Kue coklat lembut dengan topping keju, cocok untuk acara ulang tahun."
                value={form.description}
                onChange={(e) => setForm({...form, description: e.target.value})}
              />
            </div>
            <Input label="Harga Pokok" type="number" value={form.cost} onChange={(e) => setForm({...form, cost: Number(e.target.value)})} />
            <Input label="Harga Jual *" type="number" value={form.price} onChange={(e) => setForm({...form, price: Number(e.target.value)})} required />
            <Input label="Kategori" value={form.category} onChange={(e) => setForm({...form, category: e.target.value})} />
            <Input label="Stok" type="number" value={form.stock_qty} onChange={(e) => setForm({...form, stock_qty: Number(e.target.value)})} disabled={!form.track_stock} />

            <div className="flex items-center justify-between py-2 px-3 rounded-[6px] bg-gray-50 border border-gray-200">
              <div className="flex items-center gap-2">
                <Boxes size={15} className="text-gray-500" />
                <div>
                  <div className="text-[13px] font-semibold text-gray-700">Kelola Stok</div>
                  <div className="text-[11px] text-gray-500">Kurangi stok otomatis saat ada order katalog</div>
                </div>
              </div>
              <button
                type="button"
                onClick={() => setForm({...form, track_stock: !form.track_stock})}
                className={`relative rounded-full transition-colors ${form.track_stock ? 'bg-primary' : 'bg-gray-300'}`}
                style={{ width: 40, height: 22 }}
              >
                <span
                  className="absolute top-0.5 left-0.5 rounded-full bg-white shadow transition-transform"
                  style={{ width: 18, height: 18, transform: form.track_stock ? 'translateX(18px)' : 'translateX(0)' }}
                />
              </button>
            </div>

            <div className="flex items-center justify-between py-2 px-3 rounded-[6px] bg-gray-50 border border-gray-200">
              <div className="flex items-center gap-2">
                <Globe size={15} className="text-gray-500" />
                <div>
                  <div className="text-[13px] font-semibold text-gray-700">Tampilkan di Katalog</div>
                  <div className="text-[11px] text-gray-500">Produk ini akan muncul di katalog publik</div>
                </div>
              </div>
              <button
                type="button"
                onClick={() => setForm({...form, show_in_catalog: !form.show_in_catalog})}
                className={`relative w-10 h-5.5 rounded-full transition-colors ${form.show_in_catalog ? 'bg-primary' : 'bg-gray-300'}`}
                style={{ width: 40, height: 22 }}
              >
                <span
                  className="absolute top-0.5 left-0.5 w-4.5 h-4.5 rounded-full bg-white shadow transition-transform"
                  style={{ width: 18, height: 18, transform: form.show_in_catalog ? 'translateX(18px)' : 'translateX(0)' }}
                />
              </button>
            </div>

            <div className="space-y-1.5 mt-2">
              <label className="block text-xs font-semibold text-gray-700">Gambar Produk</label>
              <p className="text-[11px] text-gray-500">Bisa upload lebih dari 1 gambar. Gambar pertama menjadi gambar utama.</p>
              <div className="flex flex-wrap gap-2">
                {/* Existing images (edit mode) */}
                {editingProduct?.images?.map((img, idx) => (
                  <div key={img} className="relative w-16 h-16 group/thumb">
                    <img src={storageUrl(img)} alt={`Gambar ${idx + 1}`} className="w-16 h-16 rounded-[6px] object-cover border border-gray-200" />
                    {idx === 0 && (
                      <span className="absolute bottom-0 left-0 right-0 bg-black/60 text-white text-[8px] text-center py-0.5 rounded-b-[6px]">Utama</span>
                    )}
                    <button
                      type="button"
                      onClick={() => handleRemoveExistingImage(img)}
                      className="absolute -top-1.5 -right-1.5 w-5 h-5 rounded-full bg-red-500 text-white flex items-center justify-center shadow hover:bg-red-600 transition-colors"
                      title="Hapus gambar"
                    >
                      <X size={12} />
                    </button>
                  </div>
                ))}

                {/* Pending previews (create mode) */}
                {!editingProduct && pendingImagePreviews.map((preview, idx) => (
                  <div key={preview} className="relative w-16 h-16 group/thumb">
                    <img src={preview} alt={`Gambar ${idx + 1}`} className="w-16 h-16 rounded-[6px] object-cover border border-gray-200" />
                    {idx === 0 && (
                      <span className="absolute bottom-0 left-0 right-0 bg-black/60 text-white text-[8px] text-center py-0.5 rounded-b-[6px]">Utama</span>
                    )}
                    <button
                      type="button"
                      onClick={() => handleRemovePendingImage(idx)}
                      className="absolute -top-1.5 -right-1.5 w-5 h-5 rounded-full bg-red-500 text-white flex items-center justify-center shadow hover:bg-red-600 transition-colors"
                      title="Hapus gambar"
                    >
                      <X size={12} />
                    </button>
                  </div>
                ))}

                {/* Upload trigger */}
                <button
                  type="button"
                  onClick={() => fileInputRef.current?.click()}
                  disabled={uploadingImage}
                  className="w-16 h-16 rounded-[6px] bg-gray-50 border border-dashed border-gray-300 flex flex-col items-center justify-center text-gray-400 hover:border-gray-400 hover:text-gray-500 transition-colors disabled:opacity-60"
                  title="Upload gambar"
                >
                  {uploadingImage ? <Upload size={18} className="animate-pulse" /> : <ImageIcon size={18} />}
                  <span className="text-[9px] mt-0.5 font-medium">Upload</span>
                </button>
              </div>
              <input
                type="file"
                accept="image/png, image/jpeg, image/webp"
                multiple
                className="hidden"
                ref={fileInputRef}
                onChange={handleImageUpload}
              />
            </div>
            
            <div className="flex items-center justify-between pt-2">
              <div>
                {editingProduct && (
                  <button
                    type="button"
                    onClick={handleDelete}
                    className="flex items-center gap-1.5 text-[13px] font-medium text-red-500 hover:text-red-700 transition-colors"
                  >
                    <Trash2 size={14} /> Hapus Produk
                  </button>
                )}
              </div>
              <div className="flex gap-2">
                <Button variant="secondary" type="button" onClick={closeDialog}>Batal</Button>
                <Button type="submit" loading={isSubmitting}>{editingProduct ? 'Simpan Perubahan' : 'Simpan'}</Button>
              </div>
            </div>
          </form>
        </DialogContent>
      </Dialog>
    </div>
  );
}
