// Auto-print untuk halaman dokumen cetak (lihat App\Http\Controllers\PrintController).
// File eksternal 'self' agar lolos CSP `script-src 'self'` (inline script diblokir).
// window.print() pada halaman HTML memicu dialog cetak/AirPrint di iOS/Bluefy —
// yang tidak tersedia saat WKWebView menampilkan PDF.
(function () {
    var btn = document.getElementById('__pbtn');
    if (btn) {
        btn.addEventListener('click', function () {
            window.print();
        });
    }

    // Coba cetak otomatis setelah aset (logo/gambar) selesai dimuat, dengan sedikit
    // jeda agar layout stabil. Kalau browser memblokir auto-print, tombol tetap ada.
    function autoPrint() {
        setTimeout(function () {
            try { window.print(); } catch (e) { /* diamkan; user bisa ketuk tombol */ }
        }, 500);
    }

    if (document.readyState === 'complete') {
        autoPrint();
    } else {
        window.addEventListener('load', autoPrint);
    }
})();
