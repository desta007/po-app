import { useEffect, useRef, useState } from 'react';
import { useQuery } from '@tanstack/react-query';
import { waitlistApi } from '@/api/waitlist';
import { announce, isSpeechSupported } from '@/lib/speech';
import { Volume2, VolumeX } from 'lucide-react';
import type { WaitlistEntry } from '@/types/waitlist';

export default function WaitlistDisplayPage() {
  const [soundOn, setSoundOn] = useState(false);
  const announcedRef = useRef<Set<string>>(new Set());
  const primedRef = useRef(false);

  const { data } = useQuery({
    queryKey: ['waitlist-display'],
    queryFn: () => waitlistApi.display(),
    refetchInterval: 3000,
  });

  const called: WaitlistEntry[] = data?.data?.called ?? [];
  const waiting: WaitlistEntry[] = data?.data?.waiting ?? [];
  const current = called[0];

  // Auto-announce newly called guests (key = id + call_count so re-calls also speak).
  useEffect(() => {
    if (!soundOn) return;
    // Prime the announced-set on first load so we don't blast the backlog.
    if (!primedRef.current) {
      called.forEach((e) => announcedRef.current.add(`${e.id}:${e.call_count}`));
      primedRef.current = true;
      return;
    }
    for (const e of called) {
      const key = `${e.id}:${e.call_count}`;
      if (!announcedRef.current.has(key)) {
        announcedRef.current.add(key);
        announce(`Panggilan atas nama ${e.guest_name}, nomor antrian ${e.queue_number}, silakan menuju kasir.`);
      }
    }
  }, [called, soundOn]);

  function enableSound() {
    setSoundOn(true);
    primedRef.current = false; // will re-prime on next effect run
    // Unlock audio with a short greeting triggered by this user gesture.
    if (isSpeechSupported()) announce('Suara panggilan diaktifkan.', { repeat: 1 });
  }

  return (
    <div className="min-h-screen bg-gray-900 text-white flex flex-col">
      {/* Header */}
      <div className="flex items-center justify-between px-8 py-5 border-b border-white/10">
        <h1 className="text-2xl font-extrabold tracking-tight">Antrian <span className="text-amber-400">Resto</span></h1>
        {!soundOn ? (
          <button onClick={enableSound} className="flex items-center gap-2 rounded-xl bg-amber-500 hover:bg-amber-600 px-4 py-2 font-semibold transition-colors">
            <Volume2 size={18} /> Aktifkan Suara
          </button>
        ) : (
          <span className="flex items-center gap-2 text-amber-400 font-semibold"><Volume2 size={18} /> Suara Aktif</span>
        )}
        {!isSpeechSupported() && (
          <span className="flex items-center gap-2 text-red-400 text-sm"><VolumeX size={16} /> Browser tak mendukung suara</span>
        )}
      </div>

      {/* Now calling — hero */}
      <div className="flex-1 flex flex-col items-center justify-center px-6">
        {current ? (
          <div className="text-center">
            <div className="text-2xl uppercase tracking-[0.3em] text-gray-400 mb-4">Sedang Dipanggil</div>
            <div className="text-[7rem] leading-none font-black text-amber-400 mb-4">#{current.queue_number}</div>
            <div className="text-6xl font-extrabold">{current.guest_name}</div>
            <div className="text-xl text-gray-400 mt-4">Silakan menuju kasir</div>
          </div>
        ) : (
          <div className="text-center text-gray-500">
            <div className="text-4xl font-bold">Menunggu panggilan…</div>
          </div>
        )}
      </div>

      {/* Recently called + next up */}
      <div className="grid grid-cols-2 gap-px bg-white/10 border-t border-white/10">
        <div className="bg-gray-900 p-6">
          <div className="text-sm uppercase tracking-widest text-gray-500 mb-3">Baru Dipanggil</div>
          <div className="flex flex-wrap gap-3">
            {called.slice(1, 6).map((e) => (
              <div key={e.id} className="rounded-xl bg-white/5 px-4 py-2">
                <span className="text-amber-400 font-bold">#{e.queue_number}</span>{' '}
                <span className="font-semibold">{e.guest_name}</span>
              </div>
            ))}
            {called.length <= 1 && <div className="text-gray-600">—</div>}
          </div>
        </div>
        <div className="bg-gray-900 p-6">
          <div className="text-sm uppercase tracking-widest text-gray-500 mb-3">Antrian Berikutnya</div>
          <div className="flex flex-wrap gap-3">
            {waiting.slice(0, 6).map((e) => (
              <div key={e.id} className="rounded-xl bg-white/5 px-4 py-2">
                <span className="text-gray-400 font-bold">#{e.queue_number}</span>{' '}
                <span className="font-semibold">{e.guest_name}</span>
              </div>
            ))}
            {waiting.length === 0 && <div className="text-gray-600">—</div>}
          </div>
        </div>
      </div>
    </div>
  );
}
