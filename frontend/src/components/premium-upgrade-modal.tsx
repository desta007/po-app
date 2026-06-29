import { useState, useEffect } from 'react';
import { createPortal } from 'react-dom';
import { X, Crown, Check, Zap, BarChart3, Users, ShieldCheck, Headphones, Star, Loader2, CheckCircle2 } from 'lucide-react';
import { cn } from '@/lib/utils';
import { useAuth } from '@/contexts/auth-context';
import { subscriptionApi } from '@/api/subscription';
import { toast } from 'sonner';

const PREMIUM_FEATURES = [
  {
    icon: Zap,
    title: 'Pesanan Unlimited',
    description: 'Buat pesanan tanpa batas setiap bulannya',
  },
  {
    icon: BarChart3,
    title: 'Laporan & Analitik Lengkap',
    description: 'Laporan laba rugi, grafik penjualan, dan ekspor data',
  },
  {
    icon: Users,
    title: 'Multi-User & Tim',
    description: 'Tambahkan hingga 10 anggota tim dengan role berbeda',
  },
  {
    icon: ShieldCheck,
    title: 'Backup Data Otomatis',
    description: 'Data aman dengan backup harian otomatis ke cloud',
  },
  {
    icon: Star,
    title: 'Katalog Online Premium',
    description: 'Tampilan katalog eksklusif dengan custom domain',
  },
  {
    icon: Headphones,
    title: 'Prioritas Support',
    description: 'Dukungan pelanggan prioritas via WhatsApp',
  },
];

const SESSION_KEY = 'premium_modal_shown';
export const WA_NUMBER = '6281573254497';
export const WA_MESSAGE = 'Halo, saya tertarik dengan paket Premium PO App. Bisa info lebih lanjut?';
const WA_URL = `https://wa.me/${WA_NUMBER}?text=${encodeURIComponent(WA_MESSAGE)}`;

type ModalStep = 'info' | 'confirm';

export function PremiumUpgradeModal() {
  const [open, setOpen] = useState(false);
  const [step, setStep] = useState<ModalStep>('info');
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [paymentNote, setPaymentNote] = useState('');
  const { organizationPlan, isSuperAdmin, refreshUser } = useAuth();

  useEffect(() => {
    if (organizationPlan === 'premium' || isSuperAdmin) return;

    const alreadyShown = sessionStorage.getItem(SESSION_KEY);
    if (!alreadyShown) {
      const timer = setTimeout(() => setOpen(true), 1500);
      return () => clearTimeout(timer);
    }
  }, [organizationPlan]);

  const handleClose = () => {
    setOpen(false);
    setStep('info');
    setPaymentNote('');
    sessionStorage.setItem(SESSION_KEY, 'true');
  };

  const handleConfirmTransfer = async () => {
    setIsSubmitting(true);
    try {
      await subscriptionApi.requestUpgrade({
        payment_proof_note: paymentNote || undefined,
      });
      toast.success('Permintaan upgrade berhasil dikirim! Silakan tunggu konfirmasi dari admin.');
      handleClose();
      refreshUser();
    } catch (err: any) {
      const message = err?.response?.data?.message ?? 'Gagal mengirim permintaan upgrade.';
      toast.error(message);
    } finally {
      setIsSubmitting(false);
    }
  };

  if (organizationPlan === 'premium' || isSuperAdmin) return null;
  if (!open) return null;

  return createPortal(
    <div
      className="fixed inset-0 z-[100] flex items-center justify-center p-4"
      onClick={(e) => {
        if (e.target === e.currentTarget) handleClose();
      }}
    >
      {/* Backdrop */}
      <div className="absolute inset-0 bg-gray-900/70 backdrop-blur-sm animate-in fade-in duration-300" />

      {/* Modal */}
      <div
        className={cn(
          'relative w-full max-w-md max-h-[90vh] bg-white rounded-2xl shadow-2xl overflow-y-auto',
          'animate-in zoom-in-95 slide-in-from-bottom-4 duration-400'
        )}
      >
        {/* Gradient header */}
        <div className="relative bg-gradient-to-br from-[#1F4E79] via-[#2E75B6] to-[#1a6fb5] px-5 pt-5 pb-8 text-white overflow-hidden">
          <div className="absolute -top-10 -right-10 w-32 h-32 bg-white/10 rounded-full" />
          <div className="absolute -bottom-6 -left-6 w-24 h-24 bg-white/5 rounded-full" />

          <button
            onClick={handleClose}
            className="absolute top-2.5 right-2.5 p-1.5 rounded-full text-white/70 hover:text-white hover:bg-white/20 transition-colors"
          >
            <X size={18} />
          </button>

          <div className="relative flex items-center gap-2.5 mb-2">
            <div className="flex items-center justify-center w-10 h-10 bg-gradient-to-br from-amber-400 to-yellow-500 rounded-xl shadow-lg">
              <Crown size={20} className="text-white drop-shadow" />
            </div>
            <div>
              <div className="text-[10px] font-semibold uppercase tracking-wider text-amber-300">
                Upgrade ke
              </div>
              <div className="text-xl font-extrabold tracking-tight">
                Premium
              </div>
            </div>
          </div>

          <p className="relative text-xs text-blue-100 leading-relaxed">
            {step === 'info'
              ? 'Tingkatkan bisnis Anda dengan fitur-fitur canggih untuk mengoptimalkan pengelolaan pesanan.'
              : 'Konfirmasi pembayaran Anda untuk mengaktifkan paket Premium.'}
          </p>

          <div className="relative mt-4 inline-flex items-center gap-2.5 bg-white/15 backdrop-blur-sm rounded-xl px-3.5 py-2 border border-white/20">
            <span className="text-sm text-blue-200/80 line-through decoration-red-400 decoration-2">Rp 200.000</span>
            <div className="flex items-baseline gap-1">
              <span className="text-xs font-medium text-blue-100">Rp</span>
              <span className="text-2xl font-extrabold text-white">35.000</span>
              <span className="text-xs font-medium text-blue-200">/ bulan</span>
            </div>
          </div>
        </div>

        {step === 'info' ? (
          <>
            {/* Features list */}
            <div className="px-5 py-4">
              <div className="text-[10px] font-semibold uppercase tracking-wider text-gray-400 mb-2">
                Fitur yang Anda dapatkan
              </div>
              <div className="grid grid-cols-1 gap-1.5">
                {PREMIUM_FEATURES.map((feature) => (
                  <div
                    key={feature.title}
                    className="flex items-center gap-2.5 p-2 rounded-lg hover:bg-gray-50 transition-colors group"
                  >
                    <div className="flex-shrink-0 flex items-center justify-center w-8 h-8 rounded-lg bg-blue-50 text-[#2E75B6] group-hover:bg-blue-100 transition-colors">
                      <feature.icon size={16} />
                    </div>
                    <div className="min-w-0">
                      <div className="text-[13px] font-semibold text-gray-900 flex items-center gap-1.5">
                        {feature.title}
                        <Check size={12} className="text-emerald-500" />
                      </div>
                      <div className="text-[11px] text-gray-500 leading-snug">
                        {feature.description}
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            </div>

            {/* CTA buttons */}
            <div className="px-5 pb-5 pt-1 space-y-2">
              <a
                href={WA_URL}
                target="_blank"
                rel="noopener noreferrer"
                className={cn(
                  'block w-full py-2.5 px-4 rounded-xl text-sm font-bold text-white text-center',
                  'bg-gradient-to-r from-[#1F4E79] to-[#2E75B6]',
                  'hover:from-[#1a4368] hover:to-[#2868a3]',
                  'shadow-lg shadow-blue-500/25 hover:shadow-blue-500/40',
                  'transform hover:scale-[1.02] active:scale-[0.98]',
                  'transition-all duration-200'
                )}
              >
                Hubungi WhatsApp & Transfer
              </a>
              <button
                onClick={() => setStep('confirm')}
                className={cn(
                  'w-full py-2.5 px-4 rounded-xl text-sm font-semibold text-center',
                  'bg-emerald-50 text-emerald-700 border border-emerald-200',
                  'hover:bg-emerald-100 transition-colors'
                )}
              >
                <CheckCircle2 size={14} className="inline mr-1.5 -mt-0.5" />
                Saya Sudah Transfer
              </button>
              <button
                onClick={handleClose}
                className="w-full py-2 px-4 rounded-xl text-xs font-medium text-gray-500 hover:text-gray-700 hover:bg-gray-100 transition-colors"
              >
                Nanti saja
              </button>
            </div>
          </>
        ) : (
          <>
            {/* Confirm transfer step */}
            <div className="px-5 py-4">
              <div className="text-[10px] font-semibold uppercase tracking-wider text-gray-400 mb-3">
                Konfirmasi Pembayaran
              </div>

              <div className="bg-blue-50 rounded-xl p-3.5 mb-4">
                <p className="text-[12px] text-blue-800 leading-relaxed">
                  Pastikan Anda sudah melakukan transfer sebesar <strong>Rp 35.000</strong> ke rekening yang diberikan via WhatsApp. Admin akan memverifikasi pembayaran Anda.
                </p>
              </div>

              <label className="block mb-1.5">
                <span className="text-[12px] font-medium text-gray-700">Catatan (opsional)</span>
              </label>
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
                onClick={handleConfirmTransfer}
                disabled={isSubmitting}
                className={cn(
                  'w-full py-2.5 px-4 rounded-xl text-sm font-bold text-white text-center',
                  'bg-gradient-to-r from-emerald-600 to-emerald-500',
                  'hover:from-emerald-700 hover:to-emerald-600',
                  'shadow-lg shadow-emerald-500/25',
                  'transform hover:scale-[1.02] active:scale-[0.98]',
                  'transition-all duration-200',
                  'disabled:opacity-50 disabled:cursor-not-allowed disabled:transform-none'
                )}
              >
                {isSubmitting ? (
                  <>
                    <Loader2 size={14} className="inline mr-1.5 -mt-0.5 animate-spin" />
                    Mengirim...
                  </>
                ) : (
                  'Konfirmasi Pembayaran'
                )}
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
