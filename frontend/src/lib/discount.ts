import { formatRupiah } from '@/lib/utils';

export type DiscountType = 'percent' | 'nominal';

/** Field diskon yang dikirim API produk (internal & katalog publik). */
export interface DiscountedPrice {
  price: number;
  discount_type?: DiscountType | null;
  discount_value?: number;
  has_active_discount?: boolean;
  discount_amount?: number;
  final_price?: number;
}

/**
 * Harga untuk baris item PO dari produk: unit_price = harga setelah diskon,
 * original_price = harga normal (hanya jika diskon aktif). Server menurunkan
 * potongan per unit dari selisih keduanya.
 */
export function itemPricingFromProduct(p: DiscountedPrice): { unit_price: number; original_price: number | null } {
  if (p.has_active_discount && p.final_price !== undefined) {
    return { unit_price: p.final_price, original_price: p.price };
  }
  return { unit_price: p.price, original_price: null };
}

/** Harga jual efektif (setelah diskon jika aktif). */
export function effectivePrice(p: DiscountedPrice): number {
  return p.has_active_discount && p.final_price !== undefined ? p.final_price : p.price;
}

/** Label badge diskon, mis. "-20%" atau "-Rp5.000". */
export function discountBadgeLabel(p: DiscountedPrice): string | null {
  if (!p.has_active_discount) return null;
  if (p.discount_type === 'percent') return `-${Number(p.discount_value ?? 0).toLocaleString('id-ID')}%`;
  return `-${formatRupiah(p.discount_amount ?? 0)}`;
}

/**
 * Ganti snapshot produk di keranjang (localStorage) dengan data katalog terbaru,
 * karena harga/diskon bisa berubah sejak item dimasukkan. Mengembalikan array
 * yang sama bila tidak ada perubahan agar tidak memicu render ulang.
 */
export function refreshCartProducts<P extends { id: string }, T extends { product: P }>(cart: T[], fresh: P[]): T[] {
  const byId = new Map(fresh.map((p) => [p.id, p]));
  let changed = false;
  const next = cart.map((item) => {
    const p = byId.get(item.product.id);
    if (p && p !== item.product) {
      changed = true;
      return { ...item, product: p };
    }
    return item;
  });
  return changed ? next : cart;
}

/** True bila item PO tercatat dengan harga normal lebih tinggi dari harga jualnya. */
export function itemHasDiscount(item: { unit_price: number; original_price?: number | null }): item is { unit_price: number; original_price: number } {
  return item.original_price != null && Number(item.original_price) > Number(item.unit_price);
}
