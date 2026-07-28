import { useState, useMemo, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { useQuery } from '@tanstack/react-query';
import apiClient from '@/api/client';
import { Product } from '@/types/product';
import { Card } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { LoadingSpinner } from '@/components/ui/loading-spinner';
import { formatRupiah, storageUrl } from '@/lib/utils';
import { Package, Store, ShoppingCart, Minus, Plus } from 'lucide-react';
import { Badge } from '@/components/ui/badge';
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogFooter } from '@/components/ui/dialog';
import { toast } from 'sonner';

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

  const handleOpenCheckout = () => {
    const onlinePaymentAvailable = catalog?.store?.online_payment_available ?? false;
    if (!catalog?.organization.phone && !onlinePaymentAvailable) {
      toast.error('Toko ini belum menyediakan kontak atau pembayaran online.');
      return;
    }
    navigate(`/katalog/${slug}/checkout`);
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
