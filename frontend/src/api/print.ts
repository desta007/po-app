import apiClient from './client';
import { isBluefyLike } from '@/lib/utils';

/**
 * Payload untuk meminta URL cetak bertanda-tangan (dipakai di iOS/Bluefy yang tak
 * bisa merender/print blob:/data: PDF). Server mengembalikan URL ke halaman HTML
 * dokumen yang bisa dicetak via window.print()/AirPrint. Lihat backend PrintController.
 */
export type PrintSignPayload =
  | { type: 'po-invoice' | 'po-corporate'; id: string }
  | { type: 'po-labels'; ids: string[]; size: string }
  | { type: 'po-address-labels'; ids: string[]; size: string }
  | { type: 'po-bulk'; ids: string[]; format: 'receipt' | 'corporate' }
  | { type: 'catalog' };

export const printApi = {
  /** Terbitkan URL https bertanda-tangan sementara untuk membuka PDF di tab iOS. */
  sign: (payload: PrintSignPayload) =>
    apiClient.post<{ url: string }>('/api/print/sign', payload).then((r) => r.data.url),
};

/**
 * Kalau browser adalah iOS WebKit (Bluefy/WebBLE) yang tak bisa merender/print
 * blob:/data: PDF, minta URL bertanda-tangan lalu arahkan tab ke halaman cetak HTML
 * (punya tombol Print → window.print()/AirPrint). Kembalikan `true` bila sudah
 * ditangani; `false` bila browser biasa dan pemanggil pakai jalur blob
 * (openBlankTab + fillPdfTab).
 */
export async function tryOpenPdfViaSignedUrl(payload: PrintSignPayload): Promise<boolean> {
  if (!isBluefyLike()) return false;
  const url = await printApi.sign(payload);
  window.location.href = url;
  return true;
}
