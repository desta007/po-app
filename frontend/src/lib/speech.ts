// Web Speech API helper untuk memanggil antrian lewat speaker.
// Jalan di browser (device host/kasir atau layar TV), tidak butuh backend.

let cachedVoices: SpeechSynthesisVoice[] = [];

function loadVoices() {
  if (typeof window === 'undefined' || !('speechSynthesis' in window)) return;
  cachedVoices = window.speechSynthesis.getVoices();
}

if (typeof window !== 'undefined' && 'speechSynthesis' in window) {
  loadVoices();
  window.speechSynthesis.onvoiceschanged = loadVoices;
}

export function isSpeechSupported(): boolean {
  return typeof window !== 'undefined' && 'speechSynthesis' in window;
}

interface AnnounceOptions {
  lang?: string;
  rate?: number;
  repeat?: number;
}

/**
 * Ucapkan teks lewat speaker. Mengembalikan false jika browser tak mendukung.
 * Harus dipicu oleh interaksi user (klik) agar tidak diblokir autoplay policy.
 */
export function announce(text: string, opts: AnnounceOptions = {}): boolean {
  if (!isSpeechSupported()) return false;

  const { lang = 'id-ID', rate = 0.95, repeat = 2 } = opts;

  // Batalkan antrian ucapan sebelumnya agar tidak menumpuk.
  window.speechSynthesis.cancel();

  if (cachedVoices.length === 0) loadVoices();
  const voice = cachedVoices.find((v) => v.lang?.toLowerCase().startsWith('id'));

  for (let i = 0; i < Math.max(1, repeat); i++) {
    const utter = new SpeechSynthesisUtterance(text);
    utter.lang = lang;
    utter.rate = rate;
    if (voice) utter.voice = voice;
    window.speechSynthesis.speak(utter);
  }

  return true;
}
