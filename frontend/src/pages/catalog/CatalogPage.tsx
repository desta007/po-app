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
import { Package, Store } from 'lucide-react';
import { Badge } from '@/components/ui/badge';

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

export default function CatalogPage() {
  const { slug } = useParams<{ slug: string }>();
  const [search, setSearch] = useState('');
  const [selectedCategory, setSelectedCategory] = useState<string>('');

  const { data, isLoading, isError } = useQuery({
    queryKey: ['catalog', slug],
    queryFn: () => apiClient.get<{ data: CatalogData }>(`/api/catalog/${slug}`).then(res => res.data),
    retry: false,
  });

  const catalog = data?.data;

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
                  <div className="flex items-end justify-between">
                    <div>
                      <span className="text-[10px] text-gray-500 font-medium uppercase tracking-wider block mb-0.5">Harga / {product.unit}</span>
                      <span className="font-extrabold text-primary text-[15px]">
                        {formatRupiah(product.price)}
                      </span>
                    </div>
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
      <footer className="bg-white border-t border-gray-200 py-6 mt-12">
        <div className="max-w-5xl mx-auto px-4 text-center">
          <p className="text-[13px] text-gray-400 font-medium">
            Katalog didukung oleh <span className="font-bold text-gray-900">POScheduler</span>
          </p>
        </div>
      </footer>
    </div>
  );
}
