import { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { useQuery } from '@tanstack/react-query';
import { publicCatalogApi } from '@/api/public-catalog';
import { Card } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { LoadingSpinner } from '@/components/ui/loading-spinner';
import { formatRupiah, formatDate } from '@/lib/utils';
import { ArrowLeft, PackageSearch, ChevronRight, Inbox } from 'lucide-react';

export default function TrackOrderPage() {
  const { slug } = useParams<{ slug: string }>();
  const navigate = useNavigate();

  const [poNumber, setPoNumber] = useState('');
  const [phone, setPhone] = useState('');
  const [hasLast, setHasLast] = useState<{ poNumber: string; phone: string } | null>(null);

  // The phone we've actually searched a list for (only set when PO is left blank).
  const [searchPhone, setSearchPhone] = useState('');

  // Prefill from the most recent order made on this device, if any.
  useEffect(() => {
    try {
      const raw = localStorage.getItem(`catalog-last-order-${slug}`);
      if (raw) {
        const last = JSON.parse(raw) as { poNumber: string; phone: string };
        if (last?.poNumber) {
          setHasLast(last);
          setPoNumber(last.poNumber);
          setPhone(last.phone || '');
        }
      }
    } catch { /* ignore */ }
  }, [slug]);

  const { data: orders, isLoading, isError } = useQuery({
    queryKey: ['public-order-list', slug, searchPhone],
    queryFn: () => publicCatalogApi.orderList(slug!, searchPhone).then(r => r.data.data),
    enabled: !!searchPhone,
    retry: false,
  });

  const goToStatus = (po: string, ph: string) => {
    navigate(`/katalog/${slug}/pesanan/${encodeURIComponent(po.trim())}?phone=${encodeURIComponent(ph.trim())}`);
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!phone.trim()) return;
    // PO number is optional: if provided, jump straight to that order.
    // Otherwise, list every order tied to this WhatsApp number.
    if (poNumber.trim()) {
      goToStatus(poNumber, phone);
    } else {
      setSearchPhone(phone.trim());
    }
  };

  return (
    <div className="min-h-screen bg-gray-50">
      <header className="bg-white border-b border-gray-200 sticky top-0 z-10">
        <div className="max-w-2xl mx-auto px-4 sm:px-6">
          <div className="flex items-center gap-3 py-4">
            <button
              onClick={() => navigate(`/katalog/${slug}`)}
              className="w-9 h-9 rounded-full flex items-center justify-center text-gray-600 hover:bg-gray-100 transition-colors flex-shrink-0"
              aria-label="Kembali"
            >
              <ArrowLeft size={20} />
            </button>
            <h1 className="text-[17px] font-extrabold text-gray-900 leading-tight">Lacak Pesanan</h1>
          </div>
        </div>
      </header>

      <main className="max-w-2xl mx-auto px-4 sm:px-6 py-6 space-y-4">
        {hasLast && (
          <Card className="border-primary-100 bg-primary-50">
            <p className="text-[12px] text-gray-600 mb-2">Pesanan terakhir Anda dari perangkat ini:</p>
            <div className="flex items-center justify-between gap-3">
              <span className="text-[14px] font-bold text-gray-900 font-mono">{hasLast.poNumber}</span>
              <Button size="sm" onClick={() => goToStatus(hasLast.poNumber, hasLast.phone)}>Lihat Status</Button>
            </div>
          </Card>
        )}

        <Card>
          <div className="flex items-center gap-2 mb-1">
            <PackageSearch size={18} className="text-primary" />
            <h2 className="text-[15px] font-bold text-gray-900">Cek Status Pesanan</h2>
          </div>
          <p className="text-[13px] text-gray-500 mb-4">Masukkan No. WhatsApp yang Anda gunakan saat memesan. Nomor Pesanan (PO) opsional — kosongkan untuk melihat semua pesanan Anda.</p>
          <form onSubmit={handleSubmit} className="space-y-3">
            <Input label="No. WhatsApp" placeholder="Cth: 08123456789" value={phone} onChange={(e) => setPhone(e.target.value)} />
            <Input label="Nomor Pesanan (PO) — opsional" placeholder="Cth: PO-2026-0001" value={poNumber} onChange={(e) => setPoNumber(e.target.value)} />
            <Button type="submit" className="w-full h-11" disabled={!phone.trim()}>
              {poNumber.trim() ? 'Lihat Pesanan' : 'Lihat Semua Pesanan'}
            </Button>
          </form>
        </Card>

        {/* Results list — only when searching by phone alone */}
        {searchPhone && (
          <>
            {isLoading && (
              <div className="flex flex-col items-center justify-center py-10 space-y-3">
                <LoadingSpinner size="lg" />
                <p className="text-[13px] text-gray-500">Mencari pesanan Anda...</p>
              </div>
            )}

            {!isLoading && (isError || !orders || orders.length === 0) && (
              <Card className="text-center py-8">
                <div className="w-14 h-14 bg-gray-100 text-gray-400 rounded-full flex items-center justify-center mx-auto mb-3">
                  <Inbox size={26} />
                </div>
                <p className="text-[14px] font-bold text-gray-900 mb-1">Tidak ada pesanan ditemukan</p>
                <p className="text-[13px] text-gray-500">Tidak ada pesanan untuk nomor WhatsApp ini. Periksa kembali nomor Anda.</p>
              </Card>
            )}

            {!isLoading && orders && orders.length > 0 && (
              <div className="space-y-2">
                <p className="text-[12px] text-gray-500 px-1">{orders.length} pesanan ditemukan</p>
                {orders.map((o) => {
                  const isPaid = o.payment_status === 'paid';
                  return (
                    <button
                      key={o.po_number}
                      onClick={() => goToStatus(o.po_number, searchPhone)}
                      className="w-full text-left"
                    >
                      <Card className="hover:border-primary-200 transition-colors">
                        <div className="flex items-center justify-between gap-3">
                          <div className="min-w-0">
                            <p className="text-[14px] font-bold text-gray-900 font-mono truncate">{o.po_number}</p>
                            <p className="text-[12px] text-gray-500 mt-0.5">{formatDate(o.created_at)} · {o.status_label}</p>
                          </div>
                          <div className="flex items-center gap-2 flex-shrink-0">
                            <div className="text-right">
                              <p className="text-[13px] font-bold text-primary">{formatRupiah(o.total)}</p>
                              <span className={`inline-block text-[11px] font-semibold px-2 py-0.5 rounded-full mt-0.5 ${isPaid ? 'bg-emerald-100 text-emerald-700' : 'bg-amber-100 text-amber-700'}`}>
                                {o.payment_status_label}
                              </span>
                            </div>
                            <ChevronRight size={18} className="text-gray-400" />
                          </div>
                        </div>
                      </Card>
                    </button>
                  );
                })}
              </div>
            )}
          </>
        )}
      </main>
    </div>
  );
}
