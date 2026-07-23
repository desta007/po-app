import { clsx, type ClassValue } from 'clsx';
import { twMerge } from 'tailwind-merge';

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

export function formatRupiah(amount: number): string {
  return new Intl.NumberFormat('id-ID', {
    style: 'currency',
    currency: 'IDR',
    minimumFractionDigits: 0,
    maximumFractionDigits: 0,
  }).format(amount);
}

export function formatDate(date: string, format: 'short' | 'long' | 'relative' = 'short'): string {
  const d = new Date(date);
  if (format === 'long') {
    return d.toLocaleDateString('id-ID', { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' });
  }
  if (format === 'relative') {
    const now = new Date();
    const diff = now.getTime() - d.getTime();
    const minutes = Math.floor(diff / 60000);
    if (minutes < 1) return 'Baru saja';
    if (minutes < 60) return `${minutes} menit lalu`;
    const hours = Math.floor(minutes / 60);
    if (hours < 24) return `${hours} jam lalu`;
    const days = Math.floor(hours / 24);
    if (days < 7) return `${days} hari lalu`;
    return d.toLocaleDateString('id-ID', { day: 'numeric', month: 'short', year: 'numeric' });
  }
  return d.toLocaleDateString('id-ID', { day: 'numeric', month: 'short', year: 'numeric' });
}

export function formatPhoneWA(phone: string): string {
  let cleaned = phone.replace(/\D/g, '');
  if (cleaned.startsWith('0')) cleaned = '62' + cleaned.slice(1);
  return cleaned;
}

export function getInitials(name: string): string {
  return name
    .split(' ')
    .map((n) => n[0])
    .filter(Boolean)
    .slice(0, 2)
    .join('')
    .toUpperCase();
}

export function truncate(str: string, length: number): string {
  if (str.length <= length) return str;
  return str.slice(0, length) + '...';
}

const API_BASE_URL = import.meta.env.VITE_API_URL || '';

export function storageUrl(path: string | null | undefined): string {
  if (!path) return '';
  if (path.startsWith('http') || path.startsWith('blob:')) return path;
  return `${API_BASE_URL}${path}`;
}

/**
 * Buka tab kosong SEBELUM operasi async (mis. fetch PDF). Chrome/Edge memblokir
 * `window.open` yang dipanggil setelah `await` karena user gesture sudah hilang
 * (Safari lebih longgar). Panggil ini langsung di awal handler klik, lalu isi
 * hasilnya lewat `fillPdfTab`.
 */
export function openBlankTab(): Window | null {
  const win = window.open('', '_blank');
  if (win) {
    win.document.write(
      '<title>Menyiapkan...</title><p style="font-family:sans-serif;padding:24px;color:#555">Menyiapkan dokumen, mohon tunggu...</p>',
    );
  }
  return win;
}

/**
 * Arahkan tab yang sudah dibuka `openBlankTab` ke PDF hasil fetch. Kalau tab
 * ternyata diblokir/null, jatuh ke unduh file supaya user tetap dapat hasilnya.
 */
export function fillPdfTab(win: Window | null, data: BlobPart, filename: string): void {
  const blob = new Blob([data], { type: 'application/pdf' });
  const url = window.URL.createObjectURL(blob);
  if (win && !win.closed) {
    win.location.href = url;
  } else {
    const a = document.createElement('a');
    a.href = url;
    a.download = filename;
    document.body.appendChild(a);
    a.click();
    a.remove();
  }
  setTimeout(() => window.URL.revokeObjectURL(url), 60000);
}
