import { Outlet } from 'react-router-dom';
import { Sidebar } from './sidebar';
import { Header } from './header';
import { BottomNav } from './bottom-nav';
import { PremiumUpgradeModal, WA_NUMBER, WA_MESSAGE } from '@/components/premium-upgrade-modal';
import { useState, useRef, useCallback } from 'react';

function DraggableWhatsAppButton() {
  const SIZE = 48;
  const btnRef = useRef<HTMLDivElement>(null);
  const dragRef = useRef({ dragging: false, hasMoved: false, offsetX: 0, offsetY: 0 });
  const [pos, setPos] = useState({ left: window.innerWidth - SIZE - 16, top: window.innerHeight - SIZE - 80 });

  const clamp = (left: number, top: number) => ({
    left: Math.max(8, Math.min(window.innerWidth - SIZE - 8, left)),
    top: Math.max(8, Math.min(window.innerHeight - SIZE - 8, top)),
  });

  const onPointerDown = useCallback((e: React.PointerEvent) => {
    e.preventDefault();
    const el = btnRef.current;
    if (!el) return;
    el.setPointerCapture(e.pointerId);
    const rect = el.getBoundingClientRect();
    dragRef.current = {
      dragging: true,
      hasMoved: false,
      offsetX: e.clientX - rect.left,
      offsetY: e.clientY - rect.top,
    };
  }, []);

  const onPointerMove = useCallback((e: React.PointerEvent) => {
    if (!dragRef.current.dragging) return;
    const newLeft = e.clientX - dragRef.current.offsetX;
    const newTop = e.clientY - dragRef.current.offsetY;
    const clamped = clamp(newLeft, newTop);

    if (!dragRef.current.hasMoved) {
      const dx = Math.abs(clamped.left - pos.left);
      const dy = Math.abs(clamped.top - pos.top);
      if (dx < 4 && dy < 4) return;
      dragRef.current.hasMoved = true;
    }

    setPos(clamped);
  }, [pos.left, pos.top]);

  const onPointerUp = useCallback(() => {
    const wasDrag = dragRef.current.hasMoved;
    dragRef.current.dragging = false;
    dragRef.current.hasMoved = false;

    if (!wasDrag) {
      const url = `https://wa.me/${WA_NUMBER}?text=${encodeURIComponent(WA_MESSAGE)}`;
      window.open(url, '_blank', 'noopener,noreferrer');
    }
  }, []);

  return (
    <div
      ref={btnRef}
      onPointerDown={onPointerDown}
      onPointerMove={onPointerMove}
      onPointerUp={onPointerUp}
      className="fixed z-50 flex items-center justify-center w-12 h-12 rounded-full bg-[#25D366] text-white shadow-lg shadow-green-500/30 hover:shadow-green-500/50 hover:bg-[#20bd5a] transition-colors duration-200 cursor-grab active:cursor-grabbing touch-none select-none"
      style={{ left: pos.left, top: pos.top }}
      title="Chat via WhatsApp"
      role="button"
    >
      <svg viewBox="0 0 32 32" width="26" height="26" fill="currentColor" style={{ pointerEvents: 'none' }}>
        <path d="M16.004 2.667A13.26 13.26 0 0 0 2.87 19.932L1.333 30.667l11.02-1.503A13.26 13.26 0 1 0 16.004 2.667Zm0 24.29a11.01 11.01 0 0 1-5.603-1.53l-.4-.24-4.148.566.557-4.063-.26-.413A11.03 11.03 0 1 1 16.004 26.957Zm6.044-8.26c-.332-.166-1.96-.967-2.264-1.078-.304-.111-.525-.166-.746.167-.222.332-.858 1.078-1.052 1.3-.194.221-.388.249-.72.083a9.075 9.075 0 0 1-2.672-1.648 10.017 10.017 0 0 1-1.848-2.3c-.194-.332-.02-.512.146-.677.15-.149.332-.388.498-.582.166-.194.222-.332.332-.554.111-.222.056-.416-.028-.582-.083-.167-.746-1.798-1.022-2.462-.27-.648-.543-.56-.746-.57l-.636-.012a1.22 1.22 0 0 0-.886.416 3.722 3.722 0 0 0-1.162 2.77c0 1.632 1.19 3.208 1.356 3.43.167.221 2.343 3.575 5.677 5.014.793.342 1.412.547 1.895.7.796.253 1.52.217 2.093.131.639-.095 1.96-.801 2.237-1.575.277-.774.277-1.437.194-1.575-.083-.139-.304-.222-.636-.388Z" />
      </svg>
    </div>
  );
}

export function AppShell() {
  const [sidebarOpen, setSidebarOpen] = useState(false);

  return (
    <div className="flex min-h-screen">
      {/* Desktop sidebar */}
      <Sidebar open={sidebarOpen} onClose={() => setSidebarOpen(false)} />

      {/* Main content */}
      <div className="flex-1 flex flex-col min-w-0 lg:ml-60">
        <Header onMenuClick={() => setSidebarOpen(true)} />
        <main className="flex-1 overflow-y-auto bg-gray-50 p-4 lg:px-8 lg:py-6 pb-20 lg:pb-6">
          <Outlet />
        </main>
      </div>

      {/* Mobile bottom nav */}
      <BottomNav />

      {/* Draggable WhatsApp floating button */}
      <DraggableWhatsAppButton />

      {/* Premium upgrade modal */}
      <PremiumUpgradeModal />
    </div>
  );
}
