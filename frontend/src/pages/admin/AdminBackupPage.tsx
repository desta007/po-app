import { useState } from 'react';
import { Link } from 'react-router-dom';
import { toast } from 'sonner';
import { adminApi } from '@/api/admin';
import { PageHeader } from '@/components/layout/page-header';
import { Button } from '@/components/ui/button';
import { Card } from '@/components/ui/card';
import { ROUTES } from '@/lib/constants';
import { ArrowLeft, Database, Download, ShieldAlert } from 'lucide-react';

export default function AdminBackupPage() {
  const [downloading, setDownloading] = useState(false);

  const handleDownload = async () => {
    setDownloading(true);
    try {
      const response = await adminApi.downloadDatabaseBackup();
      const blob = new Blob([response.data], { type: 'application/sql' });
      const contentDisposition = response.headers['content-disposition'];
      const filenameMatch = contentDisposition?.match(/filename="?([^";\n]+)"?/);
      const fallbackName = `backup_db_${new Date().toISOString().slice(0, 10).replace(/-/g, '')}.sql`;
      const filename = filenameMatch?.[1] || fallbackName;
      const url = window.URL.createObjectURL(blob);
      const link = document.createElement('a');
      link.href = url;
      link.download = filename;
      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);
      window.URL.revokeObjectURL(url);
      toast.success('Backup database berhasil diunduh.');
    } catch {
      toast.error('Gagal membuat backup database. Coba lagi atau periksa log server.');
    } finally {
      setDownloading(false);
    }
  };

  return (
    <div>
      <div className="mb-4">
        <Link to={ROUTES.ADMIN_DASHBOARD} className="text-xs text-gray-500 hover:text-primary inline-flex items-center gap-1">
          <ArrowLeft size={12} /> Kembali ke Admin Dashboard
        </Link>
      </div>

      <PageHeader
        title="Backup Database"
        description="Unduh salinan lengkap database dalam format file .sql"
      />

      <div className="max-w-2xl space-y-4">
        <Card padding="none" className="p-5">
          <div className="flex items-start gap-4">
            <div className="p-3 rounded-[10px] bg-blue-50 shrink-0">
              <Database size={22} className="text-primary" />
            </div>
            <div className="flex-1">
              <h3 className="text-[15px] font-bold text-gray-900">Backup Manual</h3>
              <p className="text-[13px] text-gray-500 mt-1 leading-relaxed">
                Backup mencakup seluruh data platform: user, organisasi, purchase order,
                produk, customer, subscription, dan transaksi pembayaran. Proses dapat
                memakan waktu beberapa saat tergantung ukuran database.
              </p>
              <Button
                onClick={handleDownload}
                loading={downloading}
                className="mt-4"
              >
                <Download size={15} />
                {downloading ? 'Membuat backup…' : 'Download Backup (.sql)'}
              </Button>
            </div>
          </div>
        </Card>

        <Card padding="none" className="p-4 bg-amber-50 border-amber-200">
          <div className="flex items-start gap-3">
            <ShieldAlert size={18} className="text-amber-600 shrink-0 mt-0.5" />
            <p className="text-[12px] text-amber-800 leading-relaxed">
              File backup berisi data sensitif seluruh tenant. Simpan di lokasi yang aman
              dan jangan dibagikan. Untuk restore, impor file .sql ke database PostgreSQL
              menggunakan <code className="font-mono bg-amber-100 px-1 rounded">psql</code>.
            </p>
          </div>
        </Card>
      </div>
    </div>
  );
}
