import { useState } from 'react';
import { createPortal } from 'react-dom';
import { X, Utensils, Check, Volume2, Monitor, Armchair, ListOrdered, Loader2, CheckCircle2 } from 'lucide-react';
import { cn } from '@/lib/utils';
import { useAuth } from '@/contexts/auth-context';
import { subscriptionApi } from '@/api/subscription';
import { WA_NUMBER } from '@/components/premium-upgrade-modal';
import { toast } from 'sonner';

const RESTO_FEATURES = [
  { icon: ListOrdered, title: 'Daftar Tunggu (Waiting List)', description: 'Catat tamu, nomor antrian otomatis, FIFO' },
  { icon: Volume2, title: 'Panggilan Suara', description: 'Panggil tamu via speaker: "Panggilan atas nama…"' },
  { icon: Monitor, title: 'Layar Antrian (TV)', description: 'Tampilan panggilan fullscreen untuk pengunjung' },
  { icon: Armchair, title: 'Peta Meja', description: 'Kelola meja & kapasitas, tandai terisi/kosong' },
];

const WA_MESSAGE_RESTO = 'Halo, saya tertarik dengan Modul Resto (Waiting List) di PO App. Bisa info lebih lanjut?';
const WA_URL = `https://wa.me/${WA_NUMBER}?text=${encodeURIComponent(WA_MESSAGE_RESTO)}`;

type ModalStep = 'info' | 'confirm';

export function RestoModuleModal({ open, onClose }: { open: boolean; onClose: () => void }) {
  const [step, setStep] = useState<ModalStep>('info');
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [paymentNote, setPaymentNote] = useState('');
  const { refreshUser } = useAuth();

  const handleClose = () => {
    setStep('info');
    setPaymentNote('');
    onClose();
  };

  const handleConfirm = async () => {
    setIsSubmitting(true);
    try {
      await subscriptionApi.requestUpgrade({ module: 'resto', payment_proof_note: paymentNote || undefined });
      toast.success('Permintaan langganan Modul Resto terkirim! Tunggu konfirmasi admin.');
      handleClose();
      refreshUser();
    } catch (err: any) {
      toast.error(err?.response?.data?.message ?? 'Gagal mengirim permintaan.');
    } finally {
      setIsSubmitting(false);
    }
  };

  if (!open) return null;

  return createPortal(
    <div
      className="fixed inset-0 z-[100] flex items-center justify-center p-4"
      onClick={(e) => { if (e.target === e.currentTarget) handleClose(); }}
    >
      <div className="absolute inset-0 bg-gray-900/70 backdrop-blur-sm animate-in fade-in duration-300" />

      <div className={cn(
        'relative w-full max-w-md max-h-[90vh] bg-white rounded-2xl shadow-2xl overflow-y-auto',
        'animate-in zoom-in-95 slide-in-from-bottom-4 duration-400'
      )}>
        {/* Header */}
        <div className="relative bg-gradient-to-br from-amber-500 via-orange-500 to-amber-600 px-5 pt-5 pb-8 text-white overflow-hidden">
          <div className="absolute -top-10 -right-10 w-32 h-32 bg-white/10 rounded-full" />
          <button onClick={handleClose} className="absolute top-2.5 right-2.5 p-1.5 rounded-full text-white/70 hover:text-white hover:bg-white/20 transition-colors">
            <X size={18} />
          </button>

          <div className="relative flex items-center gap-2.5 mb-2">
            <div className="flex items-center justify-center w-10 h-10 bg-white/20 rounded-xl shadow-lg">
              <Utensils size={20} className="text-white drop-shadow" />
            </div>
            <div>
              <div className="text-[10px] font-semibold uppercase tracking-wider text-amber-100">Modul Tambahan</div>
              <div className="text-xl font-extrabold tracking-tight">Resto — Waiting List</div>
            </div>
          </div>

          <p className="relative text-xs text-amber-50 leading-relaxed">
            {step === 'info'
              ? 'Kelola antrian tamu dine-in: daftar tunggu, panggilan suara otomatis, layar antrian, dan peta meja.'
              : 'Konfirmasi pembayaran untuk mengaktifkan Modul Resto.'}
          </p>

          <div className="relative mt-4 inline-flex items-baseline gap-1 bg-white/15 backdrop-blur-sm rounded-xl px-3.5 py-2 border border-white/20">
            <span className="text-xs font-medium text-amber-100">Rp</span>
            <span className="text-2xl font-extrabold text-white">50.000</span>
            <span className="text-xs font-medium text-amber-100">/ bulan</span>
          </div>
        </div>

        {step === 'info' ? (
          <>
            <div className="px-5 py-4">
              <div className="text-[10px] font-semibold uppercase tracking-wider text-gray-400 mb-2">Fitur yang Anda dapatkan</div>
              <div className="grid grid-cols-1 gap-1.5">
                {RESTO_FEATURES.map((f) => (
                  <div key={f.title} className="flex items-center gap-2.5 p-2 rounded-lg hover:bg-gray-50 transition-colors group">
                    <div className="flex-shrink-0 flex items-center justify-center w-8 h-8 rounded-lg bg-amber-50 text-amber-600 group-hover:bg-amber-100 transition-colors">
                      <f.icon size={16} />
                    </div>
                    <div className="min-w-0">
                      <div className="text-[13px] font-semibold text-gray-900 flex items-center gap-1.5">
                        {f.title}
                        <Check size={12} className="text-emerald-500" />
                      </div>
                      <div className="text-[11px] text-gray-500 leading-snug">{f.description}</div>
                    </div>
                  </div>
                ))}
              </div>
            </div>

            <div className="px-5 pb-5 pt-1 space-y-2">
              <a
                href={WA_URL}
                target="_blank"
                rel="noopener noreferrer"
                className={cn(
                  'block w-full py-2.5 px-4 rounded-xl text-sm font-bold text-white text-center',
                  'bg-gradient-to-r from-amber-500 to-orange-500 hover:from-amber-600 hover:to-orange-600',
                  'shadow-lg shadow-amber-500/25 transition-all duration-200'
                )}
              >
                Hubungi WhatsApp & Transfer
              </a>
              <button
                onClick={() => setStep('confirm')}
                className="w-full py-2.5 px-4 rounded-xl text-sm font-semibold text-center bg-emerald-50 text-emerald-700 border border-emerald-200 hover:bg-emerald-100 transition-colors"
              >
                <CheckCircle2 size={14} className="inline mr-1.5 -mt-0.5" />
                Saya Sudah Transfer
              </button>
              <button onClick={handleClose} className="w-full py-2 px-4 rounded-xl text-xs font-medium text-gray-500 hover:text-gray-700 hover:bg-gray-100 transition-colors">
                Nanti saja
              </button>
            </div>
          </>
        ) : (
          <>
            <div className="px-5 py-4">
              <div className="text-[10px] font-semibold uppercase tracking-wider text-gray-400 mb-3">Konfirmasi Pembayaran</div>
              <div className="bg-amber-50 rounded-xl p-3.5 mb-4">
                <p className="text-[12px] text-amber-800 leading-relaxed">
                  Pastikan Anda sudah transfer <strong>Rp 50.000</strong> ke rekening yang diberikan via WhatsApp. Admin akan memverifikasi pembayaran Anda.
                </p>
              </div>
              <label className="block mb-1.5"><span className="text-[12px] font-medium text-gray-700">Catatan (opsional)</span></label>
              <textarea
                value={paymentNote}
                onChange={(e) => setPaymentNote(e.target.value)}
                placeholder="Contoh: Transfer dari BCA a.n. Budi, jam 14:30"
                rows={3}
                className="w-full px-3 py-2.5 border border-gray-300 rounded-xl text-[13px] bg-white text-gray-900 placeholder:text-gray-400 focus:outline-none focus:border-primary focus:ring-3 focus:ring-primary-50 resize-none"
                maxLength={1000}
              />
            </div>
            <div className="px-5 pb-5 pt-1 space-y-2">
              <button
                onClick={handleConfirm}
                disabled={isSubmitting}
                className="w-full py-2.5 px-4 rounded-xl text-sm font-bold text-white text-center bg-gradient-to-r from-emerald-600 to-emerald-500 hover:from-emerald-700 hover:to-emerald-600 shadow-lg shadow-emerald-500/25 transition-all duration-200 disabled:opacity-50 disabled:cursor-not-allowed"
              >
                {isSubmitting ? <><Loader2 size={14} className="inline mr-1.5 -mt-0.5 animate-spin" />Mengirim...</> : 'Konfirmasi Pembayaran'}
              </button>
              <button
                onClick={() => setStep('info')}
                disabled={isSubmitting}
                className="w-full py-2 px-4 rounded-xl text-xs font-medium text-gray-500 hover:text-gray-700 hover:bg-gray-100 transition-colors disabled:opacity-50"
              >
                Kembali
              </button>
            </div>
          </>
        )}
      </div>
    </div>,
    document.body
  );
}
