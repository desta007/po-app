import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { adminApi } from '@/api/admin';
import { PageHeader } from '@/components/layout/page-header';
import { Card } from '@/components/ui/card';
import { Skeleton } from '@/components/ui/skeleton';
import { Search, ArrowLeft, Check, X, Crown, MessageCircle, Loader2 } from 'lucide-react';
import { useState } from 'react';
import { formatDate, getInitials } from '@/lib/utils';
import { Link } from 'react-router-dom';
import { ROUTES } from '@/lib/constants';
import { toast } from 'sonner';
import { cn } from '@/lib/utils';

const STATUS_CONFIG: Record<string, { label: string; color: string; bgColor: string }> = {
  pending: { label: 'Menunggu', color: '#D97706', bgColor: '#FEF3C7' },
  active: { label: 'Aktif', color: '#70AD47', bgColor: '#D1FAE5' },
  expired: { label: 'Kedaluwarsa', color: '#9CA3AF', bgColor: '#F3F4F6' },
  rejected: { label: 'Ditolak', color: '#C00000', bgColor: '#FEE2E2' },
};

const STATUS_FILTERS = [
  { value: '', label: 'Semua' },
  { value: 'pending', label: 'Menunggu' },
  { value: 'active', label: 'Aktif' },
  { value: 'expired', label: 'Kedaluwarsa' },
  { value: 'rejected', label: 'Ditolak' },
];

const AVATAR_COLORS = ['#1F4E79', '#70AD47', '#D97706', '#8B5CF6', '#E74C3C', '#2E75B6', '#C00000'];

function formatCurrency(value: number) {
  return new Intl.NumberFormat('id-ID', { style: 'currency', currency: 'IDR', minimumFractionDigits: 0 }).format(value);
}

export default function AdminSubscriptionsPage() {
  const [search, setSearch] = useState('');
  const [statusFilter, setStatusFilter] = useState('');
  const [page, setPage] = useState(1);
  const [rejectModalId, setRejectModalId] = useState<string | null>(null);
  const [rejectReason, setRejectReason] = useState('');
  const queryClient = useQueryClient();

  const { data, isLoading } = useQuery({
    queryKey: ['admin', 'subscriptions', search, statusFilter, page],
    queryFn: () => adminApi.subscriptions({ search, status: statusFilter || undefined, page, per_page: 20 }),
  });

  const approveMutation = useMutation({
    mutationFn: (id: string) => adminApi.approveSubscription(id),
    onSuccess: () => {
      toast.success('Subscription berhasil disetujui.');
      queryClient.invalidateQueries({ queryKey: ['admin', 'subscriptions'] });
    },
    onError: (err: any) => {
      toast.error(err?.response?.data?.message ?? 'Gagal menyetujui subscription.');
    },
  });

  const rejectMutation = useMutation({
    mutationFn: ({ id, reject_reason }: { id: string; reject_reason: string }) =>
      adminApi.rejectSubscription(id, { reject_reason }),
    onSuccess: () => {
      toast.success('Subscription ditolak.');
      setRejectModalId(null);
      setRejectReason('');
      queryClient.invalidateQueries({ queryKey: ['admin', 'subscriptions'] });
    },
    onError: (err: any) => {
      toast.error(err?.response?.data?.message ?? 'Gagal menolak subscription.');
    },
  });

  const subscriptions = data?.data?.data || [];
  const meta = data?.data?.meta || data?.data;
  const lastPage = meta?.last_page ?? 1;
  const total = meta?.total ?? 0;

  const handleApprove = (id: string, orgName: string) => {
    if (window.confirm(`Setujui upgrade Premium untuk "${orgName}"?`)) {
      approveMutation.mutate(id);
    }
  };

  const handleRejectSubmit = () => {
    if (!rejectModalId || !rejectReason.trim()) return;
    rejectMutation.mutate({ id: rejectModalId, reject_reason: rejectReason });
  };

  return (
    <div>
      <div className="mb-4">
        <Link to={ROUTES.ADMIN_DASHBOARD} className="text-xs text-gray-500 hover:text-primary inline-flex items-center gap-1">
          <ArrowLeft size={12} /> Kembali ke Admin Dashboard
        </Link>
      </div>

      <PageHeader
        title="Subscription Management"
        description={`${total} permintaan subscription`}
      />

      {/* Filters */}
      <div className="flex flex-col sm:flex-row gap-3 mb-5">
        <div className="relative flex-1 max-w-md">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" size={16} />
          <input
            className="w-full pl-10 pr-3 py-2.5 border border-gray-300 rounded-[6px] text-[14px] bg-white text-gray-900 placeholder:text-gray-400 focus:outline-none focus:border-primary focus:ring-3 focus:ring-primary-50"
            placeholder="Cari organisasi atau email..."
            value={search}
            onChange={(e) => { setSearch(e.target.value); setPage(1); }}
          />
        </div>
        <div className="flex gap-1.5 flex-wrap">
          {STATUS_FILTERS.map((f) => (
            <button
              key={f.value}
              onClick={() => { setStatusFilter(f.value); setPage(1); }}
              className={cn(
                'px-3 py-2 rounded-[6px] text-[12px] font-medium border transition-colors',
                statusFilter === f.value
                  ? 'bg-primary text-white border-primary'
                  : 'bg-white text-gray-600 border-gray-300 hover:bg-gray-50'
              )}
            >
              {f.label}
            </button>
          ))}
        </div>
      </div>

      {isLoading ? (
        <div className="space-y-2">{[1, 2, 3, 4, 5].map(i => <Skeleton key={i} className="h-20 rounded-[10px]" />)}</div>
      ) : subscriptions.length === 0 ? (
        <Card><p className="text-center text-gray-500 py-8">Tidak ada subscription ditemukan.</p></Card>
      ) : (
        <Card padding="none">
          {/* Table Header */}
          <div className="hidden lg:grid grid-cols-[1fr_1fr_100px_100px_100px_140px] gap-4 px-5 py-3 border-b border-gray-100 bg-gray-50 rounded-t-[10px]">
            <span className="text-[11px] font-bold text-gray-500 uppercase">User / Organisasi</span>
            <span className="text-[11px] font-bold text-gray-500 uppercase">Catatan</span>
            <span className="text-[11px] font-bold text-gray-500 uppercase">Nominal</span>
            <span className="text-[11px] font-bold text-gray-500 uppercase">Status</span>
            <span className="text-[11px] font-bold text-gray-500 uppercase">Tanggal</span>
            <span className="text-[11px] font-bold text-gray-500 uppercase">Aksi</span>
          </div>

          <div className="divide-y divide-gray-100">
            {subscriptions.map((sub: any, i: number) => {
              const statusStyle = STATUS_CONFIG[sub.status as string] || { label: sub.status, color: '#9CA3AF', bgColor: '#F3F4F6' };
              return (
                <div key={sub.id} className="grid lg:grid-cols-[1fr_1fr_100px_100px_100px_140px] gap-2 lg:gap-4 px-5 py-3.5 hover:bg-gray-50 transition-colors items-center">
                  {/* User / Org */}
                  <div className="flex items-center gap-3">
                    <div
                      className="w-8 h-8 rounded-full flex items-center justify-center text-white font-bold text-[11px] flex-shrink-0"
                      style={{ backgroundColor: AVATAR_COLORS[i % AVATAR_COLORS.length] }}
                    >
                      {getInitials(sub.requester_name || '?')}
                    </div>
                    <div className="min-w-0">
                      <p className="text-[13px] font-semibold text-gray-900 truncate">{sub.requester_name}</p>
                      <p className="text-[11px] text-gray-400 truncate">{sub.organization_name}</p>
                      <p className="text-[10px] text-gray-400 lg:hidden">{sub.requester_email}</p>
                    </div>
                  </div>

                  {/* Payment note */}
                  <div className="hidden lg:block">
                    {sub.payment_proof_note ? (
                      <p className="text-[12px] text-gray-600 truncate" title={sub.payment_proof_note}>
                        {sub.payment_proof_note}
                      </p>
                    ) : (
                      <span className="text-[11px] text-gray-300">—</span>
                    )}
                    {sub.reject_reason && (
                      <p className="text-[11px] text-red-500 truncate mt-0.5" title={sub.reject_reason}>
                        Alasan: {sub.reject_reason}
                      </p>
                    )}
                  </div>

                  {/* Amount */}
                  <span className="text-[13px] font-semibold text-gray-700 hidden lg:block">
                    {formatCurrency(sub.amount)}
                  </span>

                  {/* Status */}
                  <span
                    className="inline-flex items-center rounded-full px-2 py-0.5 text-[10px] font-semibold w-fit"
                    style={{ backgroundColor: statusStyle.bgColor, color: statusStyle.color }}
                  >
                    {statusStyle.label}
                  </span>

                  {/* Date */}
                  <span className="text-[12px] text-gray-400 hidden lg:block">
                    {sub.requested_at ? formatDate(sub.requested_at) : '-'}
                  </span>

                  {/* Actions */}
                  <div className="flex gap-1.5">
                    {sub.status === 'pending' && (
                      <>
                        <button
                          onClick={() => handleApprove(sub.id, sub.organization_name)}
                          disabled={approveMutation.isPending}
                          className="inline-flex items-center gap-1 px-2.5 py-1.5 rounded-lg text-[11px] font-semibold bg-emerald-50 text-emerald-700 border border-emerald-200 hover:bg-emerald-100 transition-colors disabled:opacity-50"
                        >
                          {approveMutation.isPending ? <Loader2 size={12} className="animate-spin" /> : <Check size={12} />}
                          Approve
                        </button>
                        <button
                          onClick={() => { setRejectModalId(sub.id); setRejectReason(''); }}
                          className="inline-flex items-center gap-1 px-2.5 py-1.5 rounded-lg text-[11px] font-semibold bg-red-50 text-red-700 border border-red-200 hover:bg-red-100 transition-colors"
                        >
                          <X size={12} />
                          Reject
                        </button>
                      </>
                    )}
                    {sub.requester_phone && (
                      <a
                        href={`https://wa.me/${sub.requester_phone.replace(/^0/, '62')}`}
                        target="_blank"
                        rel="noopener noreferrer"
                        className="inline-flex items-center gap-1 px-2.5 py-1.5 rounded-lg text-[11px] font-semibold bg-green-50 text-green-700 border border-green-200 hover:bg-green-100 transition-colors"
                        title="Chat WhatsApp"
                      >
                        <MessageCircle size={12} />
                        WA
                      </a>
                    )}
                    {sub.status === 'active' && (
                      <span className="inline-flex items-center gap-1 px-2.5 py-1.5 text-[11px] font-semibold text-emerald-600">
                        <Crown size={12} /> Premium
                      </span>
                    )}
                  </div>

                  {/* Mobile info */}
                  <div className="lg:hidden text-[11px] text-gray-400 space-y-0.5">
                    <p>{formatCurrency(sub.amount)} · {sub.requested_at ? formatDate(sub.requested_at) : '-'}</p>
                    {sub.payment_proof_note && <p className="text-gray-600">"{sub.payment_proof_note}"</p>}
                  </div>
                </div>
              );
            })}
          </div>

          {/* Pagination */}
          {lastPage > 1 && (
            <div className="flex items-center justify-between px-5 py-3 border-t border-gray-100 bg-gray-50 rounded-b-[10px]">
              <span className="text-[12px] text-gray-500">Halaman {page} dari {lastPage}</span>
              <div className="flex gap-2">
                <button
                  onClick={() => setPage(Math.max(1, page - 1))}
                  disabled={page <= 1}
                  className="px-3 py-1.5 text-[12px] font-medium border rounded-md disabled:opacity-40 hover:bg-gray-100 transition-colors"
                >
                  Prev
                </button>
                <button
                  onClick={() => setPage(Math.min(lastPage, page + 1))}
                  disabled={page >= lastPage}
                  className="px-3 py-1.5 text-[12px] font-medium border rounded-md disabled:opacity-40 hover:bg-gray-100 transition-colors"
                >
                  Next
                </button>
              </div>
            </div>
          )}
        </Card>
      )}

      {/* Reject Modal */}
      {rejectModalId && (
        <div
          className="fixed inset-0 z-[100] flex items-center justify-center p-4"
          onClick={(e) => { if (e.target === e.currentTarget) { setRejectModalId(null); setRejectReason(''); } }}
        >
          <div className="absolute inset-0 bg-gray-900/50 backdrop-blur-sm" />
          <div className="relative w-full max-w-sm bg-white rounded-2xl shadow-2xl p-5">
            <h3 className="text-[15px] font-bold text-gray-900 mb-1">Tolak Subscription</h3>
            <p className="text-[12px] text-gray-500 mb-4">Berikan alasan penolakan untuk user.</p>

            <textarea
              value={rejectReason}
              onChange={(e) => setRejectReason(e.target.value)}
              placeholder="Alasan penolakan..."
              rows={3}
              className="w-full px-3 py-2.5 border border-gray-300 rounded-xl text-[13px] bg-white text-gray-900 placeholder:text-gray-400 focus:outline-none focus:border-primary focus:ring-3 focus:ring-primary-50 resize-none mb-4"
              maxLength={500}
            />

            <div className="flex gap-2 justify-end">
              <button
                onClick={() => { setRejectModalId(null); setRejectReason(''); }}
                className="px-4 py-2 rounded-lg text-[13px] font-medium text-gray-600 hover:bg-gray-100 transition-colors"
              >
                Batal
              </button>
              <button
                onClick={handleRejectSubmit}
                disabled={!rejectReason.trim() || rejectMutation.isPending}
                className="px-4 py-2 rounded-lg text-[13px] font-semibold bg-red-600 text-white hover:bg-red-700 transition-colors disabled:opacity-50"
              >
                {rejectMutation.isPending ? (
                  <Loader2 size={14} className="inline mr-1 animate-spin" />
                ) : null}
                Tolak
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
