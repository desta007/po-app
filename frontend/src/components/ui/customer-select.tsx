import { useState } from 'react';
import { useQuery, useMutation, useQueryClient, keepPreviousData } from '@tanstack/react-query';
import { customersApi } from '@/api/customers';
import type { Customer } from '@/types/customer';
import { SearchableSelect } from './searchable-select';
import { Dialog, DialogHeader, DialogBody, DialogFooter } from './dialog';
import { Button } from './button';
import { Input } from './input';
import { toast } from 'sonner';
import { AlertTriangle } from 'lucide-react';

interface CustomerSelectProps {
  value: string;
  /** Customer yang sedang terpilih, agar labelnya tetap tampil walau tak ada di hasil pencarian. */
  selected?: Customer | null;
  onChange: (id: string, customer: Customer) => void;
  placeholder?: string;
}

/**
 * Pemilih pelanggan dengan pencarian sisi-server + tambah pelanggan baru inline.
 * Dipakai di form buat/edit Purchase Order.
 */
export function CustomerSelect({ value, selected, onChange, placeholder = '-- Pilih Customer --' }: CustomerSelectProps) {
  const queryClient = useQueryClient();
  const [search, setSearch] = useState('');
  const [quickAddOpen, setQuickAddOpen] = useState(false);
  const [name, setName] = useState('');
  const [phone, setPhone] = useState('');

  const { data, isFetching } = useQuery({
    queryKey: ['customers-search', search],
    queryFn: () => customersApi.list({ search: search || undefined, per_page: 20 }),
    placeholderData: keepPreviousData,
  });
  const results: Customer[] = data?.data?.data || [];

  // Sisipkan customer terpilih bila tak ada di hasil pencarian saat ini.
  const merged = selected && !results.some((c) => c.id === selected.id) ? [selected, ...results] : results;
  const options = merged.map((c) => ({ value: c.id, label: `${c.name} — ${c.phone || '-'}` }));

  const createCustomer = useMutation({
    mutationFn: (d: { name: string; phone?: string }) => customersApi.create(d),
    onSuccess: (res) => {
      const created = res.data.data;
      queryClient.invalidateQueries({ queryKey: ['customers-search'] });
      onChange(created.id, created);
      setQuickAddOpen(false);
      toast.success(`Pelanggan "${created.name}" ditambahkan & dipilih.`);
    },
    onError: (err: any) => toast.error(err.response?.data?.message || 'Gagal menambah pelanggan.'),
  });

  const openQuickAdd = (q: string) => { setName(q); setPhone(''); setQuickAddOpen(true); };
  const submitQuickAdd = () => {
    const n = name.trim();
    if (!n) { toast.error('Nama pelanggan wajib diisi.'); return; }
    createCustomer.mutate({ name: n, phone: phone.trim() || undefined });
  };

  const handleChange = (id: string) => {
    const c = merged.find((x) => x.id === id);
    if (c) onChange(id, c);
  };

  // Peringatan duplikat: pelanggan yang namanya mirip dengan yang diketik.
  const similar = name.trim()
    ? results.filter((c) => c.name.toLowerCase().includes(name.trim().toLowerCase())).slice(0, 5)
    : [];

  return (
    <>
      <SearchableSelect
        options={options}
        value={value}
        onChange={handleChange}
        onSearchChange={setSearch}
        loading={isFetching}
        onCreate={openQuickAdd}
        createLabel={(q) => `Tambah pelanggan baru: "${q}"`}
        placeholder={placeholder}
      />

      <Dialog open={quickAddOpen} onClose={() => setQuickAddOpen(false)} size="sm">
        <DialogHeader onClose={() => setQuickAddOpen(false)}>Tambah Pelanggan Baru</DialogHeader>
        <DialogBody>
          <div className="space-y-3">
            <Input label="Nama Pelanggan *" value={name} onChange={(e) => setName(e.target.value)} placeholder="Nama pelanggan" autoFocus />
            <Input label="No. HP (opsional)" value={phone} onChange={(e) => setPhone(e.target.value)} placeholder="08xxxxxxxxxx" inputMode="tel" />
            {similar.length > 0 && (
              <div className="bg-amber-50 border border-amber-200 rounded-[8px] p-2.5">
                <div className="flex items-center gap-1.5 text-[12px] font-semibold text-amber-700 mb-1"><AlertTriangle size={13} /> Nama mirip sudah ada</div>
                <ul className="text-[12px] text-amber-800 space-y-0.5">
                  {similar.map((c) => (
                    <li key={c.id} className="flex items-center justify-between gap-2">
                      <span>{c.name} · {c.phone || '-'}</span>
                      <button type="button" className="text-primary font-semibold hover:underline" onClick={() => { onChange(c.id, c); setQuickAddOpen(false); }}>Pakai ini</button>
                    </li>
                  ))}
                </ul>
              </div>
            )}
          </div>
        </DialogBody>
        <DialogFooter>
          <Button variant="secondary" onClick={() => setQuickAddOpen(false)}>Batal</Button>
          <Button loading={createCustomer.isPending} onClick={submitQuickAdd}>Simpan Pelanggan</Button>
        </DialogFooter>
      </Dialog>
    </>
  );
}
