// Halaman viewer cetak untuk iOS/Bluefy (lihat App\Http\Controllers\PrintController).
// File eksternal 'self' agar lolos CSP `script-src 'self'` (inline script diblokir).
(function () {
    var app = document.getElementById('app');
    if (!app) return;

    var RAW_URL = app.getAttribute('data-raw-url');
    var TITLE = app.getAttribute('data-title') || 'dokumen';
    var FILENAME = TITLE.replace(/[^a-z0-9\-_]+/gi, '-').toLowerCase() + '.pdf';

    var shareBtn = document.getElementById('shareBtn');
    var note = document.getElementById('note');

    // Prefetch PDF supaya tombol share bisa memanggil navigator.share SINKRON di
    // dalam gesture klik (menghindari kehilangan user activation setelah await).
    var pdfBlob = null;
    var prefetch = fetch(RAW_URL)
        .then(function (r) { return r.ok ? r.blob() : null; })
        .then(function (b) { pdfBlob = b; return b; })
        .catch(function () { return null; });

    // Deteksi dukungan berbagi file (Web Share API Level 2).
    var canShareFiles = false;
    try {
        var probe = new File([new Blob(['x'])], 'x.pdf', { type: 'application/pdf' });
        canShareFiles = !!(navigator.canShare && navigator.canShare({ files: [probe] }));
    } catch (e) {
        canShareFiles = false;
    }

    if (!canShareFiles) {
        shareBtn.style.display = 'none';
        note.style.display = 'block';
        return;
    }

    function resetBtn() {
        shareBtn.disabled = false;
        shareBtn.textContent = '🖨️ Print / Bagikan';
    }

    function doShare(blob) {
        if (!blob) {
            alert('Gagal menyiapkan PDF. Coba lagi.');
            resetBtn();
            return;
        }
        var file = new File([blob], FILENAME, { type: 'application/pdf' });
        navigator.share({ files: [file], title: FILENAME })
            .catch(function (err) {
                if (err && err.name === 'AbortError') return; // user membatalkan
                alert('Tidak bisa membuka menu bagikan: ' + (err && err.message ? err.message : err));
            })
            .finally(resetBtn);
    }

    shareBtn.addEventListener('click', function () {
        if (pdfBlob) {
            doShare(pdfBlob); // sinkron dalam gesture → activation terjaga
        } else {
            shareBtn.disabled = true;
            shareBtn.textContent = 'Menyiapkan…';
            prefetch.then(doShare);
        }
    });
})();
