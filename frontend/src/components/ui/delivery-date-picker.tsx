import { useRef } from 'react';
import { CalendarDays, CalendarPlus } from 'lucide-react';

const HARI = ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'];
const BULAN = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];

export const toLocalISO = (d: Date) =>
  `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`;

const bulanShort = (d: Date) => BULAN[d.getMonth()];
const hariShort = (d: Date) => HARI[d.getDay()];

export const formatTanggal = (iso: string) => {
  if (!iso) return '-';
  const d = new Date(iso + 'T00:00');
  return `${HARI[d.getDay()]}, ${d.getDate()} ${BULAN[d.getMonth()]} ${d.getFullYear()}`;
};

/** Tanggal order — read-only karena otomatis dari tanggal sistem. */
export function OrderDateDisplay({ value }: { value: string }) {
  return (
    <div>
      <label className="block text-xs font-semibold text-gray-700 mb-1.5">Tanggal Order</label>
      <div className="flex items-center gap-2 border border-gray-200 bg-gray-50 rounded-[6px] px-3 py-2.5 text-[14px] text-gray-700">
        <CalendarDays size={16} className="text-primary" />
        <span>{formatTanggal(value)}</span>
        <span className="ml-auto text-[11px] text-gray-400">otomatis</span>
      </div>
    </div>
  );
}

/** Pemilih tanggal kirim: kartu 7 hari ke depan + "Tanggal lain" (date picker penuh). */
export function DeliveryDatePicker({ value, onChange }: { value: string; onChange: (iso: string) => void }) {
  const inputRef = useRef<HTMLInputElement>(null);

  const today = new Date();
  today.setHours(0, 0, 0, 0);
  const todayISO = toLocalISO(today);
  const dateCards = Array.from({ length: 7 }, (_, i) => {
    const d = new Date(today);
    d.setDate(d.getDate() + i);
    return d;
  });
  const customSelected = !!value && !dateCards.some((d) => toLocalISO(d) === value);

  const openPicker = () => {
    const el = inputRef.current;
    if (!el) return;
    try {
      if (typeof el.showPicker === 'function') el.showPicker();
      else el.click();
    } catch {
      el.click();
    }
  };

  return (
    <div>
      <label className="block text-xs font-semibold text-gray-700 mb-2">Tanggal Kirim</label>
      <div className="flex gap-2 overflow-x-auto pb-2 -mx-1 px-1">
        {dateCards.map((d) => {
          const iso = toLocalISO(d);
          const selected = value === iso;
          const isToday = iso === todayISO;
          return (
            <button
              key={iso}
              type="button"
              onClick={() => onChange(iso)}
              className={`flex-shrink-0 w-[66px] rounded-[12px] border py-2.5 flex flex-col items-center gap-0.5 transition ${selected ? 'bg-primary border-primary text-white' : 'bg-white border-gray-200 text-gray-700 hover:border-primary'}`}
            >
              <span className={`text-[10px] font-bold uppercase ${selected ? 'text-white/80' : 'text-gray-400'}`}>{isToday ? 'Hari Ini' : hariShort(d)}</span>
              <span className="text-[20px] font-bold leading-none">{d.getDate()}</span>
              <span className={`text-[10px] font-semibold uppercase ${selected ? 'text-white/80' : 'text-gray-400'}`}>{bulanShort(d)}</span>
            </button>
          );
        })}
        <button
          type="button"
          onClick={openPicker}
          className={`flex-shrink-0 w-[66px] rounded-[12px] border py-2.5 flex flex-col items-center justify-center gap-1 cursor-pointer transition ${customSelected ? 'bg-primary border-primary text-white' : 'bg-white border-dashed border-gray-300 text-gray-500 hover:border-primary'}`}
        >
          {customSelected ? (
            <>
              <span className="text-[20px] font-bold leading-none">{new Date(value + 'T00:00').getDate()}</span>
              <span className="text-[10px] font-semibold uppercase text-white/80">{bulanShort(new Date(value + 'T00:00'))}</span>
            </>
          ) : (
            <>
              <CalendarPlus size={18} />
              <span className="text-[10px] font-semibold text-center leading-tight">Tanggal<br />lain</span>
            </>
          )}
        </button>
        <input
          ref={inputRef}
          type="date"
          className="sr-only"
          min={todayISO}
          value={value}
          onChange={(e) => { if (e.target.value) onChange(e.target.value); }}
        />
      </div>
      {value && <p className="text-[12px] text-gray-500 mt-1">Dikirim: <strong className="text-gray-700">{formatTanggal(value)}</strong></p>}
    </div>
  );
}
