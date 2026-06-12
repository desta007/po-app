import { useQuery } from '@tanstack/react-query';
import { adminApi } from '@/api/admin';
import { PageHeader } from '@/components/layout/page-header';
import { Card } from '@/components/ui/card';
import { Skeleton } from '@/components/ui/skeleton';
import { Search, ArrowLeft } from 'lucide-react';
import { useState } from 'react';
import { formatDate, getInitials } from '@/lib/utils';
import { Link } from 'react-router-dom';
import { ROUTES } from '@/lib/constants';

const ROLE_COLORS: Record<string, { color: string; bgColor: string }> = {
  owner: { color: '#1F4E79', bgColor: '#DBEAFE' },
  admin: { color: '#D97706', bgColor: '#FEF3C7' },
  staff: { color: '#6B7280', bgColor: '#F3F4F6' },
  viewer: { color: '#9CA3AF', bgColor: '#F9FAFB' },
};

const AVATAR_COLORS = ['#1F4E79', '#70AD47', '#D97706', '#8B5CF6', '#E74C3C', '#2E75B6', '#C00000'];

export default function AdminUsersPage() {
  const [search, setSearch] = useState('');
  const [page, setPage] = useState(1);

  const { data, isLoading } = useQuery({
    queryKey: ['admin', 'users', search, page],
    queryFn: () => adminApi.users({ search, page, per_page: 20 }),
  });

  const users = data?.data?.data || [];
  const meta = data?.data?.meta || data?.data;
  const lastPage = meta?.last_page ?? 1;
  const total = meta?.total ?? 0;

  return (
    <div>
      <div className="mb-4">
        <Link to={ROUTES.ADMIN_DASHBOARD} className="text-xs text-gray-500 hover:text-primary inline-flex items-center gap-1">
          <ArrowLeft size={12} /> Kembali ke Admin Dashboard
        </Link>
      </div>

      <PageHeader
        title="👥 Semua Users"
        description={`${total} user terdaftar di platform`}
      />

      {/* Search */}
      <div className="relative max-w-md mb-5">
        <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" size={16} />
        <input
          className="w-full pl-10 pr-3 py-2.5 border border-gray-300 rounded-[6px] text-[14px] bg-white text-gray-900 placeholder:text-gray-400 focus:outline-none focus:border-primary focus:ring-3 focus:ring-primary-50"
          placeholder="Cari nama atau email..."
          value={search}
          onChange={(e) => { setSearch(e.target.value); setPage(1); }}
        />
      </div>

      {isLoading ? (
        <div className="space-y-2">{[1,2,3,4,5].map(i => <Skeleton key={i} className="h-16 rounded-[10px]" />)}</div>
      ) : users.length === 0 ? (
        <Card><p className="text-center text-gray-500 py-8">Tidak ada user ditemukan.</p></Card>
      ) : (
        <Card padding="none">
          {/* Table Header */}
          <div className="hidden md:grid grid-cols-[1fr_1fr_1fr_100px_120px] gap-4 px-5 py-3 border-b border-gray-100 bg-gray-50 rounded-t-[10px]">
            <span className="text-[11px] font-bold text-gray-500 uppercase">User</span>
            <span className="text-[11px] font-bold text-gray-500 uppercase">Organisasi</span>
            <span className="text-[11px] font-bold text-gray-500 uppercase">Email</span>
            <span className="text-[11px] font-bold text-gray-500 uppercase">Role</span>
            <span className="text-[11px] font-bold text-gray-500 uppercase">Terdaftar</span>
          </div>

          <div className="divide-y divide-gray-100">
            {users.map((u: any, i: number) => {
              const roleStyle = ROLE_COLORS[u.role] ?? { color: '#9CA3AF', bgColor: '#F9FAFB' };
              return (
                <div key={u.id} className="grid md:grid-cols-[1fr_1fr_1fr_100px_120px] gap-2 md:gap-4 px-5 py-3.5 hover:bg-gray-50 transition-colors items-center">
                  {/* User */}
                  <div className="flex items-center gap-3">
                    <div
                      className="w-8 h-8 rounded-full flex items-center justify-center text-white font-bold text-[11px] flex-shrink-0"
                      style={{ backgroundColor: AVATAR_COLORS[i % AVATAR_COLORS.length] }}
                    >
                      {getInitials(u.name || '?')}
                    </div>
                    <div className="min-w-0">
                      <p className="text-[13px] font-semibold text-gray-900 truncate">{u.name}</p>
                      <p className="text-[11px] text-gray-400 md:hidden">{u.email}</p>
                    </div>
                  </div>

                  {/* Org */}
                  <span className="text-[13px] text-gray-700 truncate hidden md:block">{u.organization || '-'}</span>

                  {/* Email */}
                  <span className="text-[13px] text-gray-500 truncate hidden md:block">{u.email}</span>

                  {/* Role */}
                  {u.role ? (
                    <span
                      className="inline-flex items-center rounded-full px-2 py-0.5 text-[10px] font-semibold w-fit"
                      style={{ backgroundColor: roleStyle.bgColor, color: roleStyle.color }}
                    >
                      {u.role}
                    </span>
                  ) : (
                    <span className="text-[11px] text-gray-300">—</span>
                  )}

                  {/* Date */}
                  <span className="text-[12px] text-gray-400 hidden md:block">
                    {u.created_at ? formatDate(u.created_at) : '-'}
                  </span>
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
                  ← Prev
                </button>
                <button
                  onClick={() => setPage(Math.min(lastPage, page + 1))}
                  disabled={page >= lastPage}
                  className="px-3 py-1.5 text-[12px] font-medium border rounded-md disabled:opacity-40 hover:bg-gray-100 transition-colors"
                >
                  Next →
                </button>
              </div>
            </div>
          )}
        </Card>
      )}
    </div>
  );
}
