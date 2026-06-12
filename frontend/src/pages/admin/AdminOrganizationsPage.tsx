import { useQuery } from '@tanstack/react-query';
import { adminApi } from '@/api/admin';
import { PageHeader } from '@/components/layout/page-header';
import { Card } from '@/components/ui/card';
import { Skeleton } from '@/components/ui/skeleton';
import { Search, ArrowLeft } from 'lucide-react';
import { useState } from 'react';
import { formatRupiah, formatDate, getInitials } from '@/lib/utils';
import { Link } from 'react-router-dom';
import { ROUTES } from '@/lib/constants';

const ORG_COLORS = ['#1F4E79', '#70AD47', '#D97706', '#8B5CF6', '#E74C3C', '#2E75B6', '#C00000'];

export default function AdminOrganizationsPage() {
  const [search, setSearch] = useState('');
  const [page, setPage] = useState(1);

  const { data, isLoading } = useQuery({
    queryKey: ['admin', 'organizations', search, page],
    queryFn: () => adminApi.organizations({ search, page, per_page: 20 }),
  });

  const orgs = data?.data?.data || [];
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
        title="🏢 Semua Organisasi"
        description={`${total} organisasi terdaftar di platform`}
      />

      {/* Search */}
      <div className="relative max-w-md mb-5">
        <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" size={16} />
        <input
          className="w-full pl-10 pr-3 py-2.5 border border-gray-300 rounded-[6px] text-[14px] bg-white text-gray-900 placeholder:text-gray-400 focus:outline-none focus:border-primary focus:ring-3 focus:ring-primary-50"
          placeholder="Cari organisasi..."
          value={search}
          onChange={(e) => { setSearch(e.target.value); setPage(1); }}
        />
      </div>

      {isLoading ? (
        <div className="space-y-2">{[1,2,3,4,5].map(i => <Skeleton key={i} className="h-16 rounded-[10px]" />)}</div>
      ) : orgs.length === 0 ? (
        <Card><p className="text-center text-gray-500 py-8">Tidak ada organisasi ditemukan.</p></Card>
      ) : (
        <Card padding="none">
          {/* Table Header */}
          <div className="hidden lg:grid grid-cols-[1.5fr_1fr_80px_80px_1fr_100px] gap-4 px-5 py-3 border-b border-gray-100 bg-gray-50 rounded-t-[10px]">
            <span className="text-[11px] font-bold text-gray-500 uppercase">Organisasi</span>
            <span className="text-[11px] font-bold text-gray-500 uppercase">Owner</span>
            <span className="text-[11px] font-bold text-gray-500 uppercase text-center">Members</span>
            <span className="text-[11px] font-bold text-gray-500 uppercase text-center">PO</span>
            <span className="text-[11px] font-bold text-gray-500 uppercase text-right">Revenue</span>
            <span className="text-[11px] font-bold text-gray-500 uppercase">Terdaftar</span>
          </div>

          <div className="divide-y divide-gray-100">
            {orgs.map((org: any, i: number) => (
              <div key={org.id} className="grid lg:grid-cols-[1.5fr_1fr_80px_80px_1fr_100px] gap-2 lg:gap-4 px-5 py-4 hover:bg-gray-50 transition-colors items-center">
                {/* Org Name */}
                <div className="flex items-center gap-3">
                  <div
                    className="w-9 h-9 rounded-[8px] flex items-center justify-center text-white font-bold text-[12px] flex-shrink-0"
                    style={{ backgroundColor: ORG_COLORS[i % ORG_COLORS.length] }}
                  >
                    {getInitials(org.name)}
                  </div>
                  <div className="min-w-0">
                    <p className="text-[13px] font-semibold text-gray-900 truncate">{org.name}</p>
                    <p className="text-[11px] text-gray-400 lg:hidden">{org.owner_name}</p>
                  </div>
                </div>

                {/* Owner */}
                <div className="hidden lg:block min-w-0">
                  <p className="text-[13px] text-gray-700 truncate">{org.owner_name}</p>
                  <p className="text-[11px] text-gray-400 truncate">{org.owner_email}</p>
                </div>

                {/* Members */}
                <div className="text-center">
                  <span className="inline-flex items-center justify-center bg-gray-100 text-gray-700 rounded-full px-2.5 py-0.5 text-[12px] font-semibold">
                    {org.members_count}
                  </span>
                </div>

                {/* PO Count */}
                <div className="text-center">
                  <span className="text-[13px] font-semibold text-gray-700">{org.purchase_orders_count}</span>
                </div>

                {/* Revenue */}
                <div className="text-right">
                  <span className="text-[13px] font-bold text-primary">{formatRupiah(org.total_revenue)}</span>
                </div>

                {/* Date */}
                <span className="text-[12px] text-gray-400 hidden lg:block">
                  {org.created_at ? formatDate(org.created_at) : '-'}
                </span>
              </div>
            ))}
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
