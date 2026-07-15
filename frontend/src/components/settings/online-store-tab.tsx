import { useState, useEffect } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { toast } from 'sonner';
import { Card } from '@/components/ui/card';
import { Input } from '@/components/ui/input';
import { Button } from '@/components/ui/button';
import { onlineStoreApi, type FlatRate } from '@/api/online-store';
import { useQuota } from '@/hooks/use-quota';
import { formatRupiah } from '@/lib/utils';
import { Crown, CreditCard, Truck, Plus, Trash2, CheckCircle2, ShieldCheck, Copy, Webhook } from 'lucide-react';

function Toggle({ checked, onChange, disabled }: { checked: boolean; onChange: (v: boolean) => void; disabled?: boolean }) {
  return (
    <button
      type="button"
      role="switch"
      aria-checked={checked}
      disabled={disabled}
      onClick={() => onChange(!checked)}
      className={`relative inline-flex h-6 w-11 flex-shrink-0 items-center rounded-full transition-colors focus:outline-none disabled:opacity-40 disabled:cursor-not-allowed ${
        checked ? 'bg-emerald-500' : 'bg-gray-300'
      }`}
    >
      <span className={`inline-block h-4 w-4 transform rounded-full bg-white shadow-sm transition-transform ${checked ? 'translate-x-6' : 'translate-x-1'}`} />
    </button>
  );
}

export function OnlineStoreTab({ storeSlug }: { storeSlug?: string }) {
  const queryClient = useQueryClient();
  const { isPremiumOrAdmin } = useQuota();
  const webhookUrl = storeSlug ? `${window.location.origin}/api/webhooks/midtrans/${storeSlug}` : '';

  const { data, isLoading } = useQuery({
    queryKey: ['online-store'],
    queryFn: () => onlineStoreApi.get(),
  });
  const config = data?.data?.data;

  const [midtransEnabled, setMidtransEnabled] = useState(false);
  const [isProduction, setIsProduction] = useState(false);
  const [clientKey, setClientKey] = useState('');
  const [serverKey, setServerKey] = useState('');
  const [serverKeySet, setServerKeySet] = useState(false);
  const [flatRates, setFlatRates] = useState<FlatRate[]>([]);
  const [allowPickup, setAllowPickup] = useState(false);
  const [allowTbd, setAllowTbd] = useState(false);
  const [hydrated, setHydrated] = useState(false);

  useEffect(() => {
    if (config && !hydrated) {
      setMidtransEnabled(config.midtrans.is_enabled);
      setIsProduction(config.midtrans.is_production);
      setClientKey(config.midtrans.client_key);
      setServerKeySet(config.midtrans.server_key_set);
      setFlatRates(config.shipping.flat_rates);
      setAllowPickup(config.shipping.allow_pickup);
      setAllowTbd(config.shipping.allow_shipping_tbd);
      setHydrated(true);
    }
  }, [config, hydrated]);

  const save = useMutation({
    mutationFn: () => onlineStoreApi.update({
      midtrans: {
        is_enabled: midtransEnabled,
        is_production: isProduction,
        client_key: clientKey.trim(),
        server_key: serverKey.trim() || undefined,
      },
      shipping: { flat_rates: flatRates, allow_pickup: allowPickup, allow_shipping_tbd: allowTbd },
    }),
    onSuccess: (res) => {
      const updated = res.data.data;
      setServerKeySet(updated.midtrans.server_key_set);
      setServerKey('');
      queryClient.invalidateQueries({ queryKey: ['online-store'] });
      toast.success(res.data.message || 'Pengaturan tersimpan.');
    },
    onError: (err: any) => toast.error(err.response?.data?.message || 'Gagal menyimpan pengaturan.'),
  });

  const testConn = useMutation({
    mutationFn: () => onlineStoreApi.testMidtrans({ server_key: serverKey.trim() || undefined, is_production: isProduction }),
    onSuccess: (res) => {
      if (res.data.valid) toast.success(res.data.message);
      else toast.error(res.data.message);
    },
    onError: (err: any) => toast.error(err.response?.data?.message || 'Koneksi ke Midtrans gagal.'),
  });

  const addFlatRate = () => setFlatRates([...flatRates, { name: '', cost: 0 }]);
  const updateFlatRate = (i: number, patch: Partial<FlatRate>) =>
    setFlatRates(flatRates.map((r, idx) => (idx === i ? { ...r, ...patch } : r)));
  const removeFlatRate = (i: number) => setFlatRates(flatRates.filter((_, idx) => idx !== i));

  const handleSave = () => {
    if (midtransEnabled && !serverKeySet && !serverKey.trim()) {
      toast.error('Isi Server Key Midtrans sebelum mengaktifkan pembayaran online.');
      return;
    }
    if (flatRates.some(r => !r.name.trim())) {
      toast.error('Nama zona ongkir tidak boleh kosong.');
      return;
    }
    save.mutate();
  };

  // Free plan → upgrade CTA only
  if (!isPremiumOrAdmin) {
    return (
      <Card>
        <div className="flex flex-col items-center text-center py-8 px-4">
          <div className="w-14 h-14 rounded-2xl bg-amber-100 text-amber-600 flex items-center justify-center mb-4">
            <Crown size={28} />
          </div>
          <h3 className="text-[16px] font-bold text-gray-900">Toko Online adalah fitur Premium</h3>
          <p className="text-[13px] text-gray-500 mt-1.5 max-w-md">
            Aktifkan pembayaran online (Midtrans) dan atur ongkos kirim agar pelanggan bisa memesan
            dan membayar langsung dari katalog Anda. Upgrade ke Premium untuk membuka fitur ini.
          </p>
          <div className="inline-flex items-center gap-1.5 mt-5 text-primary font-semibold text-[13px]">
            <Crown size={14} /> Upgrade ke Premium
          </div>
        </div>
      </Card>
    );
  }

  if (isLoading) {
    return <Card><div className="animate-pulse space-y-3">{[1, 2, 3].map(i => <div key={i} className="h-16 bg-gray-100 rounded-lg" />)}</div></Card>;
  }

  return (
    <div className="space-y-4">
      {/* Midtrans */}
      <Card>
        <div className="flex items-start gap-3 mb-4">
          <div className="w-10 h-10 rounded-full bg-blue-50 text-blue-600 flex items-center justify-center flex-shrink-0">
            <CreditCard size={18} />
          </div>
          <div className="flex-1">
            <h3 className="text-[14px] font-bold text-gray-900">Pembayaran Online (Midtrans)</h3>
            <p className="text-[12px] text-gray-500 mt-0.5">
              Gunakan akun Midtrans <strong>milik Anda sendiri</strong> — dana masuk langsung ke rekening Anda,
              bukan ke platform.
            </p>
          </div>
          <Toggle checked={midtransEnabled} onChange={setMidtransEnabled} />
        </div>

        <div className={`space-y-3 transition-opacity ${midtransEnabled ? '' : 'opacity-50 pointer-events-none'}`}>
          <div className="flex items-center gap-2 bg-gray-50 border border-gray-200 rounded-[8px] px-3 py-2.5">
            <ShieldCheck size={16} className={isProduction ? 'text-emerald-600' : 'text-amber-500'} />
            <div className="flex-1">
              <span className="text-[13px] font-semibold text-gray-800">Mode {isProduction ? 'Production' : 'Sandbox (Uji Coba)'}</span>
              <p className="text-[11px] text-gray-500">{isProduction ? 'Transaksi nyata dengan uang asli.' : 'Untuk pengujian — tidak ada uang nyata berpindah.'}</p>
            </div>
            <Toggle checked={isProduction} onChange={setIsProduction} />
          </div>

          <Input
            label="Client Key"
            placeholder={isProduction ? 'Mid-client-xxxx' : 'SB-Mid-client-xxxx'}
            value={clientKey}
            onChange={(e) => setClientKey(e.target.value)}
          />

          <div>
            <Input
              label="Server Key"
              type="password"
              placeholder={serverKeySet ? '•••••••••• (tersimpan — isi untuk mengganti)' : (isProduction ? 'Mid-server-xxxx' : 'SB-Mid-server-xxxx')}
              value={serverKey}
              onChange={(e) => setServerKey(e.target.value)}
            />
            <p className="text-[11px] text-gray-400 mt-1">
              Server Key disimpan terenkripsi dan tidak pernah ditampilkan kembali.
              {serverKeySet && ' Biarkan kosong jika tidak ingin mengubahnya.'}
            </p>
          </div>

          <Button
            type="button"
            variant="secondary"
            size="sm"
            loading={testConn.isPending}
            onClick={() => testConn.mutate()}
          >
            <CheckCircle2 size={14} className="mr-1.5" /> Test Koneksi
          </Button>
        </div>
      </Card>

      {/* Webhook instruction */}
      <Card>
        <div className="flex items-start gap-3 mb-3">
          <div className="w-10 h-10 rounded-full bg-amber-50 text-amber-600 flex items-center justify-center flex-shrink-0">
            <Webhook size={18} />
          </div>
          <div className="flex-1">
            <h3 className="text-[14px] font-bold text-gray-900">Wajib: Atur Notification URL di Midtrans</h3>
            <p className="text-[12px] text-gray-500 mt-0.5">
              Agar status pesanan otomatis menjadi <strong>Lunas</strong> setelah pembayaran, salin URL di bawah dan tempel
              ke dashboard Midtrans Anda: <span className="font-medium">Settings → Configuration → Payment Notification URL</span>.
            </p>
          </div>
        </div>
        <div className="flex items-center gap-2 bg-gray-50 border border-gray-200 rounded-[8px] p-2">
          <span className="text-[12px] text-gray-700 font-mono select-all truncate flex-1 pl-1">
            {webhookUrl || 'Menyiapkan link toko...'}
          </span>
          <Button
            type="button"
            variant="secondary"
            size="sm"
            disabled={!webhookUrl}
            onClick={() => { navigator.clipboard.writeText(webhookUrl); toast.success('URL webhook disalin.'); }}
          >
            <Copy size={13} className="mr-1" /> Salin
          </Button>
        </div>
        <p className="text-[11px] text-gray-400 mt-2">
          Tanpa langkah ini, pembayaran tetap diterima di akun Midtrans Anda, tetapi status pesanan di aplikasi
          tidak akan diperbarui otomatis.
        </p>
      </Card>

      {/* Shipping */}
      <Card>
        <div className="flex items-start gap-3 mb-4">
          <div className="w-10 h-10 rounded-full bg-violet-50 text-violet-600 flex items-center justify-center flex-shrink-0">
            <Truck size={18} />
          </div>
          <div className="flex-1">
            <h3 className="text-[14px] font-bold text-gray-900">Ongkos Kirim</h3>
            <p className="text-[12px] text-gray-500 mt-0.5">Tarif flat per zona yang bisa dipilih pelanggan saat checkout.</p>
          </div>
        </div>

        <div className="space-y-2 mb-3">
          {flatRates.length === 0 && (
            <p className="text-[12px] text-gray-400 italic py-2">Belum ada zona ongkir. Tambahkan minimal satu zona, atau aktifkan opsi di bawah.</p>
          )}
          {flatRates.map((rate, i) => (
            <div key={i} className="flex items-center gap-2">
              <div className="flex-1">
                <Input
                  placeholder="Nama zona (cth: Dalam Kota)"
                  value={rate.name}
                  onChange={(e) => updateFlatRate(i, { name: e.target.value })}
                />
              </div>
              <div className="w-36">
                <Input
                  type="number"
                  min={0}
                  placeholder="Biaya"
                  value={rate.cost === 0 ? '' : rate.cost}
                  onChange={(e) => updateFlatRate(i, { cost: Number(e.target.value) || 0 })}
                />
              </div>
              <button
                type="button"
                onClick={() => removeFlatRate(i)}
                className="p-2 rounded-lg text-gray-400 hover:text-red-500 hover:bg-red-50 transition-colors flex-shrink-0"
                title="Hapus zona"
              >
                <Trash2 size={15} />
              </button>
            </div>
          ))}
        </div>

        <Button type="button" variant="secondary" size="sm" onClick={addFlatRate}>
          <Plus size={14} className="mr-1" /> Tambah Zona
        </Button>

        <div className="mt-4 pt-4 border-t border-gray-100 space-y-3">
          <label className="flex items-center justify-between cursor-pointer">
            <div>
              <span className="text-[13px] font-semibold text-gray-800">Ambil di Tempat (Pickup)</span>
              <p className="text-[11px] text-gray-500">Pelanggan bisa memilih ambil sendiri — ongkir Rp0.</p>
            </div>
            <Toggle checked={allowPickup} onChange={setAllowPickup} />
          </label>
          <label className="flex items-center justify-between cursor-pointer">
            <div>
              <span className="text-[13px] font-semibold text-gray-800">Ongkir Dihitung Kemudian</span>
              <p className="text-[11px] text-gray-500">Ongkir dikonfirmasi via WhatsApp setelah pesanan masuk.</p>
            </div>
            <Toggle checked={allowTbd} onChange={setAllowTbd} />
          </label>
        </div>
      </Card>

      {/* Preview total shipping options */}
      {(flatRates.length > 0 || allowPickup || allowTbd) && (
        <Card>
          <p className="text-[12px] font-semibold text-gray-700 mb-2">Opsi pengiriman yang akan dilihat pelanggan:</p>
          <div className="flex flex-wrap gap-2">
            {flatRates.filter(r => r.name.trim()).map((r, i) => (
              <span key={i} className="inline-flex items-center gap-1.5 bg-gray-100 text-gray-700 rounded-full px-3 py-1 text-[12px] font-medium">
                {r.name} · {formatRupiah(r.cost)}
              </span>
            ))}
            {allowPickup && <span className="inline-flex items-center bg-emerald-50 text-emerald-700 rounded-full px-3 py-1 text-[12px] font-medium">Ambil di Tempat · Gratis</span>}
            {allowTbd && <span className="inline-flex items-center bg-amber-50 text-amber-700 rounded-full px-3 py-1 text-[12px] font-medium">Dihitung kemudian</span>}
          </div>
        </Card>
      )}

      <div className="flex justify-end">
        <Button type="button" loading={save.isPending} onClick={handleSave}>Simpan Pengaturan Toko Online</Button>
      </div>
    </div>
  );
}
