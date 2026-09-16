<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">
    <title>{{ $title }} — Cetak</title>
    {{-- Inline style diizinkan CSP (style-src 'unsafe-inline'); JS harus file
         eksternal 'self' karena script-src hanya 'self' (lihat SecurityHeaders). --}}
    <style>
        :root { color-scheme: light dark; }
        * { box-sizing: border-box; }
        body {
            margin: 0;
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
            background: #f3f4f6;
            color: #111827;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 24px 16px calc(24px + env(safe-area-inset-bottom));
        }
        @media (prefers-color-scheme: dark) {
            body { background: #0b0f19; color: #e5e7eb; }
            .card { background: #111827 !important; }
            .btn-secondary { background: #1f2937 !important; color: #e5e7eb !important; border-color: #374151 !important; }
            .note { background: #422006 !important; color: #fcd34d !important; }
        }
        .card {
            width: 100%;
            max-width: 460px;
            background: #fff;
            border-radius: 16px;
            padding: 28px 22px;
            box-shadow: 0 1px 3px rgba(0,0,0,.1);
            text-align: center;
        }
        .icon { font-size: 44px; line-height: 1; margin-bottom: 10px; }
        h1 { font-size: 19px; margin: 0 0 6px; }
        p.sub { margin: 0 0 20px; font-size: 14px; line-height: 1.5; opacity: .72; }
        .btn {
            display: flex; align-items: center; justify-content: center; gap: 8px;
            width: 100%;
            padding: 15px 16px;
            border-radius: 12px;
            font-size: 16px;
            font-weight: 600;
            border: 1px solid transparent;
            cursor: pointer;
            text-decoration: none;
            margin-top: 10px;
            -webkit-tap-highlight-color: transparent;
        }
        .btn-primary { background: #2563eb; color: #fff; }
        .btn-primary:active { background: #1d4ed8; }
        .btn-primary:disabled { opacity: .6; }
        .btn-secondary { background: #f3f4f6; color: #111827; border-color: #e5e7eb; }
        .note {
            display: none;
            margin-top: 16px;
            font-size: 13px;
            line-height: 1.5;
            padding: 12px;
            border-radius: 10px;
            background: #fef3c7;
            color: #92400e;
            text-align: left;
        }
    </style>
</head>
<body>
    <div class="card" id="app" data-raw-url="{{ $rawUrl }}" data-title="{{ $title }}">
        <div class="icon">🖨️</div>
        <h1>{{ $title }} siap</h1>
        <p class="sub">Ketuk <b>Print / Bagikan</b> lalu pilih <b>Print</b> (AirPrint) atau <b>Simpan ke File</b>.</p>

        <button id="shareBtn" class="btn btn-primary">🖨️ Print / Bagikan</button>
        <a id="viewBtn" class="btn btn-secondary" href="{{ $rawUrl }}">👁️ Lihat PDF</a>

        <div id="note" class="note">
            Browser ini tidak mendukung menu bagikan. Ketuk <b>Lihat PDF</b> untuk
            melihat dokumen, lalu buka tautan yang sama di <b>Safari</b> dan gunakan
            tombol bagikan untuk mencetak.
        </div>
    </div>

    <script src="/js/print-viewer.js"></script>
</body>
</html>
