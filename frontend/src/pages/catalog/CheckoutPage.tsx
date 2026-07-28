import { useState, useMemo, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { useQuery } from '@tanstack/react-query';
import apiClient from '@/api/client';
import { publicCatalogApi } from '@/api/public-catalog';
import { loadSnap } from '@/lib/midtrans';
import { Product } from '@/types/product';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { LoadingSpinner } from '@/components/ui/loading-spinner';
import { DeliveryDatePicker, toLocalISO } from '@/components/ui/delivery-date-picker';
import { formatRupiah } from '@/lib/utils';
import { ArrowLeft, Store, User, Truck, Wallet, Receipt, Check, MapPin, CalendarDays, CreditCard, MessageCircle, Minus, Plus, Trash2 } from 'lucide-react';
import { toast } from 'sonner';

interface ShippingOption {
  id: string;
  label: string;
  cost: number;
  note?: string;
}

interface CartItem {
  product: Product;
  quantity: number;
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

export default function CheckoutPage() {
  const { slug } = useParams<{ slug: string }>();
  const navigate = useNavigate();
  const cartStorageKey = `catalog-cart-${slug}`;

  const [cart, setCart] = useState<CartItem[]>(() => {
    try {
      const raw = localStorage.getItem(cartStorageKey);
      return raw ? (JSON.parse(raw) as CartItem[]) : [];
    } catch {
      return [];
    }
  });

  const [customerName, setCustomerName] = useState('');
  const [customerPhone, setCustomerPhone] = useState('');
  const [customerAddress, setCustomerAddress] = useState('');
  const [fulfillmentType, setFulfillmentType] = useState<'pickup' | 'delivery'>('delivery');
  const [deliveryMethodId, setDeliveryMethodId] = useState<string>('');
  const [paymentPref, setPaymentPref] = useState<'online' | 'whatsapp'>('whatsapp');
  const [deliveryDate, setDeliveryDate] = useState<string>(() => toLocalISO(new Date()));
  const [isSubmitting, setIsSubmitting] = useState(false);

  // Keep localStorage in sync so edits here reflect back on the catalog page.
  useEffect(() => {
    try {
      localStorage.setItem(cartStorageKey, JSON.stringify(cart));
    } catch {
      /* ignore quota errors */
    }
  }, [cart, cartStorageKey]);

  const handleUpdateQuantity = (productId: string, delta: number) => {
    setCart(prev => {
      const existing = prev.find(item => item.product.id === productId);
      if (!existing) return prev;
      const newQty = existing.quantity + delta;
      if (newQty <= 0) return prev.filter(item => item.product.id !== productId);
      return prev.map(item => item.product.id === productId ? { ...item, quantity: newQty } : item);
    });
  };

  const handleRemoveItem = (productId: string) => {
    setCart(prev => prev.filter(item => item.product.id !== productId));
  };

  const { data: catalog, isLoading, isError } = useQuery({
    queryKey: ['catalog', slug],
    queryFn: () => apiClient.get<CatalogData>(`/api/catalog/${slug}`).then(res => res.data),
    retry: false,
  });

  const onlinePaymentAvailable = catalog?.store?.online_payment_available ?? false;

  // Delivery options require an address (flat rates + "ongkir dihitung kemudian").
  // If the store has configured nothing at all, we fall back to offering both
  // pickup and a "confirmed via WhatsApp" delivery so the choice always appears.
  const { deliveryOptions, pickupAvailable } = useMemo(() => {
    const s = catalog?.store?.shipping;
    const opts: ShippingOption[] = (s?.flat_rates ?? [])
      .filter(r => r.name.trim())
      .map(r => ({ id: r.name, label: r.name, cost: r.cost }));
    if (s?.allow_shipping_tbd) opts.push({ id: 'tbd', label: 'Ongkir dihitung kemudian', cost: 0, note: 'Dikonfirmasi via WhatsApp' });

    const configuredPickup = s?.allow_pickup ?? false;
    const noConfig = opts.length === 0 && !configuredPickup;
    if (noConfig) {
      return {
        deliveryOptions: [{ id: 'tbd', label: 'Ongkir dihitung kemudian', cost: 0, note: 'Dikonfirmasi via WhatsApp' }] as ShippingOption[],
        pickupAvailable: true,
      };
    }
    return { deliveryOptions: opts, pickupAvailable: configuredPickup };
  }, [catalog?.store?.shipping]);

  const deliveryAvailable = deliveryOptions.length > 0;

  // Preselect sensible defaults once catalog loads.
  useEffect(() => {
    if (!catalog) return;
    setPaymentPref(onlinePaymentAvailable ? 'online' : 'whatsapp');
    // Default the fulfillment type to whatever the store actually supports.
    if (!deliveryAvailable && pickupAvailable) setFulfillmentType('pickup');
    else if (deliveryAvailable && !pickupAvailable) setFulfillmentType('delivery');
    setDeliveryMethodId(prev => prev || (deliveryOptions[0]?.id ?? ''));
  }, [catalog, onlinePaymentAvailable, deliveryAvailable, pickupAvailable, deliveryOptions]);

  const cartTotal = useMemo(() => cart.reduce((sum, item) => sum + (item.product.price * item.quantity), 0), [cart]);

  // The shipping_method value the backend expects: 'pickup' or a delivery option id.
  const effectiveShippingId = fulfillmentType === 'pickup' ? 'pickup' : deliveryMethodId;
  const selectedDelivery = deliveryOptions.find(o => o.id === deliveryMethodId);
  const shippingCost = fulfillmentType === 'pickup' ? 0 : (selectedDelivery?.cost ?? 0);
  const shippingLabel = fulfillmentType === 'pickup' ? 'Ambil Sendiri' : (selectedDelivery?.label ?? null);
  const grandTotal = cartTotal + shippingCost;
  const addressRequired = fulfillmentType === 'delivery';

  const clearCart = () => {
    setCart([]);
    try { localStorage.removeItem(cartStorageKey); } catch { /* ignore */ }
  };

  const sendViaWhatsApp = (poNumber: string) => {
    let text = `Halo ${catalog?.organization.name}, saya ingin memesan:\n\n`;
    if (poNumber) text += `*No. PO: ${poNumber}*\n\n`;
    text += `*Data Pemesan*\nNama: ${customerName}\nNo. HP: ${customerPhone}\n`;
    if (fulfillmentType === 'delivery' && customerAddress.trim()) text += `Alamat: ${customerAddress}\n`;
    text += `\n`;
    text += `*Metode:* ${fulfillmentType === 'pickup' ? 'Ambil Sendiri (Pick-up)' : 'Dikirim (Delivery)'}\n`;
    text += `*Tanggal ${fulfillmentType === 'pickup' ? 'Ambil' : 'Kirim'}:* ${deliveryDate}\n\n`;
    text += `*Detail Pesanan*\n`;
    cart.forEach((item, i) => {
      text += `${i + 1}. ${item.product.name} (x${item.quantity}) - ${formatRupiah(item.product.price * item.quantity)}\n`;
    });
    if (shippingLabel) text += `\nPengiriman: ${shippingLabel}${shippingCost > 0 ? ` (${formatRupiah(shippingCost)})` : ''}`;
    text += `\nTotal: *${formatRupiah(grandTotal)}*\n\nMohon info ketersediaannya. Terima kasih.`;

    let phone = catalog?.organization.phone?.replace(/[^0-9]/g, '') || '';
    if (phone.startsWith('0')) phone = '62' + phone.substring(1);
    window.open(`https://wa.me/${phone}?text=${encodeURIComponent(text)}`, '_blank');
  };

  const goToOrderStatus = (poNumber: string) => {
    navigate(`/katalog/${slug}/pesanan/${encodeURIComponent(poNumber)}?phone=${encodeURIComponent(customerPhone.trim())}`);
  };

  const handleSubmitOrder = async () => {
    if (!customerName.trim() || !customerPhone.trim()) {
      toast.error('Mohon lengkapi Nama dan No. HP.');
      return;
    }
    if (addressRequired && !customerAddress.trim()) {
      toast.error('Mohon isi Alamat Pengiriman untuk pesanan yang dikirim.');
      return;
    }
    if (!deliveryDate) {
      toast.error('Pilih tanggal terlebih dahulu.');
      return;
    }
    if (fulfillmentType === 'delivery' && deliveryAvailable && !deliveryMethodId) {
      toast.error('Pilih metode pengiriman terlebih dahulu.');
      return;
    }

    setIsSubmitting(true);
    try {
      const res = await publicCatalogApi.checkout(slug!, {
        customer_name: customerName.trim(),
        customer_phone: customerPhone.trim(),
        customer_address: customerAddress.trim(),
        shipping_method: effectiveShippingId || null,
        payment_preference: paymentPref,
        delivery_date: deliveryDate || null,
        items: cart.map(item => ({
          product_id: item.product.id,
          product_name: item.product.name,
          quantity: item.quantity,
          unit_price: item.product.price,
        })),
      });

      const poNumber = res.data.po_number;

      // Remember the last order so the customer can re-open its status later.
      try {
        localStorage.setItem(`catalog-last-order-${slug}`, JSON.stringify({ poNumber, phone: customerPhone.trim() }));
      } catch { /* ignore */ }

      // Online payment path
      if (paymentPref === 'online' && res.data.online_payment_available) {
        try {
          const pay = await publicCatalogApi.pay(slug!, poNumber, customerPhone.trim());
          const snap = await loadSnap(pay.data.client_key, pay.data.is_production);
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
          clearCart();
          goToOrderStatus(poNumber);
          return;
        }
      }

      // WhatsApp path
      setIsSubmitting(false);
      sendViaWhatsApp(poNumber);
      clearCart();
      toast.success(`Pesanan ${poNumber} berhasil dibuat! Lanjutkan percakapan di WhatsApp.`, { duration: 5000 });
      goToOrderStatus(poNumber);
    } catch (err: any) {
      setIsSubmitting(false);
      const msg = err?.response?.data?.errors?.items?.[0]
        || err?.response?.data?.message
        || 'Gagal membuat pesanan. Silakan coba lagi.';
      toast.error(msg);
    }
  };

  if (isLoading) {
    return (
      <div className="min-h-screen bg-gray-50 flex flex-col items-center justify-center space-y-4">
        <LoadingSpinner size="lg" />
        <p className="text-gray-500 font-medium">Memuat data checkout...</p>
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
        <p className="text-gray-500 mb-4">Toko atau organisasi yang Anda cari tidak ada atau link salah.</p>
        <Button variant="secondary" onClick={() => navigate(`/katalog/${slug}`)}>Kembali ke Katalog</Button>
      </div>
    );
  }

  // Empty cart — nothing to check out.
  if (cart.length === 0) {
    return (
      <div className="min-h-screen bg-gray-50 flex flex-col items-center justify-center p-6 text-center">
        <div className="w-16 h-16 bg-primary-50 text-primary rounded-full flex items-center justify-center mb-4">
          <Receipt size={32} />
        </div>
        <h1 className="text-2xl font-bold text-gray-900 mb-2">Keranjang Kosong</h1>
        <p className="text-gray-500 mb-4">Belum ada produk yang dipilih untuk dipesan.</p>
        <Button onClick={() => navigate(`/katalog/${slug}`)}>Kembali ke Katalog</Button>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
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
            <div className="min-w-0">
              <h1 className="text-[17px] font-extrabold text-gray-900 leading-tight">Checkout Pesanan</h1>
              <p className="text-[12px] text-gray-500 line-clamp-1">{catalog.organization.name}</p>
            </div>
          </div>
        </div>
      </header>

      {/* Content */}
      <main className="max-w-2xl mx-auto px-4 sm:px-6 py-6 space-y-5 pb-36">
        {/* Metode Pengambilan: Pick-up vs Delivery */}
        {(pickupAvailable || deliveryAvailable) && (
          <section className="bg-white rounded-2xl border border-gray-100 shadow-sm p-4 space-y-3">
            <div className="flex items-center gap-2">
              <Truck size={15} className="text-primary" />
              <h4 className="text-[12px] font-bold uppercase tracking-wider text-gray-700">Metode Pengiriman</h4>
            </div>

            {/* Segmented toggle */}
            <div className="flex gap-2">
              {pickupAvailable && (
                <button
                  type="button"
                  onClick={() => setFulfillmentType('pickup')}
                  className={`flex-1 flex flex-col items-center gap-1 px-3 py-3 rounded-2xl border transition-all ${fulfillmentType === 'pickup' ? 'border-primary bg-primary text-white shadow-md shadow-primary/20' : 'border-gray-200 bg-white text-gray-700 hover:border-primary/40'}`}
                >
                  <Store size={20} className={fulfillmentType === 'pickup' ? 'text-white' : 'text-primary'} />
                  <span className="text-[13px] font-bold">Ambil Sendiri</span>
                  <span className={`text-[10px] ${fulfillmentType === 'pickup' ? 'text-white/80' : 'text-gray-400'}`}>Pick-up di lokasi</span>
                </button>
              )}
              {deliveryAvailable && (
                <button
                  type="button"
                  onClick={() => setFulfillmentType('delivery')}
                  className={`flex-1 flex flex-col items-center gap-1 px-3 py-3 rounded-2xl border transition-all ${fulfillmentType === 'delivery' ? 'border-primary bg-primary text-white shadow-md shadow-primary/20' : 'border-gray-200 bg-white text-gray-700 hover:border-primary/40'}`}
                >
                  <Truck size={20} className={fulfillmentType === 'delivery' ? 'text-white' : 'text-primary'} />
                  <span className="text-[13px] font-bold">Dikirim</span>
                  <span className={`text-[10px] ${fulfillmentType === 'delivery' ? 'text-white/80' : 'text-gray-400'}`}>Delivery ke alamat</span>
                </button>
              )}
            </div>

            {/* Pickup location info */}
            {fulfillmentType === 'pickup' && (
              <div className="flex items-start gap-2.5 rounded-xl bg-primary-50 border border-primary-100 p-3">
                <MapPin size={16} className="text-primary flex-shrink-0 mt-0.5" />
                <div className="text-[12px]">
                  <p className="font-semibold text-gray-800">Ambil di lokasi toko</p>
                  <p className="text-gray-600">{catalog.organization.address || 'Alamat & jam pengambilan dikonfirmasi via WhatsApp.'}</p>
                </div>
              </div>
            )}

            {/* Delivery method options */}
            {fulfillmentType === 'delivery' && deliveryOptions.length > 0 && (
              <div className="space-y-2 pt-1">
                <p className="text-[11px] font-semibold text-gray-500 uppercase tracking-wider">Pilih Pengiriman</p>
                {deliveryOptions.map(opt => {
                  const active = deliveryMethodId === opt.id;
                  return (
                    <button
                      type="button"
                      key={opt.id}
                      onClick={() => setDeliveryMethodId(opt.id)}
                      className={`w-full flex items-center justify-between gap-3 px-4 py-3 rounded-2xl border text-left transition-all ${active ? 'border-primary bg-primary shadow-md shadow-primary/20' : 'border-gray-200 bg-white hover:border-primary/40'}`}
                    >
                      <div>
                        <span className={`block text-[13px] font-semibold ${active ? 'text-white' : 'text-gray-800'}`}>{opt.label}</span>
                        {opt.note && <p className={`text-[11px] ${active ? 'text-white/80' : 'text-gray-500'}`}>{opt.note}</p>}
                      </div>
                      <span className={`text-[13px] font-bold whitespace-nowrap ${active ? 'text-white' : 'text-primary'}`}>{opt.cost > 0 ? formatRupiah(opt.cost) : 'Gratis'}</span>
                    </button>
                  );
                })}
              </div>
            )}
          </section>
        )}

        {/* Data Penerima */}
        <section className="bg-white rounded-2xl border border-gray-100 shadow-sm p-4 space-y-3.5">
          <div className="flex items-center gap-2">
            <User size={15} className="text-primary" />
            <h4 className="text-[12px] font-bold uppercase tracking-wider text-gray-700">Data Penerima</h4>
          </div>
          <Input label="Nama Lengkap" placeholder="Cth: Budi Santoso" value={customerName} onChange={(e) => setCustomerName(e.target.value)} />
          <Input label="No. WhatsApp" placeholder="Cth: 08123456789" value={customerPhone} onChange={(e) => setCustomerPhone(e.target.value)} />
          {addressRequired && (
            <div className="flex flex-col gap-1.5">
              <label className="text-xs font-semibold text-gray-700 flex items-center gap-1.5">
                <MapPin size={13} className="text-gray-400" /> Alamat Pengiriman
              </label>
              <textarea
                className="w-full border border-gray-300 rounded-[6px] px-3 py-2.5 text-[14px] min-h-[80px] focus:outline-none focus:border-primary focus:ring-3 focus:ring-primary-50"
                placeholder="Cth: Jl. Sudirman No. 12, RT 01/02, Jakarta"
                value={customerAddress}
                onChange={(e) => setCustomerAddress(e.target.value)}
              />
            </div>
          )}
        </section>

        {/* Jadwal */}
        <section className="bg-white rounded-2xl border border-gray-100 shadow-sm p-4 space-y-1">
          <div className="flex items-center gap-2 mb-1">
            <CalendarDays size={15} className="text-primary" />
            <h4 className="text-[12px] font-bold uppercase tracking-wider text-gray-700">{fulfillmentType === 'pickup' ? 'Jadwal Pengambilan' : 'Jadwal Pengiriman'}</h4>
          </div>
          <DeliveryDatePicker value={deliveryDate} onChange={setDeliveryDate} />
        </section>

        {/* Metode Pembayaran */}
        <section className="bg-white rounded-2xl border border-gray-100 shadow-sm p-4 space-y-3">
          <div className="flex items-center gap-2">
            <Wallet size={15} className="text-primary" />
            <h4 className="text-[12px] font-bold uppercase tracking-wider text-gray-700">Metode Pembayaran</h4>
          </div>
          <div className="grid grid-cols-1 gap-2">
            {onlinePaymentAvailable && (
              <button
                type="button"
                onClick={() => setPaymentPref('online')}
                className={`w-full flex items-center gap-3 px-4 py-3 rounded-2xl border text-left transition-all ${paymentPref === 'online' ? 'border-primary bg-primary shadow-md shadow-primary/20' : 'border-gray-200 bg-white hover:border-primary/40'}`}
              >
                <div className={`w-9 h-9 rounded-xl flex items-center justify-center flex-shrink-0 ${paymentPref === 'online' ? 'bg-white/20 text-white' : 'bg-primary-50 text-primary'}`}>
                  <CreditCard size={18} />
                </div>
                <div className="flex-1">
                  <span className={`block text-[13px] font-semibold ${paymentPref === 'online' ? 'text-white' : 'text-gray-800'}`}>Bayar Online Sekarang</span>
                  <p className={`text-[11px] ${paymentPref === 'online' ? 'text-white/80' : 'text-gray-500'}`}>Transfer, QRIS, e-wallet, kartu — aman via Midtrans.</p>
                </div>
                <div className={`w-5 h-5 rounded-full border-2 flex items-center justify-center flex-shrink-0 ${paymentPref === 'online' ? 'border-white bg-white' : 'border-gray-300'}`}>
                  {paymentPref === 'online' && <Check size={12} className="text-primary" strokeWidth={3} />}
                </div>
              </button>
            )}
            <button
              type="button"
              onClick={() => setPaymentPref('whatsapp')}
              className={`w-full flex items-center gap-3 px-4 py-3 rounded-2xl border text-left transition-all ${paymentPref === 'whatsapp' ? 'border-primary bg-primary shadow-md shadow-primary/20' : 'border-gray-200 bg-white hover:border-primary/40'}`}
            >
              <div className={`w-9 h-9 rounded-xl flex items-center justify-center flex-shrink-0 ${paymentPref === 'whatsapp' ? 'bg-white/20 text-white' : 'bg-green-50 text-green-600'}`}>
                <MessageCircle size={18} />
              </div>
              <div className="flex-1">
                <span className={`block text-[13px] font-semibold ${paymentPref === 'whatsapp' ? 'text-white' : 'text-gray-800'}`}>Pesan via WhatsApp</span>
                <p className={`text-[11px] ${paymentPref === 'whatsapp' ? 'text-white/80' : 'text-gray-500'}`}>Konfirmasi & pembayaran diatur langsung dengan penjual.</p>
              </div>
              <div className={`w-5 h-5 rounded-full border-2 flex items-center justify-center flex-shrink-0 ${paymentPref === 'whatsapp' ? 'border-white bg-white' : 'border-gray-300'}`}>
                {paymentPref === 'whatsapp' && <Check size={12} className="text-primary" strokeWidth={3} />}
              </div>
            </button>
          </div>
        </section>

        {/* Ringkasan Pesanan */}
        <section className="bg-white rounded-2xl border border-gray-100 shadow-sm p-4 space-y-3">
          <div className="flex items-center justify-between gap-2">
            <div className="flex items-center gap-2">
              <Receipt size={15} className="text-primary" />
              <h4 className="text-[12px] font-bold uppercase tracking-wider text-gray-700">Ringkasan Pesanan</h4>
            </div>
            <button
              type="button"
              onClick={() => navigate(`/katalog/${slug}`)}
              className="flex items-center gap-1 text-[12px] font-semibold text-primary hover:underline"
            >
              <Plus size={13} /> Tambah item
            </button>
          </div>
          <div className="space-y-3">
            {cart.map((item, idx) => (
              <div key={idx} className="flex items-center justify-between gap-3">
                <div className="min-w-0 flex-1">
                  <p className="text-[13px] font-semibold text-gray-800 line-clamp-1">{item.product.name}</p>
                  <p className="text-[12px] text-gray-500">{formatRupiah(item.product.price)} × {item.quantity} = <span className="font-semibold text-gray-700">{formatRupiah(item.product.price * item.quantity)}</span></p>
                </div>
                <div className="flex items-center gap-1.5 flex-shrink-0">
                  <div className="flex items-center border border-gray-200 rounded-full overflow-hidden">
                    <button
                      type="button"
                      onClick={() => handleUpdateQuantity(item.product.id, -1)}
                      className="w-8 h-8 flex items-center justify-center text-gray-600 hover:bg-gray-100 transition-colors"
                      aria-label="Kurangi"
                    >
                      <Minus size={14} />
                    </button>
                    <span className="w-7 text-center text-[13px] font-bold text-gray-900">{item.quantity}</span>
                    <button
                      type="button"
                      onClick={() => handleUpdateQuantity(item.product.id, 1)}
                      className="w-8 h-8 flex items-center justify-center text-gray-600 hover:bg-gray-100 transition-colors"
                      aria-label="Tambah"
                    >
                      <Plus size={14} />
                    </button>
                  </div>
                  <button
                    type="button"
                    onClick={() => handleRemoveItem(item.product.id)}
                    className="w-8 h-8 flex items-center justify-center rounded-full text-gray-400 hover:text-danger hover:bg-danger-light transition-colors"
                    aria-label="Hapus item"
                  >
                    <Trash2 size={15} />
                  </button>
                </div>
              </div>
            ))}
            <div className="border-t border-dashed border-gray-200 pt-2.5 space-y-1.5">
              <div className="flex justify-between text-[13px] text-gray-600">
                <span>Subtotal</span><span>{formatRupiah(cartTotal)}</span>
              </div>
              {shippingLabel && (
                <div className="flex justify-between text-[13px] text-gray-600">
                  <span>{fulfillmentType === 'pickup' ? shippingLabel : `Ongkir (${shippingLabel})`}</span>
                  <span>{shippingCost > 0 ? formatRupiah(shippingCost) : 'Gratis'}</span>
                </div>
              )}
            </div>
            <div className="border-t border-gray-200 pt-2.5 flex justify-between items-center">
              <span className="text-[14px] font-bold text-gray-900">Total</span>
              <span className="text-[18px] font-extrabold text-primary">{formatRupiah(grandTotal)}</span>
            </div>
          </div>
        </section>
      </main>

      {/* Sticky bottom action bar */}
      <div className="fixed bottom-0 left-0 right-0 bg-white border-t border-gray-200 z-20">
        <div className="max-w-2xl mx-auto px-4 sm:px-6 py-3 flex items-center gap-4">
          <div className="flex flex-col">
            <span className="text-[11px] font-medium text-gray-400 uppercase tracking-wider">Total Bayar</span>
            <span className="text-[18px] font-extrabold text-gray-900">{formatRupiah(grandTotal)}</span>
          </div>
          <Button
            onClick={handleSubmitOrder}
            className={`flex-1 rounded-full h-12 ${paymentPref === 'online' ? '' : 'bg-green-500 hover:bg-green-600 text-white border-0'}`}
            disabled={!customerName.trim() || !customerPhone.trim() || (addressRequired && !customerAddress.trim()) || isSubmitting}
            loading={isSubmitting}
          >
            {paymentPref === 'online' ? 'Lanjut ke Pembayaran' : 'Kirim ke WhatsApp'}
          </Button>
        </div>
      </div>
    </div>
  );
}
