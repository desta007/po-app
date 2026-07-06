import { createPortal } from 'react-dom';
import { X, Crown, AlertTriangle } from 'lucide-react';
import { cn } from '@/lib/utils';
import { WA_NUMBER, WA_MESSAGE } from '@/components/premium-upgrade-modal';
import type { UpgradePromptData } from '@/hooks/use-upgrade-prompt';

const WA_URL = `https://wa.me/${WA_NUMBER}?text=${encodeURIComponent(WA_MESSAGE)}`;

const RESOURCE_LABELS: Record<string, string> = {
  po_monthly: 'PO Bulan Ini',
  products: 'Produk',
  team_members: 'Anggota Tim',
};

interface Props {
  data: UpgradePromptData | null;
  onDismiss: () => void;
}

export function UpgradeLimitModal({ data, onDismiss }: Props) {
  if (!data) return null;

  const resourceLabel = RESOURCE_LABELS[data.resource] || data.resource;

  return createPortal(
    <div
      className="fixed inset-0 z-[100] flex items-center justify-center p-4"
      onClick={(e) => { if (e.target === e.currentTarget) onDismiss(); }}
    >
      {/* Backdrop */}
      <div className="absolute inset-0 bg-gray-900/70 backdrop-blur-sm animate-in fade-in duration-300" />

      {/* Modal */}
      <div className={cn(
        'relative w-full max-w-sm bg-white rounded-2xl shadow-2xl overflow-hidden',
        'animate-in zoom-in-95 slide-in-from-bottom-4 duration-400'
      )}>
        {/* Header */}
        <div className="relative bg-gradient-to-br from-amber-500 via-amber-400 to-yellow-400 px-5 pt-5 pb-6 text-white overflow-hidden">
          <div className="absolute -top-8 -right-8 w-28 h-28 bg-white/10 rounded-full" />

          <button
            onClick={onDismiss}
            className="absolute top-2.5 right-2.5 p-1.5 rounded-full text-white/70 hover:text-white hover:bg-white/20 transition-colors"
          >
            <X size={18} />
          </button>

          <div className="relative flex items-center gap-3 mb-2">
            <div className="flex items-center justify-center w-10 h-10 bg-white/20 rounded-xl">
              <AlertTriangle size={20} className="text-white" />
            </div>
            <div className="text-lg font-extrabold tracking-tight">
              Batas Tercapai
            </div>
          </div>

          <p className="relative text-sm text-amber-50 leading-relaxed">
            {data.message}
          </p>
        </div>

        {/* Usage info */}
        {data.usage && (
          <div className="px-5 py-4">
            <div className="flex items-center justify-between bg-gray-50 rounded-xl px-4 py-3">
              <span className="text-sm text-gray-600">{resourceLabel}</span>
              <span className="text-lg font-bold text-gray-900">
                {data.usage.current}<span className="text-gray-400">/{data.usage.limit}</span>
              </span>
            </div>
          </div>
        )}

        {/* CTA */}
        <div className="px-5 pb-5 pt-1 space-y-2">
          <a
            href={WA_URL}
            target="_blank"
            rel="noopener noreferrer"
            className={cn(
              'flex items-center justify-center gap-2 w-full py-2.5 px-4 rounded-xl text-sm font-bold text-white text-center',
              'bg-gradient-to-r from-[#1F4E79] to-[#2E75B6]',
              'hover:from-[#1a4368] hover:to-[#2868a3]',
              'shadow-lg shadow-blue-500/25 hover:shadow-blue-500/40',
              'transition-all duration-200'
            )}
          >
            <Crown size={16} />
            Upgrade ke Premium
          </a>
          <button
            onClick={onDismiss}
            className="w-full py-2 px-4 rounded-xl text-xs font-medium text-gray-500 hover:text-gray-700 hover:bg-gray-100 transition-colors"
          >
            Tutup
          </button>
        </div>
      </div>
    </div>,
    document.body
  );
}
