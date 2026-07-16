import { useState, useMemo, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { useQuery } from '@tanstack/react-query';
import apiClient from '@/api/client';
import { publicCatalogApi } from '@/api/public-catalog';
import { loadSnap } from '@/lib/midtrans';
import { Product } from '@/types/product';
import { Card } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { LoadingSpinner } from '@/components/ui/loading-spinner';
import { formatRupiah, storageUrl } from '@/lib/utils';
import { Package, Store, ShoppingCart, Minus, Plus, CreditCard, MessageCircle } from 'lucide-react';
import { Badge } from '@/components/ui/badge';
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogFooter } from '@/components/ui/dialog';
import { toast } from 'sonner';

interface ShippingOption {
  id: string;      // 'pickup' | 'tbd' | flat rate name
  label: string;
  cost: number;
  note?: string;
}

interface CatalogData {
  organization: { name: string; phone: string | null; address: string | null; logo_url: string | null };
  products: Product[];
  categories: string[];
  store?: {
    online_payment_available: boolean;
    shipping: {
      flat_rates: { name: string; cost: number }[];
      allow_pickup: boolean;
      allow_shipping_tbd: boolean;
    };
  };
}

interface CartItem {
  product: Product;
  quantity: number;
}

export default function CatalogPage() {
  const { slug } = useParams<{ slug: string }>();
  const navigate = useNavigate();
  const [search, setSearch] = useState('');
  const [selectedCategory, setSelectedCategory] = useState<string>('');
  const cartStorageKey = `catalog-cart-${slug}`;

  const [cart, setCart] = useState<CartItem[]>(() => {
    try {
      const raw = localStorage.getItem(`catalog-cart-${slug}`);
      return raw ? (JSON.parse(raw) as CartItem[]) : [];
    } catch {
      return [];
    }
  });

  useEffect(() => {
    try {
      localStorage.setItem(cartStorageKey, JSON.stringify(cart));
    } catch {
      /* ignore quota errors */
    }
  }, [cart, cartStorageKey]);

  const handleAddToCart = (product: Product) => {
    if ((product.stock_qty ?? 0) <= 0) {
      toast.error('Stok produk ini sedang habis.');
      return;
    }
    setCart(prev => {
      const existing = prev.find(item => item.product.id === product.id);
      if (existing) {
        return prev.map(item => item.product.id === product.id ? { ...item, quantity: item.quantity + 1 } : item);
      }
      return [...prev, { product, quantity: 1 }];
    });
  };

  const handleUpdateQuantity = (productId: string, delta: number) => {
    setCart(prev => {
      const existing = prev.find(item => item.product.id === productId);
      if (!existing) return prev;
      const newQty = existing.quantity + delta;
      if (newQty <= 0) return prev.filter(item => item.product.id !== productId);
      return prev.map(item => item.product.id === productId ? { ...item, quantity: newQty } : item);
    });
  };

  const cartTotal = useMemo(() => cart.reduce((sum, item) => sum + (item.product.price * item.quantity), 0), [cart]);
  const cartItemsCount = cart.length;

  const [showCheckoutDialog, setShowCheckoutDialog] = useState(false);
  const [customerName, setCustomerName] = useState('');
  const [customerPhone, setCustomerPhone] = useState('');
  const [customerAddress, setCustomerAddress] = useState('');
  const [shippingId, setShippingId] = useState<string>('');
  const [paymentPref, setPaymentPref] = useState<'online' | 'whatsapp'>('whatsapp');
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [detailProduct, setDetailProduct] = useState<Product | null>(null);
  const [detailImageIdx, setDetailImageIdx] = useState(0);

  const openDetail = (product: Product) => {
    setDetailProduct(product);
    setDetailImageIdx(0);
  };

  const detailImages = useMemo(() => {
    if (!detailProduct) return [];
    const imgs = detailProduct.images && detailProduct.images.length > 0
      ? detailProduct.images
      : (detailProduct.image_url ? [detailProduct.image_url] : []);
    return imgs;
  }, [detailProduct]);

  const { data, isLoading, isError } = useQuery({
    queryKey: ['catalog', slug],
    queryFn: () => apiClient.get<CatalogData>(`/api/catalog/${slug}`).then(res => res.data),
    retry: false,
  });
  const catalog = data;

  const onlinePaymentAvailable = catalog?.store?.online_payment_available ?? false;

  const shippingOptions = useMemo<ShippingOption[]>(() => {
    const s = catalog?.store?.shipping;
    if (!s) return [];
    const opts: ShippingOption[] = s.flat_rates
      .filter(r => r.name.trim())
      .map(r => ({ id: r.name, label: r.name, cost: r.cost }));
    if (s.allow_pickup) opts.push({ id: 'pickup', label: 'Ambil di Tempat', cost: 0, note: 'Gratis' });
    if (s.allow_shipping_tbd) opts.push({ id: 'tbd', label: 'Ongkir dihitung kemudian', cost: 0, note: 'Dikonfirmasi via WhatsApp' });
    return opts;
  }, [catalog?.store?.shipping]);

  const selectedShipping = shippingOptions.find(o => o.id === shippingId);
  const shippingCost = selectedShipping?.cost ?? 0;
  const grandTotal = cartTotal + shippingCost;

  const handleOpenCheckout = () => {
    if (!catalog?.organization.phone && !onlinePaymentAvailable) {
      toast.error('Toko ini belum menyediakan kontak atau pembayaran online.');
      return;
    }
    // Preselect sensible defaults.
    setPaymentPref(onlinePaymentAvailable ? 'online' : 'whatsapp');
    if (shippingOptions.length > 0 && !shippingId) setShippingId(shippingOptions[0]!.id);
    setShowCheckoutDialog(true);
  };

  const clearCart = () => {
    setCart([]);
    try { localStorage.removeItem(cartStorageKey); } catch { /* ignore */ }
  };

  const sendViaWhatsApp = (poNumber: string) => {
    let text = `Halo ${catalog?.organization.name}, saya ingin memesan:\n\n`;
    if (poNumber) text += `*No. PO: ${poNumber}*\n\n`;
    text += `*Data Pemesan*\nNama: ${customerName}\nNo. HP: ${customerPhone}\nAlamat: ${customerAddress}\n\n`;
    text += `*Detail Pesanan*\n`;
    cart.forEach((item, i) => {
      text += `${i + 1}. ${item.product.name} (x${item.quantity}) - ${formatRupiah(item.product.price * item.quantity)}\n`;
    });
    if (selectedShipping) text += `\nPengiriman: ${selectedShipping.label}${shippingCost > 0 ? ` (${formatRupiah(shippingCost)})` : ''}`;
    text += `\nTotal: *${formatRupiah(grandTotal)}*\n\nMohon info ketersediaannya. Terima kasih.`;

    let phone = catalog?.organization.phone?.replace(/[^0-9]/g, '') || '';
    if (phone.startsWith('0')) phone = '62' + phone.substring(1);
    window.open(`https://wa.me/${phone}?text=${encodeURIComponent(text)}`, '_blank');
  };

  const goToOrderStatus = (poNumber: string) => {
    navigate(`/katalog/${slug}/pesanan/${encodeURIComponent(poNumber)}?phone=${encodeURIComponent(customerPhone.trim())}`);
  };

  const handleSubmitOrder = async () => {
    if (!customerName.trim() || !customerPhone.trim() || !customerAddress.trim()) {
      toast.error('Mohon lengkapi Nama, No. HP, dan Alamat Pengiriman.');
      return;
    }
    if (shippingOptions.length > 0 && !shippingId) {
      toast.error('Pilih metode pengiriman terlebih dahulu.');
      return;
    }

    setIsSubmitting(true);
    try {
      const res = await publicCatalogApi.checkout(slug!, {
        customer_name: customerName.trim(),
        customer_phone: customerPhone.trim(),
        customer_address: customerAddress.trim(),
        shipping_method: shippingId || null,
        payment_preference: paymentPref,
        items: cart.map(item => ({
          product_id: item.product.id,
          product_name: item.product.name,
          quantity: item.quantity,
          unit_price: item.product.price,
        })),
      });

      const poNumber = res.data.po_number;

      // Online payment path
      if (paymentPref === 'online' && res.data.online_payment_available) {
        try {
          const pay = await publicCatalogApi.pay(slug!, poNumber, customerPhone.trim());
          const snap = await loadSnap(pay.data.client_key, pay.data.is_production);
          setShowCheckoutDialog(false);
          setIsSubmitting(false);
          snap.pay(pay.data.snap_token, {
            onSuccess: () => { clearCart(); toast.success('Pembayaran berhasil!'); goToOrderStatus(poNumber); },
            onPending: () => { clearCart(); toast.info('Menunggu pembayaran Anda.'); goToOrderStatus(poNumber); },
            onError: () => { toast.error('Pembayaran gagal. Anda bisa mencoba lagi dari halaman status pesanan.'); goToOrderStatus(poNumber); },
            onClose: () => { toast.info('Pembayaran belum selesai. Pesanan tersimpan — bisa dibayar nanti.'); goToOrderStatus(poNumber); },
          });
          return;
        } catch {
          toast.error('Gagal memulai pembayaran online. Pesanan tetap tersimpan — silakan bayar via halaman status.');
          setIsSubmitting(false);
          setShowCheckoutDialog(false);
          clearCart();
          goToOrderStatus(poNumber);
          return;
        }
      }

      // WhatsApp path
      setIsSubmitting(false);
      setShowCheckoutDialog(false);
      sendViaWhatsApp(poNumber);
      clearCart();
      toast.success(`Pesanan ${poNumber} berhasil dibuat! Lanjutkan percakapan di WhatsApp.`, { duration: 5000 });
    } catch (err: any) {
      setIsSubmitting(false);
      const msg = err?.response?.data?.errors?.items?.[0]
        || err?.response?.data?.message
        || 'Gagal membuat pesanan. Silakan coba lagi.';
      toast.error(msg);
    }
  };

  const filteredProducts = useMemo(() => {
    if (!catalog?.products) return [];
    let result = catalog.products;
    if (search) {
      const q = search.toLowerCase();
      result = result.filter(p => p.name.toLowerCase().includes(q) || (p.description || '').toLowerCase().includes(q));
    }
    if (selectedCategory) result = result.filter(p => p.category === selectedCategory);
    return result;
  }, [catalog?.products, search, selectedCategory]);

  if (isLoading) {
    return (
      <div className="min-h-screen bg-gray-50 flex flex-col items-center justify-center space-y-4">
        <LoadingSpinner size="lg" />
        <p className="text-gray-500 font-medium">Memuat katalog produk...</p>
      </div>
    );
  }

  if (isError || !catalog) {
    return (
      <div className="min-h-screen bg-gray-50 flex flex-col items-center justify-center p-6 text-center">
        <div className="w-16 h-16 bg-red-100 text-red-500 rounded-full flex items-center justify-center mb-4">
          <Store size={32} />
        </div>
        <h1 className="text-2xl font-bold text-gray-900 mb-2">Katalog Tidak Ditemukan</h1>
        <p className="text-gray-500">Toko atau organisasi yang Anda cari tidak ada atau link salah.</p>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <header className="bg-white border-b border-gray-200 sticky top-0 z-10">
        <div className="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex items-center gap-4 py-4">
            {catalog.organization.logo_url ? (
              <img src={storageUrl(catalog.organization.logo_url)} alt={catalog.organization.name} className="h-12 w-auto object-contain rounded-md" />
            ) : (
              <div className="h-12 w-12 bg-primary-50 text-primary rounded-xl flex items-center justify-center flex-shrink-0">
                <Store size={24} />
              </div>
            )}
            <div>
              <h1 className="text-xl font-extrabold text-gray-900">{catalog.organization.name}</h1>
              <p className="text-[13px] text-gray-500 line-clamp-1">
                {catalog.organization.address} {catalog.organization.phone && `• ${catalog.organization.phone}`}
              </p>
            </div>
          </div>
        </div>
      </header>

      {/* Main Content */}
      <main className="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Filters */}
        <div className="flex flex-col sm:flex-row gap-4 mb-8">
          <div className="flex-1">
            <Input type="search" placeholder="Cari produk..." value={search} onChange={(e) => setSearch(e.target.value)} className="bg-white" />
          </div>
          {catalog.categories && catalog.categories.length > 0 && (
            <div className="flex gap-2 overflow-x-auto pb-2 sm:pb-0 hide-scrollbar">
              <button
                className={`px-4 py-2 rounded-[8px] text-[13px] font-semibold whitespace-nowrap transition-colors border ${selectedCategory === '' ? 'bg-primary text-white border-primary' : 'bg-white text-gray-600 border-gray-200 hover:bg-gray-50'}`}
                onClick={() => setSelectedCategory('')}
              >
                Semua Produk
              </button>
              {catalog.categories.map(cat => (
                <button
                  key={cat}
                  className={`px-4 py-2 rounded-[8px] text-[13px] font-semibold whitespace-nowrap transition-colors border ${selectedCategory === cat ? 'bg-primary text-white border-primary' : 'bg-white text-gray-600 border-gray-200 hover:bg-gray-50'}`}
                  onClick={() => setSelectedCategory(cat)}
                >
                  {cat}
                </button>
              ))}
            </div>
          )}
        </div>

        {/* Product Grid */}
        {filteredProducts.length > 0 ? (
          <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4 sm:gap-6">
            {filteredProducts.map(product => {
              const isOutOfStock = (product.stock_qty ?? 0) <= 0;
              return (
                <Card key={product.id} onClick={() => openDetail(product)} className="overflow-hidden hover:shadow-md transition-shadow group border-gray-200 cursor-pointer">
                  <div className="aspect-square bg-gray-100 flex items-center justify-center relative overflow-hidden">
                    {product.image_url ? (
                      <img src={storageUrl(product.image_url)} alt={product.name} className={`w-full h-full object-cover transition-transform duration-300 ${isOutOfStock ? '' : 'group-hover:scale-105'}`} />
                    ) : (
                      <Package className="w-12 h-12 text-gray-300" />
                    )}
                    {product.category && (
                      <div className="absolute top-2 left-2">
                        <Badge variant="secondary" className="bg-white/90 backdrop-blur text-xs">{product.category}</Badge>
                      </div>
                    )}
                    {isOutOfStock && (
                      <div className="absolute inset-0 flex items-center justify-center">
                        <span className="bg-gray-900/80 text-white text-[12px] font-bold px-3 py-1 rounded-full">Stok Habis</span>
                      </div>
                    )}
                  </div>
                  <div className="p-4">
                    <h3 className="font-bold text-gray-900 break-words whitespace-normal mb-1 group-hover:text-primary transition-colors text-[14px]">{product.name}</h3>
                    <p className="text-[12px] text-gray-500 mb-3 whitespace-pre-line break-words min-h-[36px]">{product.description || '-'}</p>
                    <div className="flex flex-col gap-3 mt-1">
                      <div>
                        <span className="text-[10px] text-gray-500 font-medium uppercase tracking-wider block mb-0.5">Harga Jual / {product.unit}</span>
                        <span className="font-extrabold text-primary text-[15px]">{formatRupiah(product.price)}</span>
                      </div>
                      {isOutOfStock ? (
                        <Button size="sm" variant="secondary" className="w-full text-[12px] h-8 opacity-60 cursor-not-allowed" disabled>Stok Habis</Button>
                      ) : cart.find(item => item.product.id === product.id) ? (
                        <div className="flex items-center justify-between border border-primary rounded-[8px] overflow-hidden bg-primary-50">
                          <button className="w-8 h-8 flex items-center justify-center text-primary hover:bg-primary-100 transition-colors" onClick={(e) => { e.stopPropagation(); handleUpdateQuantity(product.id, -1); }}>
                            <Minus size={14} />
                          </button>
                          <span className="text-[13px] font-bold text-primary w-8 text-center">{cart.find(item => item.product.id === product.id)?.quantity}</span>
                          <button className="w-8 h-8 flex items-center justify-center text-primary hover:bg-primary-100 transition-colors" onClick={(e) => { e.stopPropagation(); handleUpdateQuantity(product.id, 1); }}>
                            <Plus size={14} />
                          </button>
                        </div>
                      ) : (
                        <Button size="sm" variant="secondary" className="w-full text-[12px] h-8" onClick={(e) => { e.stopPropagation(); handleAddToCart(product); }}>
                          <Plus size={14} className="mr-1" /> Tambah
                        </Button>
                      )}
                    </div>
                  </div>
                </Card>
              );
            })}
          </div>
        ) : (
          <div className="text-center py-20 bg-white rounded-xl border border-gray-200 border-dashed">
            <Package className="mx-auto h-12 w-12 text-gray-300 mb-4" />
            <h3 className="text-lg font-medium text-gray-900">Tidak ada produk</h3>
            <p className="mt-1 text-gray-500">
              {search || selectedCategory ? 'Tidak ada produk yang sesuai dengan pencarian atau filter Anda.' : 'Toko ini belum menambahkan produk ke katalog.'}
            </p>
            {(search || selectedCategory) && (
              <Button variant="secondary" className="mt-4" onClick={() => { setSearch(''); setSelectedCategory(''); }}>Reset Filter</Button>
            )}
          </div>
        )}
      </main>

      {/* Footer */}
      <footer className={`bg-white border-t border-gray-200 py-6 mt-12 ${cart.length > 0 ? 'mb-20' : ''}`}>
        <div className="max-w-5xl mx-auto px-4 text-center">
          <p className="text-[13px] text-gray-400 font-medium">Katalog didukung oleh <span className="font-bold text-gray-900">POScheduler</span></p>
        </div>
      </footer>

      {/* Floating Cart Bar */}
      {cart.length > 0 && (
        <div className="fixed bottom-0 left-0 right-0 p-4 z-50 animate-in slide-in-from-bottom-5">
          <div className="max-w-5xl mx-auto">
            <div className="bg-gray-900 text-white rounded-2xl shadow-2xl p-3 px-4 flex items-center justify-between">
              <div className="flex flex-col">
                <span className="text-[11px] font-medium text-gray-400 uppercase tracking-wider">{cartItemsCount} Produk Terpilih</span>
                <span className="text-[16px] font-bold">{formatRupiah(cartTotal)}</span>
              </div>
              <Button onClick={handleOpenCheckout} className="bg-green-500 hover:bg-green-600 text-white rounded-xl shadow-lg shadow-green-500/20 border-0 h-11 px-5">
                <ShoppingCart size={18} className="mr-2" /> Checkout Pesanan
              </Button>
            </div>
          </div>
        </div>
      )}

      {/* Checkout Dialog */}
      <Dialog open={showCheckoutDialog} onOpenChange={setShowCheckoutDialog}>
        <DialogContent className="max-w-md w-full">
          <DialogHeader>
            <DialogTitle>Detail Pesanan</DialogTitle>
          </DialogHeader>
          <div className="space-y-4 py-2 max-h-[70vh] overflow-y-auto">
            <div className="space-y-3">
              <Input label="Nama Lengkap" placeholder="Cth: Budi Santoso" value={customerName} onChange={(e) => setCustomerName(e.target.value)} />
              <Input label="No. WhatsApp" placeholder="Cth: 08123456789" value={customerPhone} onChange={(e) => setCustomerPhone(e.target.value)} />
              <div>
                <label className="block text-xs font-semibold text-gray-700 mb-1.5">Alamat Pengiriman</label>
                <textarea
                  className="w-full border border-gray-300 rounded-[6px] px-3 py-2.5 text-[14px] min-h-[80px] focus:outline-none focus:border-primary focus:ring-3 focus:ring-primary-50"
                  placeholder="Cth: Jl. Sudirman No. 12, RT 01/02, Jakarta"
                  value={customerAddress}
                  onChange={(e) => setCustomerAddress(e.target.value)}
                />
              </div>
            </div>

            {/* Shipping options */}
            {shippingOptions.length > 0 && (
              <div>
                <label className="block text-xs font-semibold text-gray-700 mb-2">Metode Pengiriman</label>
                <div className="space-y-2">
                  {shippingOptions.map(opt => (
                    <label key={opt.id} className={`flex items-center justify-between gap-3 p-3 rounded-lg border cursor-pointer transition-all ${shippingId === opt.id ? 'border-primary bg-primary-50' : 'border-gray-200 hover:border-gray-300'}`}>
                      <div className="flex items-center gap-3">
                        <input type="radio" name="shipping" checked={shippingId === opt.id} onChange={() => setShippingId(opt.id)} className="accent-primary" />
                        <div>
                          <span className="text-[13px] font-medium text-gray-800">{opt.label}</span>
                          {opt.note && <p className="text-[11px] text-gray-500">{opt.note}</p>}
                        </div>
                      </div>
                      <span className="text-[13px] font-semibold text-gray-700">{opt.cost > 0 ? formatRupiah(opt.cost) : 'Gratis'}</span>
                    </label>
                  ))}
                </div>
              </div>
            )}

            {/* Order summary */}
            <div className="border-t border-gray-100 pt-4">
              <h4 className="text-[13px] font-bold text-gray-900 mb-3">Ringkasan Pesanan</h4>
              <div className="bg-gray-50 rounded-[10px] p-3 space-y-2">
                {cart.map((item, idx) => (
                  <div key={idx} className="flex justify-between text-[13px]">
                    <div className="flex gap-2">
                      <span className="font-medium text-gray-500">{item.quantity}x</span>
                      <span className="text-gray-900 line-clamp-1">{item.product.name}</span>
                    </div>
                    <span className="font-semibold">{formatRupiah(item.product.price * item.quantity)}</span>
                  </div>
                ))}
                <div className="flex justify-between text-[13px] text-gray-600 pt-1">
                  <span>Subtotal</span><span>{formatRupiah(cartTotal)}</span>
                </div>
                {selectedShipping && (
                  <div className="flex justify-between text-[13px] text-gray-600">
                    <span>Ongkir ({selectedShipping.label})</span>
                    <span>{shippingCost > 0 ? formatRupiah(shippingCost) : 'Gratis'}</span>
                  </div>
                )}
                <div className="border-t border-gray-200 mt-1 pt-2 flex justify-between font-bold">
                  <span>Total</span><span className="text-primary">{formatRupiah(grandTotal)}</span>
                </div>
              </div>
            </div>

            {/* Payment method */}
            <div>
              <label className="block text-xs font-semibold text-gray-700 mb-2">Metode Pembayaran</label>
              <div className="space-y-2">
                {onlinePaymentAvailable && (
                  <label className={`flex items-center gap-3 p-3 rounded-lg border cursor-pointer transition-all ${paymentPref === 'online' ? 'border-primary bg-primary-50' : 'border-gray-200 hover:border-gray-300'}`}>
                    <input type="radio" name="payment" checked={paymentPref === 'online'} onChange={() => setPaymentPref('online')} className="accent-primary" />
                    <CreditCard size={18} className="text-primary" />
                    <div>
                      <span className="text-[13px] font-semibold text-gray-800">Bayar Online Sekarang</span>
                      <p className="text-[11px] text-gray-500">Transfer, QRIS, e-wallet, kartu — aman via Midtrans.</p>
                    </div>
                  </label>
                )}
                <label className={`flex items-center gap-3 p-3 rounded-lg border cursor-pointer transition-all ${paymentPref === 'whatsapp' ? 'border-primary bg-primary-50' : 'border-gray-200 hover:border-gray-300'}`}>
                  <input type="radio" name="payment" checked={paymentPref === 'whatsapp'} onChange={() => setPaymentPref('whatsapp')} className="accent-primary" />
                  <MessageCircle size={18} className="text-green-600" />
                  <div>
                    <span className="text-[13px] font-semibold text-gray-800">Pesan via WhatsApp</span>
                    <p className="text-[11px] text-gray-500">Konfirmasi & pembayaran diatur langsung dengan penjual.</p>
                  </div>
                </label>
              </div>
            </div>
          </div>

          <DialogFooter className="mt-2">
            <Button variant="secondary" onClick={() => setShowCheckoutDialog(false)}>Batal</Button>
            <Button
              onClick={handleSubmitOrder}
              className={paymentPref === 'online' ? '' : 'bg-green-500 hover:bg-green-600 text-white border-0'}
              disabled={!customerName.trim() || !customerPhone.trim() || !customerAddress.trim() || isSubmitting}
              loading={isSubmitting}
            >
              {paymentPref === 'online' ? 'Lanjut ke Pembayaran' : 'Kirim ke WhatsApp'}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* Product Detail Dialog */}
      <Dialog open={!!detailProduct} onOpenChange={(open) => { if (!open) setDetailProduct(null); }}>
        <DialogContent className="max-w-lg w-full">
          {detailProduct && (() => {
            const isOut = (detailProduct.stock_qty ?? 0) <= 0;
            const inCart = cart.find(i => i.product.id === detailProduct.id);
            return (
              <>
                <DialogHeader onClose={() => setDetailProduct(null)}>
                  <DialogTitle className="pr-6">{detailProduct.name}</DialogTitle>
                </DialogHeader>
                <div className="space-y-4 py-1 max-h-[75vh] overflow-y-auto">
                  {/* Gallery */}
                  <div className="aspect-square bg-gray-100 rounded-[10px] overflow-hidden flex items-center justify-center">
                    {detailImages.length > 0 ? (
                      <img src={storageUrl(detailImages[detailImageIdx])} alt={detailProduct.name} className="w-full h-full object-cover" />
                    ) : (
                      <Package className="w-16 h-16 text-gray-300" />
                    )}
                  </div>
                  {detailImages.length > 1 && (
                    <div className="flex gap-2 overflow-x-auto hide-scrollbar">
                      {detailImages.map((img, i) => (
                        <button
                          key={i}
                          onClick={() => setDetailImageIdx(i)}
                          className={`w-14 h-14 rounded-[8px] overflow-hidden flex-shrink-0 border-2 transition-colors ${i === detailImageIdx ? 'border-primary' : 'border-transparent opacity-70'}`}
                        >
                          <img src={storageUrl(img)} alt="" className="w-full h-full object-cover" />
                        </button>
                      ))}
                    </div>
                  )}

                  <div>
                    {detailProduct.category && <Badge variant="secondary" className="mb-2">{detailProduct.category}</Badge>}
                    <div className="text-[10px] text-gray-500 font-medium uppercase tracking-wider">Harga / {detailProduct.unit}</div>
                    <div className="text-[22px] font-extrabold text-primary">{formatRupiah(detailProduct.price)}</div>
                    {!isOut && <div className="text-[12px] text-gray-500 mt-0.5">Stok tersedia: {detailProduct.stock_qty}</div>}
                  </div>

                  {detailProduct.description && (
                    <div>
                      <h4 className="text-[13px] font-bold text-gray-900 mb-1">Deskripsi</h4>
                      <p className="text-[13px] text-gray-600 whitespace-pre-line">{detailProduct.description}</p>
                    </div>
                  )}
                </div>
                <DialogFooter className="mt-2">
                  {isOut ? (
                    <Button variant="secondary" disabled className="w-full">Stok Habis</Button>
                  ) : inCart ? (
                    <div className="flex items-center justify-between border border-primary rounded-[8px] overflow-hidden bg-primary-50 w-full">
                      <button className="w-11 h-10 flex items-center justify-center text-primary hover:bg-primary-100" onClick={() => handleUpdateQuantity(detailProduct.id, -1)}><Minus size={16} /></button>
                      <span className="text-[14px] font-bold text-primary">{inCart.quantity} di keranjang</span>
                      <button className="w-11 h-10 flex items-center justify-center text-primary hover:bg-primary-100" onClick={() => handleUpdateQuantity(detailProduct.id, 1)}><Plus size={16} /></button>
                    </div>
                  ) : (
                    <Button className="w-full" onClick={() => handleAddToCart(detailProduct)}><Plus size={16} className="mr-1" /> Tambah ke Keranjang</Button>
                  )}
                </DialogFooter>
              </>
            );
          })()}
        </DialogContent>
      </Dialog>
    </div>
  );
}
