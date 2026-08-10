import { useState, useRef, useEffect, useCallback } from 'react';
import { createPortal } from 'react-dom';

export interface SearchableOption {
  value: string;
  label: string;
}

interface SearchableSelectProps {
  options: SearchableOption[];
  value: string;
  onChange: (value: string) => void;
  placeholder?: string;
  className?: string;
  /**
   * Bila diisi, tampilkan opsi "+ Tambah '<query>'" ketika teks pencarian belum
   * cocok persis dengan opsi mana pun. Dipanggil dengan query yang sedang diketik.
   */
  onCreate?: (query: string) => void;
  createLabel?: (query: string) => string;
  /**
   * Mode async: bila diisi, pencarian dilakukan di server. Komponen tidak
   * memfilter `options` di sisi klien (parent yang menyuplai hasil), dan
   * memanggil callback ini (dengan debounce) tiap teks pencarian berubah.
   */
  onSearchChange?: (query: string) => void;
  /** Tampilkan indikator loading di dalam dropdown (untuk mode async). */
  loading?: boolean;
}

export function SearchableSelect({ options, value, onChange, placeholder = '-- Pilih --', className = '', onCreate, createLabel, onSearchChange, loading = false }: SearchableSelectProps) {
  const [open, setOpen] = useState(false);
  const [search, setSearch] = useState('');
  const buttonRef = useRef<HTMLButtonElement>(null);
  const dropdownRef = useRef<HTMLDivElement>(null);
  const inputRef = useRef<HTMLInputElement>(null);

  const async = !!onSearchChange;
  const selectedLabel = options.find(o => o.value === value)?.label || '';

  // Debounce teks pencarian ke parent saat mode async. Simpan callback di ref
  // agar perubahan identitas fungsi tidak memicu ulang efek tiap render.
  const onSearchChangeRef = useRef(onSearchChange);
  onSearchChangeRef.current = onSearchChange;
  useEffect(() => {
    if (!async) return;
    const t = setTimeout(() => onSearchChangeRef.current?.(search.trim()), 300);
    return () => clearTimeout(t);
  }, [search, async]);

  const filtered = async
    ? options
    : (search ? options.filter(o => o.label.toLowerCase().includes(search.toLowerCase())) : options);

  const trimmedQuery = search.trim();
  const hasExactMatch = options.some(o => o.label.toLowerCase() === trimmedQuery.toLowerCase());
  const showCreate = !!onCreate && trimmedQuery.length > 0 && !hasExactMatch;

  const handleCreate = () => {
    onCreate?.(trimmedQuery);
    setOpen(false);
    setSearch('');
  };

  const updatePosition = useCallback(() => {
    if (!open || !buttonRef.current || !dropdownRef.current) return;
    const rect = buttonRef.current.getBoundingClientRect();
    const dropdown = dropdownRef.current;
    const spaceBelow = window.innerHeight - rect.bottom;
    const dropdownHeight = Math.min(280, dropdown.scrollHeight);
    const showAbove = spaceBelow < dropdownHeight + 8 && rect.top > dropdownHeight;

    dropdown.style.position = 'fixed';
    dropdown.style.width = `${rect.width}px`;
    dropdown.style.left = `${rect.left}px`;
    if (showAbove) {
      dropdown.style.bottom = `${window.innerHeight - rect.top + 4}px`;
      dropdown.style.top = 'auto';
    } else {
      dropdown.style.top = `${rect.bottom + 4}px`;
      dropdown.style.bottom = 'auto';
    }
  }, [open]);

  useEffect(() => {
    if (!open) return;
    updatePosition();
    window.addEventListener('scroll', updatePosition, true);
    window.addEventListener('resize', updatePosition);
    return () => {
      window.removeEventListener('scroll', updatePosition, true);
      window.removeEventListener('resize', updatePosition);
    };
  }, [open, updatePosition]);

  useEffect(() => {
    if (!open) return;
    function handleClickOutside(e: MouseEvent) {
      const target = e.target as Node;
      if (
        buttonRef.current && !buttonRef.current.contains(target) &&
        dropdownRef.current && !dropdownRef.current.contains(target)
      ) {
        setOpen(false);
        setSearch('');
      }
    }
    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, [open]);

  useEffect(() => {
    if (open && inputRef.current) {
      inputRef.current.focus();
    }
  }, [open]);

  return (
    <div className={`relative ${className}`}>
      <button
        ref={buttonRef}
        type="button"
        className="w-full border border-gray-300 rounded-[6px] px-3 py-2.5 text-[14px] bg-white focus:outline-none focus:border-primary focus:ring-3 focus:ring-primary-50 text-left flex items-center justify-between"
        onClick={() => { setOpen(!open); setSearch(''); }}
      >
        <span className={value ? 'text-gray-900' : 'text-gray-400'}>{value ? selectedLabel : placeholder}</span>
        <svg className={`w-4 h-4 text-gray-400 transition-transform ${open ? 'rotate-180' : ''}`} fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 9l-7 7-7-7" /></svg>
      </button>

      {open && createPortal(
        <div ref={dropdownRef} className="bg-white border border-gray-200 rounded-[8px] shadow-lg max-h-[280px] flex flex-col" style={{ zIndex: 9999 }}>
          <div className="p-2 border-b border-gray-100">
            <input
              ref={inputRef}
              type="text"
              className="w-full border border-gray-200 rounded-[6px] px-3 py-2 text-[13px] focus:outline-none focus:border-primary focus:ring-2 focus:ring-primary-50"
              placeholder="Ketik untuk mencari..."
              value={search}
              onChange={(e) => setSearch(e.target.value)}
            />
          </div>
          <div className="overflow-y-auto flex-1">
            {loading && (
              <div className="px-3 py-4 text-[13px] text-gray-400 text-center">Mencari…</div>
            )}
            {!loading && filtered.length === 0 && !showCreate ? (
              <div className="px-3 py-4 text-[13px] text-gray-400 text-center">Tidak ditemukan</div>
            ) : (
              filtered.map(o => (
                <button
                  key={o.value}
                  type="button"
                  className={`w-full text-left px-3 py-2.5 text-[13px] hover:bg-primary-50 transition-colors ${o.value === value ? 'bg-primary-50 text-primary font-semibold' : 'text-gray-700'}`}
                  onClick={() => { onChange(o.value); setOpen(false); setSearch(''); }}
                >
                  {o.label}
                </button>
              ))
            )}
            {showCreate && (
              <>
                {filtered.length > 0 && (
                  <div className="px-3 pt-2 pb-1 text-[10px] font-semibold text-gray-400 uppercase tracking-wide border-t border-gray-100">Belum ada yang cocok?</div>
                )}
                <button
                  type="button"
                  className="w-full text-left px-3 py-2.5 text-[13px] text-accent font-semibold hover:bg-accent-light transition-colors flex items-center gap-1.5"
                  onClick={handleCreate}
                >
                  <span className="text-base leading-none">+</span>
                  {createLabel ? createLabel(trimmedQuery) : `Tambah "${trimmedQuery}"`}
                </button>
              </>
            )}
          </div>
        </div>,
        document.body
      )}
    </div>
  );
}
