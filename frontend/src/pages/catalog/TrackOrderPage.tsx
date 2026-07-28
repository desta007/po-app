import { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { Card } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { ArrowLeft, PackageSearch } from 'lucide-react';

export default function TrackOrderPage() {
  const { slug } = useParams<{ slug: string }>();
  const navigate = useNavigate();

  const [poNumber, setPoNumber] = useState('');
  const [phone, setPhone] = useState('');
  const [hasLast, setHasLast] = useState<{ poNumber: string; phone: string } | null>(null);

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

  const goToStatus = (po: string, ph: string) => {
    navigate(`/katalog/${slug}/pesanan/${encodeURIComponent(po.trim())}?phone=${encodeURIComponent(ph.trim())}`);
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!poNumber.trim() || !phone.trim()) return;
    goToStatus(poNumber, phone);
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
          <p className="text-[13px] text-gray-500 mb-4">Masukkan Nomor Pesanan dan No. WhatsApp yang Anda gunakan saat memesan.</p>
          <form onSubmit={handleSubmit} className="space-y-3">
            <Input label="Nomor Pesanan (PO)" placeholder="Cth: PO-2026-0001" value={poNumber} onChange={(e) => setPoNumber(e.target.value)} />
            <Input label="No. WhatsApp" placeholder="Cth: 08123456789" value={phone} onChange={(e) => setPhone(e.target.value)} />
            <Button type="submit" className="w-full h-11" disabled={!poNumber.trim() || !phone.trim()}>Lihat Pesanan</Button>
          </form>
        </Card>
      </main>
    </div>
  );
}
