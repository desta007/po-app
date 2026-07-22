// Cetak struk langsung ke printer thermal Bluetooth (ESC/POS) via Web Bluetooth.
//
// Kenapa bukan PDF: printer thermal ESC/POS tidak mengerti PDF — kalau byte PDF
// dikirim ke printer, hasilnya karakter/hex acak. Di sini struk dibangun sebagai
// perintah ESC/POS lalu dikirim langsung ke karakteristik BLE printer, sehingga
// hasilnya rapi seperti struk kasir dan tidak bergantung driver Windows.
//
// Dukungan browser: Chrome / Edge (desktop & Android) di context aman (HTTPS /
// localhost). Firefox & Safari belum mendukung Web Bluetooth.

import type { PurchaseOrder } from '@/types/purchase-order';
import type { Organization } from '@/types/auth';

export type PaperWidth = '58' | '80';

const PAPER_WIDTH_KEY = 'thermal_paper_width';

/** Jumlah kolom karakter (font A, 203 dpi): 58mm ≈ 32, 80mm ≈ 48. */
const COLUMNS: Record<PaperWidth, number> = { '58': 32, '80': 48 };

export function getPaperWidth(): PaperWidth {
  const v = localStorage.getItem(PAPER_WIDTH_KEY);
  return v === '58' || v === '80' ? v : '80';
}

export function setPaperWidth(width: PaperWidth): void {
  localStorage.setItem(PAPER_WIDTH_KEY, width);
}

// ---------------------------------------------------------------------------
// Koneksi Web Bluetooth
// ---------------------------------------------------------------------------

// Daftar service GATT yang umum dipakai printer thermal BLE murah. Dipakai untuk
// `optionalServices` agar karakteristik tulisnya bisa ditemukan setelah connect.
const KNOWN_SERVICES: (number | string)[] = [
  0xffe0, 0xff00, 0x18f0, 0xff12,
  '49535343-fe7d-4ae5-8fa9-9fafd205e455', // Microchip / banyak printer BT
  '0000ff00-0000-1000-8000-00805f9b34fb',
  '6e400001-b5a3-f393-e0a9-e50e24dcca9e', // Nordic UART
];

// Handle disimpan di level modul agar koneksi bertahan selama sesi (banyak print
// pakai satu pairing). `any` dipakai karena tipe Web Bluetooth tidak ada di
// lib.dom.d.ts standar.
let device: any = null;
let characteristic: any = null;

export function isBluetoothPrintingSupported(): boolean {
  return typeof navigator !== 'undefined' && !!(navigator as any).bluetooth;
}

// iOS memaksa semua browser (termasuk Chrome/Edge) memakai WebKit yang tidak
// mendukung Web Bluetooth — jadi arahannya berbeda dari desktop/Android.
function isIOS(): boolean {
  if (typeof navigator === 'undefined') return false;
  const ua = navigator.userAgent;
  return (
    /iPad|iPhone|iPod/.test(ua) ||
    // iPadOS 13+ menyamar sebagai Mac; deteksi lewat touch point
    (navigator.platform === 'MacIntel' && navigator.maxTouchPoints > 1)
  );
}

/** Pesan siap-tampil kenapa cetak Bluetooth tak tersedia, sesuai platform. */
export function bluetoothUnsupportedReason(): string {
  if (isIOS()) {
    return 'iPhone/iPad tidak mendukung cetak Bluetooth (semua browser iOS memakai Safari). Gunakan HP Android/laptop dengan Chrome, atau browser "Bluefy" di iOS.';
  }
  return 'Browser tidak mendukung Bluetooth. Gunakan Chrome atau Edge terbaru.';
}

export function isPrinterConnected(): boolean {
  return !!(device && device.gatt && device.gatt.connected && characteristic);
}

export function connectedPrinterName(): string | null {
  return device?.name ?? null;
}

async function findWritableCharacteristic(server: any): Promise<any> {
  const services = await server.getPrimaryServices();
  for (const service of services) {
    const chars = await service.getCharacteristics();
    for (const c of chars) {
      if (c.properties.write || c.properties.writeWithoutResponse) return c;
    }
  }
  return null;
}

/** Buka dialog pemilih perangkat & pasangkan printer baru. Butuh gesture user. */
export async function connectPrinter(): Promise<string> {
  const bt = (navigator as any).bluetooth;
  if (!bt) {
    throw new Error('Browser tidak mendukung Bluetooth. Gunakan Chrome atau Edge.');
  }
  device = await bt.requestDevice({
    acceptAllDevices: true,
    optionalServices: KNOWN_SERVICES,
  });
  device.addEventListener('gattserverdisconnected', () => {
    characteristic = null;
  });
  const server = await device.gatt.connect();
  characteristic = await findWritableCharacteristic(server);
  if (!characteristic) {
    throw new Error('Karakteristik tulis printer tidak ditemukan.');
  }
  return device.name || 'Printer';
}

/**
 * Pastikan ada printer terhubung. Kalau perangkat sudah pernah dipasangkan tapi
 * terputus, reconnect diam-diam (tanpa dialog). Kalau belum ada, buka pemilih
 * perangkat — jadi panggil ini lebih dulu di handler klik sebelum `await` lain.
 */
export async function ensurePrinterConnected(): Promise<string> {
  if (isPrinterConnected()) return device.name || 'Printer';
  if (device && device.gatt) {
    try {
      const server = await device.gatt.connect();
      characteristic = await findWritableCharacteristic(server);
      if (characteristic) return device.name || 'Printer';
    } catch {
      // perangkat lama tak terjangkau — jatuh ke pairing baru di bawah
    }
  }
  return connectPrinter();
}

const delay = (ms: number) => new Promise((r) => setTimeout(r, ms));

async function sendBytes(bytes: Uint8Array): Promise<void> {
  await ensurePrinterConnected();
  // BLE membatasi ukuran paket; potong kecil agar aman di printer murah.
  const chunkSize = 180;
  const noResponse = characteristic.properties.writeWithoutResponse;
  for (let i = 0; i < bytes.length; i += chunkSize) {
    const chunk = bytes.slice(i, i + chunkSize);
    if (noResponse) {
      await characteristic.writeValueWithoutResponse(chunk);
      await delay(20); // beri jeda agar buffer printer tidak overflow
    } else {
      await characteristic.writeValue(chunk);
    }
  }
}

// ---------------------------------------------------------------------------
// Encoder ESC/POS
// ---------------------------------------------------------------------------

// Buang karakter non-ASCII (mis. aksen, '×') agar tidak keluar simbol aneh di
// codepage default printer (CP437).
function sanitize(s: string): string {
  return (s || '')
    .normalize('NFKD')
    .replace(/[×]/g, 'x')
    .replace(/[–—]/g, '-')
    .replace(/[^\x20-\x7E\n]/g, '');
}

class EscPos {
  private bytes: number[] = [];

  raw(...b: number[]): this {
    this.bytes.push(...b);
    return this;
  }
  text(s: string): this {
    for (const ch of sanitize(s)) this.bytes.push(ch.charCodeAt(0) & 0xff);
    return this;
  }
  line(s = ''): this {
    return this.text(s).raw(0x0a);
  }
  init(): this {
    return this.raw(0x1b, 0x40);
  }
  align(n: 0 | 1 | 2): this {
    return this.raw(0x1b, 0x61, n);
  } // 0 kiri, 1 tengah, 2 kanan
  bold(on: boolean): this {
    return this.raw(0x1b, 0x45, on ? 1 : 0);
  }
  double(on: boolean): this {
    return this.raw(0x1d, 0x21, on ? 0x11 : 0x00);
  } // 2x tinggi & lebar
  feed(n = 1): this {
    return this.raw(0x1b, 0x64, n);
  }
  cut(): this {
    return this.raw(0x1d, 0x56, 0x42, 0x00);
  } // partial cut (diabaikan printer tanpa cutter)
  done(): Uint8Array {
    return new Uint8Array(this.bytes);
  }
}

// --- Helper layout teks ---

const fmt = (n: number) => Math.round(n || 0).toLocaleString('id-ID');

function fmtDate(d: string): string {
  return new Date(d).toLocaleDateString('id-ID', {
    day: 'numeric',
    month: 'short',
    year: 'numeric',
  });
}

function divider(cols: number): string {
  return '-'.repeat(cols);
}

/** Kiri & kanan dalam satu baris selebar `cols`, kanan menempel tepi. */
function twoCol(left: string, right: string, cols: number): string {
  const gap = cols - left.length - right.length;
  if (gap >= 1) return left + ' '.repeat(gap) + right;
  const maxLeft = Math.max(0, cols - right.length - 1);
  return left.slice(0, maxLeft) + ' ' + right;
}

/** Pecah teks panjang jadi beberapa baris selebar `cols`. */
function wrap(text: string, cols: number): string[] {
  const words = sanitize(text).split(/\s+/).filter(Boolean);
  const lines: string[] = [];
  let cur = '';
  for (const w of words) {
    let word = w;
    while (word.length > cols) {
      if (cur) {
        lines.push(cur);
        cur = '';
      }
      lines.push(word.slice(0, cols));
      word = word.slice(cols);
    }
    if (!cur) cur = word;
    else if ((cur + ' ' + word).length <= cols) cur += ' ' + word;
    else {
      lines.push(cur);
      cur = word;
    }
  }
  if (cur) lines.push(cur);
  return lines.length ? lines : [''];
}

/**
 * Bangun perintah ESC/POS untuk satu struk PO. `org` opsional — kalau tidak ada,
 * header nama toko & info bank dilewati.
 */
export function buildReceipt(
  po: PurchaseOrder,
  org: Organization | null | undefined,
  paperWidth: PaperWidth = getPaperWidth(),
): Uint8Array {
  const cols = COLUMNS[paperWidth];
  const e = new EscPos().init();

  // Header toko
  e.align(1);
  if (org?.name) {
    e.bold(true).double(true).line(org.name).double(false).bold(false);
  }
  if (org?.phone) e.line(org.phone);
  if (org?.address) for (const l of wrap(org.address, cols)) e.line(l);

  e.line('INVOICE').line(po.po_number);
  e.align(0).line(divider(cols));

  // Info pesanan
  const info: [string, string][] = [
    ['Tgl Order', fmtDate(po.order_date)],
    ['Tgl Kirim', fmtDate(po.delivery_date)],
    ['Kepada', po.customer?.name || '-'],
  ];
  if (po.customer?.phone) info.push(['No HP', po.customer.phone]);
  if (po.payment_method) info.push(['Bayar', po.payment_method]);
  for (const [label, value] of info) {
    const prefix = `${label}: `;
    const valLines = wrap(value, cols - prefix.length);
    e.line(prefix + valLines[0]);
    for (let i = 1; i < valLines.length; i++) e.line(' '.repeat(prefix.length) + valLines[i]);
  }
  e.line(divider(cols));

  // Item
  const items = po.items || [];
  let totalQty = 0;
  for (const item of items) {
    totalQty += item.quantity;
    for (const l of wrap(item.product_name, cols)) e.line(l);
    if (item.notes) for (const l of wrap(item.notes, cols)) e.line(l);
    const qtyPrice = `  ${fmt(item.quantity)} x ${fmt(item.unit_price)}`;
    e.line(twoCol(qtyPrice, fmt(item.subtotal), cols));
  }
  e.line(divider(cols));

  // Ringkasan
  e.line(twoCol('Total Qty', fmt(totalQty), cols));
  e.line(twoCol('Subtotal', 'Rp ' + fmt(po.subtotal), cols));
  if (po.discount > 0) e.line(twoCol('Diskon', '-' + fmt(po.discount), cols));
  if (po.tax > 0) e.line(twoCol('Pajak', fmt(po.tax), cols));
  if (po.shipping_cost > 0) e.line(twoCol('Ongkir', fmt(po.shipping_cost), cols));
  e.bold(true).line(twoCol('GRAND TOTAL', 'Rp ' + fmt(po.total), cols)).bold(false);

  if (po.paid_amount > 0 && po.paid_amount < po.total) {
    e.line(twoCol('Dibayar', 'Rp ' + fmt(po.paid_amount), cols));
    e.line(twoCol('Sisa', 'Rp ' + fmt(po.total - po.paid_amount), cols));
  }
  e.line(divider(cols));

  // Catatan
  if (po.notes) {
    e.align(1).line('Catatan:');
    for (const l of wrap(po.notes, cols)) e.line(l);
    e.align(0).line(divider(cols));
  }

  // Info bank (dari settings organisasi)
  const bank = (org?.settings?.bank_info || null) as
    | { bank_name?: string; account_number?: string; account_name?: string }
    | null;
  if (bank?.bank_name) {
    e.align(1).line('Pembayaran ke rekening:');
    e.bold(true).line(bank.bank_name).bold(false);
    e.line(`${bank.account_number || ''} a.n ${bank.account_name || ''}`.trim());
    e.align(0).line(divider(cols));
  }

  e.align(1).line('Terima kasih atas pesanan Anda.').align(0);
  e.feed(3).cut();
  return e.done();
}

/** Bangun struk lalu kirim ke printer thermal terhubung. */
export async function printReceipt(
  po: PurchaseOrder,
  org: Organization | null | undefined,
  paperWidth: PaperWidth = getPaperWidth(),
): Promise<void> {
  await sendBytes(buildReceipt(po, org, paperWidth));
}
