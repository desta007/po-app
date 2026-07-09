import { ImageResponse } from '@vercel/og';

export const config = { runtime: 'edge' };

const BRAND = '#1F4E79';
const BRAND_DARK = '#153A5C';
const API_BASE = (process.env.VITE_API_URL || process.env.API_URL || 'http://localhost:8000').replace(/\/$/, '');

interface CatalogProduct {
  name: string;
  price: number;
  image_url: string | null;
}

interface CatalogData {
  organization: { name: string; address: string | null; logo_url: string | null };
  products: CatalogProduct[];
}

/** Ubah path relatif storage menjadi URL absolut agar bisa dimuat di dalam OG image. */
function absUrl(url?: string | null): string | null {
  if (!url) return null;
  if (url.startsWith('http') || url.startsWith('data:')) return url;
  return `${API_BASE}${url.startsWith('/') ? '' : '/'}${url}`;
}

function rupiah(n: number): string {
  return 'Rp' + Math.round(n || 0).toString().replace(/\B(?=(\d{3})+(?!\d))/g, '.');
}

/** Fisher-Yates shuffle agar produk yang tampil di kartu OG berganti-ganti antar regenerasi cache. */
function shuffle<T>(arr: T[]): T[] {
  const result = arr.slice();
  for (let i = result.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [result[i], result[j]] = [result[j], result[i]];
  }
  return result;
}

function arrayBufferToBase64(buffer: ArrayBuffer): string {
  const bytes = new Uint8Array(buffer);
  let binary = '';
  const chunkSize = 0x8000;
  for (let i = 0; i < bytes.length; i += chunkSize) {
    binary += String.fromCharCode(...bytes.subarray(i, i + chunkSize));
  }
  return btoa(binary);
}

/**
 * WhatsApp/Facebook crawler punya batas waktu ketat saat mengambil og:image.
 * Render kartu ini melibatkan beberapa fetch gambar eksternal ke backend Railway,
 * jadi setiap fetch dibatasi timeout ketat dan gagal dianggap "tidak ada gambar"
 * (bukan mengulur waktu total request) agar fungsi selalu selesai cepat & terprediksi.
 */
async function fetchDataUri(url: string | null, timeoutMs: number): Promise<string | null> {
  if (!url) return null;
  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), timeoutMs);
  try {
    const res = await fetch(url, { signal: controller.signal });
    if (!res.ok) return null;
    const buf = await res.arrayBuffer();
    if (buf.byteLength > 1_500_000) return null; // hindari sumber gambar raksasa membengkakkan hasil PNG
    const contentType = res.headers.get('content-type') || 'image/jpeg';
    return `data:${contentType};base64,${arrayBufferToBase64(buf)}`;
  } catch {
    return null;
  } finally {
    clearTimeout(timer);
  }
}

async function fetchCatalog(slug: string, timeoutMs: number): Promise<CatalogData | null> {
  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), timeoutMs);
  try {
    const res = await fetch(`${API_BASE}/api/catalog/${encodeURIComponent(slug)}`, {
      headers: { Accept: 'application/json' },
      signal: controller.signal,
    });
    if (!res.ok) return null;
    return (await res.json()) as CatalogData;
  } catch {
    return null;
  } finally {
    clearTimeout(timer);
  }
}

export default async function handler(req: Request) {
  const { searchParams } = new URL(req.url);
  const slug = searchParams.get('slug') || '';
  const data = slug ? await fetchCatalog(slug, 3000) : null;

  const orgName = (data?.organization?.name || 'Katalog Online').slice(0, 42);
  const address = (data?.organization?.address || '').slice(0, 60);
  const allProducts = data?.products || [];
  const productCount = allProducts.length;
  const previewProducts = shuffle(allProducts.filter((p) => p.image_url)).slice(0, 2);
  const initial = orgName.trim().charAt(0).toUpperCase() || 'K';

  // Fetch semua gambar sekaligus (paralel) dengan timeout ketat, lalu inline sebagai data URI.
  // Ini menghindari satori melakukan fetch remote-nya sendiri yang latensinya tak terkontrol.
  const [logo, ...previewImages] = await Promise.all([
    fetchDataUri(absUrl(data?.organization?.logo_url), 1500),
    ...previewProducts.map((p) => fetchDataUri(absUrl(p.image_url), 1500)),
  ]);
  const preview = previewProducts.map((p, i) => ({ ...p, dataUri: previewImages[i] })).filter((p) => p.dataUri);

  const image = new ImageResponse(
    (
      <div
        style={{
          width: '1200px',
          height: '630px',
          display: 'flex',
          flexDirection: 'column',
          justifyContent: 'space-between',
          padding: '52px 56px',
          backgroundColor: BRAND,
          backgroundImage: `linear-gradient(135deg, ${BRAND} 0%, ${BRAND_DARK} 100%)`,
          fontFamily: 'sans-serif',
          position: 'relative',
        }}
      >
        {/* Ornamen dekoratif */}
        <div
          style={{
            position: 'absolute',
            top: '-160px',
            right: '-120px',
            width: '460px',
            height: '460px',
            borderRadius: '460px',
            background: 'rgba(255,255,255,0.06)',
            display: 'flex',
          }}
        />
        <div
          style={{
            position: 'absolute',
            bottom: '-200px',
            left: '-140px',
            width: '400px',
            height: '400px',
            borderRadius: '400px',
            background: 'rgba(255,255,255,0.05)',
            display: 'flex',
          }}
        />

        {/* Header: logo + nama toko */}
        <div style={{ display: 'flex', alignItems: 'center', gap: '26px' }}>
          <div
            style={{
              width: '112px',
              height: '112px',
              borderRadius: '28px',
              backgroundColor: '#ffffff',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              overflow: 'hidden',
              boxShadow: '0 12px 30px rgba(0,0,0,0.22)',
              flexShrink: 0,
            }}
          >
            {logo ? (
              <img
                src={logo}
                width={112}
                height={112}
                style={{ width: '112px', height: '112px', objectFit: 'contain' }}
              />
            ) : (
              <div style={{ display: 'flex', fontSize: '58px', fontWeight: 800, color: BRAND }}>{initial}</div>
            )}
          </div>
          <div style={{ display: 'flex', flexDirection: 'column', maxWidth: '900px' }}>
            <div
              style={{
                display: 'flex',
                fontSize: '20px',
                letterSpacing: '4px',
                fontWeight: 700,
                color: 'rgba(255,255,255,0.72)',
              }}
            >
              KATALOG ONLINE
            </div>
            <div style={{ display: 'flex', fontSize: '58px', fontWeight: 800, color: '#ffffff', lineHeight: 1.05 }}>
              {orgName}
            </div>
            {address ? (
              <div style={{ display: 'flex', fontSize: '22px', color: 'rgba(255,255,255,0.72)', marginTop: '6px' }}>
                {address}
              </div>
            ) : null}
          </div>
        </div>

        {/* Preview produk / tagline */}
        {preview.length > 0 ? (
          <div style={{ display: 'flex', gap: '22px', marginTop: '8px' }}>
            {preview.map((p, i) => (
              <div
                key={i}
                style={{
                  display: 'flex',
                  flexDirection: 'column',
                  width: '332px',
                  height: '258px',
                  borderRadius: '24px',
                  overflow: 'hidden',
                  position: 'relative',
                  backgroundColor: '#ffffff',
                  boxShadow: '0 16px 34px rgba(0,0,0,0.28)',
                }}
              >
                <img
                  src={p.dataUri as string}
                  width={332}
                  height={258}
                  style={{ width: '332px', height: '258px', objectFit: 'cover' }}
                />
                <div
                  style={{
                    position: 'absolute',
                    bottom: '14px',
                    left: '14px',
                    display: 'flex',
                    backgroundColor: 'rgba(21,58,92,0.92)',
                    color: '#ffffff',
                    fontSize: '22px',
                    fontWeight: 700,
                    padding: '8px 16px',
                    borderRadius: '999px',
                  }}
                >
                  {rupiah(p.price)}
                </div>
              </div>
            ))}
          </div>
        ) : (
          <div
            style={{
              display: 'flex',
              flexDirection: 'column',
              backgroundColor: 'rgba(255,255,255,0.10)',
              borderRadius: '28px',
              padding: '34px 40px',
              marginTop: '8px',
            }}
          >
            <div style={{ display: 'flex', fontSize: '40px', fontWeight: 800, color: '#ffffff' }}>
              Belanja mudah, pesan langsung 👋
            </div>
            <div style={{ display: 'flex', fontSize: '26px', color: 'rgba(255,255,255,0.82)', marginTop: '10px' }}>
              Pilih produk favoritmu dan checkout cepat lewat WhatsApp.
            </div>
          </div>
        )}

        {/* Footer: CTA + jumlah produk */}
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '16px' }}>
            <div
              style={{
                display: 'flex',
                alignItems: 'center',
                gap: '10px',
                backgroundColor: '#22C55E',
                color: '#ffffff',
                fontSize: '24px',
                fontWeight: 700,
                padding: '14px 26px',
                borderRadius: '999px',
              }}
            >
              Pesan via WhatsApp
            </div>
            {productCount > 0 ? (
              <div
                style={{
                  display: 'flex',
                  color: 'rgba(255,255,255,0.85)',
                  fontSize: '24px',
                  fontWeight: 600,
                }}
              >
                {productCount} produk siap dipesan
              </div>
            ) : null}
          </div>
          <div style={{ display: 'flex', alignItems: 'center', fontSize: '22px', color: 'rgba(255,255,255,0.6)', fontWeight: 600 }}>
            POScheduler
          </div>
        </div>
      </div>
    ),
    {
      width: 1200,
      height: 630,
    },
  );

  // Buffer penuh lalu kirim ulang dengan Content-Length eksplisit.
  // Crawler WhatsApp menolak me-render gambar yang dikirim chunked/tanpa Content-Length.
  const buffer = await image.arrayBuffer();
  return new Response(buffer, {
    headers: {
      'content-type': 'image/png',
      'content-length': String(buffer.byteLength),
      'cache-control': 'public, max-age=3600, s-maxage=3600, stale-while-revalidate=86400',
    },
  });
}
