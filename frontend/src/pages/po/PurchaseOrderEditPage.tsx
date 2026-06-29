import { useState, useEffect } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
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
import { Trash2, Check } from 'lucide-react';
import { LoadingSpinner } from '@/components/ui/loading-spinner';
import { SearchableSelect } from '@/components/ui/searchable-select';

interface ItemRow { product_id: string | null; product_name: string; quantity: number; unit_price: number; notes: string; }

export default function PurchaseOrderEditPage() {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const queryClient = useQueryClient();

  const [step, setStep] = useState(0);
  const [customerId, setCustomerId] = useState('');
  const [deliveryDate, setDeliveryDate] = useState('');
  const [orderDate, setOrderDate] = useState('');
  const [discount, setDiscount] = useState(0);
  const [tax, setTax] = useState(0);
  const [shippingCost, setShippingCost] = useState(0);
  const [notes, setNotes] = useState('');
  const [items, setItems] = useState<ItemRow[]>([]);

  const { data: poData, isLoading: isLoadingPo } = useQuery({
    queryKey: ['purchase-order', id],
    queryFn: () => purchaseOrdersApi.show(id!),
    enabled: !!id,
  });

  const { data: customersData } = useQuery({ queryKey: ['customers-all'], queryFn: () => customersApi.list({ per_page: 100 }) });
  const { data: productsData } = useQuery({ queryKey: ['products-all'], queryFn: () => productsApi.list({ per_page: 100 }) });
  const customers = customersData?.data?.data || [];
  const products = productsData?.data?.data || [];

  useEffect(() => {
    if (poData?.data?.data) {
      const po = poData.data.data;
      setCustomerId(po.customer_id);
      setOrderDate(po.order_date.slice(0, 10));
      setDeliveryDate(po.delivery_date.slice(0, 10));
      setDiscount(Number(po.discount));
      setTax(Number(po.tax));
      setShippingCost(Number(po.shipping_cost || 0));
      setNotes(po.notes || '');

      if (po.items && po.items.length > 0) {
        setItems(po.items.map(it => ({
          product_id: it.product_id,
          product_name: it.product_name,
          quantity: Number(it.quantity),
          unit_price: Number(it.unit_price),
          notes: it.notes || ''
        })));
      }
    }
  }, [poData]);

  const updatePO = useMutation({
    mutationFn: (data: any) => purchaseOrdersApi.update(id!, data),
    onSuccess: () => { 
      toast.success('PO berhasil diperbarui!'); 
      queryClient.invalidateQueries({ queryKey: ['purchase-order', id] });
      navigate(ROUTES.PO_DETAIL(id!)); 
    },
    onError: (err: any) => toast.error(err.response?.data?.message || 'Gagal.'),
  });

  const removeItem = (i: number) => setItems(items.filter((_, idx) => idx !== i));
  const updateItem = (i: number, field: keyof ItemRow, value: any) => {
    const next = [...items];
    (next[i] as any)[field] = value;
    if (field === 'product_id' && value) { const p = (products as any[]).find((p: any) => p.id === value); if (p) { (next[i] as any).product_name = p.name; (next[i] as any).unit_price = p.price; } }
    setItems(next);
  };

  const subtotal = items.reduce((sum, it) => sum + it.quantity * it.unit_price, 0);
  const total = subtotal - discount + tax + shippingCost;
  const handleSubmit = () => { updatePO.mutate({ customer_id: customerId, order_date: orderDate, delivery_date: deliveryDate, discount, tax, shipping_cost: shippingCost, notes, items }); };
  const steps = ['Customer', 'Items', 'Jadwal & Bayar', 'Review'];
  const selectedCustomer = customers.find((c: any) => c.id === customerId);

  if (isLoadingPo) {
    return <div className="flex justify-center p-12"><LoadingSpinner size="lg" /></div>;
  }

  return (
    <div>
      <PageHeader title={`Edit PO: ${poData?.data?.data?.po_number || ''}`} description="Perbarui detail pesanan" />

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
          <SearchableSelect
            options={customers.map((c: any) => ({ value: c.id, label: `${c.name} — ${c.phone || '-'}` }))}
            value={customerId}
            onChange={setCustomerId}
            placeholder="-- Pilih Customer --"
          />
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
          <h3 className="text-base font-bold mb-3">Item Pesanan</h3>
          <div className="overflow-x-auto rounded-[10px] border border-gray-200 mb-4">
            <table className="w-full border-collapse">
              <thead className="bg-gray-50 border-b border-gray-200"><tr><th className="px-3 py-2.5 text-left text-[11px] font-bold text-gray-500 uppercase">Produk</th><th className="px-3 py-2.5 text-[11px] font-bold text-gray-500 uppercase w-[100px]">Qty</th><th className="px-3 py-2.5 text-[11px] font-bold text-gray-500 uppercase w-[140px]">Harga Satuan</th><th className="px-3 py-2.5 text-[11px] font-bold text-gray-500 uppercase w-[130px]">Subtotal</th><th className="w-10"></th></tr></thead>
              <tbody>
                {items.map((item, i) => (
                  <tr key={i} className="border-b border-gray-100">
                    <td className="px-3 py-2">
                      {item.product_id ? (
                         <div className="px-2 py-2 text-[13px] font-medium bg-gray-50 rounded-[6px] border border-gray-200">{item.product_name}</div>
                      ) : (
                         <input type="text" className="w-full border border-gray-300 rounded-[6px] px-2 py-2 text-[13px]" placeholder="Nama Produk Manual" value={item.product_name} onChange={(e) => updateItem(i, 'product_name', e.target.value)} />
                      )}
                    </td>
                    <td className="px-3 py-2"><input type="number" className="w-full border border-gray-300 rounded-[6px] px-2 py-2 text-[13px]" value={item.quantity} onChange={(e) => updateItem(i, 'quantity', Number(e.target.value))} min={1} /></td>
                    <td className="px-3 py-2"><input type="number" className="w-full border border-gray-300 rounded-[6px] px-2 py-2 text-[13px]" value={item.unit_price} onChange={(e) => updateItem(i, 'unit_price', Number(e.target.value))} /></td>
                    <td className="px-3 py-2 text-right font-semibold text-[13px] tabular-nums">{formatRupiah(item.quantity * item.unit_price)}</td>
                    <td className="px-2"><button onClick={() => removeItem(i)} className="text-danger p-1 hover:bg-red-50 rounded-md"><Trash2 size={14} /></button></td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
          <div className="mb-4">
            <SearchableSelect
              options={products.map((p: any) => ({ value: p.id, label: p.name }))}
              value=""
              onChange={(val) => {
                if (!val) return;
                const p = products.find((x: any) => x.id === val);
                if (p) {
                  setItems([...items, { product_id: p.id, product_name: p.name, quantity: 1, unit_price: p.price, notes: '' }]);
                }
              }}
              placeholder="+ Tambah Produk dari Katalog"
            />
          </div>
          <div className="bg-primary-50 p-4 rounded-[10px] mb-4">
            <div className="flex justify-between text-[13px] mb-1"><span className="text-gray-700">Subtotal ({items.length} item)</span><span className="font-semibold">{formatRupiah(subtotal)}</span></div>
            <div className="border-t border-primary-100 mt-2 pt-2 flex justify-between"><strong>Total Item</strong><strong className="text-primary text-lg">{formatRupiah(subtotal)}</strong></div>
          </div>
          <div className="flex justify-between">
            <Button variant="secondary" onClick={() => navigate(-1)}>Batal</Button>
            <div className="flex gap-2">
              <Button variant="secondary" onClick={() => setStep(0)}>← Customer</Button>
              <Button disabled={items.length === 0 || items.every(it => !it.product_name)} onClick={() => setStep(2)}>Lanjut: Jadwal →</Button>
            </div>
          </div>
        </Card>
      )}

      {step === 2 && (
        <Card className="max-w-xl mx-auto" padding="lg">
          <div className="grid sm:grid-cols-2 gap-3 mb-4">
            <Input label="Tanggal Order" type="date" value={orderDate} onChange={(e) => setOrderDate(e.target.value)} />
            <Input label="Tanggal Kirim" type="date" value={deliveryDate} onChange={(e) => setDeliveryDate(e.target.value)} />
            <Input label="Diskon (Rp)" type="number" value={discount} onChange={(e) => setDiscount(Number(e.target.value))} />
            <Input label="Pajak (Rp)" type="number" value={tax} onChange={(e) => setTax(Number(e.target.value))} />
            <Input label="Ongkos Kirim (Rp)" type="number" value={shippingCost} onChange={(e) => setShippingCost(Number(e.target.value))} />
          </div>
          <div className="mb-4"><label className="block text-xs font-semibold text-gray-700 mb-1.5">Catatan (opsional)</label><textarea className="w-full border border-gray-300 rounded-[6px] px-3 py-2.5 text-[14px] min-h-[80px] focus:outline-none focus:border-primary focus:ring-3 focus:ring-primary-50" placeholder="Cth: Bahan tanpa pengawet" value={notes} onChange={(e) => setNotes(e.target.value)} /></div>
          <div className="flex justify-between"><Button variant="secondary" onClick={() => setStep(1)}>← Items</Button><Button onClick={() => setStep(3)}>Review & Simpan →</Button></div>
        </Card>
      )}

      {step === 3 && (
        <Card className="max-w-xl mx-auto" padding="lg">
          <h3 className="text-base font-bold mb-4">Review Perubahan PO</h3>
          <p className="text-[13px] mb-1"><strong>Customer:</strong> {selectedCustomer?.name}</p>
          <p className="text-[13px] mb-3"><strong>Kirim:</strong> {deliveryDate}</p>
          <div className="rounded-[10px] border border-gray-200 overflow-hidden mb-4">
            <table className="w-full border-collapse"><thead className="bg-gray-50 border-b border-gray-200"><tr><th className="p-2.5 text-left text-[11px] font-bold text-gray-500 uppercase">Produk</th><th className="p-2.5 text-right text-[11px] font-bold text-gray-500 uppercase">Qty</th><th className="p-2.5 text-right text-[11px] font-bold text-gray-500 uppercase">Harga</th><th className="p-2.5 text-right text-[11px] font-bold text-gray-500 uppercase">Subtotal</th></tr></thead>
            <tbody>{items.filter(it => it.product_name).map((it, i) => (<tr key={i} className="border-b border-gray-100"><td className="p-2.5 text-[13px]">{it.product_name}</td><td className="p-2.5 text-right text-[13px]">{it.quantity}</td><td className="p-2.5 text-right text-[13px]">{formatRupiah(it.unit_price)}</td><td className="p-2.5 text-right text-[13px] font-semibold">{formatRupiah(it.quantity * it.unit_price)}</td></tr>))}</tbody></table>
          </div>
          <div className="bg-primary-50 p-4 rounded-[10px] mb-4 space-y-1">
            <div className="flex justify-between text-[13px]"><span>Subtotal</span><span className="font-semibold">{formatRupiah(subtotal)}</span></div>
            {discount > 0 && <div className="flex justify-between text-[13px]"><span>Diskon</span><span>-{formatRupiah(discount)}</span></div>}
            {tax > 0 && <div className="flex justify-between text-[13px]"><span>Pajak</span><span>{formatRupiah(tax)}</span></div>}
            {shippingCost > 0 && <div className="flex justify-between text-[13px]"><span>Ongkos Kirim</span><span>{formatRupiah(shippingCost)}</span></div>}
            <div className="border-t border-primary-100 mt-2 pt-2 flex justify-between font-bold"><span>Total Akhir</span><span className="text-primary text-lg">{formatRupiah(total)}</span></div>
          </div>
          <div className="flex justify-between"><Button variant="secondary" onClick={() => setStep(2)}>← Jadwal</Button><Button loading={updatePO.isPending} onClick={handleSubmit}>Simpan Perubahan</Button></div>
        </Card>
      )}
    </div>
  );
}
