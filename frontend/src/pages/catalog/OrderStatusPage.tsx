import { useState } from 'react';
import { useParams, useSearchParams, Link } from 'react-router-dom';
import { useQuery } from '@tanstack/react-query';
import { publicCatalogApi } from '@/api/public-catalog';
import { loadSnap } from '@/lib/midtrans';
import { Card } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { LoadingSpinner } from '@/components/ui/loading-spinner';
import { formatRupiah } from '@/lib/utils';
import { Store, CheckCircle2, Clock, Package, CreditCard } from 'lucide-react';
import { toast } from 'sonner';

export default function OrderStatusPage() {
  const { slug, poNumber } = useParams<{ slug: string; poNumber: string }>();
  const [searchParams] = useSearchParams();
  const phoneFromUrl = searchParams.get('phone') || '';

  const [phone, setPhone] = useState(phoneFromUrl);
  const [submittedPhone, setSubmittedPhone] = useState(phoneFromUrl);
  const [paying, setPaying] = useState(false);

  const { data, isLoading, isError, refetch } = useQuery({
    queryKey: ['public-order', slug, poNumber, submittedPhone],
    queryFn: () => publicCatalogApi.orderStatus(slug!, poNumber!, submittedPhone).then(r => r.data.data),
    enabled: !!submittedPhone,
    retry: false,
  });

  const order = data;
  const isPaid = order?.payment_status === 'paid';

  const handlePayNow = async () => {
    if (!order) return;
    setPaying(true);
    try {
      const pay = await publicCatalogApi.pay(slug!, poNumber!, submittedPhone);
      const snap = await loadSnap(pay.data.client_key, pay.data.is_production);
      snap.pay(pay.data.snap_token, {
        onSuccess: () => { toast.success('Pembayaran berhasil!'); refetch(); },
        onPending: () => { toast.info('Menunggu pembayaran.'); refetch(); },
        onError: () => toast.error('Pembayaran gagal. Silakan coba lagi.'),
        onClose: () => refetch(),
      });
    } catch (err: any) {
      toast.error(err?.response?.data?.message || 'Gagal memulai pembayaran.');
    } finally {
      setPaying(false);
    }
  };

  // Phone gate
  if (!submittedPhone) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center p-4">
        <Card className="max-w-sm w-full">
          <h1 className="text-[16px] font-bold text-gray-900 mb-1">Lacak Pesanan</h1>
          <p className="text-[13px] text-gray-500 mb-4">Masukkan nomor HP yang Anda gunakan saat memesan untuk melihat status pesanan <strong>{poNumber}</strong>.</p>
          <form onSubmit={(e) => { e.preventDefault(); setSubmittedPhone(phone.trim()); }} className="space-y-3">
            <Input label="No. WhatsApp" placeholder="08123456789" value={phone} onChange={(e) => setPhone(e.target.value)} />
            <Button type="submit" className="w-full" disabled={!phone.trim()}>Lihat Pesanan</Button>
          </form>
        </Card>
      </div>
    );
  }

  if (isLoading) {
    return (
      <div className="min-h-screen bg-gray-50 flex flex-col items-center justify-center space-y-4">
        <LoadingSpinner size="lg" />
        <p className="text-gray-500 font-medium">Memuat status pesanan...</p>
      </div>
    );
  }

  if (isError || !order) {
    return (
      <div className="min-h-screen bg-gray-50 flex flex-col items-center justify-center p-6 text-center">
        <div className="w-16 h-16 bg-red-100 text-red-500 rounded-full flex items-center justify-center mb-4">
          <Package size={32} />
        </div>
        <h1 className="text-xl font-bold text-gray-900 mb-2">Pesanan tidak ditemukan</h1>
        <p className="text-gray-500 mb-4">Nomor pesanan atau No. HP tidak cocok. Periksa kembali.</p>
        <Button variant="secondary" onClick={() => setSubmittedPhone('')}>Coba Lagi</Button>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50">
      <header className="bg-white border-b border-gray-200">
        <div className="max-w-2xl mx-auto px-4 py-4 flex items-center gap-3">
          <div className="h-10 w-10 bg-primary-50 text-primary rounded-xl flex items-center justify-center">
            <Store size={20} />
          </div>
          <div>
            <h1 className="text-[15px] font-extrabold text-gray-900">{order.organization.name}</h1>
            <p className="text-[12px] text-gray-500">Status Pesanan</p>
          </div>
        </div>
      </header>

      <main className="max-w-2xl mx-auto px-4 py-6 space-y-4">
        {/* Status banner */}
        <Card className={isPaid ? 'border-emerald-200 bg-emerald-50' : 'border-amber-200 bg-amber-50'}>
          <div className="flex items-center gap-3">
            <div className={`w-11 h-11 rounded-full flex items-center justify-center ${isPaid ? 'bg-emerald-100 text-emerald-600' : 'bg-amber-100 text-amber-600'}`}>
              {isPaid ? <CheckCircle2 size={22} /> : <Clock size={22} />}
            </div>
            <div className="flex-1">
              <p className="text-[15px] font-bold text-gray-900">{isPaid ? 'Pembayaran Lunas' : order.payment_status_label}</p>
              <p className="text-[12px] text-gray-600">Pesanan {order.po_number} · {order.status_label}</p>
            </div>
          </div>
        </Card>

        {/* Pay now */}
        {!isPaid && order.online_payment_available && (
          <Button className="w-full h-12" loading={paying} onClick={handlePayNow}>
            <CreditCard size={18} className="mr-2" /> Bayar Sekarang · {formatRupiah(order.total)}
          </Button>
        )}

        {/* Items */}
        <Card>
          <h3 className="text-[13px] font-bold text-gray-900 mb-3">Rincian Pesanan</h3>
          <div className="space-y-2">
            {order.items.map((item, i) => (
              <div key={i} className="flex justify-between text-[13px]">
                <div className="flex gap-2">
                  <span className="font-medium text-gray-500">{item.quantity}x</span>
                  <span className="text-gray-900">{item.product_name}</span>
                </div>
                <span className="font-semibold">{formatRupiah(item.subtotal)}</span>
              </div>
            ))}
            <div className="border-t border-gray-100 pt-2 mt-2 space-y-1">
              <div className="flex justify-between text-[13px] text-gray-600"><span>Subtotal</span><span>{formatRupiah(order.subtotal)}</span></div>
              {order.shipping_cost > 0 && (
                <div className="flex justify-between text-[13px] text-gray-600"><span>Ongkir</span><span>{formatRupiah(order.shipping_cost)}</span></div>
              )}
              <div className="flex justify-between font-bold pt-1"><span>Total</span><span className="text-primary">{formatRupiah(order.total)}</span></div>
            </div>
          </div>
          {order.notes && <p className="text-[12px] text-gray-500 mt-3 pt-3 border-t border-gray-100">{order.notes}</p>}
        </Card>

        {/* Shipping / tracking */}
        {(order.shipping_method || order.tracking_number) && (
          <Card>
            <h3 className="text-[13px] font-bold text-gray-900 mb-2">Pengiriman</h3>
            {order.shipping_method && <p className="text-[13px] text-gray-700">Metode: <strong>{order.shipping_method}</strong></p>}
            {order.tracking_number && (
              <div className="mt-2 flex items-center justify-between bg-gray-50 rounded-[8px] px-3 py-2">
                <span className="text-[12px] text-gray-500">No. Resi</span>
                <span className="text-[13px] font-mono font-semibold text-gray-900 select-all">{order.tracking_number}</span>
              </div>
            )}
          </Card>
        )}

        <div className="text-center">
          <Link to={`/katalog/${slug}`} className="text-[13px] text-primary font-semibold hover:underline">← Kembali ke katalog</Link>
        </div>
      </main>
    </div>
  );
}
