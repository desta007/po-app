import { useParams, Link } from 'react-router-dom';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { purchaseOrdersApi } from '@/api/purchase-orders';
import { settingsApi } from '@/api/settings';
import { Button } from '@/components/ui/button';
import { Card } from '@/components/ui/card';
import { Skeleton } from '@/components/ui/skeleton';
import { PO_STATUS_CONFIG, PAYMENT_STATUS_CONFIG } from '@/lib/constants';
import { formatRupiah, formatDate, getInitials } from '@/lib/utils';
import { toast } from 'sonner';
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogFooter } from '@/components/ui/dialog';
import { Download, MessageCircle, Check, X, DollarSign, Pencil, ShoppingBag, Truck } from 'lucide-react';
import { useState, useEffect } from 'react';

const STATUS_ORDER = ['draft', 'confirmed', 'in_progress', 'completed'] as const;

export default function PurchaseOrderDetailPage() {
  const { id } = useParams<{ id: string }>();
  const queryClient = useQueryClient();

  const { data, isLoading } = useQuery({
    queryKey: ['purchase-order', id],
    queryFn: () => purchaseOrdersApi.show(id!),
    enabled: !!id,
  });

  const po = data?.data?.data;

  const [showPaymentDialog, setShowPaymentDialog] = useState(false);
  const [paymentStatus, setPaymentStatus] = useState<any>('unpaid');
  const [paidAmount, setPaidAmount] = useState(0);
  const [paymentMethod, setPaymentMethod] = useState('');
  const [trackingInput, setTrackingInput] = useState('');

  const { data: paymentMethodsData } = useQuery({
    queryKey: ['payment-methods'],
    queryFn: () => settingsApi.getPaymentMethods(),
  });



  const configuredMethods: { name: string; is_active: boolean }[] = paymentMethodsData?.data?.data || [];
  const activeMethods = configuredMethods.filter(m => m.is_active);

  const displayMethods = activeMethods.map(m => m.name);
  if (po?.payment_method && !displayMethods.includes(po.payment_method)) {
    displayMethods.push(po.payment_method);
  }

  useEffect(() => {
    if (po) {
      setPaymentStatus(po.payment_status);
      setPaidAmount(po.paid_amount || 0);
      setPaymentMethod(po.payment_method || '');
      setTrackingInput(po.tracking_number || '');
    }
  }, [po]);

  const updateStatus = useMutation({
    mutationFn: ({ status, reason }: { status: string; reason?: string }) =>
      purchaseOrdersApi.updateStatus(id!, status, reason),
    onSuccess: () => { queryClient.invalidateQueries({ queryKey: ['purchase-order', id] }); toast.success('Status diperbarui.'); },
    onError: (err: any) => toast.error(err.response?.data?.message || 'Gagal.'),
  });

  const updatePayment = useMutation({
    mutationFn: (payload: { payment_status: any; paid_amount: number; payment_method: string }) =>
      purchaseOrdersApi.updatePayment(id!, payload),
    onSuccess: () => { queryClient.invalidateQueries({ queryKey: ['purchase-order', id] }); toast.success('Status pembayaran diperbarui.'); setShowPaymentDialog(false); },
    onError: (err: any) => toast.error(err.response?.data?.message || 'Gagal.'),
  });

  const updateTracking = useMutation({
    mutationFn: (tracking: string) => purchaseOrdersApi.updateTracking(id!, tracking),
    onSuccess: () => { queryClient.invalidateQueries({ queryKey: ['purchase-order', id] }); toast.success('Nomor resi disimpan.'); },
    onError: (err: any) => toast.error(err.response?.data?.message || 'Gagal menyimpan resi.'),
  });

  const handleDownloadImage = async () => {
    try {
      const response = await purchaseOrdersApi.exportImage(id!) as any;
      const blob = new Blob([response.data], { type: 'image/png' });
      const url = window.URL.createObjectURL(blob);
      const link = document.createElement('a');
      link.href = url;
      link.setAttribute('download', `Invoice-${po?.po_number}.png`);
      document.body.appendChild(link);
      link.click();
      link.remove();
      window.URL.revokeObjectURL(url);
    } catch (err) {
      toast.error('Gagal mengunduh gambar invoice');
    }
  };



  const handleDownloadCorporatePdf = async () => {
    try {
      const response = await purchaseOrdersApi.exportCorporatePdf(id!) as any;
      const blob = new Blob([response.data], { type: 'application/pdf' });
      const url = window.URL.createObjectURL(blob);
      const link = document.createElement('a');
      link.href = url;
      link.setAttribute('download', `Invoice-${po?.po_number}.pdf`);
      document.body.appendChild(link);
      link.click();
      link.remove();
      window.URL.revokeObjectURL(url);
    } catch (err) {
      toast.error('Gagal mengunduh PDF Corporate');
    }
  };

  if (isLoading) return <div className="space-y-4">{[1,2,3].map(i => <Skeleton key={i} className="h-32 rounded-[10px]" />)}</div>;
  if (!po) return <p className="text-gray-500">PO tidak ditemukan.</p>;

  const sc = PO_STATUS_CONFIG[po.status];
  const pc = PAYMENT_STATUS_CONFIG[po.payment_status];
  const currentIdx = STATUS_ORDER.indexOf(po.status as any);
  const nextStatus = po.status !== 'cancelled' && currentIdx >= 0 && currentIdx < STATUS_ORDER.length - 1 ? STATUS_ORDER[currentIdx + 1] : null;

  return (
    <div>
      <div className="mb-4"><Link to="/pesanan" className="text-xs text-gray-500 hover:text-primary">← Kembali ke daftar PO</Link></div>
      <div className="flex flex-col md:flex-row md:items-start justify-between gap-4 mb-5">
        <div>
          <div className="flex items-center gap-2.5 mb-1 flex-wrap">
            <h1 className="text-2xl font-bold text-gray-900">{po.po_number}</h1>
            <span className="inline-flex items-center gap-1 rounded-full px-2 py-0.5 text-[11px] font-semibold" style={{ backgroundColor: sc.bgColor, color: sc.color }}><span className="h-1.5 w-1.5 rounded-full" style={{ backgroundColor: sc.color }} />{sc.label}</span>
            <span className="inline-flex items-center gap-1 rounded-full px-2 py-0.5 text-[11px] font-semibold" style={{ backgroundColor: pc.bgColor, color: pc.color }}><span className="h-1.5 w-1.5 rounded-full" style={{ backgroundColor: pc.color }} />{pc.label}</span>
            {po.source === 'catalog' && (
              <span className="inline-flex items-center gap-1 rounded-full px-2 py-0.5 text-[11px] font-semibold bg-violet-100 text-violet-700"><ShoppingBag size={11} /> Order Katalog</span>
            )}
          </div>
          <p className="text-[13px] text-gray-500">Dibuat {formatDate(po.order_date)} · Kirim {formatDate(po.delivery_date)}</p>
        </div>
        <div className="flex gap-2 flex-wrap">
          <Link to={`/pesanan/${id}/edit`}>
            <Button variant="secondary"><Pencil size={15} /> Edit PO</Button>
          </Link>
          <Button variant="secondary" onClick={() => setShowPaymentDialog(true)}><DollarSign size={15} /> Update Bayar</Button>
          <Button variant="secondary" onClick={handleDownloadImage}>
            <Download size={15} /> Download Image (Struk)
          </Button>
          <Button variant="secondary" onClick={handleDownloadCorporatePdf}>
            <Download size={15} /> Download PDF Corporate
          </Button>
          <Button variant="accent" onClick={() => {
            if (po.customer?.phone) {
              let phone = po.customer.phone.replace(/[^0-9]/g, '');
              if (phone.startsWith('0')) phone = '62' + phone.substring(1);
              window.open(`https://wa.me/${phone}`, '_blank');
            } else {
              toast.error('Nomor HP pelanggan tidak tersedia');
            }
          }}><MessageCircle size={15} /> Kirim WA</Button>
          {nextStatus && <Button onClick={() => updateStatus.mutate({ status: nextStatus })} loading={updateStatus.isPending}>{nextStatus === 'confirmed' ? 'Konfirmasi' : nextStatus === 'in_progress' ? 'Proses' : 'Selesai'} <Check size={15} /></Button>}
        </div>
      </div>
      <div className="grid lg:grid-cols-3 gap-5">
        <div className="lg:col-span-2 space-y-4">
          <Card>
            <div className="flex items-center justify-between mb-3"><h3 className="text-[14px] font-bold">Customer</h3><Link to={`/pelanggan/${po.customer?.id}`} className="text-xs text-primary font-semibold">Lihat profil →</Link></div>
            <div className="flex gap-3 items-center">
              <div className="w-12 h-12 rounded-full bg-primary text-white flex items-center justify-center font-bold text-lg flex-shrink-0">{getInitials(po.customer?.name || '?')}</div>
              <div className="flex-1"><div className="font-bold text-base">{po.customer?.name}</div><div className="text-[13px] text-gray-500">{po.customer?.phone || '-'} · {po.customer?.email || '-'}</div></div>
            </div>
          </Card>
          <Card>
            <h3 className="text-[14px] font-bold mb-3">Items Pesanan</h3>
            <div className="overflow-x-auto rounded-[10px] border border-gray-200">
              <table className="w-full border-collapse">
                <thead className="bg-gray-50 border-b border-gray-200"><tr><th className="px-3.5 py-2.5 text-left text-[11px] font-bold text-gray-500 uppercase tracking-wider">Produk</th><th className="px-3.5 py-2.5 text-right text-[11px] font-bold text-gray-500 uppercase tracking-wider">Qty</th><th className="px-3.5 py-2.5 text-right text-[11px] font-bold text-gray-500 uppercase tracking-wider">Harga</th><th className="px-3.5 py-2.5 text-right text-[11px] font-bold text-gray-500 uppercase tracking-wider">Subtotal</th></tr></thead>
                <tbody>{po.items?.map((item: any) => (<tr key={item.id} className="border-b border-gray-100 last:border-b-0 hover:bg-gray-50"><td className="px-3.5 py-3.5 text-[13px]"><strong>{item.product_name}</strong>{item.notes && <div className="text-[11px] text-gray-500">{item.notes}</div>}</td><td className="px-3.5 py-3.5 text-right text-[13px]">{item.quantity}</td><td className="px-3.5 py-3.5 text-right text-[13px] font-semibold tabular-nums">{formatRupiah(item.unit_price)}</td><td className="px-3.5 py-3.5 text-right text-[13px] font-semibold tabular-nums">{formatRupiah(item.subtotal)}</td></tr>))}</tbody>
              </table>
            </div>
            <div className="mt-3 pt-3 border-t border-gray-200 space-y-1">
              <div className="flex justify-between text-[13px]"><span>Subtotal</span><span className="font-semibold">{formatRupiah(po.subtotal)}</span></div>
              {po.discount > 0 && <div className="flex justify-between text-[13px]"><span>Diskon</span><span>-{formatRupiah(po.discount)}</span></div>}
              {po.tax > 0 && <div className="flex justify-between text-[13px]"><span>Pajak</span><span>{formatRupiah(po.tax)}</span></div>}
              {Number(po.shipping_cost) > 0 && <div className="flex justify-between text-[13px]"><span>Ongkos Kirim</span><span>{formatRupiah(po.shipping_cost)}</span></div>}
              <div className="flex justify-between pt-2 border-t border-gray-100 font-bold"><span>Total</span><span className="text-primary text-base">{formatRupiah(po.total)}</span></div>
            </div>
          </Card>
          {po.payment_method && <Card><h3 className="text-[14px] font-bold mb-2">Info Pembayaran</h3><p className="text-[13px] text-gray-700">Metode: <strong>{po.payment_method}</strong></p></Card>}

          <Card>
            <h3 className="text-[14px] font-bold mb-1 flex items-center gap-1.5"><Truck size={15} /> Pengiriman</h3>
            {po.shipping_method && <p className="text-[13px] text-gray-700 mb-2">Metode: <strong>{po.shipping_method}</strong></p>}
            <label className="block text-[12px] font-semibold text-gray-700 mb-1.5">Nomor Resi</label>
            <div className="flex gap-2">
              <input
                className="flex-1 border border-gray-300 rounded-[6px] px-3 py-2 text-[13px] focus:outline-none focus:border-primary focus:ring-3 focus:ring-primary-50"
                placeholder="Cth: JX1234567890"
                value={trackingInput}
                onChange={(e) => setTrackingInput(e.target.value)}
              />
              <Button
                size="sm"
                variant="secondary"
                loading={updateTracking.isPending}
                disabled={trackingInput === (po.tracking_number || '')}
                onClick={() => updateTracking.mutate(trackingInput.trim())}
              >
                Simpan
              </Button>
            </div>
            <p className="text-[11px] text-gray-400 mt-1.5">Resi otomatis tampil di halaman status pesanan pelanggan.</p>
          </Card>

          {po.notes && <Card><h3 className="text-[14px] font-bold mb-2">Catatan Internal</h3><p className="text-[13px] text-gray-700">{po.notes}</p></Card>}
        </div>
        <div className="space-y-4">
          <Card>
            <h3 className="text-[14px] font-bold mb-3">Status Workflow</h3>
            <div className="flex flex-col gap-1">
              {STATUS_ORDER.map((status, i) => { const isDone = i <= currentIdx; const cfg = PO_STATUS_CONFIG[status]; return (<div key={status} className={`flex items-center gap-2 px-2 py-2 rounded-[6px] ${isDone ? 'bg-accent-light' : 'opacity-50'}`}><div className={`w-5 h-5 rounded-full flex items-center justify-center text-[11px] flex-shrink-0 ${isDone ? 'bg-accent text-white' : 'border-2 border-dashed border-gray-300'}`}>{isDone && '✓'}</div><div className="text-[13px] font-semibold">{cfg.label}</div></div>); })}
            </div>
            {nextStatus && <Button className="w-full mt-3" onClick={() => updateStatus.mutate({ status: nextStatus })} loading={updateStatus.isPending}>{nextStatus === 'confirmed' ? 'Konfirmasi' : 'Proses Sekarang'} →</Button>}
            {po.status !== 'completed' && po.status !== 'cancelled' && <Button variant="secondary" size="sm" className="w-full mt-3 text-danger" onClick={() => { const r = prompt('Alasan:'); if (r) updateStatus.mutate({ status: 'cancelled', reason: r }); }}><X size={14} /> Batalkan PO</Button>}
          </Card>
          <Card>
            <h3 className="text-[14px] font-bold mb-3">Aktivitas</h3>
            {po.status_history?.map((h: any, i: number) => { const sc2 = PO_STATUS_CONFIG[h.to_status as keyof typeof PO_STATUS_CONFIG]; const isLast = i === (po.status_history?.length ?? 0) - 1; return (<div key={h.id} className="flex gap-3 relative" style={{ paddingBottom: isLast ? 0 : 16 }}>{!isLast && <div className="absolute left-3 top-7 bottom-0 w-0.5 bg-gray-200" />}<div className="w-6 h-6 rounded-full flex items-center justify-center flex-shrink-0 z-10 bg-accent text-white"><Check size={14} /></div><div className="pt-0.5"><div className="text-[13px] font-semibold">{sc2?.label || h.to_status}</div>{h.reason && <div className="text-[11px] text-gray-500">{h.reason}</div>}<div className="text-[11px] text-gray-500">{formatDate(h.changed_at, 'relative')}</div></div></div>); })}
          </Card>
        </div>
      </div>

      <Dialog open={showPaymentDialog} onOpenChange={setShowPaymentDialog}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Update Status Pembayaran</DialogTitle>
          </DialogHeader>
          <div className="space-y-4 py-4">
            <div className="space-y-2">
              <label className="text-[13px] font-semibold text-gray-900">Status Pembayaran</label>
              <select
                className="w-full px-3 py-2.5 bg-white border border-gray-300 rounded-[10px] text-[14px] focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary"
                value={paymentStatus}
                onChange={(e) => setPaymentStatus(e.target.value)}
              >
                <option value="unpaid">Belum Bayar</option>
                <option value="dp">DP (Sebagian)</option>
                <option value="paid">Lunas</option>
              </select>
            </div>
            {paymentStatus !== 'unpaid' && (
              <div className="space-y-4">
                <div className="space-y-2">
                  <label className="text-[13px] font-semibold text-gray-900">Metode Bayar (Opsional)</label>
                  <select
                    className="w-full px-3 py-2.5 bg-white border border-gray-300 rounded-[10px] text-[14px] focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary"
                    value={paymentMethod}
                    onChange={(e) => setPaymentMethod(e.target.value)}
                  >
                    <option value="">-- Pilih Metode --</option>
                    {displayMethods.map((name) => (
                      <option key={name} value={name}>{name}</option>
                    ))}
                  </select>
                </div>
                <div className="space-y-2">
                  <label className="text-[13px] font-semibold text-gray-900">Nominal Dibayar (Rp)</label>
                  <input
                    type="number"
                    className="w-full px-3 py-2.5 border border-gray-300 rounded-[10px] text-[14px] focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary"
                    value={paidAmount}
                    onChange={(e) => setPaidAmount(Number(e.target.value))}
                  />
                </div>
              </div>
            )}
          </div>
          <DialogFooter>
            <Button variant="secondary" onClick={() => setShowPaymentDialog(false)}>Batal</Button>
            <Button
              onClick={() => {
                updatePayment.mutate({
                  payment_status: paymentStatus,
                  paid_amount: paymentStatus === 'unpaid' ? 0 : paymentStatus === 'paid' ? po.total : paidAmount,
                  payment_method: paymentStatus === 'unpaid' ? '' : paymentMethod,
                });
              }}
              loading={updatePayment.isPending}
            >
              Simpan Pembayaran
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}
