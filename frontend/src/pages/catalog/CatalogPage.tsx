import { useState, useMemo } from 'react';
import { useParams } from 'react-router-dom';
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

interface CatalogData {
  organization: {
    name: string;
    phone: string | null;
    address: string | null;
    logo_url: string | null;
  };
  products: Product[];
  categories: string[];
}

interface CartItem {
  product: Product;
  quantity: number;
}

export default function CatalogPage() {
  const { slug } = useParams<{ slug: string }>();
  const [search, setSearch] = useState('');
  const [selectedCategory, setSelectedCategory] = useState<string>('');
  const [cart, setCart] = useState<CartItem[]>([]);

  const handleAddToCart = (product: Product) => {
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
      if (newQty <= 0) {
        return prev.filter(item => item.product.id !== productId);
      }
      return prev.map(item => item.product.id === productId ? { ...item, quantity: newQty } : item);
    });
  };

  const cartTotal = useMemo(() => cart.reduce((sum, item) => sum + (item.product.price * item.quantity), 0), [cart]);
  const cartItemsCount = useMemo(() => cart.reduce((sum, item) => sum + item.quantity, 0), [cart]);

  const [showCheckoutDialog, setShowCheckoutDialog] = useState(false);
  const [customerName, setCustomerName] = useState('');
  const [customerPhone, setCustomerPhone] = useState('');
  const [customerAddress, setCustomerAddress] = useState('');

  const handleOpenCheckout = () => {
    if (!catalog?.organization.phone) {
      alert('Nomor WhatsApp toko tidak tersedia.');
      return;
    }
    setShowCheckoutDialog(true);
  };

  const handleSendOrder = () => {
    if (!customerName.trim() || !customerPhone.trim() || !customerAddress.trim()) {
      alert('Mohon lengkapi Nama, No. HP, dan Alamat Pengiriman.');
      return;
    }

    let text = `Halo ${catalog?.organization.name}, saya ingin memesan:\n\n`;
    text += `*Data Pemesan*\n`;
    text += `Nama: ${customerName}\n`;
    text += `No. HP: ${customerPhone}\n`;
    text += `Alamat: ${customerAddress}\n\n`;
    
    text += `*Detail Pesanan*\n`;
    cart.forEach((item, index) => {
      text += `${index + 1}. ${item.product.name} (x${item.quantity}) - ${formatRupiah(item.product.price * item.quantity)}\n`;
    });
    text += `\nTotal: *${formatRupiah(cartTotal)}*\n\nMohon info ketersediaannya. Terima kasih.`;

    const encodedText = encodeURIComponent(text);
    let phone = catalog?.organization.phone?.replace(/[^0-9]/g, '') || '';
    if (phone.startsWith('0')) {
      phone = '62' + phone.substring(1);
    }
    
    setShowCheckoutDialog(false);
    window.open(`https://wa.me/${phone}?text=${encodedText}`, '_blank');
  };

  const { data, isLoading, isError } = useQuery({
    queryKey: ['catalog', slug],
    queryFn: () => apiClient.get<CatalogData>(`/api/catalog/${slug}`).then(res => res.data),
    retry: false,
  });

  const catalog = data;

  const filteredProducts = useMemo(() => {
    if (!catalog?.products) return [];
    let result = catalog.products;
    
    if (search) {
      const q = search.toLowerCase();
      result = result.filter(p => p.name.toLowerCase().includes(q) || (p.description || '').toLowerCase().includes(q));
    }
    
    if (selectedCategory) {
      result = result.filter(p => p.category === selectedCategory);
    }
    
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
            <Input 
              type="search" 
              placeholder="Cari produk..." 
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              className="bg-white"
            />
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
            {filteredProducts.map(product => (
              <Card key={product.id} className="overflow-hidden hover:shadow-md transition-shadow group cursor-pointer border-gray-200">
                <div className="aspect-square bg-gray-100 flex items-center justify-center relative overflow-hidden">
                  {product.image_url ? (
                    <img
                      src={storageUrl(product.image_url)}
                      alt={product.name} 
                      className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300"
                    />
                  ) : (
                    <Package className="w-12 h-12 text-gray-300" />
                  )}
                  {product.category && (
                    <div className="absolute top-2 left-2">
                      <Badge variant="secondary" className="bg-white/90 backdrop-blur text-xs">
                        {product.category}
                      </Badge>
                    </div>
                  )}
                </div>
                <div className="p-4">
                  <h3 className="font-bold text-gray-900 line-clamp-2 mb-1 group-hover:text-primary transition-colors text-[14px]">
                    {product.name}
                  </h3>
                  <p className="text-[12px] text-gray-500 mb-3 line-clamp-2 min-h-[36px]">
                    {product.description || '-'}
                  </p>
                  <div className="flex flex-col gap-3 mt-1">
                    <div>
                      <span className="text-[10px] text-gray-500 font-medium uppercase tracking-wider block mb-0.5">Harga / {product.unit}</span>
                      <span className="font-extrabold text-primary text-[15px]">
                        {formatRupiah(product.price)}
                      </span>
                    </div>
                    {cart.find(item => item.product.id === product.id) ? (
                      <div className="flex items-center justify-between border border-primary rounded-[8px] overflow-hidden bg-primary-50">
                        <button 
                          className="w-8 h-8 flex items-center justify-center text-primary hover:bg-primary-100 transition-colors"
                          onClick={(e) => { e.stopPropagation(); handleUpdateQuantity(product.id, -1); }}
                        >
                          <Minus size={14} />
                        </button>
                        <span className="text-[13px] font-bold text-primary w-8 text-center">
                          {cart.find(item => item.product.id === product.id)?.quantity}
                        </span>
                        <button 
                          className="w-8 h-8 flex items-center justify-center text-primary hover:bg-primary-100 transition-colors"
                          onClick={(e) => { e.stopPropagation(); handleUpdateQuantity(product.id, 1); }}
                        >
                          <Plus size={14} />
                        </button>
                      </div>
                    ) : (
                      <Button 
                        size="sm" 
                        variant="secondary" 
                        className="w-full text-[12px] h-8"
                        onClick={(e) => { e.stopPropagation(); handleAddToCart(product); }}
                      >
                        <Plus size={14} className="mr-1" /> Tambah
                      </Button>
                    )}
                  </div>
                </div>
              </Card>
            ))}
          </div>
        ) : (
          <div className="text-center py-20 bg-white rounded-xl border border-gray-200 border-dashed">
            <Package className="mx-auto h-12 w-12 text-gray-300 mb-4" />
            <h3 className="text-lg font-medium text-gray-900">Tidak ada produk</h3>
            <p className="mt-1 text-gray-500">
              {search || selectedCategory 
                ? 'Tidak ada produk yang sesuai dengan pencarian atau filter Anda.' 
                : 'Toko ini belum menambahkan produk ke katalog.'}
            </p>
            {(search || selectedCategory) && (
              <Button variant="secondary" className="mt-4" onClick={() => { setSearch(''); setSelectedCategory(''); }}>
                Reset Filter
              </Button>
            )}
          </div>
        )}
      </main>
      
      {/* Footer */}
      <footer className={`bg-white border-t border-gray-200 py-6 mt-12 ${cart.length > 0 ? 'mb-20' : ''}`}>
        <div className="max-w-5xl mx-auto px-4 text-center">
          <p className="text-[13px] text-gray-400 font-medium">
            Katalog didukung oleh <span className="font-bold text-gray-900">POScheduler</span>
          </p>
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
                <ShoppingCart size={18} className="mr-2" />
                Checkout Pesanan
              </Button>
            </div>
          </div>
        </div>
      )}

      {/* Checkout Dialog */}
      <Dialog open={showCheckoutDialog} onOpenChange={setShowCheckoutDialog}>
        <DialogContent className="max-w-md w-full">
          <DialogHeader>
            <DialogTitle>Detail Pengiriman</DialogTitle>
          </DialogHeader>
          <div className="space-y-4 py-2 max-h-[70vh] overflow-y-auto">
            <div className="space-y-3">
              <Input 
                label="Nama Lengkap" 
                placeholder="Cth: Budi Santoso"
                value={customerName}
                onChange={(e) => setCustomerName(e.target.value)}
              />
              <Input 
                label="No. WhatsApp" 
                placeholder="Cth: 08123456789"
                value={customerPhone}
                onChange={(e) => setCustomerPhone(e.target.value)}
              />
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

            <div className="border-t border-gray-100 pt-4 mt-2">
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
                <div className="border-t border-gray-200 mt-2 pt-2 flex justify-between font-bold">
                  <span>Total</span>
                  <span className="text-primary">{formatRupiah(cartTotal)}</span>
                </div>
              </div>
            </div>
          </div>
          <DialogFooter className="mt-2">
            <Button variant="secondary" onClick={() => setShowCheckoutDialog(false)}>Batal</Button>
            <Button 
              onClick={handleSendOrder} 
              className="bg-green-500 hover:bg-green-600 text-white border-0"
              disabled={!customerName.trim() || !customerPhone.trim() || !customerAddress.trim()}
            >
              Kirim ke WhatsApp
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}
