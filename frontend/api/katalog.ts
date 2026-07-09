export const config = { runtime: 'edge' };

const API_BASE = (process.env.VITE_API_URL || process.env.API_URL || 'http://localhost:8000').replace(/\/$/, '');

function esc(s: string): string {
  return s
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;');
}

/** Ganti isi content pada <meta property="..."> jika tag tersebut ada. */
function setMetaProp(html: string, key: string, value: string): string {
  const re = new RegExp(`(<meta\\s+property="${key}"\\s+content=")[^"]*(")`, 'i');
  return re.test(html) ? html.replace(re, `$1${esc(value)}$2`) : html;
}

/** Ganti isi content pada <meta name="..."> jika tag tersebut ada. */
function setMetaName(html: string, key: string, value: string): string {
  const re = new RegExp(`(<meta\\s+name="${key}"\\s+content=")[^"]*(")`, 'i');
  return re.test(html) ? html.replace(re, `$1${esc(value)}$2`) : html;
}

interface CatalogData {
  organization: { name: string; address: string | null };
  products: unknown[];
}

/**
 * WhatsApp membuat preview link secara real-time (saat link ditempel di chat) dengan
 * jendela waktu sangat ketat — beda dari crawler Facebook yang persisten & bisa di-scrape ulang.
 * Kalau backend Railway sedang cold-start, fetch tanpa timeout bisa membuat seluruh
 * respons menggantung sampai WhatsApp menyerah dan menampilkan fallback URL polos
 * (judul & deskripsi ikut hilang, bukan cuma gambar). Maka setiap fetch dibatasi ketat.
 */
async function fetchWithTimeout(url: string, timeoutMs: number, init?: RequestInit): Promise<Response | null> {
  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), timeoutMs);
  try {
    return await fetch(url, { ...init, signal: controller.signal });
  } catch {
    return null;
  } finally {
    clearTimeout(timer);
  }
}

export default async function handler(req: Request) {
  const url = new URL(req.url);
  const origin = url.origin;
  const slug = (url.searchParams.get('slug') || '').trim();

  // Ambil shell HTML hasil build (berisi referensi asset ber-hash + script SPA).
  let html = '';
  try {
    const res = await fetchWithTimeout(`${origin}/index.html`, 2000, { headers: { 'x-og-shell': '1' } });
    html = res ? await res.text() : '';
  } catch {
    html = '';
  }

  // Kalau shell gagal diambil, arahkan browser ke SPA biasa (crawler tetap dapat default).
  if (!html) {
    return Response.redirect(`${origin}/index.html`, 302);
  }

  // Ambil data katalog untuk mengisi meta tag, dibatasi timeout ketat agar tidak menggantung.
  let orgName = 'Katalog Online';
  let description = 'Lihat katalog produk dan pesan langsung via WhatsApp.';
  try {
    const res = await fetchWithTimeout(`${API_BASE}/api/catalog/${encodeURIComponent(slug)}`, 2500, {
      headers: { Accept: 'application/json' },
    });
    if (res?.ok) {
      const data = (await res.json()) as CatalogData;
      orgName = data?.organization?.name || orgName;
      const count = Array.isArray(data?.products) ? data.products.length : 0;
      const addr = data?.organization?.address;
      description =
        `Belanja ${count > 0 ? `${count} ` : ''}produk pilihan dari ${orgName}` +
        `${addr ? ` di ${addr}` : ''}. Pesan mudah & cepat langsung via WhatsApp.`;
    }
  } catch {
    // biarkan nilai default
  }

  const title = `${orgName} — Katalog Online`;
  const pageUrl = `${origin}/katalog/${slug}`;
  const ogImage = `${origin}/api/og?slug=${encodeURIComponent(slug)}`;

  html = html.replace(/<title>[^<]*<\/title>/i, `<title>${esc(title)}</title>`);
  html = setMetaName(html, 'description', description);
  html = setMetaProp(html, 'og:type', 'website');
  html = setMetaProp(html, 'og:title', title);
  html = setMetaProp(html, 'og:description', description);
  html = setMetaProp(html, 'og:url', pageUrl);
  html = setMetaProp(html, 'og:image', ogImage);
  html = setMetaName(html, 'twitter:title', title);
  html = setMetaName(html, 'twitter:description', description);
  html = setMetaName(html, 'twitter:image', ogImage);
  html = html.replace(/(<link\s+rel="canonical"\s+href=")[^"]*(")/i, `$1${esc(pageUrl)}$2`);

  // Lengkapi dimensi gambar agar preview tampil "large" di WhatsApp/Facebook/Twitter.
  if (!/og:image:width/i.test(html)) {
    html = html.replace(
      '</head>',
      '    <meta property="og:image:width" content="1200" />\n' +
        '    <meta property="og:image:height" content="630" />\n' +
        '    <meta property="og:image:type" content="image/png" />\n  </head>',
    );
  }

  return new Response(html, {
    headers: {
      'content-type': 'text/html; charset=utf-8',
      'cache-control': 'public, max-age=0, s-maxage=600, stale-while-revalidate=3600',
    },
  });
}
