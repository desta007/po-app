interface SnapCallbacks {
  onSuccess?: (result: unknown) => void;
  onPending?: (result: unknown) => void;
  onError?: (result: unknown) => void;
  onClose?: () => void;
}

interface SnapInstance {
  pay: (token: string, callbacks?: SnapCallbacks) => void;
}

const SCRIPT_ID = 'midtrans-snap';
let loaded: { key: string; production: boolean } | null = null;

/**
 * Dynamically load Midtrans Snap for a specific store's client key. The store's
 * key/environment can differ per catalog, so we reload the script if it changes.
 */
export function loadSnap(clientKey: string, isProduction: boolean): Promise<SnapInstance> {
  return new Promise((resolve, reject) => {
    const w = window as unknown as { snap?: SnapInstance };
    const src = isProduction
      ? 'https://app.midtrans.com/snap/snap.js'
      : 'https://app.sandbox.midtrans.com/snap/snap.js';

    if (w.snap && loaded && loaded.key === clientKey && loaded.production === isProduction) {
      resolve(w.snap);
      return;
    }

    document.getElementById(SCRIPT_ID)?.remove();

    const script = document.createElement('script');
    script.id = SCRIPT_ID;
    script.src = src;
    script.setAttribute('data-client-key', clientKey);
    script.onload = () => {
      const snap = (window as unknown as { snap?: SnapInstance }).snap;
      if (snap) {
        loaded = { key: clientKey, production: isProduction };
        resolve(snap);
      } else {
        reject(new Error('Midtrans Snap gagal diinisialisasi.'));
      }
    };
    script.onerror = () => reject(new Error('Gagal memuat Midtrans Snap.'));
    document.body.appendChild(script);
  });
}

export type { SnapInstance };
