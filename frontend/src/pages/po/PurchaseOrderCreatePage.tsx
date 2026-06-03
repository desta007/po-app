import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useQuery, useMutation } from '@tanstack/react-query';
import { purchaseOrdersApi } from '@/api/purchase-orders';
import { customersApi } from '@/api/customers';
import { productsApi } from '@/api/products';
import { PageHeader } from '@/components/layout/page-header';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Card } from '@/components/ui/card';
import { ROUTES } from '@/lib/constants';
import { formatRupiah } from '@/lib/utils';
import { toast } from 'sonner';
import { Plus, Trash2, Check } from 'lucide-react';

interface ItemRow { product_id: string | null; product_name: string; quantity: number; unit_price: number; notes: string; }

export default function PurchaseOrderCreatePage() {
  const navigate = useNavigate();
  const [step, setStep] = useState(0);
  const [customerId, setCustomerId] = useState('');
  const [deliveryDate, setDeliveryDate] = useState(new Date(Date.now() + 86400000).toISOString().slice(0, 10));
  const [orderDate, setOrderDate] = useState(new Date().toISOString().slice(0, 10));
  const [discount, setDiscount] = useState(0);
  const [tax, setTax] = useState(0);
  const [notes, setNotes] = useState('');
  const [items, setItems] = useState<ItemRow[]>([{ product_id: null, product_name: '', quantity: 1, unit_price: 0, notes: '' }]);

  const { data: customersData } = useQuery({ queryKey: ['customers-all'], queryFn: () => customersApi.list({ per_page: 100 }) });
  const { data: productsData } = useQuery({ queryKey: ['products-all'], queryFn: () => productsApi.list({ per_page: 100 }) });
  const customers = customersData?.data?.data || [];
  const products = productsData?.data?.data || [];

  const createPO = useMutation({
    mutationFn: (data: any) => purchaseOrdersApi.create(data),
    onSuccess: (res) => { toast.success('PO berhasil dibuat!'); navigate(ROUTES.PO_DETAIL(res.data.data.id)); },
    onError: (err: any) => toast.error(err.response?.data?.message || 'Gagal.'),
  });

  const addItem = () => setItems([...items, { product_id: null, product_name: '', quantity: 1, unit_price: 0, notes: '' }]);
  const removeItem = (i: number) => setItems(items.filter((_, idx) => idx !== i));
  const updateItem = (i: number, field: keyof ItemRow, value: any) => {
    const next = [...items];
    (next[i] as any)[field] = value;
    if (field === 'product_id' && value) { const p = (products as any[]).find((p: any) => p.id === value); if (p) { (next[i] as any).product_name = p.name; (next[i] as any).unit_price = p.price; } }
    setItems(next);
  };

  const subtotal = items.reduce((sum, it) => sum + it.quantity * it.unit_price, 0);
  const total = subtotal - discount + tax;
  const handleSubmit = () => { createPO.mutate({ customer_id: customerId, order_date: orderDate, delivery_date: deliveryDate, discount, tax, notes, items }); };
  const steps = ['Customer', 'Items', 'Jadwal & Bayar', 'Review'];
  const selectedCustomer = customers.find((c: any) => c.id === customerId);

  return (
    <div>
      <PageHeader title="Buat Purchase Order Baru" description="Isi detail pesanan dengan lengkap" />

      {/* Stepper */}
      <div className="flex items-center gap-2 mb-6 overflow-x-auto">
        {steps.map((s, i) => (<div key={i} className="flex items-center gap-2">
          <div className={`w-7 h-7 rounded-full flex items-center justify-center text-xs font-bold flex-shrink-0 ${i < step ? 'bg-accent text-white' : i === step ? 'bg-primary text-white' : 'bg-gray-200 text-gray-500'}`}>
            {i < step ? <Check size={14} /> : i + 1}
          </div>
          <span className={`text-xs font-semibold whitespace-nowrap ${i < step ? 'text-accent' : i === step ? 'text-primary' : 'text-gray-400'}`}>{s}</span>
          {i < steps.length - 1 && <div className={`w-10 h-0.5 ${i < step ? 'bg-accent' : 'bg-gray-200'}`} />}
        </div>))}
      </div>

      {step === 0 && (
        <Card className="max-w-xl mx-auto" padding="lg">
          <label className="block text-xs font-semibold text-gray-700 mb-1.5">Pilih Customer</label>
          <select className="w-full border border-gray-300 rounded-[6px] px-3 py-2.5 text-[14px] bg-white focus:outline-none focus:border-primary focus:ring-3 focus:ring-primary-50" value={customerId} onChange={(e) => setCustomerId(e.target.value)}>
            <option value="">-- Pilih Customer --</option>
            {customers.map((c: any) => <option key={c.id} value={c.id}>{c.name} — {c.phone || '-'}</option>)}
          </select>
          <div className="flex justify-end mt-6"><Button disabled={!customerId} onClick={() => setStep(1)}>Lanjut →</Button></div>
        </Card>
      )}

      {step === 1 && (
        <Card className="max-w-3xl mx-auto">
          {selectedCustomer && (
            <div className="bg-accent-light px-3.5 py-3 rounded-[6px] mb-4 flex items-center gap-2.5">
              <Check size={18} className="text-accent" />
              <div className="flex-1 text-[13px]"><strong>{selectedCustomer.name}</strong> · {selectedCustomer.phone || '-'}</div>
              <Button variant="secondary" size="sm" onClick={() => setStep(0)}>Ganti</Button>
            </div>
          )}
          <h3 className="text-base font-bold mb-3">Tambah Item Pesanan</h3>
          <div className="overflow-x-auto rounded-[10px] border border-gray-200 mb-4">
            <table className="w-full border-collapse">
              <thead className="bg-gray-50 border-b border-gray-200"><tr><th className="px-3 py-2.5 text-left text-[11px] font-bold text-gray-500 uppercase">Produk</th><th className="px-3 py-2.5 text-[11px] font-bold text-gray-500 uppercase w-[100px]">Qty</th><th className="px-3 py-2.5 text-[11px] font-bold text-gray-500 uppercase w-[140px]">Harga Satuan</th><th className="px-3 py-2.5 text-[11px] font-bold text-gray-500 uppercase w-[130px]">Subtotal</th><th className="w-10"></th></tr></thead>
              <tbody>
                {items.map((item, i) => (
                  <tr key={i} className="border-b border-gray-100">
                    <td className="px-3 py-2"><select className="w-full border border-gray-300 rounded-[6px] px-2 py-2 text-[13px]" value={item.product_id || ''} onChange={(e) => updateItem(i, 'product_id', e.target.value || null)}><option value="" disabled>-- Pilih Produk --</option>{products.map((p: any) => <option key={p.id} value={p.id}>{p.name}</option>)}</select></td>
                    <td className="px-3 py-2"><input type="number" className="w-full border border-gray-300 rounded-[6px] px-2 py-2 text-[13px]" value={item.quantity} onChange={(e) => updateItem(i, 'quantity', Number(e.target.value))} min={1} /></td>
                    <td className="px-3 py-2"><input type="number" className="w-full border border-gray-300 rounded-[6px] px-2 py-2 text-[13px]" value={item.unit_price} onChange={(e) => updateItem(i, 'unit_price', Number(e.target.value))} /></td>
                    <td className="px-3 py-2 text-right font-semibold text-[13px] tabular-nums">{formatRupiah(item.quantity * item.unit_price)}</td>
                    <td className="px-2">{items.length > 1 && <button onClick={() => removeItem(i)} className="text-danger p-1"><Trash2 size={14} /></button>}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
          <Button variant="secondary" fullWidth className="border-dashed mb-4" onClick={addItem}><Plus size={15} /> Tambah Item</Button>
          <div className="bg-primary-50 p-4 rounded-[10px] mb-4">
            <div className="flex justify-between text-[13px] mb-1"><span className="text-gray-700">Subtotal ({items.length} item)</span><span className="font-semibold">{formatRupiah(subtotal)}</span></div>
            <div className="border-t border-primary-100 mt-2 pt-2 flex justify-between"><strong>Total</strong><strong className="text-primary text-lg">{formatRupiah(subtotal)}</strong></div>
          </div>
          <div className="flex justify-between"><Button variant="secondary" onClick={() => setStep(0)}>← Kembali</Button><div className="flex gap-2"><Button variant="secondary">Simpan Draft</Button><Button disabled={items.every(it => !it.product_name && !it.product_id)} onClick={() => setStep(2)}>Lanjut: Jadwal →</Button></div></div>
        </Card>
      )}

      {step === 2 && (
        <Card className="max-w-xl mx-auto" padding="lg">
          <div className="grid sm:grid-cols-2 gap-3 mb-4">
            <Input label="Tanggal Order" type="date" value={orderDate} onChange={(e) => setOrderDate(e.target.value)} />
            <Input label="Tanggal Kirim" type="date" value={deliveryDate} onChange={(e) => setDeliveryDate(e.target.value)} />
            <Input label="Diskon (Rp)" type="number" value={discount} onChange={(e) => setDiscount(Number(e.target.value))} />
            <Input label="Pajak (Rp)" type="number" value={tax} onChange={(e) => setTax(Number(e.target.value))} />
          </div>
          <div className="mb-4"><label className="block text-xs font-semibold text-gray-700 mb-1.5">Catatan (opsional)</label><textarea className="w-full border border-gray-300 rounded-[6px] px-3 py-2.5 text-[14px] min-h-[80px] focus:outline-none focus:border-primary focus:ring-3 focus:ring-primary-50" placeholder="Cth: Bahan tanpa pengawet" value={notes} onChange={(e) => setNotes(e.target.value)} /></div>
          <div className="flex justify-between"><Button variant="secondary" onClick={() => setStep(1)}>← Kembali</Button><Button onClick={() => setStep(3)}>Lanjut →</Button></div>
        </Card>
      )}

      {step === 3 && (
        <Card className="max-w-xl mx-auto" padding="lg">
          <h3 className="text-base font-bold mb-4">Review Pesanan</h3>
          <p className="text-[13px] mb-1"><strong>Customer:</strong> {selectedCustomer?.name}</p>
          <p className="text-[13px] mb-3"><strong>Kirim:</strong> {deliveryDate}</p>
          <div className="rounded-[10px] border border-gray-200 overflow-hidden mb-4">
            <table className="w-full border-collapse"><thead className="bg-gray-50 border-b border-gray-200"><tr><th className="p-2.5 text-left text-[11px] font-bold text-gray-500 uppercase">Produk</th><th className="p-2.5 text-right text-[11px] font-bold text-gray-500 uppercase">Qty</th><th className="p-2.5 text-right text-[11px] font-bold text-gray-500 uppercase">Harga</th><th className="p-2.5 text-right text-[11px] font-bold text-gray-500 uppercase">Subtotal</th></tr></thead>
            <tbody>{items.filter(it => it.product_name || it.product_id).map((it, i) => (<tr key={i} className="border-b border-gray-100"><td className="p-2.5 text-[13px]">{it.product_name}</td><td className="p-2.5 text-right text-[13px]">{it.quantity}</td><td className="p-2.5 text-right text-[13px]">{formatRupiah(it.unit_price)}</td><td className="p-2.5 text-right text-[13px] font-semibold">{formatRupiah(it.quantity * it.unit_price)}</td></tr>))}</tbody></table>
          </div>
          <div className="bg-primary-50 p-4 rounded-[10px] mb-4 space-y-1">
            <div className="flex justify-between text-[13px]"><span>Subtotal</span><span className="font-semibold">{formatRupiah(subtotal)}</span></div>
            {discount > 0 && <div className="flex justify-between text-[13px]"><span>Diskon</span><span>-{formatRupiah(discount)}</span></div>}
            <div className="border-t border-primary-100 mt-2 pt-2 flex justify-between font-bold"><span>Total</span><span className="text-primary text-lg">{formatRupiah(total)}</span></div>
          </div>
          <div className="flex justify-between"><Button variant="secondary" onClick={() => setStep(2)}>← Kembali</Button><Button loading={createPO.isPending} onClick={handleSubmit}>Simpan sebagai Draft</Button></div>
        </Card>
      )}
    </div>
  );
}
