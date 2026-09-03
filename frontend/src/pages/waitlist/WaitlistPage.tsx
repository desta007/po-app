import { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { Link } from 'react-router-dom';
import { waitlistApi, restoTableApi } from '@/api/waitlist';
import { PageHeader } from '@/components/layout/page-header';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Card } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Dialog, DialogContent, DialogHeader, DialogTitle } from '@/components/ui/dialog';
import { EmptyState } from '@/components/ui/empty-state';
import { Volume2, UserPlus, Users, Armchair, X, Monitor, Table2, Trash2, Plus } from 'lucide-react';
import { toast } from 'sonner';
import { announce, isSpeechSupported } from '@/lib/speech';
import type { WaitlistEntry, WaitlistStats, RestoTable } from '@/types/waitlist';

function waitMinutes(createdAt: string): number {
  return Math.max(0, Math.round((Date.now() - new Date(createdAt).getTime()) / 60000));
}

const EMPTY_STATS: WaitlistStats = { waiting: 0, called: 0, seated: 0, cancelled: 0, no_show: 0 };

export default function WaitlistPage() {
  const queryClient = useQueryClient();
  const [form, setForm] = useState({ guest_name: '', party_size: 2, phone: '' });
  const [seatingEntry, setSeatingEntry] = useState<WaitlistEntry | null>(null);
  const [tablesOpen, setTablesOpen] = useState(false);
  const speechOk = isSpeechSupported();

  const { data } = useQuery({
    queryKey: ['waitlist'],
    queryFn: () => waitlistApi.list(),
    refetchInterval: 4000,
  });

  const { data: tablesData } = useQuery({
    queryKey: ['resto-tables'],
    queryFn: () => restoTableApi.list(),
  });

  const invalidate = () => {
    queryClient.invalidateQueries({ queryKey: ['waitlist'] });
    queryClient.invalidateQueries({ queryKey: ['resto-tables'] });
  };

  const addGuest = useMutation({
    mutationFn: () => waitlistApi.add({ guest_name: form.guest_name.trim(), party_size: form.party_size, phone: form.phone.trim() || undefined }),
    onSuccess: () => {
      invalidate();
      setForm({ guest_name: '', party_size: 2, phone: '' });
      toast.success('Tamu ditambahkan ke antrian.');
    },
    onError: (err: any) => toast.error(err.response?.data?.message || 'Gagal menambahkan tamu.'),
  });

  const callGuest = useMutation({
    mutationFn: (id: string) => waitlistApi.call(id),
    onSuccess: (res) => {
      invalidate();
      const spoken = announce(res.data.announcement);
      if (!spoken) toast.warning('Browser ini tidak mendukung suara. Panggil manual ya.');
      if (res.data.whatsapp_sent) toast.success('Notifikasi WhatsApp terkirim ke tamu.');
    },
    onError: (err: any) => toast.error(err.response?.data?.message || 'Gagal memanggil.'),
  });

  const seatGuest = useMutation({
    mutationFn: ({ id, tableId }: { id: string; tableId?: string }) => waitlistApi.seat(id, tableId),
    onSuccess: () => {
      invalidate();
      setSeatingEntry(null);
      toast.success('Tamu telah duduk.');
    },
    onError: (err: any) => toast.error(err.response?.data?.message || 'Gagal mendudukkan tamu.'),
  });

  const cancelGuest = useMutation({
    mutationFn: ({ id, status }: { id: string; status: 'cancelled' | 'no_show' }) => waitlistApi.cancel(id, status),
    onSuccess: () => { invalidate(); toast.success('Antrian diperbarui.'); },
    onError: (err: any) => toast.error(err.response?.data?.message || 'Gagal memperbarui antrian.'),
  });

  const entries: WaitlistEntry[] = data?.data?.data ?? [];
  const stats: WaitlistStats = data?.data?.stats ?? EMPTY_STATS;
  const waiting = entries.filter((e) => e.status === 'waiting');
  const called = entries.filter((e) => e.status === 'called');
  const tables: RestoTable[] = tablesData?.data?.data ?? [];
  const availableTables = tables.filter((t) => t.is_active && t.status === 'available');

  function handleAdd(e: React.FormEvent) {
    e.preventDefault();
    if (!form.guest_name.trim()) return;
    addGuest.mutate();
  }

  return (
    <div>
      <PageHeader
        title="Antrian Resto"
        description={`${stats.waiting} menunggu · ${stats.called} dipanggil · ${stats.seated} sudah duduk hari ini`}
        actions={
          <div className="flex gap-2">
            <Button variant="secondary" onClick={() => setTablesOpen(true)}><Table2 size={15} /> Kelola Meja</Button>
            <Link to="/antrian/display" target="_blank">
              <Button variant="secondary"><Monitor size={15} /> Layar Panggilan</Button>
            </Link>
          </div>
        }
      />

      {!speechOk && (
        <div className="mb-4 bg-amber-50 border border-amber-200 rounded-xl px-4 py-2.5 text-sm text-amber-800">
          Browser ini tidak mendukung suara otomatis. Panggilan tetap tercatat, tapi Anda perlu memanggil secara manual.
        </div>
      )}

      {/* Form tambah tamu */}
      <Card className="mb-5">
        <form onSubmit={handleAdd} className="flex flex-wrap items-end gap-3">
          <div className="flex-1 min-w-[200px]">
            <Input label="Nama Tamu *" placeholder="Cth: Desta" value={form.guest_name} onChange={(e) => setForm({ ...form, guest_name: e.target.value })} required />
          </div>
          <div className="w-28">
            <Input label="Jumlah Orang" type="number" min={1} value={form.party_size} onChange={(e) => setForm({ ...form, party_size: Number(e.target.value) })} />
          </div>
          <div className="w-44">
            <Input label="No. HP (opsional)" placeholder="0812..." value={form.phone} onChange={(e) => setForm({ ...form, phone: e.target.value })} />
          </div>
          <Button type="submit" loading={addGuest.isPending}><UserPlus size={15} /> Tambah ke Antrian</Button>
        </form>
      </Card>

      <div className="grid md:grid-cols-2 gap-5">
        {/* Kolom Menunggu */}
        <div>
          <div className="flex items-center gap-2 mb-3">
            <h2 className="text-sm font-bold uppercase tracking-wide text-gray-500">Menunggu</h2>
            <Badge variant="warning">{waiting.length}</Badge>
          </div>
          {waiting.length === 0 ? (
            <EmptyState icon={<Users size={40} />} title="Belum ada antrian" description="Tambahkan tamu di form atas" />
          ) : (
            <div className="space-y-2.5">
              {waiting.map((e) => (
                <Card key={e.id} className="flex items-center justify-between gap-3">
                  <div className="flex items-center gap-3 min-w-0">
                    <div className="flex-shrink-0 w-11 h-11 rounded-xl bg-primary-50 text-primary flex items-center justify-center font-bold text-lg">
                      {e.queue_number}
                    </div>
                    <div className="min-w-0">
                      <div className="font-bold text-gray-900 truncate">{e.guest_name}</div>
                      <div className="text-[12px] text-gray-500">{e.party_size} orang · menunggu {waitMinutes(e.created_at)} mnt</div>
                    </div>
                  </div>
                  <div className="flex items-center gap-1.5 flex-shrink-0">
                    <Button size="sm" onClick={() => callGuest.mutate(e.id)} loading={callGuest.isPending && callGuest.variables === e.id}><Volume2 size={14} /> Panggil</Button>
                    <Button size="sm" variant="secondary" onClick={() => setSeatingEntry(e)}><Armchair size={14} /> Duduk</Button>
                    <Button size="sm" variant="ghost" title="Batalkan" onClick={() => cancelGuest.mutate({ id: e.id, status: 'cancelled' })}><X size={14} /></Button>
                  </div>
                </Card>
              ))}
            </div>
          )}
        </div>

        {/* Kolom Dipanggil */}
        <div>
          <div className="flex items-center gap-2 mb-3">
            <h2 className="text-sm font-bold uppercase tracking-wide text-gray-500">Dipanggil</h2>
            <Badge variant="primary">{called.length}</Badge>
          </div>
          {called.length === 0 ? (
            <EmptyState icon={<Volume2 size={40} />} title="Belum ada yang dipanggil" description="Klik Panggil pada antrian" />
          ) : (
            <div className="space-y-2.5">
              {called.map((e) => (
                <Card key={e.id} className="flex items-center justify-between gap-3 border-primary-100 bg-primary-50/30">
                  <div className="flex items-center gap-3 min-w-0">
                    <div className="flex-shrink-0 w-11 h-11 rounded-xl bg-primary text-white flex items-center justify-center font-bold text-lg">
                      {e.queue_number}
                    </div>
                    <div className="min-w-0">
                      <div className="font-bold text-gray-900 truncate">{e.guest_name}</div>
                      <div className="text-[12px] text-gray-500">{e.party_size} orang · dipanggil {e.call_count}x</div>
                    </div>
                  </div>
                  <div className="flex items-center gap-1.5 flex-shrink-0">
                    <Button size="sm" variant="secondary" onClick={() => callGuest.mutate(e.id)}><Volume2 size={14} /> Ulang</Button>
                    <Button size="sm" onClick={() => setSeatingEntry(e)}><Armchair size={14} /> Duduk</Button>
                    <Button size="sm" variant="ghost" title="Tidak hadir" onClick={() => cancelGuest.mutate({ id: e.id, status: 'no_show' })}><X size={14} /></Button>
                  </div>
                </Card>
              ))}
            </div>
          )}
        </div>
      </div>

      {/* Dialog: pilih meja saat mendudukkan */}
      <Dialog open={!!seatingEntry} onOpenChange={(o) => { if (!o) setSeatingEntry(null); }}>
        <DialogContent>
          <DialogHeader><DialogTitle>Dudukkan {seatingEntry?.guest_name}</DialogTitle></DialogHeader>
          <p className="text-sm text-gray-500 mb-3">Pilih meja, atau dudukkan tanpa memilih meja.</p>
          {availableTables.length === 0 ? (
            <p className="text-sm text-gray-500 mb-4">Belum ada meja tersedia. Anda bisa menambah meja lewat "Kelola Meja".</p>
          ) : (
            <div className="grid grid-cols-3 gap-2 mb-4">
              {availableTables.map((t) => (
                <button
                  key={t.id}
                  onClick={() => seatingEntry && seatGuest.mutate({ id: seatingEntry.id, tableId: t.id })}
                  className="rounded-xl border border-gray-200 hover:border-primary hover:bg-primary-50 p-3 text-center transition-colors"
                >
                  <div className="font-bold text-gray-900">{t.label}</div>
                  <div className="text-[11px] text-gray-500">{t.capacity} kursi</div>
                </button>
              ))}
            </div>
          )}
          <div className="flex justify-end gap-2">
            <Button variant="secondary" onClick={() => setSeatingEntry(null)}>Batal</Button>
            <Button variant="accent" onClick={() => seatingEntry && seatGuest.mutate({ id: seatingEntry.id })} loading={seatGuest.isPending}>Duduk Tanpa Meja</Button>
          </div>
        </DialogContent>
      </Dialog>

      <TableManagerDialog open={tablesOpen} onClose={() => setTablesOpen(false)} tables={tables} onChanged={invalidate} />
    </div>
  );
}

function TableManagerDialog({ open, onClose, tables, onChanged }: { open: boolean; onClose: () => void; tables: RestoTable[]; onChanged: () => void }) {
  const [label, setLabel] = useState('');
  const [capacity, setCapacity] = useState(4);

  const addTable = useMutation({
    mutationFn: () => restoTableApi.create({ label: label.trim(), capacity }),
    onSuccess: () => { onChanged(); setLabel(''); setCapacity(4); toast.success('Meja ditambahkan.'); },
    onError: (err: any) => toast.error(err.response?.data?.message || 'Gagal menambah meja.'),
  });

  const toggleStatus = useMutation({
    mutationFn: ({ id, status }: { id: string; status: 'available' | 'occupied' }) => restoTableApi.updateStatus(id, status),
    onSuccess: onChanged,
  });

  const deleteTable = useMutation({
    mutationFn: (id: string) => restoTableApi.delete(id),
    onSuccess: () => { onChanged(); toast.success('Meja dihapus.'); },
  });

  return (
    <Dialog open={open} onOpenChange={(o) => { if (!o) onClose(); }}>
      <DialogContent>
        <DialogHeader><DialogTitle>Kelola Meja</DialogTitle></DialogHeader>

        <form
          onSubmit={(e) => { e.preventDefault(); if (label.trim()) addTable.mutate(); }}
          className="flex items-end gap-2 mb-4"
        >
          <div className="flex-1"><Input label="Nama Meja *" placeholder="Cth: Meja 1" value={label} onChange={(e) => setLabel(e.target.value)} required /></div>
          <div className="w-24"><Input label="Kursi" type="number" min={1} value={capacity} onChange={(e) => setCapacity(Number(e.target.value))} /></div>
          <Button type="submit" loading={addTable.isPending}><Plus size={15} /></Button>
        </form>

        {tables.length === 0 ? (
          <p className="text-sm text-gray-500">Belum ada meja.</p>
        ) : (
          <div className="space-y-2 max-h-[320px] overflow-y-auto">
            {tables.map((t) => (
              <div key={t.id} className="flex items-center justify-between gap-2 rounded-xl border border-gray-200 px-3 py-2">
                <div className="flex items-center gap-2">
                  <Armchair size={16} className="text-gray-400" />
                  <div>
                    <div className="font-semibold text-gray-900 text-[14px]">{t.label}</div>
                    <div className="text-[11px] text-gray-500">{t.capacity} kursi</div>
                  </div>
                </div>
                <div className="flex items-center gap-2">
                  {t.status === 'occupied'
                    ? <Badge variant="danger" dot>Terisi</Badge>
                    : <Badge variant="success" dot>Kosong</Badge>}
                  <Button
                    size="sm"
                    variant="ghost"
                    onClick={() => toggleStatus.mutate({ id: t.id, status: t.status === 'occupied' ? 'available' : 'occupied' })}
                  >
                    {t.status === 'occupied' ? 'Kosongkan' : 'Tandai isi'}
                  </Button>
                  <Button size="sm" variant="ghost" title="Hapus" onClick={() => deleteTable.mutate(t.id)}><Trash2 size={14} className="text-red-500" /></Button>
                </div>
              </div>
            ))}
          </div>
        )}
      </DialogContent>
    </Dialog>
  );
}
