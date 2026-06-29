import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { purchaseOrdersApi } from '@/api/purchase-orders';
import { PageHeader } from '@/components/layout/page-header';
import { Button } from '@/components/ui/button';
import { Table, TableHeader, TableBody, TableRow, TableHead, TableCell } from '@/components/ui/table';
import { EmptyState } from '@/components/ui/empty-state';
import { Skeleton } from '@/components/ui/skeleton';
import { DropdownMenu, DropdownMenuContent, DropdownMenuItem, DropdownMenuSeparator, DropdownMenuTrigger } from '@/components/ui/dropdown-menu';
import { useNavigate, useSearchParams } from 'react-router-dom';
import { Download, Search, FileText, Eye, MessageCircle, Printer, Pencil, XCircle, Trash2, ArrowUpDown, ArrowUp, ArrowDown, ChevronLeft, ChevronRight } from 'lucide-react';
import { PO_STATUS_CONFIG, PAYMENT_STATUS_CONFIG } from '@/lib/constants';
import { formatRupiah, formatDate } from '@/lib/utils';
import { useState } from 'react';
import { toast } from 'sonner';
import type { PurchaseOrder } from '@/types/purchase-order';

export default function PurchaseOrderListPage() {
  const navigate = useNavigate();
  const [searchParams, setSearchParams] = useSearchParams();
  const [search, setSearch] = useState('');
  const [statusFilter, setStatusFilter] = useState('');
  const [paymentFilter, setPaymentFilter] = useState('');
  const [sortBy, setSortBy] = useState<string>('created_at');
  const [sortDir, setSortDir] = useState<'asc' | 'desc'>('desc');

  const page = Number(searchParams.get('page') || '1');
  const queryClient = useQueryClient();

  const { data, isLoading } = useQuery({
    queryKey: ['purchase-orders', { search, status: statusFilter, payment_status: paymentFilter, page, sort_by: sortBy, sort_dir: sortDir }],
    queryFn: () => purchaseOrdersApi.list({
      search,
      status: statusFilter as any,
      payment_status: paymentFilter as any,
      page,
      per_page: 20,
      sort_by: sortBy,
      sort_dir: sortDir,
    }),
  });

  const updateStatus = useMutation({
    mutationFn: ({ id, status, reason }: { id: string; status: string; reason?: string }) =>
      purchaseOrdersApi.updateStatus(id, status, reason),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['purchase-orders'] });
      toast.success('Status PO berhasil diperbarui.');
    },
    onError: (err: any) => toast.error(err.response?.data?.message || 'Gagal mengubah status PO.'),
  });

  const deletePo = useMutation({
    mutationFn: (id: string) => purchaseOrdersApi.delete(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['purchase-orders'] });
      toast.success('PO berhasil dihapus.');
    },
    onError: (err: any) => toast.error(err.response?.data?.message || 'Gagal menghapus PO.'),
  });

  const handlePrintImage = async (po: PurchaseOrder) => {
    try {
      const response = await purchaseOrdersApi.exportImage(po.id) as any;
      const blob = new Blob([response.data], { type: 'image/png' });
      const url = window.URL.createObjectURL(blob);
      const printWindow = window.open('', '_blank');
      if (printWindow) {
        printWindow.document.write(`
          <html><head><title>Invoice-${po.po_number}</title>
          <style>body{margin:0;display:flex;justify-content:center;}img{max-width:100%;height:auto;}</style>
          </head><body><img src="${url}" onload="window.print();" /></body></html>
        `);
        printWindow.document.close();
      }
      setTimeout(() => window.URL.revokeObjectURL(url), 30000);
    } catch (err) {
      toast.error('Gagal mencetak gambar invoice');
    }
  };

  const handlePrintCorporatePdf = async (po: PurchaseOrder) => {
    try {
      const response = await purchaseOrdersApi.exportCorporatePdf(po.id) as any;
      const blob = new Blob([response.data], { type: 'application/pdf' });
      const url = window.URL.createObjectURL(blob);
      window.open(url, '_blank');
      setTimeout(() => window.URL.revokeObjectURL(url), 1000);
    } catch (err) {
      toast.error('Gagal mencetak PDF Corporate');
    }
  };

  const handleKirimWA = (po: PurchaseOrder) => {
    if (po.customer?.phone) {
      let phone = po.customer.phone.replace(/[^0-9]/g, '');
      if (phone.startsWith('0')) phone = '62' + phone.substring(1);
      window.open(`https://wa.me/${phone}`, '_blank');
    } else {
      toast.error('Nomor HP pelanggan tidak tersedia');
    }
  };

  const goToPage = (p: number) => {
    const params = new URLSearchParams(searchParams);
    params.set('page', String(p));
    setSearchParams(params);
  };

  const toggleSort = (field: string) => {
    if (sortBy === field) {
      setSortDir(prev => prev === 'desc' ? 'asc' : 'desc');
    } else {
      setSortBy(field);
      setSortDir('desc');
    }
    // Reset to page 1 when sort changes
    goToPage(1);
  };

  const getSortIcon = (field: string) => {
    if (sortBy !== field) return <ArrowUpDown size={13} className="text-gray-400" />;
    return sortDir === 'desc'
      ? <ArrowDown size={13} className="text-primary" />
      : <ArrowUp size={13} className="text-primary" />;
  };

  const pos: PurchaseOrder[] = data?.data?.data || [];
  const meta: any = data?.data?.meta;

  // Build pagination page numbers with ellipsis
  const buildPageNumbers = () => {
    if (!meta || meta.last_page <= 1) return [];
    const pages: (number | 'ellipsis')[] = [];
    const total = meta.last_page;
    const current = meta.current_page;

    // Always show first page
    pages.push(1);

    if (current > 3) pages.push('ellipsis');

    // Pages around current
    for (let i = Math.max(2, current - 1); i <= Math.min(total - 1, current + 1); i++) {
      pages.push(i);
    }

    if (current < total - 2) pages.push('ellipsis');

    // Always show last page (if > 1)
    if (total > 1) pages.push(total);

    return pages;
  };


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
            onChange={(e) => { setSearch(e.target.value); goToPage(1); }}
          />
        </div>
        <select
          className="px-3 py-2.5 border border-gray-300 rounded-[6px] text-[14px] bg-white text-gray-900 focus:outline-none focus:border-primary"
          value={statusFilter}
          onChange={(e) => { setStatusFilter(e.target.value); goToPage(1); }}
        >
          <option value="">Status: Semua</option>
          {Object.entries(PO_STATUS_CONFIG).map(([k, v]) => (
            <option key={k} value={k}>{v.label}</option>
          ))}
        </select>
        <select
          className="px-3 py-2.5 border border-gray-300 rounded-[6px] text-[14px] bg-white text-gray-900 focus:outline-none focus:border-primary"
          value={paymentFilter}
          onChange={(e) => { setPaymentFilter(e.target.value); goToPage(1); }}
        >
          <option value="">Bayar: Semua</option>
          {Object.entries(PAYMENT_STATUS_CONFIG).map(([k, v]) => (
            <option key={k} value={k}>{v.label}</option>
          ))}
        </select>

        {/* Sort control */}
        <div className="flex items-center border border-gray-300 rounded-[6px] bg-white overflow-hidden">
          <select
            className="px-3 py-2.5 text-[14px] bg-transparent text-gray-900 focus:outline-none border-none"
            value={sortBy}
            onChange={(e) => { setSortBy(e.target.value); goToPage(1); }}
          >
            <option value="created_at">Urut: Terbaru</option>
            <option value="delivery_date">Urut: Tgl Kirim</option>
            <option value="order_date">Urut: Tgl Order</option>
          </select>
          <button
            type="button"
            className="px-2.5 py-2.5 border-l border-gray-300 hover:bg-gray-50 transition-colors flex items-center gap-1 text-[13px] font-medium text-gray-600"
            onClick={() => setSortDir(prev => prev === 'desc' ? 'asc' : 'desc')}
            title={sortDir === 'desc' ? 'Descending (terbaru/terbesar di atas)' : 'Ascending (terlama/terkecil di atas)'}
          >
            {sortDir === 'desc' ? <ArrowDown size={14} /> : <ArrowUp size={14} />}
            {sortDir === 'desc' ? 'DESC' : 'ASC'}
          </button>
        </div>
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
                <TableHead>
                  <button
                    type="button"
                    className="inline-flex items-center gap-1 hover:text-primary transition-colors"
                    onClick={() => toggleSort('order_date')}
                  >
                    Tgl Order {getSortIcon('order_date')}
                  </button>
                </TableHead>
                <TableHead>
                  <button
                    type="button"
                    className="inline-flex items-center gap-1 hover:text-primary transition-colors"
                    onClick={() => toggleSort('delivery_date')}
                  >
                    Tgl Kirim {getSortIcon('delivery_date')}
                  </button>
                </TableHead>
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
                    <TableCell>{formatDate(po.order_date)}</TableCell>
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
                      <DropdownMenu>
                        <DropdownMenuTrigger asChild>
                          <Button variant="secondary" size="sm">⋯</Button>
                        </DropdownMenuTrigger>
                        <DropdownMenuContent align="end" className="w-48">
                          <DropdownMenuItem onClick={() => navigate(`/pesanan/${po.id}`)}>
                            <Eye className="mr-2" /> Lihat Detail
                          </DropdownMenuItem>
                          <DropdownMenuItem onClick={() => handleKirimWA(po)}>
                            <MessageCircle className="mr-2" /> Kirim WA
                          </DropdownMenuItem>
                          <DropdownMenuItem onClick={() => handlePrintImage(po)}>
                            <Printer className="mr-2" /> Cetak Image (Struk)
                          </DropdownMenuItem>
                          <DropdownMenuItem onClick={() => handlePrintCorporatePdf(po)}>
                            <FileText className="mr-2" /> Invoice Corporate (A4)
                          </DropdownMenuItem>
                          <DropdownMenuItem onClick={() => navigate(`/pesanan/${po.id}/edit`)}>
                            <Pencil className="mr-2" /> Edit PO
                          </DropdownMenuItem>
                          {po.status !== 'cancelled' && (
                            <>
                              <DropdownMenuSeparator />
                              <DropdownMenuItem
                                className="text-danger focus:text-danger focus:bg-red-50"
                                onClick={() => {
                                  const r = prompt('Alasan pembatalan:');
                                  if (r !== null) updateStatus.mutate({ id: po.id, status: 'cancelled', reason: r });
                                }}
                              >
                                <XCircle className="mr-2" /> Batalkan PO
                              </DropdownMenuItem>
                            </>
                          )}
                          <DropdownMenuSeparator />
                          <DropdownMenuItem
                            className="text-danger focus:text-danger focus:bg-red-50"
                            onClick={() => {
                              if (window.confirm('Yakin ingin menghapus PO ini? Data tidak dapat dikembalikan.')) {
                                deletePo.mutate(po.id);
                              }
                            }}
                          >
                            <Trash2 className="mr-2" /> Delete PO
                          </DropdownMenuItem>
                        </DropdownMenuContent>
                      </DropdownMenu>
                    </TableCell>
                  </TableRow>
                );
              })}
            </TableBody>
          </Table>

          {/* Pagination */}
          {meta && meta.last_page > 1 && (
            <div className="flex items-center justify-between mt-4">
              <div className="text-xs text-gray-500">
                Menampilkan {meta.from}–{meta.to} dari {meta.total} PO
              </div>
              <div className="flex items-center gap-1">
                {/* Previous */}
                <button
                  onClick={() => goToPage(Math.max(1, page - 1))}
                  disabled={page <= 1}
                  className="px-2 py-1.5 rounded-[6px] text-xs font-semibold bg-white text-gray-700 border border-gray-300 hover:bg-gray-50 disabled:opacity-40 disabled:cursor-not-allowed flex items-center"
                >
                  <ChevronLeft size={14} />
                </button>

                {buildPageNumbers().map((p, idx) =>
                  p === 'ellipsis' ? (
                    <span key={`e-${idx}`} className="px-1.5 text-xs text-gray-400">…</span>
                  ) : (
                    <button
                      key={p}
                      onClick={() => goToPage(p)}
                      className={`px-2.5 py-1.5 rounded-[6px] text-xs font-semibold ${
                        meta.current_page === p
                          ? 'bg-primary text-white'
                          : 'bg-white text-gray-700 border border-gray-300 hover:bg-gray-50'
                      }`}
                    >
                      {p}
                    </button>
                  )
                )}

                {/* Next */}
                <button
                  onClick={() => goToPage(Math.min(meta.last_page, page + 1))}
                  disabled={page >= meta.last_page}
                  className="px-2 py-1.5 rounded-[6px] text-xs font-semibold bg-white text-gray-700 border border-gray-300 hover:bg-gray-50 disabled:opacity-40 disabled:cursor-not-allowed flex items-center"
                >
                  <ChevronRight size={14} />
                </button>
              </div>
            </div>
          )}
        </>
      )}
    </div>
  );
}
