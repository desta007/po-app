import { useQuery } from '@tanstack/react-query';
import { purchaseOrdersApi } from '@/api/purchase-orders';
import { PageHeader } from '@/components/layout/page-header';
import { Button } from '@/components/ui/button';
import { Table, TableHeader, TableBody, TableRow, TableHead, TableCell } from '@/components/ui/table';
import { EmptyState } from '@/components/ui/empty-state';
import { Skeleton } from '@/components/ui/skeleton';
import { useNavigate, useSearchParams } from 'react-router-dom';
import { Download, Search, FileText } from 'lucide-react';
import { PO_STATUS_CONFIG, PAYMENT_STATUS_CONFIG } from '@/lib/constants';
import { formatRupiah, formatDate } from '@/lib/utils';
import { useState } from 'react';
import type { PurchaseOrder } from '@/types/purchase-order';

export default function PurchaseOrderListPage() {
  const navigate = useNavigate();
  const [search, setSearch] = useState('');
  const [statusFilter, setStatusFilter] = useState('');
  const [searchParams] = useSearchParams();
  const page = Number(searchParams.get('page') || '1');

  const { data, isLoading } = useQuery({
    queryKey: ['purchase-orders', { search, status: statusFilter, page }],
    queryFn: () => purchaseOrdersApi.list({ search, status: statusFilter as any, page }),
  });

  const pos: PurchaseOrder[] = data?.data?.data || [];
  const meta: any = data?.data?.meta;

  return (
    <div>
      <PageHeader
        title="Purchase Order"
        description={meta ? `${meta.total} PO · Total ${formatRupiah(pos.reduce((s, p) => s + (p.total || 0), 0))}` : 'Kelola semua purchase order'}
        actions={
          <div className="flex gap-2">
            <Button variant="secondary"><Download size={15} /> Export</Button>
            <Button onClick={() => navigate('/pesanan/baru')}>+ PO Baru</Button>
          </div>
        }
      />

      {/* Filter bar */}
      <div className="flex gap-2.5 mb-4 flex-wrap">
        <div className="flex-1 min-w-[240px] relative">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" size={16} />
          <input
            className="w-full pl-10 pr-3 py-2.5 border border-gray-300 rounded-[6px] text-[14px] bg-white text-gray-900 placeholder:text-gray-400 focus:outline-none focus:border-primary focus:ring-3 focus:ring-primary-50"
            placeholder="Cari PO, customer, atau produk..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
          />
        </div>
        <select
          className="px-3 py-2.5 border border-gray-300 rounded-[6px] text-[14px] bg-white text-gray-900 focus:outline-none focus:border-primary"
          value={statusFilter}
          onChange={(e) => setStatusFilter(e.target.value)}
        >
          <option value="">Status: Semua</option>
          {Object.entries(PO_STATUS_CONFIG).map(([k, v]) => (
            <option key={k} value={k}>{v.label}</option>
          ))}
        </select>
      </div>

      {isLoading ? (
        <div className="space-y-3">{[1,2,3].map(i => <Skeleton key={i} className="h-16 w-full rounded-[10px]" />)}</div>
      ) : pos.length === 0 ? (
        <EmptyState icon={<FileText size={48} />} title="Belum ada pesanan" description="Buat PO pertama Anda" />
      ) : (
        <>
          <Table>
            <TableHeader>
              <tr>
                <TableHead style={{ width: 30 }}><input type="checkbox" /></TableHead>
                <TableHead>No. PO</TableHead>
                <TableHead>Customer</TableHead>
                <TableHead>Tgl Kirim</TableHead>
                <TableHead>Items</TableHead>
                <TableHead className="text-right">Total</TableHead>
                <TableHead>Status</TableHead>
                <TableHead>Bayar</TableHead>
                <TableHead style={{ width: 60 }}></TableHead>
              </tr>
            </TableHeader>
            <TableBody>
              {pos.map((po) => {
                const sc = PO_STATUS_CONFIG[po.status as keyof typeof PO_STATUS_CONFIG];
                const pc = PAYMENT_STATUS_CONFIG[po.payment_status as keyof typeof PAYMENT_STATUS_CONFIG];
                return (
                  <TableRow key={po.id} className="cursor-pointer" onClick={() => navigate(`/pesanan/${po.id}`)}>
                    <TableCell onClick={(e) => e.stopPropagation()}><input type="checkbox" /></TableCell>
                    <TableCell className="font-mono-po text-xs text-primary font-semibold">{po.po_number}</TableCell>
                    <TableCell>
                      <strong className="text-gray-900">{po.customer?.name}</strong>
                      {po.customer?.phone && <div className="text-[11px] text-gray-500">{po.customer.phone}</div>}
                    </TableCell>
                    <TableCell>{formatDate(po.delivery_date)}</TableCell>
                    <TableCell>{po.items?.length ?? 0} item</TableCell>
                    <TableCell className="text-right font-semibold tabular-nums">{formatRupiah(po.total)}</TableCell>
                    <TableCell>
                      <span className="inline-flex items-center gap-1 rounded-full px-2 py-0.5 text-[11px] font-semibold" style={{ backgroundColor: sc.bgColor, color: sc.color }}>
                        <span className="h-1.5 w-1.5 rounded-full" style={{ backgroundColor: sc.color }} />
                        {sc.label}
                      </span>
                    </TableCell>
                    <TableCell>
                      <span className="inline-flex items-center gap-1 rounded-full px-2 py-0.5 text-[11px] font-semibold" style={{ backgroundColor: pc.bgColor, color: pc.color }}>
                        <span className="h-1.5 w-1.5 rounded-full" style={{ backgroundColor: pc.color }} />
                        {pc.label}
                      </span>
                    </TableCell>
                    <TableCell onClick={(e) => e.stopPropagation()}>
                      <Button variant="secondary" size="sm">⋯</Button>
                    </TableCell>
                  </TableRow>
                );
              })}
            </TableBody>
          </Table>

          {/* Pagination */}
          {meta && meta.last_page > 1 && (
            <div className="flex items-center justify-between mt-4">
              <div className="text-xs text-gray-500">Menampilkan {meta.from}-{meta.to} dari {meta.total} PO</div>
              <div className="flex gap-1">
                {Array.from({ length: Math.min(meta.last_page, 5) }, (_, i) => (
                  <button
                    key={i}
                    onClick={() => navigate(`?page=${i + 1}`)}
                    className={`px-2.5 py-1.5 rounded-[10px] text-xs font-semibold ${
                      meta.current_page === i + 1
                        ? 'bg-primary text-white'
                        : 'bg-white text-gray-700 border border-gray-300 hover:bg-gray-50'
                    }`}
                  >
                    {i + 1}
                  </button>
                ))}
              </div>
            </div>
          )}
        </>
      )}
    </div>
  );
}
